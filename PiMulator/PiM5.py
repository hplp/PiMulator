import subprocess
import os

os.system('make Bank_HLS -C Bank_HLS/')#TARGET=xczu3eg-sfva625-1-i-es1
print("make Bank_HLS completed")

os.system('make UZEG_Bank_Hardware -C Bank_Hardware_Design/')
print("make Bank Hardware Design completed")
