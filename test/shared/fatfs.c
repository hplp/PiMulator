
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#include "xil_printf.h"
#include "ff.h"

#define MAX_FD 2

static int mounted;
static FATFS ffsvol;
static FIL fds[MAX_FD];

/*
  Mapping: see list and descriptions at bottom of file
  O_RDONLY -> FA_READ
  O_WRONLY -> FA_WRITE
  O_RDWR -> (FA_READ | FA_WRITE)
  default -> FA_OPEN_EXISTING
  O_CREAT and O_EXCL -> FA_CREATE_NEW (create new)
  O_TRUNC (need not create) -> call f_truncate (FA_CREATE_ALWAYS will create and truncate)
  O_CREAT -> FA_OPEN_ALWAYS (create)
  O_APPEND (need not create) -> call f_lseek (FA_OPEN_APPEND will create and append)
*/

static BYTE map_access(int flags)
{
	BYTE access = 0;

	if (flags & O_RDWR) access = FA_READ | FA_WRITE;
	else if (flags & O_WRONLY) access = FA_WRITE;
	else access = FA_READ;
	if (flags & O_CREAT && flags & O_EXCL) access |= FA_CREATE_NEW;
	else if (flags & O_CREAT) access |= FA_OPEN_ALWAYS;
	return access;
}

/*
  Mapping: see list and descriptions at bottom of file
*/

static int map_error(FRESULT fr)
{
	switch (fr) {
	case FR_DISK_ERR:        return EIO;    /* I/O error */
	case FR_INT_ERR:         return EFAULT; /* Bad address */
	case FR_NOT_READY:       return EBUSY;  /* Device or resource busy */
	case FR_NO_FILE:         return ENOENT; /* No such file or directory */
	case FR_NO_PATH:         return ENOENT; /* No such file or directory */
	case FR_INVALID_NAME:    return EINVAL; /* Invalid argument */
	case FR_DENIED:          return EACCES; /* Permission denied */
	case FR_EXIST:           return EEXIST; /* File exists */
	case FR_INVALID_OBJECT:  return EBADF;  /* Bad file number */
	case FR_WRITE_PROTECTED: return EROFS;  /* Read-only file system */
	case FR_INVALID_DRIVE:   return ENODEV; /* No such device */
	case FR_NOT_ENABLED:     return ENOMEM; /* Not enough space */
	case FR_NO_FILESYSTEM:   return ENXIO;  /* No such device or address */
	case FR_MKFS_ABORTED:    return ECANCELED; /* Operation canceled */
	case FR_TIMEOUT:         return EBUSY;  /* Device or resource busy */
	case FR_LOCKED:          return EBUSY;  /* Device or resource busy */
	case FR_NOT_ENOUGH_CORE: return ENOMEM; /* Not enough space */
	case FR_TOO_MANY_OPEN_FILES: return ENFILE; /* Too many open files in system */
	case FR_INVALID_PARAMETER:   return EINVAL; /* Invalid argument */
	default: return 0;
	}
}

/* * * * * * * * * * - * * * * * * * * * */

/* TODO: validate arguments: return EBADF or EINVAL if not */

int _isatty(int fd)
{
	// xil_printf("[_isatty:%d]", fd);
	if (fd < 3) return(1);
	// errno = EINVAL; /* Invalid argument */
	errno = ENOTTY; /* Not a character device */
	return(0);
}

int _fcntl(int fd, int cmd, long arg)
{
	// xil_printf("[_fcntl:%d:%d:%ld]", fd, cmd, arg);
	return(0);
}

int _fstat(int fd, struct stat *buf)
{
	// xil_printf("[_fstat:%d:%p]", fd, buf);
	buf->st_mode = (fd < 3) ? S_IFCHR : S_IFREG;
	return(0);
}

