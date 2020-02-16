/**
 * Buildroot wrapper for toolchains. This simply executes the real toolchain
 * with a number of arguments (sysroot/arch/..) hardcoded, to ensure the
 * toolchain uses the correct configuration.
 * The hardcoded path arguments are defined relative to the actual location
 * of the binary.
 *
 * (C) 2011 Peter Korsgaard <jacmet@sunsite.dk>
 * (C) 2011 Daniel Nyström <daniel.nystrom@timeterminal.se>
 * (C) 2012 Arnout Vandecappelle (Essensium/Mind) <arnout@mind.be>
 * (C) 2013 Spenser Gilliland <spenser@gillilanding.com>
 *
 * This file is licensed under the terms of the GNU General Public License
 * version 2.  This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>

#ifdef BR_CCACHE
static char ccache_path[PATH_MAX];
#endif
static char path[PATH_MAX];
static char sysroot[PATH_MAX];

/**
 * GCC errors out with certain combinations of arguments (examples are
 * -mfloat-abi={hard|soft} and -m{little|big}-endian), so we have to ensure
 * that we only pass the predefined one to the real compiler if the inverse
 * option isn't in the argument list.
 * This specifies the worst case number of extra arguments we might pass
 * Currently, we have:
 * 	-mfloat-abi=
 * 	-march=
 * 	-mcpu=
 */
#define EXCLUSIVE_ARGS	3

static char *predef_args[] = {
#ifdef BR_CCACHE
	ccache_path,
#endif
	path,
	"--sysroot", sysroot,
#ifdef BR_ABI
	"-mabi=" BR_ABI,
#endif
#ifdef BR_FPU
	"-mfpu=" BR_FPU,
#endif
#ifdef BR_SOFTFLOAT
	"-msoft-float",
#endif /* BR_SOFTFLOAT */
#ifdef BR_MODE
	"-m" BR_MODE,
#endif
#ifdef BR_64
	"-m64",
#endif
#ifdef BR_OMIT_LOCK_PREFIX
	"-Wa,-momit-lock-prefix=yes",
#endif
#ifdef BR_BINFMT_FLAT
	"-Wl,-elf2flt",
#endif
#ifdef BR_MIPS_TARGET_LITTLE_ENDIAN
	"-EL",
#endif
#if defined(BR_MIPS_TARGET_BIG_ENDIAN) || defined(BR_ARC_TARGET_BIG_ENDIAN)
	"-EB",
#endif
#ifdef BR_ADDITIONAL_CFLAGS
	BR_ADDITIONAL_CFLAGS
#endif
};

static void check_unsafe_path(const char *path, int paranoid)
{
	char **c;
	static char *unsafe_paths[] = {
		"/lib", "/usr/include", "/usr/lib", "/usr/local/include", "/usr/local/lib", NULL,
	};

	for (c = unsafe_paths; *c != NULL; c++) {
		if (!strncmp(path, *c, strlen(*c))) {
			fprintf(stderr, "%s: %s: unsafe header/library path used in cross-compilation: '%s'\n",
				program_invocation_short_name,
				paranoid ? "ERROR" : "WARNING", path);
			if (paranoid)
				exit(1);
			continue;
		}
	}
}

