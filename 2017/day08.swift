//
//  main.swift
//  day08
//
//  Created by Mark Johnson on 1/11/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10
"""
let input = """
sdj dec 558 if r <= 8
cpv inc 669 if csu >= -6
ke dec 312 if pep != 0
sdj inc -97 if bs == 0
nj inc -593 if hp < 1
rcb inc -121 if t != 0
moe inc -437 if vt > -7
n dec 865 if t == 0
dtf dec 137 if u != 1
cpv inc -625 if ke == 0
zx inc 410 if nwg < 8
hp dec -263 if nj >= -585
ib dec 335 if ifd > -8
pmp inc -432 if sdj <= -648
vt inc 612 if vt > -4
pep inc -244 if pep == 9
zx dec 237 if pmp <= -433
sdj inc 805 if cpv > 39
cpv dec -110 if nwg != 4
n inc -644 if yk == 0
zx dec -522 if ke > -8
cpv inc -360 if ojk >= 0
ifd inc -999 if rcb >= -8
nwg dec -726 if cpv > -207
moe inc -758 if n > -1512
t inc 854 if moe != -1188
vt dec 576 if sdj == 150
cpv dec 642 if t < 857
vt inc -376 if s >= -8
csu dec -495 if ojk == 0
n inc -774 if vt != -339
zx inc -489 if n <= -2276
vdv dec 764 if yk >= -2
s dec 488 if dtf != -137
pmp dec 587 if rcb == -8
cpv inc -889 if pep > -1
yk inc 400 if ib < -325
if inc 652 if t == 854
vt inc -669 if dtf != -137
ojk inc -772 if ib != -335
nj inc 357 if nj >= -598
yk inc 980 if pep == 4
u dec -718 if yk <= 406
pep dec -75 if r == 0
nj inc -104 if n > -2285
moe inc 585 if csu == 495
n dec 599 if sdj > 151
u dec -942 if vt != -340
rcb dec -921 if if > 649
n inc 385 if cpv != -1737
vdv dec -949 if vdv != -765
u inc 300 if sdj <= 152
moe inc -208 if r != 5
dtf dec 805 if vt <= -339
cpv dec 943 if nj > -350
moe inc 474 if cpv >= -2684
s inc -852 if ojk == 0
ke dec 2 if moe != -336
pmp dec 977 if zx >= 441
ke dec 539 if rcb >= 915
dtf inc -771 if rcb > 911
bs inc -485 if vt > -350
nwg dec -875 if nwg != 726
dtf inc -90 if vdv == 185
s inc 446 if csu <= 495
t dec -450 if r >= 0
r inc 764 if vt > -348
sdj dec -130 if zx < 447
r dec -134 if t >= 1304
dtf inc 258 if dtf <= -1813
ib dec 92 if dtf >= -1803
csu dec -88 if dtf != -1810
zx dec -985 if csu >= 576
vdv inc -960 if vt < -336
zx inc 758 if moe >= -352
t inc -158 if pep > 70
sdj dec 852 if if >= 643
bs inc 503 if csu != 583
dtf inc -416 if vdv >= -782
zx inc -212 if moe == -344
vt dec -200 if csu == 592
vdv dec -159 if vdv < -765
bs inc -227 if pmp <= -1405
nj inc 524 if ib <= -437
yk dec -270 if cpv < -2681
u dec -744 if cpv == -2680
bs inc 665 if dtf < -2210
u dec 242 if n <= -2283
nj dec 958 if t < 1148
vt inc 357 if dtf <= -2210
cpv inc -503 if pep > 74
yk dec 847 if nwg != 722
s inc -64 if ib == -427
nwg dec 518 if hp >= -2
u dec -945 if u <= 1528
moe inc -11 if zx < 1970
r dec 643 if if <= 654
t dec 274 if s <= -463
csu dec 835 if sdj <= -565
t inc -870 if vt > 14
csu inc -888 if moe >= -345
ojk dec 314 if moe > -345
ke inc -886 if ke > -539
moe inc -134 if ib <= -424
ojk dec 433 if sdj > -568
u dec -982 if yk == -453
t inc -983 if zx <= 1976
r dec 799 if dtf != -2222
hp dec -802 if r > -545
dtf dec 222 if if == 652
nj dec 617 if moe != -486
ke dec -384 if s >= -471
ifd inc -769 if cpv != -3183
nwg inc -389 if rcb < 918
n inc -203 if csu == -1140
ke dec -359 if s == -470
cpv dec -201 if pep > 69
nj dec -166 if vt < 22
ke dec 944 if zx >= 1975
yk inc 878 if ib > -436
vt inc -209 if pep != 76
vdv inc 84 if n >= -2487
dtf dec 15 if t <= -977
hp inc -461 if ifd > -1004
n inc 30 if pmp >= -1417
u dec -605 if zx < 1978
s dec 909 if if > 644
ifd dec -720 if t < -971
pep inc 784 if ifd > -281
sdj dec 75 if t != -977
moe dec 561 if if != 657
sdj dec -552 if bs != -47
ib inc 27 if pep != 862
pmp inc 215 if s < -1370
pep inc 314 if s >= -1374
ib inc -218 if r <= -537
vdv inc 769 if pmp >= -1195
cpv dec 585 if ifd != -277
t inc 377 if nwg < 211
nwg dec -397 if bs <= -52
cpv dec -224 if cpv == -3567
hp inc 441 if ojk == -314
s inc -736 if moe < -1047
pmp dec 888 if cpv == -3342
rcb inc -311 if vt == -192
moe dec 470 if pmp >= -1199
ib inc -470 if if == 652
hp dec -317 if csu <= -1149
ifd dec -293 if sdj >= -655
nwg inc 254 if rcb > 611
dtf dec 36 if nj == -1749
moe dec 552 if r > -544
vt inc -497 if vt > -196
ib inc -479 if ojk <= -312
n dec -342 if pep <= 863
yk dec -242 if ifd > 12
ib dec 870 if cpv != -3341
n dec -99 if ib < -2427
bs dec -458 if ojk == -314
if dec -638 if csu != -1140
bs dec -229 if s == -1379
pep inc -179 if rcb > 609
n inc 455 if ifd < 15
dtf dec -187 if t < -594
r inc -344 if csu == -1140
ib inc 540 if yk < 669
sdj inc -336 if pep <= 680
vt inc -437 if pmp != -1198
dtf dec 904 if dtf < -2299
yk inc -30 if cpv >= -3351
rcb inc -132 if if < 661
rcb inc 38 if ifd >= 7
ojk dec 516 if ifd >= 23
n inc 509 if yk > 633
pep inc 63 if ke == 202
ib inc 500 if vt >= -1132
bs inc -738 if ojk > -305
t inc -710 if s >= -1388
u dec -514 if sdj >= -978
csu inc -763 if nj != -1757
n dec 562 if nj == -1749
ib inc -759 if bs <= 648
vdv inc -870 if r <= -888
n inc -905 if pmp > -1194
ke dec -839 if csu < -1896
nj inc -713 if yk <= 648
ifd inc 915 if ifd >= 12
vdv dec 110 if sdj <= -983
hp dec 847 if nj <= -2458
bs dec 637 if zx > 1967
vdv inc 892 if zx == 1974
pep inc 138 if hp > -56
moe dec 452 if r <= -887
zx inc 313 if pep > 739
ojk dec 425 if ib <= -2688
ojk inc 747 if nj <= -2462
sdj inc 822 if u != 3074
t dec -245 if dtf < -3212
csu inc -360 if ojk > 9
s dec -184 if sdj > -162
nj inc 955 if vdv > 148
ib inc -115 if pep <= 750
zx inc 568 if pmp > -1196
vt dec -781 if u >= 3068
n inc -880 if r >= -893
cpv inc 942 if cpv < -3341
vdv dec -714 if cpv != -2403
n dec -397 if yk == 643
vdv dec -277 if vt > -351
csu inc 102 if csu <= -1899
u inc -284 if nj >= -1509
pep inc -685 if bs <= 4
bs inc -350 if if < 653
s inc -991 if rcb != 513
nwg dec -198 if ojk > 9
hp inc -901 if zx < 2854
r dec -310 if dtf == -3209
r dec -399 if dtf == -3209
dtf inc 241 if sdj >= -163
bs dec 288 if bs >= -337
cpv inc -125 if ojk < 14
if inc -118 if pep < 64
dtf inc 117 if vt != -340
zx inc 505 if t > -1307
ojk dec 15 if bs != -347
csu dec 428 if n < -2086
nj dec -855 if s != -2184
nj inc -559 if moe >= -1964
vdv inc 85 if moe <= -1960
ojk dec -475 if cpv == -2526
pmp dec 647 if ke == 1041
t inc -454 if rcb == 516
vdv inc -718 if vdv < 1226
csu dec 126 if csu != -2223
r dec 95 if ifd > 921
yk inc 336 if t > -1776
cpv inc -100 if bs < -337
zx dec 910 if ib >= -2808
ib inc -278 if ke <= 1045
nj dec 167 if sdj == -161
pmp inc -432 if yk >= 976
csu inc 685 if hp <= -58
bs dec -427 if ke < 1037
ke inc -848 if ifd >= 924
vt dec -426 if s <= -2183
ib dec -397 if cpv == -2626
moe inc -30 if csu <= -1670
ifd dec -139 if ke != 187
ke inc -690 if ojk <= 486
sdj dec -113 if zx == 2855
pmp dec -490 if r >= -266
bs dec 750 if bs == -347
dtf dec -848 if ib < -2691
if dec 274 if pmp == -2273
if dec -496 if pep <= 64
s dec -478 if pep != 56
hp inc 977 if moe == -1991
yk dec 928 if s < -1699
rcb inc -110 if if != 756
hp inc -617 if pep == 58
cpv dec -557 if sdj >= -57
vt inc 227 if zx >= 2855
sdj inc 286 if r <= -273
bs inc 517 if dtf < -2012
nj dec 887 if pep == 64
if inc -798 if dtf < -1997
hp dec -704 if csu > -1678
t inc -480 if n <= -2087
pep dec 52 if zx < 2861
cpv dec -997 if r < -279
pep dec -789 if rcb != 522
dtf inc 768 if pep <= 799
ojk dec -19 if csu < -1672
r dec -24 if vt == 308
ke inc 108 if dtf != -1239
moe dec -334 if csu >= -1677
s inc -208 if rcb < 520
ib dec -285 if rcb == 516
sdj dec 860 if ojk > 479
nwg inc -456 if rcb >= 509
dtf inc 208 if moe <= -1655
bs inc 714 if n != -2101
t inc -931 if nwg >= -238
if dec -532 if r > -250
s inc 741 if pep < 800
pmp inc -890 if nwg == -248
n dec -183 if sdj < -631
ke dec -140 if yk <= 58
nj dec -904 if ifd == 1068
dtf inc 432 if r > -257
t dec -717 if dtf < -586
hp inc 897 if pep <= 795
rcb inc 277 if vdv >= 498
r inc -147 if u > 2784
vt dec 761 if u == 2786
pmp inc -484 if ib >= -2397
hp inc 128 if nwg != -248
zx dec 156 if pmp == -3163
u dec 648 if ke != -244
hp dec 1 if csu > -1676
r dec 681 if u == 2138
vdv inc 797 if u < 2136
ib inc 365 if vdv != 499
zx dec 796 if ib >= -2039
rcb inc 905 if nj == -474
s dec 460 if n != -2093
ke inc 217 if ib > -2048
u inc 506 if cpv < -2068
zx dec -146 if u <= 2645
n inc -906 if moe != -1652
dtf inc 41 if zx > 2835
yk dec 332 if zx < 2855
u dec -688 if bs <= -376
bs inc 182 if bs != -386
ojk dec 430 if sdj == -632
ke inc -900 if bs != -204
sdj inc -670 if dtf != -560
vdv dec 266 if pep <= 803
yk dec -920 if s != -1635
ifd inc -122 if ke != -941
rcb inc 688 if ojk > 482
bs inc 824 if pep >= 793
u dec 750 if moe < -1656
pmp inc -836 if hp != 1892
bs dec 203 if bs == 623
zx inc 169 if s < -1628
vt dec -444 if zx != 3004
pmp inc -732 if r >= -1085
nj inc 144 if moe <= -1661
sdj dec 899 if ib != -2043
ifd inc -198 if ib != -2041
nj dec 754 if dtf < -546
nwg inc -797 if r >= -1084
dtf inc -121 if if <= -35
ke inc -22 if pep >= 786
yk dec -33 if moe != -1667
u dec -993 if sdj != -2188
hp dec -209 if bs == 420
ifd dec 423 if dtf > -680
ke inc -632 if pmp > -4734
r inc -707 if if != -36
yk dec -66 if ke < -1580
if inc -458 if rcb < 2387
sdj inc 131 if vdv >= 241
csu inc -217 if ke == -1586
ke inc -204 if moe <= -1664
s inc -423 if nwg != -1044
csu dec 273 if nwg >= -1053
vt inc -822 if r == -1785
sdj inc -564 if t > -1536
csu inc 283 if if < -505
u inc -374 if ke > -1591
nj inc 803 if ke < -1581
ojk inc -778 if zx == 3014
pmp inc -790 if yk > -182
r inc -375 if hp >= 2100
cpv dec -363 if vdv > 238
ifd dec -657 if ib > -2052
r inc -578 if yk <= -177
u dec 727 if cpv <= -1712
r dec 108 if csu != -2165
rcb dec -840 if rcb > 2379
sdj inc 733 if s != -2051
ke inc 775 if n > -3007
if inc -752 if s < -2065
s inc 382 if t <= -1524
vt dec 900 if hp != 2109
vdv inc 635 if u >= 3196
t inc 430 if rcb >= 3219
nwg inc 780 if ifd > 982
bs inc 460 if cpv >= -1714
ke inc 122 if pep != 796
pep inc 503 if rcb == 3226
pep inc -441 if sdj >= -1888
moe dec -329 if zx <= 3019
ke dec 618 if ib > -2045
if dec 500 if sdj < -1881
vt inc -251 if u == 3202
zx inc -893 if nj != -435
ojk dec 815 if ojk != -297
ifd inc 29 if ojk != -1110
ib dec 160 if ke == -1307
zx inc 24 if ib <= -2193
pep inc -704 if vt < -1729
vt inc -706 if hp < 2100
ojk dec -477 if pep <= 602
s inc -475 if ojk > -641
ifd inc -820 if ojk == -633
csu dec 631 if vt > -1736
if inc -78 if csu == -2791
ojk inc 829 if vt != -1731
pep dec -391 if r < -2842
hp dec 413 if s == -2151
ib inc -79 if pep < 987
ojk inc -788 if s == -2151
if dec 883 if ib < -2280
vdv inc 980 if pep > 988
zx dec -680 if zx < 2148
vt dec 276 if pmp > -4737
ojk dec -672 if nwg <= -1046
t inc -983 if rcb == 3226
csu dec 977 if r >= -2848
rcb inc 341 if u > 3206
rcb inc 158 if hp != 1682
bs inc -416 if bs != 874
n dec -79 if ojk >= -1427
if inc -32 if t == -2084
vdv dec -735 if sdj < -1883
vdv inc 217 if yk > -185
ifd inc -699 if u == 3201
bs dec 287 if bs != 469
sdj inc 30 if vt >= -2008
u inc 527 if moe == -1337
pep dec -677 if ifd < -529
moe dec -208 if n != -2923
ke inc -186 if s >= -2141
s dec 661 if rcb <= 3391
pep dec 78 if hp <= 1698
vdv dec -131 if pmp <= -4722
rcb inc 476 if nwg != -1053
yk dec -851 if vt <= -1998
vdv inc 113 if nj <= -421
bs inc -765 if u < 3207
vdv dec 266 if csu >= -3764
t dec 142 if vt <= -2014
ifd dec 298 if u == 3201
nwg dec -173 if ifd == -835
yk dec 838 if zx >= 2828
yk dec -340 if zx <= 2821
rcb inc -517 if cpv != -1697
ib dec 502 if pep != 1593
s inc 690 if vdv > 2073
yk dec -976 if bs >= -594
hp dec -663 if yk < 1637
n inc 604 if nj >= -418
vdv inc -177 if ib != -2778
ib inc -4 if csu >= -3777
ifd inc -472 if ib != -2790
u dec 919 if nwg < -862
moe dec 672 if nwg >= -866
u inc -828 if pmp == -4731
csu inc -691 if hp >= 1689
pep inc 452 if yk > 1644
nwg inc 712 if nwg > -878
u dec 895 if vdv >= 1904
r dec 159 if pep != 2039
bs inc -660 if csu >= -4452
nwg dec 87 if ke >= -1316
zx inc -385 if rcb != 3343
zx dec 383 if pmp >= -4732
if inc -581 if if > -1992
ifd dec 431 if dtf != -675
hp dec 339 if ib >= -2796
if dec 216 if r >= -3005
ke dec 724 if ojk <= -1414
rcb inc 478 if pmp <= -4731
if inc -648 if ojk <= -1414
vdv dec 19 if zx < 2440
zx inc 267 if csu == -4459
r inc -444 if ojk < -1418
yk dec 256 if csu < -4464
ojk dec -33 if cpv <= -1709
csu dec -313 if pmp <= -4728
ib dec 635 if rcb == 3821
r dec -186 if csu == -4154
bs dec -87 if sdj < -1867
pep inc 169 if moe <= -1328
s inc 665 if yk <= 1642
cpv dec 953 if hp <= 1359
nj dec -418 if ke >= -2037
if inc 578 if s <= -2805
vt dec 968 if vdv < 1897
vdv inc 322 if dtf != -680
csu dec 73 if nwg == -241
ifd dec -977 if hp == 1352
ojk inc -483 if pmp != -4737
rcb inc -335 if r != -3451
ifd inc -850 if ke == -2031
cpv inc 567 if r != -3442
cpv inc 319 if vdv < 2224
ifd inc 48 if moe < -1320
sdj inc 148 if nwg != -247
rcb inc -396 if nj <= -1
nj dec 397 if s < -2819
yk dec -184 if csu != -4150
ifd dec 209 if n >= -2926
hp dec -338 if yk >= 1820
ib inc 586 if r < -3445
hp dec 482 if rcb <= 3094
yk inc 399 if nj == -7
cpv dec -855 if vt == -2979
if inc 398 if s < -2804
u dec -138 if t >= -2087
rcb inc -863 if ifd >= -1350
pmp inc 697 if pmp <= -4723
zx dec -286 if vt >= -2983
ib dec -557 if ojk > -1906
ib inc -415 if ojk >= -1910
bs inc -724 if bs != -594
moe dec -176 if r >= -3455
moe inc -816 if pmp < -4029
dtf inc 770 if vt <= -2974
yk inc 536 if vt <= -2967
rcb dec 965 if pep != 2214
ojk dec -456 if zx == 2996
u dec 597 if ke != -2028
hp dec 790 if ib != -2694
ifd dec -94 if csu <= -4142
hp inc -460 if s <= -2803
moe dec 439 if dtf <= 95
vdv dec 902 if sdj < -1851
yk inc 182 if bs >= -1315
sdj dec 535 if ke != -2026
vdv dec 941 if nj != -10
csu inc 905 if s == -2812
pmp dec -817 if u >= 986
bs dec -624 if nj <= 2
nwg inc -497 if sdj >= -2396
ojk dec -549 if csu > -3249
n inc 744 if ib >= -2696
csu dec 463 if bs <= -693
t dec 94 if pmp >= -3214
vt inc -312 if n <= -2186
rcb dec 939 if vdv <= 376
nj dec -936 if if > -1890
n inc 652 if s != -2812
yk dec -302 if r != -3442
ib dec -874 if ojk <= -1347
dtf inc -609 if hp <= 756
pmp inc -377 if yk <= 3250
r inc 846 if vdv <= 369
n dec 182 if nwg >= -745
hp inc -540 if vt == -2975
rcb inc 167 if pmp < -3599
yk inc 689 if vt < -2971
moe dec 916 if yk < 3946
csu dec 440 if zx < 3001
ke dec 389 if ke <= -2037
pep inc -791 if zx < 3001
r inc -430 if ifd != -1240
ib inc -826 if s < -2805
ojk inc 918 if t != -2084
r inc 809 if if == -1881
if inc 621 if hp != 201
yk inc -85 if sdj != -2386
pep inc 55 if ib >= -2639
n dec 164 if cpv == -1773
s inc 42 if vdv < 378
s dec 608 if s == -2770
zx inc 984 if n > -2535
s inc -175 if ifd == -1247
n inc 662 if dtf < -505
pmp dec 283 if ke < -2029
ke inc 138 if r <= -3069
bs dec -247 if pep <= 1414
pmp dec -925 if r > -3076
nwg dec 466 if ojk > -1361
dtf dec -233 if if > -1260
nwg dec -176 if zx <= 3981
pmp inc 128 if r < -3062
ke dec 488 if nj != 932
rcb inc 99 if zx == 3979
dtf dec 936 if pmp <= -2817
moe dec 895 if dtf < -1448
if inc 650 if r > -3080
pmp inc -184 if dtf == -1442
pep dec -68 if rcb <= 428
u inc 259 if u < 999
t dec -934 if bs < -431
yk inc -451 if if != -603
ib dec 408 if nj <= 933
ojk inc -306 if nj >= 929
cpv dec -165 if u <= 1263
ke inc 130 if nj <= 933
csu dec 533 if ib <= -3064
bs dec 308 if pep <= 1488
cpv inc -720 if if >= -618
moe inc 165 if hp > 204
csu dec 553 if vdv < 384
s dec 465 if zx >= 3984
csu dec 523 if hp > 217
moe dec 473 if csu <= -4231
csu dec 859 if hp >= 213
moe inc -810 if n != -1863
dtf dec 472 if cpv < -2327
nwg inc 609 if pmp > -2828
moe dec -924 if pep != 1483
moe inc -626 if hp < 204
csu dec -152 if zx != 3971
n dec 581 if nwg < -424
ib inc 15 if cpv >= -2336
t inc -346 if ifd > -1256
vt dec -973 if nj > 925
ke dec 446 if yk > 3398
rcb inc 605 if ifd <= -1245
if dec -221 if dtf != -1922
nj inc -195 if s < -3560
yk inc -556 if s >= -3548
nwg inc 566 if r == -3070
ib dec 846 if zx <= 3988
dtf dec 942 if pep >= 1476
s dec -477 if vt < -1999
r inc -822 if cpv != -2321
r dec 241 if zx == 3979
nwg dec -790 if vdv == 374
vt dec -222 if u != 1262
if dec 556 if if >= -617
dtf dec -953 if vt >= -1786
zx inc 255 if sdj != -2396
ojk dec -770 if moe < -3594
dtf inc 347 if nj != 920
yk inc 812 if yk < 3406
nwg dec -746 if moe >= -3596
bs dec 330 if vdv >= 369
zx dec 893 if n <= -2437
dtf dec -828 if if >= -1166
pmp inc -694 if u > 1263
hp dec -633 if nj != 919
csu dec -462 if csu > -4090
if dec -19 if rcb < 1024
r dec -542 if ib >= -3875
dtf inc 937 if vt != -1780
if dec 940 if ib > -3887
n inc -659 if vt != -1778
r dec -729 if sdj == -2396
bs dec -621 if u <= 1260
bs dec 963 if r == -3404
moe inc 297 if nj == 937
nwg inc -746 if r < -3394
hp inc -485 if zx > 3079
vt inc 977 if ke == -2697
ke dec 35 if n <= -3103
nj dec 773 if if == -2106
bs dec -853 if csu < -3626
if inc 220 if csu < -3619
vt inc 803 if nj > 155
ke dec 670 if n == -3103
r dec -487 if if > -1894
nj inc 458 if t >= -1504
u dec 69 if nwg >= 183
yk dec -822 if pmp >= -2824
pep dec -267 if t < -1487
vdv inc -633 if vdv >= 369
dtf inc 252 if ke < -3406
t dec 343 if r <= -2927
zx inc 103 if ifd != -1245
s inc -667 if t > -1502
moe dec 694 if nwg < 195
rcb inc 443 if s != -3733
vdv dec 385 if t != -1501
n inc 743 if zx == 3189
ojk inc 889 if ke != -3394
rcb inc -314 if vdv <= -647
r inc -334 if r > -2925
yk dec 934 if if == -1886
dtf inc 732 if ifd <= -1247
u inc 305 if ojk <= -8
n inc 969 if ifd < -1237
cpv dec 562 if yk <= 4108
n dec 284 if if == -1886
pep dec -413 if nj == 614
n dec 878 if t > -1498
ojk dec 566 if zx < 3196
s inc -231 if bs == -1421
n inc -683 if csu != -3612
yk inc -675 if pep > 2154
n dec -805 if ifd > -1242
cpv inc -229 if nwg > 182
pmp inc 725 if pmp > -2830
nj dec -294 if nj != 620
r inc -754 if ifd < -1246
dtf dec -780 if nj < 912
ke inc -632 if pmp <= -2094
s inc 193 if s == -3974
dtf dec 215 if nwg >= 184
hp dec 646 if if != -1890
r inc 707 if ke >= -4034
ke inc 546 if csu <= -3613
yk inc -149 if s < -3774
rcb dec 101 if t > -1488
yk inc 47 if t != -1497
n inc -396 if sdj < -2386
ifd inc -728 if cpv > -3126
ib inc -178 if yk <= 3327
r dec 952 if s != -3786
nwg dec 953 if t > -1504
vdv inc 11 if vdv == -647
ib dec 22 if yk >= 3327
dtf dec -309 if if <= -1895
pmp inc -906 if n < -3627
u inc 711 if sdj >= -2389
zx dec 492 if pmp != -3005
yk inc -187 if moe <= -4298
pep inc 46 if pep == 2162
vdv dec -692 if t != -1496
zx inc -573 if u <= 1187
n dec -429 if yk < 3327
r dec 514 if if >= -1892
moe inc -637 if yk <= 3327
moe dec -797 if zx <= 2622
dtf inc 64 if u == 1189
u inc 311 if dtf == 561
sdj inc -754 if ib == -4066
if dec -139 if sdj != -2404
s inc 549 if t < -1503
bs dec 592 if csu < -3610
pmp inc 159 if vt >= -2
yk inc -872 if pep != 2208
ojk dec 816 if moe == -4136
cpv dec -922 if r != -4758
ojk dec -765 if pmp > -2853
vdv dec 219 if bs >= -2022
nwg dec 175 if if != -1747
nwg dec -374 if u == 1496
u inc 975 if n > -3207
sdj dec -669 if u >= 2474
moe inc 451 if sdj > -2400
hp inc 794 if moe != -3685
r inc 895 if zx > 2613
cpv inc -825 if vt < -8
n inc 866 if vt <= 8
t inc 102 if dtf == 561
csu dec -293 if ojk >= -628
csu dec 99 if sdj < -2387
moe dec 822 if s <= -3775
pmp inc 788 if ke <= -3486
moe dec 378 if nj == 908
yk dec 80 if yk != 3334
pmp dec -656 if nj < 917
pmp dec 1 if t != -1385
pmp inc -384 if ojk < -623
n dec 220 if bs > -2009
s dec 64 if hp < -280
yk dec 957 if dtf == 561
rcb dec 326 if u > 2464
ke inc -168 if vt == 0
vt inc -203 if if == -1747
ojk inc -232 if r < -3863
yk dec -62 if ib > -4064
vdv inc 205 if nwg <= -403
moe inc -283 if sdj > -2399
pmp inc 89 if ke >= -3650
cpv inc -521 if pmp >= -1400
bs inc 459 if zx == 2616
t inc 154 if hp <= -299
dtf inc 670 if u != 2462
ojk dec -835 if nj < 906
ib dec 306 if ojk != -851
moe inc -395 if zx < 2619
n inc 306 if zx != 2626
s dec -380 if pep <= 2209
ifd inc -697 if ke == -3656
bs dec 1000 if moe <= -5560
yk inc -655 if ke < -3647
nwg dec 578 if s == -3465
csu dec -49 if vdv > -866
n inc 336 if vt < -200
n dec -847 if vt > -194
moe dec -573 if pep > 2198
pmp dec 325 if nwg <= -972
cpv inc 942 if ke < -3655
u dec -149 if yk >= 1687
ib inc 293 if nwg > -977
vdv inc 486 if csu <= -3378
u dec 559 if u <= 2624
pmp dec 829 if rcb < 1151
ifd dec 356 if ifd > -2665
u inc -424 if ifd != -2680
csu dec 962 if csu > -3373
ib dec 306 if nwg >= -962
pep inc -423 if s != -3469
pmp inc 658 if dtf > 1230
dtf dec 140 if pep >= 1778
ke inc -356 if n <= -1693
ojk dec 508 if bs < -2551
u dec 990 if moe != -4992
rcb inc 904 if nj <= 898
dtf inc -317 if nj != 915
hp dec -734 if t != -1389
zx dec -431 if ke <= -4021
u dec 638 if dtf == 774
cpv dec -958 if if == -1747
vdv dec -431 if vt != -205
nwg inc -831 if hp != 445
hp inc -338 if nwg > -1809
csu inc 409 if pmp < -1895
t inc 109 if u > 3
rcb dec -629 if zx >= 2618
moe dec -897 if s > -3462
vt inc -111 if u < 12
u dec -239 if vdv != -433
ifd dec -304 if cpv < -288
csu dec 538 if moe > -4996
rcb dec 847 if csu <= -3500
r dec 845 if csu != -3514
bs inc 535 if u < 257
nwg inc 328 if pmp < -1893
bs dec -959 if zx < 2617
pep inc -513 if u > 243
t dec -817 if dtf > 765
nj inc 378 if ifd < -2359
ifd dec 99 if ifd < -2367
pmp dec -177 if dtf != 780
n dec -626 if t < -467
cpv inc 324 if nj != 1279
ojk inc -186 if if < -1740
pmp dec -529 if hp != 104
u dec 818 if vt >= -320
moe inc -583 if dtf < 783
nj dec -907 if ib <= -3764
pep dec 362 if ke <= -4003
moe inc 158 if t >= -476
ke inc 693 if s == -3465
vt inc 966 if ifd != -2462
pep inc -454 if bs <= -1068
vdv dec 241 if cpv == 27
n inc 411 if hp <= 97
sdj inc -301 if dtf == 774
ke inc -629 if moe >= -5424
ib inc 681 if dtf < 783
rcb inc -924 if ib >= -3094
rcb dec 12 if if < -1744
vdv dec -752 if csu > -3509
ifd inc -112 if vt >= 643
pmp dec 165 if r == -4714
csu dec -125 if n <= -1061
ke dec 405 if nwg == -1475
s inc 196 if s <= -3462
ib inc 398 if zx <= 2609
ifd inc -26 if vdv >= 71
s inc -121 if moe <= -5414
moe inc -217 if if == -1753
nj inc -248 if hp == 106
ojk dec -114 if pep <= 913
vt inc 64 if nj < 1947
u dec -440 if cpv != 21
t inc 579 if ib >= -3089
vt inc 213 if dtf <= 771
vt inc 74 if ojk > -1429
pmp dec 883 if t > 108
moe dec -189 if pmp >= -2246
cpv dec -286 if n > -1074
n inc 379 if s < -3385
nwg dec -164 if bs > -1070
if inc 552 if vt == 716
yk dec 777 if moe > -5236
u inc -495 if yk <= 921
ib dec 460 if moe == -5220
moe dec 243 if t < 121
u dec -233 if csu > -3384
ke dec 528 if dtf != 774
csu dec 507 if ifd <= -2596
yk dec 578 if rcb == -639
if dec -260 if hp == 112
ke dec -369 if yk == 345
cpv inc 471 if dtf <= 782
sdj inc -744 if t >= 108
u inc -494 if if <= -1200
csu inc 832 if yk >= 333
ifd dec -184 if yk <= 339
csu inc -623 if vt <= 723
s inc 573 if n != -686
ifd dec -10 if t < 113
ojk inc 921 if cpv < 790
nwg inc -782 if nwg < -1306
vt dec 474 if ifd > -2416
ke inc 89 if hp < 110
u dec -292 if zx == 2618
ifd inc 64 if dtf > 767
u dec 56 if vdv < 88
nwg inc 165 if nwg < -2096
yk inc -332 if yk >= 336
hp dec 58 if n == -690
ifd dec 168 if s < -2807
rcb inc -906 if rcb <= -643
nwg dec 597 if s > -2820
nj dec 419 if pep <= 913
u dec -470 if bs == -1060
hp inc -555 if dtf <= 769
ojk dec -392 if ke == -4264
r inc 72 if r > -4718
n inc 888 if s >= -2824
yk dec -234 if if > -1190
rcb dec 818 if nwg > -2693
sdj dec -726 if sdj > -3433
hp dec 190 if t > 108
hp dec -252 if csu > -3672
bs inc -158 if hp > -144
hp inc -334 if rcb < -1459
s dec 516 if pmp >= -2235
sdj inc 42 if sdj == -3440
r inc -301 if cpv > 783
dtf inc 919 if n != 198
if inc 636 if bs < -1210
ib inc 988 if moe != -5462
ifd dec 844 if r >= -4949
moe dec 748 if ke != -4263
pep inc -985 if u >= 19
ifd dec 642 if ifd < -3350
ojk dec -782 if csu < -3673
zx dec -6 if vdv < 80
ojk dec -957 if pep != -75
pmp inc -23 if vt < 250
dtf dec 631 if nwg <= -2684
nwg inc 968 if s > -2824
zx inc -728 if cpv > 777
yk dec -961 if if == -559
ib inc 415 if bs != -1218
t inc -665 if ifd > -3996
cpv dec -467 if u >= 17
ojk inc 36 if dtf > 138
cpv dec -899 if sdj == -3441
csu dec -23 if ojk < 702
nj inc -599 if t >= 107
zx dec 4 if yk < 976
t dec -848 if vdv >= 83
pmp dec 390 if csu != -3651
r inc -985 if csu > -3661
dtf dec 646 if cpv >= 2149
nj dec -489 if ifd < -3992
yk inc -731 if hp != -142
dtf inc 121 if r != -5928
cpv dec -696 if dtf < -502
dtf inc -872 if csu <= -3656
cpv dec -720 if bs > -1216
s inc 935 if ib <= -2111
dtf inc 189 if t == 101
sdj inc 871 if dtf != -1375
pmp dec -490 if rcb >= -1461
pmp dec 893 if pmp != -2164
yk inc -595 if vt < 238
ifd inc -830 if ib != -2101
pep dec -103 if nj < 1418
u dec 952 if sdj >= -3445
bs dec -210 if ke >= -4266
ib inc 38 if dtf != -1376
dtf dec -778 if ib >= -2071
cpv dec -537 if moe <= -6226
u dec -987 if s == -2817
pmp inc -164 if ib >= -2070
hp inc 57 if ib < -2057
bs dec -184 if yk <= 977
hp dec 593 if hp > -91
nj inc 430 if csu != -3662
ojk inc 869 if nj < 1849
nj dec -369 if vt >= 247
n dec 245 if ke <= -4258
nj dec 735 if vt <= 245
hp dec -859 if ib == -2063
n dec 31 if ke <= -4256
hp dec -647 if sdj > -3450
dtf dec -853 if nwg <= -1721
vdv inc -93 if cpv >= 2837
yk dec 352 if vdv <= -13
cpv inc -735 if s <= -2818
dtf inc -646 if cpv > 2845
moe dec 844 if moe < -6210
zx dec 569 if bs < -818
r dec 536 if bs != -824
cpv dec 53 if rcb > -1464
zx dec 265 if t < 118
cpv inc 280 if u <= 49
vdv inc -966 if hp < 831
n dec 210 if cpv >= 2784
yk dec -786 if moe < -7053
s dec 230 if nwg == -1722
pep inc -689 if t >= 108
ib dec 973 if pmp != -2336
cpv dec -171 if sdj < -3432
r dec -248 if pep > -663
bs inc 981 if pmp < -2319
pmp inc -135 if ojk > 1568
ke dec -834 if yk == 1402
s dec -569 if nwg < -1714
yk dec 983 if rcb > -1458
if dec 652 if zx < 1062
if inc 999 if r == -5675
pep dec -814 if u > 56
ke dec 209 if moe == -7061
yk dec 968 if nwg >= -1722
s dec 136 if pep >= 148
cpv dec -916 if ojk >= 1561
dtf dec -691 if if >= -1212
ojk dec -406 if yk >= -548
csu inc -601 if nj > 1118
ke inc 340 if u <= 50
vt inc -401 if ib < -3033
vdv inc -760 if bs <= 157
nwg inc -245 if vdv >= -1740
u inc -727 if pep > 151
bs dec -447 if zx != 1056
u inc 541 if n < -285
rcb dec -368 if nwg < -1962
rcb dec 95 if nwg != -1967
nwg inc 556 if ib == -3041
ifd dec -727 if r == -5680
ke inc 168 if ifd > -3284
ojk dec -250 if moe > -7052
pmp inc -869 if zx == 1056
dtf inc 304 if nwg > -1974
"""

func process( input: String ) -> ( Int, Int ) {
    var registers: [ Substring : Int ] = [:]
    let lines = input.split(separator: "\n")
    var biggest = Int.min
    
    for line in lines {
        let words = line.split(separator: " ")
        let targetRegister = words[0]
        let operation = words[1]
        let modifier = Int( words[2] )!
        let testRegister = words[4]
        let condition = words[5]
        let rhs = Int( words[6] )!
        
        var lhs = 0
        var success: Bool
        
        if let value = registers[testRegister] {
            lhs = value
        } else {
            registers[testRegister] = lhs
        }
        
        switch condition {
        case "==":
            success = lhs == rhs
        case "!=":
            success = lhs != rhs
        case "<":
            success = lhs < rhs
        case ">":
            success = lhs > rhs
        case "<=":
            success = lhs <= rhs
        case ">=":
            success = lhs >= rhs
        default:
            print( "Bad condition:", condition )
            exit(1)
        }
        
        if success {
            if registers[targetRegister] == nil {
                registers[targetRegister] = 0
            }
            switch operation {
            case "inc":
                let value = registers[targetRegister]! + modifier
                
                registers[targetRegister] = value
                biggest = max( biggest, value )
            case "dec":
                let value = registers[targetRegister]! - modifier
                
                registers[targetRegister] = value
                biggest = max( biggest, value )
            default:
                print( "Bad operation:", operation )
                exit(1)
            }
        }
    }
    
    return ( registers.max(by: { $0.value < $1.value } )!.value, biggest )
}

let ( part1, part2 ) = process(input: input)

print( "Part1:", part1 )
print( "Part2:", part2 )