int _open(const char *pathname, int flags, mode_t mode)
{
	int i;
	FRESULT fr; /* FAT FS result */

	// xil_printf("[_open:%s:%x:%x]", pathname, flags, mode);
	if (!mounted) {
		fr = f_mount(&ffsvol, (TCHAR*)"0:/", 0);
		if (fr != FR_OK) {
			xil_printf("fr:%d = f_mount(fs, drive, 0)\r\n", fr);
			errno = ENXIO; /* No such device or address */
			return(-1);
		}
		mounted = 1;
	}
	for (i = 0; i < MAX_FD; i++) {
		if (fds[i].fs == NULL) {
			BYTE access = map_access(flags);
			fr = f_open(&fds[i], pathname, access);
			if (fr != FR_OK) {
				xil_printf("fr:%d = f_open(fd:%d, fn:%s, mode:%x)\r\n", fr, i+3, pathname, mode);
				errno = map_error(fr);
				return(-1);
			}
			if (flags & O_CREAT) {
				BYTE attrib = (flags & S_IWUSR) ? 0x00U : AM_RDO;
				fr = f_chmod(pathname, attrib, AM_RDO);
				if (fr != FR_OK) {
					xil_printf("fr:%d = f_chmod(fn:%s, attrib:%x)\r\n", fr, pathname, attrib);
					errno = map_error(fr);
					return(-1);
				}
			}
			if (flags & O_TRUNC) {
				fr = f_truncate(&fds[i]);
				if (fr != FR_OK) {
					xil_printf("fr:%d = f_truncate(fd:%d)\r\n", fr, i+3);
					errno = map_error(fr);
					return(-1);
				}
			}
			if (flags & O_APPEND) {
				fr = f_lseek(&fds[i], file_size(&fds[i]));
				if (fr != FR_OK) {
					xil_printf("fr:%d = f_lseek(fd:%d, off:%d)\r\n", fr, i+3, file_size(&fds[i]));
					errno = map_error(fr);
					return(-1);
				}
			}
			return(i+3);
		}
	}
	errno = ENFILE; /* Too many open files in system */
	return(-1);
}

off_t _lseek(int fd, off_t offset, int whence)
{
	// xil_printf("[_lseek:%d:%ld:%d]", fd, offset, whence);
	if (fd < 3) {
		errno = ESPIPE; /* Illegal seek */
		return(-1);
	} else if (fd-3 < MAX_FD) {
		FIL *fp = &fds[fd-3];
		DWORD absoff;
		FRESULT fr; /* FAT FS result */
		switch (whence) {
		case SEEK_SET: absoff = offset; break;
		case SEEK_CUR: absoff = f_tell(fp) + offset; break;
		case SEEK_END: absoff = file_size(fp) + offset; break;
		default: errno = EINVAL; return(-1); /* Invalid argument */
		}
		fr = f_lseek(fp, absoff); 
		if (fr != FR_OK) {
			xil_printf("fr:%d = f_lseek(fd:%d, off:%d)\r\n", fr, fd, absoff);
			errno = map_error(fr);
			return(-1);
		}
		return(absoff);
	}
	errno = EMFILE; /* File descriptor value too large */
	return(-1);
}

ssize_t _read(int fd, void *buf, size_t count)
{
	// xil_printf("[_read:%d:%p:%d]", fd, buf, count);
	if (buf == NULL) {
		errno = EINVAL; /* Invalid argument */
		return(-1);
	}
	if (fd < 3) {
		size_t i;
		char *ptr = buf;
		if (fd != STDIN_FILENO) {
			errno = EINVAL; /* Invalid argument */
			return(-1);
		}
		for (i = 0; i < count; i++) {
			ptr[i] = inbyte();
			if ((ptr[i] == '\n') || (ptr[i] == '\r')) {i++; break;}
		}
		return(i);
	} else if (fd-3 < MAX_FD) {
		FIL *fp = &fds[fd-3];
		UINT br; /* bytes read */
		FRESULT fr; /* FAT FS result */
		fr = f_read(fp, buf, count, &br);
		if (fr != FR_OK) {
			xil_printf("fr:%d = f_read(fd:%d, cnt:%u, br:%u)\r\n", fr, fd, count, br);
			errno = map_error(fr);
			return(-1);
		}
		return(br);
	}
	errno = EMFILE; /* File descriptor value too large */
	return(-1);
}

ssize_t _write(int fd, const void *buf, size_t count)
{
	// xil_printf("[_write:%d:%p:%d]", fd, buf, count);
	if (buf == NULL) {
		errno = EINVAL; /* Invalid argument */
		return(-1);
	}
	if (fd < 3) {
		size_t i;
		const char *ptr = buf;
		if (fd == STDIN_FILENO) {
			errno = EINVAL; /* Invalid argument */
			return(-1);
		}
		for (i = 0; i < count; i++) {
			if (ptr[i] == '\n') outbyte('\r');
			outbyte(ptr[i]);
		}
		return(count);
	} else if (fd-3 < MAX_FD) {
		FIL *fp = &fds[fd-3];
		UINT bw; /* bytes written */
		FRESULT fr; /* FAT FS result */
		fr = f_write(fp, buf, count, &bw);
		if (fr != FR_OK) {
			xil_printf("fr:%d = f_write(fd:%d, cnt:%u, bw:%u)\r\n", fr, fd, count, bw);
			errno = map_error(fr);
			return(-1);
		}
		return(bw);
	}
	errno = EMFILE; /* File descriptor value too large */
	return(-1);
}