int main(int argc, char **argv)
{
	char **args, **cur, **exec_args;
	char *relbasedir, *absbasedir;
	char *progpath = argv[0];
	char *basename;
	char *env_debug;
	char *paranoid_wrapper;
	int paranoid;
	int ret, i, count = 0, debug;

	/* Calculate the relative paths */
	basename = strrchr(progpath, '/');
	if (basename) {
		*basename = '\0';
		basename++;
		relbasedir = malloc(strlen(progpath) + 7);
		if (relbasedir == NULL) {
			perror(__FILE__ ": malloc");
			return 2;
		}
		sprintf(relbasedir, "%s/../..", argv[0]);
		absbasedir = realpath(relbasedir, NULL);
	} else {
		basename = progpath;
		absbasedir = malloc(PATH_MAX + 1);
		ret = readlink("/proc/self/exe", absbasedir, PATH_MAX);
		if (ret < 0) {
			perror(__FILE__ ": readlink");
			return 2;
		}
		absbasedir[ret] = '\0';
		for (i = ret; i > 0; i--) {
			if (absbasedir[i] == '/') {
				absbasedir[i] = '\0';
				if (++count == 3)
					break;
			}
		}
	}
	if (absbasedir == NULL) {
		perror(__FILE__ ": realpath");
		return 2;
	}

	/* Fill in the relative paths */
#ifdef BR_CROSS_PATH_REL
	ret = snprintf(path, sizeof(path), "%s/" BR_CROSS_PATH_REL "/%s" BR_CROSS_PATH_SUFFIX, absbasedir, basename);
#elif defined(BR_CROSS_PATH_ABS)
	ret = snprintf(path, sizeof(path), BR_CROSS_PATH_ABS "/%s" BR_CROSS_PATH_SUFFIX, basename);
#else
	ret = snprintf(path, sizeof(path), "%s/usr/bin/%s" BR_CROSS_PATH_SUFFIX, absbasedir, basename);
#endif
	if (ret >= sizeof(path)) {
		perror(__FILE__ ": overflow");
		return 3;
	}
#ifdef BR_CCACHE
	ret = snprintf(ccache_path, sizeof(ccache_path), "%s/usr/bin/ccache", absbasedir);
	if (ret >= sizeof(ccache_path)) {
		perror(__FILE__ ": overflow");
		return 3;
	}
#endif
	ret = snprintf(sysroot, sizeof(sysroot), "%s/" BR_SYSROOT, absbasedir);
	if (ret >= sizeof(sysroot)) {
		perror(__FILE__ ": overflow");
		return 3;
	}

	cur = args = malloc(sizeof(predef_args) +
			    (sizeof(char *) * (argc + EXCLUSIVE_ARGS)));
	if (args == NULL) {
		perror(__FILE__ ": malloc");
		return 2;
	}

	/* start with predefined args */
	memcpy(cur, predef_args, sizeof(predef_args));
	cur += sizeof(predef_args) / sizeof(predef_args[0]);

#ifdef BR_FLOAT_ABI
	/* add float abi if not overridden in args */
	for (i = 1; i < argc; i++) {
		if (!strncmp(argv[i], "-mfloat-abi=", strlen("-mfloat-abi=")) ||
		    !strcmp(argv[i], "-msoft-float") ||
		    !strcmp(argv[i], "-mhard-float"))
			break;
	}

	if (i == argc)
		*cur++ = "-mfloat-abi=" BR_FLOAT_ABI;
#endif

#if defined(BR_ARCH) || \
    defined(BR_CPU)
	/* Add our -march/cpu flags, but only if none of
	 * -march/mtune/mcpu are already specified on the commandline
	 */
	for (i = 1; i < argc; i++) {
		if (!strncmp(argv[i], "-march=", strlen("-march=")) ||
		    !strncmp(argv[i], "-mtune=", strlen("-mtune=")) ||
		    !strncmp(argv[i], "-mcpu=",  strlen("-mcpu=" )))
			break;
	}
	if (i == argc) {
#ifdef BR_ARCH
		*cur++ = "-march=" BR_ARCH;
#endif
#ifdef BR_CPU
		*cur++ = "-mcpu=" BR_CPU;
#endif
	}
#endif /* ARCH || CPU */

	paranoid_wrapper = getenv("BR_COMPILER_PARANOID_UNSAFE_PATH");
	if (paranoid_wrapper && strlen(paranoid_wrapper) > 0)
		paranoid = 1;
	else
		paranoid = 0;

	/* Check for unsafe library and header paths */
	for (i = 1; i < argc; i++) {

		/* Skip options that do not start with -I and -L */
		if (strncmp(argv[i], "-I", 2) && strncmp(argv[i], "-L", 2))
			continue;

		/* We handle two cases: first the case where -I/-L and
		 * the path are separated by one space and therefore
		 * visible as two separate options, and then the case
		 * where they are stuck together forming one single
		 * option.
		 */
		if (argv[i][2] == '\0') {
			i++;
			if (i == argc)
				continue;
			check_unsafe_path(argv[i], paranoid);
		} else {
			check_unsafe_path(argv[i] + 2, paranoid);
		}
	}

	/* append forward args */
	memcpy(cur, &argv[1], sizeof(char *) * (argc - 1));
	cur += argc - 1;

	/* finish with NULL termination */
	*cur = NULL;

	exec_args = args;
#ifdef BR_CCACHE
	if (getenv("BR_NO_CCACHE"))
		/* Skip the ccache call */
		exec_args++;
#endif

	/* Debug the wrapper to see actual arguments passed to
	 * the compiler:
	 * unset, empty, or 0: do not trace
	 * set to 1          : trace all arguments on a single line
	 * set to 2          : trace one argument per line
	 */
	if ((env_debug = getenv("BR2_DEBUG_WRAPPER"))) {
		debug = atoi(env_debug);
		if (debug > 0) {
			fprintf(stderr, "Toolchain wrapper executing:");
#ifdef BR_CCACHE_HASH
			fprintf(stderr, "%sCCACHE_COMPILERCHECK='string:" BR_CCACHE_HASH "'",
				(debug == 2) ? "\n    " : " ");
#endif
#ifdef BR_CCACHE_BASEDIR
			fprintf(stderr, "%sCCACHE_BASEDIR='" BR_CCACHE_BASEDIR "'",
				(debug == 2) ? "\n    " : " ");
#endif
			for (i = 0; exec_args[i]; i++)
				fprintf(stderr, "%s'%s'",
					(debug == 2) ? "\n    " : " ", exec_args[i]);
			fprintf(stderr, "\n");
		}
	}

#ifdef BR_CCACHE_HASH
	/* Allow compilercheck to be overridden through the environment */
	if (setenv("CCACHE_COMPILERCHECK", "string:" BR_CCACHE_HASH, 0)) {
		perror(__FILE__ ": Failed to set CCACHE_COMPILERCHECK");
		return 3;
	}
#endif
#ifdef BR_CCACHE_BASEDIR
	/* Allow compilercheck to be overridden through the environment */
	if (setenv("CCACHE_BASEDIR", BR_CCACHE_BASEDIR, 0)) {
		perror(__FILE__ ": Failed to set CCACHE_BASEDIR");
		return 3;
	}
#endif

	if (execv(exec_args[0], exec_args))
		perror(path);

	free(args);

	return 2;
}
