from test_support import *

prove_all(opt=["--limit-subp=proveline.adb:1", "--limit-line=proveline.adb:3"])