int _close(int fd)
{
	// xil_printf("[_close:%d]", fd);
	if (fd < 3) {
		return(0);
	} else if (fd-3 < MAX_FD) {
		FIL *fp = &fds[fd-3];
		FRESULT fr; /* FAT FS result */
		fr = f_close(fp);
		if (fr != FR_OK) {
			xil_printf("fr:%d = f_close(fd:%d)\r\n", fr, fd);
			errno = map_error(fr);
			return(-1);
		}
		return(0);
	}
	errno = EMFILE; /* File descriptor value too large */
	return(-1);
}

int _unlink(const char *pathname)
{
	FRESULT fr; /* FAT FS result */

	// xil_printf("[_unlink:%s]", pathname);
	fr = f_unlink(pathname);
	if (fr != FR_OK) {
		xil_printf("fr:%d = f_unlink(fn:%s)\r\n", fr, pathname);
		errno = map_error(fr);
		return(-1);
	}
	return(0);
}

/* * * * * * * * * * - * * * * * * * * * */

int isatty(int fd)
{
	return _isatty(fd);
}

int fcntl(int fd, int cmd, ... /* arg */ )
{
	return _fcntl(fd, cmd, 0L);
}

int fstat(int fd, struct stat *buf)
{
	return _fstat(fd, buf);
}

int open(const char *pathname, int flags, ... /* mode */)
{
	int res;
	mode_t mode;
	va_list ap;

	va_start(ap, flags);
	mode = va_arg(ap, mode_t);
	res = _open(pathname, flags, mode);
	va_end(ap);
	return res;
}

off_t lseek(int fd, off_t offset, int whence)
{
	return _lseek(fd, offset, whence);
}

_READ_WRITE_RETURN_TYPE read(int fd, void *buf, size_t count)
{
	return _read(fd, buf, count);
}

_READ_WRITE_RETURN_TYPE write(int fd, const void *buf, size_t count)
{
	return _write(fd, buf, count);
}

int close(int fd)
{
	return _close(fd);
}

int unlink(const char *pathname)
{
	return _unlink(pathname);
}

/*
  FatFs Access: see ff.h & http://elm-chan.org/fsw/ff/en/open.html

  FA_READ          0x01U Read access.
  FA_WRITE         0x02U Write access. Combine with FA_READ for read-write access.

  FA_OPEN_EXISTING 0x00U Open the file. Fail if file does not exist. (Default)
  FA_CREATE_NEW    0x04U Create new file. Fail with FR_EXIST if it does not exist.
  FA_CREATE_ALWAYS 0x08U Create a file. If file exists, truncate and overwrite.
  FA_OPEN_ALWAYS   0x10U Open the file or create a new file.
  FA_OPEN_APPEND   none

  FA__WRITTEN      0x20U
  FA__DIRTY        0x40U
*/
/*
  Flags for open(): see fcntl.h & http://man7.org/linux/man-pages/man2/open.2.html

  Access:
  O_ACCMODE   (O_RDONLY|O_WRONLY|O_RDWR)
  O_RDONLY    0
  O_WRONLY    1
  O_RDWR      2

  Creation:
  O_NOINHERIT Windows/Cygwin
  O_CLOEXEC   Linux equivalent to O_NOINHERIT
  O_CREAT
  O_DIRECTORY
  O_EXCL
  O_NOCTTY
  O_NOFOLLOW
  O_TMPFILE
  O_TRUNC

  Status:
  O_APPEND
  O_ASYNC
  O_DIRECT
  O_DSYNC
  O_LARGEFILE
  O_NOATIME
  O_NONBLOCK or O_NDELAY
  O_PATH
  O_SYNC
  O_BINARY    Windows/Cygwin
  O_TEXT      Windows/Cygwin
*/

