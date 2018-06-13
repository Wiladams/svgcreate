AA[ ]
0x7F
p
-
ABS[ ]
0x64
n
|n|
ADD[ ]
0x60
n2, n1
(n1 + n2)
ALIGNPTS[ ]
0x27
p2, p1
-
ALIGNRP[ ]
0x3C
p1, p2, ... , ploopvalue
-
AND[ ]
0x5A
e2, e1
b
CALL[ ]
0x2B
f
-
CEILING[ ]
0x67
n
Èn
CINDEX[ ]
0x25
k
ek
CLEAR[ ]
0x22
all items on the stack
-
DEBUG[ ]
0x4F
n
-
DELTAC1[ ],
0x73
argn, cn, argn-1,cn-1, , arg1, c1
-
DELTAC2[ ]
0x74
argn, cn, argn-1,cn-1, , arg1, c1
-
DELTAC3[ ]
0x75
argn, cn, argn-1,cn-1, , arg1, c1
-
DELTAP1[ ]
0x5D
argn, pn, argn-1, pn-1, , arg1, p1
-
DELTAP2[ ]
0x71
argn, pn, argn-1, pn-1, , arg1, p1
-
DELTAP3[ ]
0x72
argn, pn, argn-1, pn-1, , arg1, p1
-
DEPTH[ ]
0x24
-
n
DIV[ ]
0x62
n2, n1
(n1 * 64)/ n2
DUP[ ]
0x20
e
e, e
EIF[ ]
0x59
-
-
ELSE
0x1B
-
-
ENDF[ ]
0x2D
-
-
EQ[ ]
0x54
e2, e1
b
EVEN[ ]
0x57
e
b
FDEF[ ]
0x2C
f
-
FLIPOFF[ ]
0x4E
-
-
FLIPON[ ]
0x4D
-
-
FLIPPT[ ]
0x80
p1, p2, ..., ploopvalue
-
FLIPRGOFF[ ]
0x82
h, l
-
FLIPRGON[ ]
0x81
h, l
-
FLOOR[ ]
0x66
n
În°
GC[a]
0x46 - 0x47
p
c
GETINFO[ ]
0x88
selector
result
GFV[ ]
0x0D
-
px, py
GPV[ ]
0x0C
-
px, py
GT[ ]
0x52
e2, e1
b
GTEQ[ ]
0x53
e2, e1
b
IDEF[ ]
0x89
f
-
IF[ ]
0x58
e
-
INSTCTRL
0x8E
s, v
-
IP[ ]
0x39
p1, p2, ... , ploopvalue
-
ISECT[ ]
0x0F
a1, a0, b1, b0, p
-
IUP[a]
0x30 - 0x31
-
-
JMPR
0x1C
offset
-
JROF[ ]
0x79
e, offset
-
JROT[ ]
0x78
e, offset
-
LOOPCALL[ ]
0x2A
f, count
-
LT[ ]
0x50
e2, e1
b
LTEQ[ ]
0x51
e2, e1
b
MAX[ ]
0X8B
e2, e1
max(e1, e2)
MD[a]
0x49 - 0x4A
p2,p1
d
MDAP[ a ]
0x2E - 0x2F
p
-
MDRP[abcde]
0xC0 - 0xDF
p
-
MIAP[a]
0x3E - 0x3F
n, p
-
MIN[ ]
0X8C
e2, e1
min(e1, e2)
MINDEX[ ]
0x26
k
ek
MIRP[abcde]
0xE0 - 0xFF
n, p
-
MPPEM[ ]
0x4B
-
ppem
MPS[ ]
0x4C
-
pointSize
MSIRP[a]
0x3A - 0x3B
d, p
-
MUL[ ]
0x63
n2, n1
(n1 * n2)/64
NEG[ ]
0x65
n
-n
NEQ[ ]
0x55
e2, e1
b
NOT[ ]
0x5C
e
( not e )
NROUND[ab]
0x6C - 0x6F
n1
n2
ODD[ ]
0x56
e
b
OR[ ]
0x5B
e2, e1
b
POP[ ]
0x21
e
-
RCVT[ ]
0x45
location
value
RDTG[ ]
0x7D
-
-
ROFF[ ]
0x7A
-
-
ROLL
0x8a
a,b,c
b,a,c
ROUND[ab]
0x68 - 0x6B
n1
n2
RS[ ]
0x43
n
v
RTDG[ ]
0x3D
-
-
RTG[ ]
0x18
-
-
RTHG[ ]
0x19
-
-
RUTG[ ]
0x7C
-
-
S45ROUND[ ]
0x77
n
-
SANGW[ ]
0x7E
weight
-
SCANCTRL[ ]
0x85
n
-
SCANTYPE[ ]
0x8D
n
-
SCFS[ ]
0x48
c, p
-
SCVTCI[ ]
0x1D
n
-
SDB[ ]
0x5E
n
-
SDPVTL[a]
0x86 - 0x87
p2, p1
-
SDS[ ]
0x5F
n
-
SFVFS[ ]
0x0B
y, x
-
SFVTCA[a]
0x04 - 0x05
-
-
SFVTL[a]
0x08 - 0x09
p2, p1
-
SFVTPV[ ]
0x0E
-
-
SHC[a]
0x34 - 0x35
c
-
SHP[a]
0x32 - 0x33
p1, p2, ..., ploopvalue
-
SHPIX[ ]
0x38
d, p1, p2, ..., ploopvalue
-
SHZ[a]
0x36 - 0x37
e
-
SLOOP[ ]
0x17
n
-
SMD[ ]
0x1A
distance
-
SPVFS[ ]
0x0A
y, x
-
SPVTCA[a]
0x02 - 0x03
-
-
SPVTL[a]
0x06 - 0x07
p2, p1
-
SROUND[ ]
0x76
n
-
SRP0[ ]
0x10
p
-
SRP1[ ]
0x11
p
-
SRP2[ ]
0x12
p
-
SSW[ ]
0x1F
n
-
SSWCI[ ]
0x1E
n
-
SUB[ ]
0x61
n2, n1
(n1 - n2)
SVTCA[a]
0x00 - 0x01
-
-
SWAP[ ]
0x23
e2, e1
e1, e2
SZP0[ ]
0x13
n
-
SZP1[ ]
0x14
n
-
SZP2[ ]
0x15
n
-
SZPS[ ]
0x16
n
-
UTP[ ]
0x29
p
-
WCVTF[ ]
0x70
n, l
-
WCVTP[ ]
0x44
v, l
-
WS[ ]
0x42
v, l
-