/*
  FatFs attribute bits: see ff.h & http://elm-chan.org/fsw/ff/en/open.html

  AM_RDO  0x01U Read only
  AM_HID  0x02U Hidden
  AM_SYS  0x04U System
  AM_VOL  0x08U Volume label
  AM_LFN  0x0FU LFN entry
  AM_DIR  0x10U Directory
  AM_ARC  0x20U Archive
  AM_MASK 0x3FU Mask of defined bits
*/
/*
  File mode bits: see sys/stat.h

  S_IRWXU (S_IRUSR | S_IWUSR | S_IXUSR)
  S_IRUSR 0000400 read permission, owner
  S_IWUSR 0000200 write permission, owner
  S_IXUSR 0000100 execute/search permission, owner
  S_IRWXG (S_IRGRP | S_IWGRP | S_IXGRP)
  S_IRGRP 0000040 read permission, group
  S_IWGRP 0000020 write permission, grougroup
  S_IXGRP 0000010 execute/search permission, group
  S_IRWXO (S_IROTH | S_IWOTH | S_IXOTH)
  S_IROTH 0000004 read permission, other
  S_IWOTH 0000002 write permission, other
  S_IXOTH 0000001 execute/search permission, other
  
  Linux:
  S_ISUID 0004000 set user id on execution
  S_ISGID 0002000 set group id on execution
  S_ISVTX 0001000 save swapped text even after use

*/

/*
  FatFs Response: see ff.h & http://elm-chan.org/fsw/ff/en/open.html

  FR_OK = 0U              (0) Succeeded
  FR_DISK_ERR             (1) A hard error occurred in the low level disk I/O layer
  FR_INT_ERR              (2) Assertion failed
  FR_NOT_READY            (3) The physical drive cannot work
  FR_NO_FILE              (4) Could not find the file
  FR_NO_PATH              (5) Could not find the path
  FR_INVALID_NAME         (6) The path name format is invalid
  FR_DENIED               (7) Access denied due to prohibited access or directory full
  FR_EXIST                (8) Access denied due to prohibited access
  FR_INVALID_OBJECT       (9) The file/directory object is invalid
  FR_WRITE_PROTECTED     (10) The physical drive is write protected
  FR_INVALID_DRIVE       (11) The logical drive number is invalid
  FR_NOT_ENABLED         (12) The volume has no work area
  FR_NO_FILESYSTEM       (13) There is no valid FAT volume
  FR_MKFS_ABORTED        (14) The f_mkfs() aborted due to any parameter error
  FR_TIMEOUT             (15) Could not get a grant to access the volume within defined period
  FR_LOCKED              (16) The operation is rejected according to the file sharing policy
  FR_NOT_ENOUGH_CORE     (17) LFN working buffer could not be allocated
  FR_TOO_MANY_OPEN_FILES (18) Number of open files > _FS_SHARE
  FR_INVALID_PARAMETER   (19) Given parameter is invalid
*/
/*
  Errors: see errno.h

  EPERM 1         Not owner
  ENOENT 2        No such file or directory
  ESRCH 3         No such process
  EINTR 4         Interrupted system call
  EIO 5           I/O error
  ENXIO 6         No such device or address
  E2BIG 7         Arg list too long
  ENOEXEC 8       Exec format error
  EBADF 9         Bad file number
  ECHILD 10       No children
  EAGAIN 11       No more processes
  ENOMEM 12       Not enough space
  EACCES 13       Permission denied
  EFAULT 14       Bad address
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ENOTBLK 15      Block device required
#endif
  EBUSY 16        Device or resource busy
  EEXIST 17       File exists
  EXDEV 18        Cross-device link
  ENODEV 19       No such device
  ENOTDIR 20      Not a directory
  EISDIR 21       Is a directory
  EINVAL 22       Invalid argument
  ENFILE 23       Too many open files in system
  EMFILE 24       File descriptor value too large
  ENOTTY 25       Not a character device
  ETXTBSY 26      Text file busy
  EFBIG 27        File too large
  ENOSPC 28       No space left on device
  ESPIPE 29       Illegal seek
  EROFS 30        Read-only file system
  EMLINK 31       Too many links
  EPIPE 32        Broken pipe
  EDOM 33         Mathematics argument out of domain of function
  ERANGE 34       Result too large
  ENOMSG 35       No message of desired type
  EIDRM 36        Identifier removed
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ECHRNG 37       Channel number out of range
  EL2NSYNC 38     Level 2 not synchronized
  EL3HLT 39       Level 3 halted
  EL3RST 40       Level 3 reset
  ELNRNG 41       Link number out of range
  EUNATCH 42      Protocol driver not attached
  ENOCSI 43       No CSI structure available
  EL2HLT 44       Level 2 halted
#endif
  EDEADLK 45      Deadlock
  ENOLCK 46       No lock
#ifdef __LINUX_ERRNO_EXTENSIONS__
  EBADE 50        Invalid exchange
  EBADR 51        Invalid request descriptor
  EXFULL 52       Exchange full
  ENOANO 53       No anode
  EBADRQC 54      Invalid request code
  EBADSLT 55      Invalid slot
  EDEADLOCK 56    File locking deadlock error
  EBFONT 57       Bad font file fmt
#endif
  ENOSTR 60       Not a stream
  ENODATA 61      No data (for no delay io)
  ETIME 62        Stream ioctl timeout
  ENOSR 63        No stream resources
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ENONET 64       Machine is not on the network
  ENOPKG 65       Package not installed
  EREMOTE 66      The object is remote
#endif
  ENOLINK 67      Virtual circuit is gone
#ifdef __LINUX_ERRNO_EXTENSIONS__
  EADV 68         Advertise error
  ESRMNT 69       Srmount error
  ECOMM 70        Communication error on send
#endif
  EPROTO 71       Protocol error
  EMULTIHOP 74    Multihop attempted
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ELBIN 75        Inode is remote (not really error)
  EDOTDOT 76      Cross mount point (not really error)
#endif
  EBADMSG 77      Bad message
  EFTYPE 79       Inappropriate file type or format
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ENOTUNIQ 80     Given log. name not unique
  EBADFD 81       f.d. invalid for this operation
  EREMCHG 82      Remote address changed
  ELIBACC 83      Can't access a needed shared lib
  ELIBBAD 84      Accessing a corrupted shared lib
  ELIBSCN 85      .lib section in a.out corrupted
  ELIBMAX 86      Attempting to link in too many libs
  ELIBEXEC 87     Attempting to exec a shared library
#endif
  ENOSYS 88       Function not implemented
#ifdef __CYGWIN__
  ENMFILE 89      No more files
#endif
  ENOTEMPTY 90    Directory not empty
  ENAMETOOLONG 91 File or path name too long
  ELOOP 92        Too many symbolic links
  EOPNOTSUPP 95   Operation not supported on socket
  EPFNOSUPPORT 96 Protocol family not supported
  ECONNRESET 104  Connection reset by peer
  ENOBUFS 105     No buffer space available
  EAFNOSUPPORT 106 Address family not supported by protocol family
  EPROTOTYPE 107  Protocol wrong type for socket
  ENOTSOCK 108    Socket operation on non-socket
  ENOPROTOOPT 109 Protocol not available
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ESHUTDOWN 110   Can't send after socket shutdown
#endif
  ECONNREFUSED 111        Connection refused
  EADDRINUSE 112          Address already in use
  ECONNABORTED 113        Software caused connection abort
  ENETUNREACH 114         Network is unreachable
  ENETDOWN 115            Network interface is not configured
  ETIMEDOUT 116           Connection timed out
  EHOSTDOWN 117           Host is down
  EHOSTUNREACH 118        Host is unreachable
  EINPROGRESS 119         Connection already in progress
  EALREADY 120            Socket already connected
  EDESTADDRREQ 121        Destination address required
  EMSGSIZE 122            Message too long
  EPROTONOSUPPORT 123     Unknown protocol
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ESOCKTNOSUPPORT 124     Socket type not supported
#endif
  EADDRNOTAVAIL 125       Address not available
  ENETRESET 126           Connection aborted by network
  EISCONN 127             Socket is already connected
  ENOTCONN 128            Socket is not connected
  ETOOMANYREFS 129
#ifdef __LINUX_ERRNO_EXTENSIONS__
  EPROCLIM 130
  EUSERS 131
#endif
  EDQUOT 132
  ESTALE 133
  ENOTSUP 134             Not supported
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ENOMEDIUM 135           No medium (in tape drive)
#endif
#ifdef __CYGWIN__
  ENOSHARE 136            No such host or network path
  ECASECLASH 137          Filename exists with different case
#endif
  EILSEQ 138              Illegal byte sequence
  EOVERFLOW 139           Value too large for defined data type
  ECANCELED 140           Operation canceled
  ENOTRECOVERABLE 141     State not recoverable
  EOWNERDEAD 142          Previous owner died
#ifdef __LINUX_ERRNO_EXTENSIONS__
  ESTRPIPE 143            Streams pipe error
#endif
  EWOULDBLOCK EAGAIN      Operation would block
  __ELASTERROR 2000       Users can add values starting here
*/
