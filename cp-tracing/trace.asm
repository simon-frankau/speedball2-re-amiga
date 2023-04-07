trap_trace_vector EQU 0x24
trap_illegal_vector EQU 0x10
cp_key EQU 0x08
cp_addr EQU 0x0c
cp_end EQU 0x01bb72

Key=2F3C712C Tracer=trap_trace   000150F0 5db9 0000 0024           SUB.L 0x6,(trap_trace_vector)                # Reactivate the "re-encrypt last instruction" code.
Key=2F3CDA2C Tracer=trap_trace   000150F6 42b9 0000 0008           CLR.L (cp_key)
Key=2F3C8354 Tracer=trap_trace   000150FC 42b9 0000 0010           CLR.L (trap_illegal_vector)                  # Prevent reverse engineers using illegal instructions.
Key=2F3C6C50 Tracer=trap_trace   00015102 4ac4                     TAS.B D4
Key=2F3CD554 Tracer=trap_trace   00015104 4440                     NEG.W D0
Key=2F3CBE54 Tracer=trap_trace   00015106 0803 00e8                BTST.L 0x00e8,D3
Key=2F3C676F Tracer=trap_trace   0001510A 5c4a                     ADDA.W 0x00000006,A2
Key=2F3CC07A Tracer=trap_trace   0001510C 7a92                     MOVE.L 0xffffff92,D5
Key=2F3CA99F Tracer=trap_trace   0001510E 08c1 00d6                BSET.L 0x00d6,D1
Key=2F7C12BF Tracer=trap_trace   00015112 d2bc 4e3c 4e4d           ADD.L 0x4e3c4e4d,D1
Key=61010C10 Tracer=trap_trace   00015118 4a81                     TST.L D1
Key=2F7CF510 Tracer=trap_trace   0001511A 4043                     NEGX.W D3
Key=61015E10 Tracer=trap_trace   0001511C 4205                     CLR.B D5
Key=2F7C0729 Tracer=trap_trace   0001511E c388                     EXG.L D1,A0
Key=FF3ADE5E Tracer=trap_trace   00015120 2f7c d246 d046 0010      MOVE.L 0xd246d046,(A7, 0x0010) == 0x0001bbd6 # Overwrite part of trace with add.w D6, D1, add.w D6, D0.
Key=2F7C877A Tracer=trap_trace   00015128 08c3 007e                BSET.L 0x007e,D3
Key=FF3A6082 Tracer=trap_trace   0001512C d4cc                     ADDA.W A4,A2
Key=2F7CC9A6 Tracer=trap_trace   0001512E eb2a                     LSL.B D5,D2
Key=FF3AB2BA Tracer=trap_trace   00015130 ca7c 51c1                AND.W 0x51c1,D5
Key=2F7C1BCA Tracer=trap_trace   00015134 d901                     ADDX.B D1,D4
Key=FF3AC4EA Tracer=trap_trace   00015136 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check integrity of trace routine.
Key=2F7CADF5 Tracer=trap_trace   0001513A 5384                     SUB.L 0x00000001,D4
Key=FF3A16E4 Tracer=trap_trace   0001513C bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check intregity of trace vector.
Key=2F7CFE14 Tracer=trap_trace   00015142 4081                     NEGX.L D1
Key=00C5E910 Tracer=trap_trace   00015144 4243                     CLR.W D3
Key=2F7C5221 Tracer=trap_trace   00015146 d183                     ADDX.L D3,D0
Key=00C53B35 Tracer=trap_trace   00015148 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check intregity of trace vector.
Key=2F7CE427 Tracer=trap_trace   0001514E 5540                     SUB.W 0x00000002,D0
Key=00C54D23 Tracer=trap_trace   00015150 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check intregity of trace vector.
Key=2F7C362B Tracer=trap_trace   00015156 5588                     SUBA.L 0x00000002,A0
Key=00C59F57 Tracer=trap_trace   00015158 d2fc 4644                ADDA.W 0x4644,A1
Key=2F7C7853 Tracer=trap_trace   0001515C e448                     LSR.W 0x00000002,D0
Key=00C52159 Tracer=trap_trace   0001515E c6bc 4721 4732           AND.L 0x47214732,D3
Key=2F7C8A68 Tracer=trap_trace   00015164 c388                     EXG.L D1,A0
Key=6101E03B Tracer=trap_trace   00015166 2f7c d246 d046 0010      MOVE.L 0xd246d046,(A7, 0x0010) == 0x0001bbd6 # Rewrite part of trace with add.w D6, D1, add.w D6, D0.
Key=2F7C495B Tracer=trap_trace   0001516E 08c3 0086                BSET.L 0x0086,D3
Key=61013263 Tracer=trap_trace   00015172 d848                     ADD.W A0,D4
Key=2F7C9B7F Tracer=trap_trace   00015174 4e71                     NOP                                          # Probably removed when breaking copy protection. :)
Key=6101447F Tracer=trap_trace   00015176 4a43                     TST.W D3
Key=2F7C2D7F Tracer=trap_trace   00015178 4005                     NEGX.B D5
Key=6101967F Tracer=trap_trace   0001517A 4240                     CLR.W D0
Key=2F7C7F67 Tracer=trap_trace   0001517C c74a                     EXG.L A3,A2
Key=6101D863 Tracer=trap_trace   0001517E 2f7c b386 b186 0014      MOVE.L 0xb386b186,(A7, 0x0014) == 0x0001bbda # Overwrite part of trace with eor.l D1, D6, eor.l D0, D6.
Key=C58E7467 Tracer=trap_trace   00015186 08c5 001e                BSET.L 0x001e,D5
Key=6101F697 Tracer=trap_trace   0001518A d8c0                     ADDA.W D0,A4
Key=C58E90A7 Tracer=trap_trace   0001518C 4a05                     TST.B D5
Key=610156B3 Tracer=trap_trace   0001518E 4081                     NEGX.L D1
Key=3A71BDA2 Tracer=trap_trace   00015190 4243                     CLR.W D3
Key=6101ADDF Tracer=trap_trace   00015192 cb44                     EXG.L D5,D4
Key=3A71A1DF Tracer=trap_trace   00015194 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=6101A1AF Tracer=trap_trace   0001519A 5d40                     SUB.W 0x00000006,D0
Key=3A71ADB9 Tracer=trap_trace   0001519C 0c81 5e2c 5e2c           CMP.L 0x5e2c5e2c,D1
Key=6101BDB3 Tracer=trap_trace   000151A2 e668                     LSR.W D3,D0
Key=3A71A959 Tracer=trap_trace   000151A4 c680                     AND.L D0,D3
Key=61019951 Tracer=trap_trace   000151A6 4402                     NEG.B D2
Key=3A71AD6A Tracer=trap_trace   000151A8 0804 0080                BTST.L 0x0080,D4
Key=6101BCAC Tracer=trap_trace   000151AC 5e01                     ADD.B 0x00000007,D1
Key=3A71A2AA Tracer=trap_trace   000151AE 5101                     SUB.B 0x00000008,D1
Key=6101A0B2 Tracer=trap_trace   000151B0 2f7c b386 b186 0014      MOVE.L 0xb386b186,(A7, 0x0014) == 0x0001bbda # Rewrite part of trace with eor.l D1, D6, eor.l D0, D6.
Key=3A71A2DA Tracer=trap_trace   000151B8 ca7c 61b1                AND.W 0x61b1,D5
Key=6101ACD2 Tracer=trap_trace   000151BC d901                     ADDX.B D1,D4
Key=3A71BAD2 Tracer=trap_trace   000151BE 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check part of trace routine.
Key=BC9F5B2C Tracer=trap_trace   000151C2 5383                     SUB.L 0x00000001,D3
Key=3A710B2C Tracer=trap_trace   000151C4 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=BC9FF350 Tracer=trap_trace   000151CA 4081                     NEGX.L D1
Key=C58E3ABF Tracer=trap_trace   000151CC 4243                     CLR.W D3
Key=BC9F4962 Tracer=trap_trace   000151CE cb44                     EXG.L D5,D4
Key=C58E194A Tracer=trap_trace   000151D0 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=BC9FCDA2 Tracer=trap_trace   000151D6 5540                     SUB.W 0x00000002,D0
Key=C58E3DDC Tracer=trap_trace   000151D8 2f7c d246 d046 0010      MOVE.L 0xd246d046,(A7, 0x0010) == 0x0001bbd6 # Overwrite part of trace with add.w D6, D1, add.w D6, D0.
Key=BC9F01DC Tracer=trap_trace   000151E0 c6bc 5601 5601           AND.L 0x56015601,D3
Key=C58EC1D4 Tracer=trap_trace   000151E6 01c5                     BSET.L D0,D5
Key=BC9F1DD4 Tracer=trap_trace   000151E8 bac0                     CMPA.W D0,A5
Key=C58E4DD4 Tracer=trap_trace   000151EA 4ac1                     TAS.B D1
Key=BC9F3954 Tracer=trap_trace   000151EC 2f7c b386 b186 0014      MOVE.L 0xb386b186,(A7, 0x0014) == 0x0001bbda # Overwrite part of trace with eor.l D1, D6, eor.l D0, D6.
Key=C58E097C Tracer=trap_trace   000151F4 9b42                     SUBX.W D2,D5
Key=BC9F5D74 Tracer=trap_trace   000151F6 bb43                     EOR.W D5,D3
Key=C58E0D74 Tracer=trap_trace   000151F8 183c 58dc                MOVE.B 0xdc,D4
Key=BC9FC17C Tracer=trap_trace   000151FC eb6b                     LSL.W D5,D3
Key=C58E4168 Tracer=trap_trace   000151FE 4084                     NEGX.L D4
Key=BC9F0D3D Tracer=trap_trace   00015200 e391                     ROXL.L 0x00000001,D1
Key=1708EB22 Tracer=trap_trace   00015202 90af 000c                SUB.L (A7, 0x000c) == 0x0001bbd2,D0          # Check part of trace routine.
Key=BED64049 Tracer=trap_trace   00015206 1a03                     MOVE.B D3,D5
Key=1708824D Tracer=trap_trace   00015208 2f7c 0002 3c17 0008      MOVE.L 0x00023c17,(A7, 0x0008) == 0x0001bbce # Mid-instruction overwrite, ensuring it remains move.l (0x2,SP), A6, move.l (SP), D6.
Key=BED6CC49 Tracer=trap_trace   00015210 e3b4                     ROXL.L D1,D4
Key=17087A51 Tracer=trap_trace   00015212 0801 0020                BTST.L 0x0020,D1
Key=BED68841 Tracer=trap_trace   00015216 5a81                     ADD.L 0x00000005,D1
Key=1708DBCA Tracer=trap_trace   00015218 76ca                     MOVE.L 0xffffffca,D3
Key=BED68BCA Tracer=trap_trace   0001521A 08c5 000e                BSET.L 0x000e,D5
Key=170843CA Tracer=trap_trace   0001521E d8c0                     ADDA.W D0,A4
Key=BED6C3CA Tracer=trap_trace   00015220 e3ac                     LSL.L D1,D4
Key=170883C2 Tracer=trap_trace   00015222 c23c 6c51                AND.B 0x51,D1
Key=BED643CE Tracer=trap_trace   00015226 d184                     ADDX.L D4,D0
Key=57088BCE Tracer=trap_trace   00015228 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=BED6FBF2 Tracer=trap_trace   0001522E 5d88                     SUBA.L 0x00000006,A0
Key=57084BFA Tracer=trap_trace   00015230 d2bc 6e1c 6e2d           ADD.L 0x6e1c6e2d,D1
Key=293AEDB0 Tracer=trap_trace   00015236 4a81                     TST.L D1
Key=57085E71 Tracer=trap_trace   00015238 4043                     NEGX.W D3
Key=293A107E Tracer=trap_trace   0001523A eb53                     ROXL.W 0x00000005,D3
Key=5708EE6F Tracer=trap_trace   0001523C 2f7c d046 d246 0010      MOVE.L 0xd046d246,(A7, 0x0010) == 0x0001bbd6 # Overwrite part of trace with add.w D6, D0, add.w D6, D1.
Key=293A7C57 Tracer=trap_trace   00015244 721a                     MOVE.L 0x0000001a,D1
Key=5C1F743A Tracer=trap_trace   00015246 08c3 005e                BSET.L 0x005e,D3
Key=293AF23A Tracer=trap_trace   0001524A d4cc                     ADDA.W A4,A2
Key=5C1F903A Tracer=trap_trace   0001524C 4a43                     TST.W D3
Key=293A523A Tracer=trap_trace   0001524E 4005                     NEGX.B D5
Key=5C1FF43A Tracer=trap_trace   00015250 4281                     CLR.L D1
Key=293AB724 Tracer=trap_trace   00015252 c74a                     EXG.L A3,A2
Key=5C1FB724 Tracer=trap_trace   00015254 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check part of trace routine.
Key=9D810185 Tracer=trap_trace   00015258 5384                     SUB.L 0x00000001,D4
Key=5C1FC19E Tracer=trap_trace   0001525A bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=9D8145E2 Tracer=trap_trace   00015260 4081                     NEGX.L D1
Key=A3E08C31 Tracer=trap_trace   00015262 4243                     CLR.W D3
Key=9D8143FC Tracer=trap_trace   00015264 db43                     ADDX.W D3,D5
Key=A3E083E8 Tracer=trap_trace   00015266 2f7c b386 b586 0014      MOVE.L 0xb386b586,(A7, 0x0014) == 0x0001bbda # Overwrite part of trace with eor.l D1, D6, eor.l D2, D6.
Key=5C1FFEF6 Tracer=trap_trace   0001526E 08c1 00ae                BSET.L 0x00ae,D1
Key=A3E0A7EE Tracer=trap_trace   00015272 d2bc 7614 7614           ADD.L 0x76147614,D1
Key=D5F3BADA Tracer=trap_trace   00015278 e648                     LSR.W 0x00000003,D0
Key=A3E063AD Tracer=trap_trace   0001527A c6bc 76f1 7702           AND.L 0x76f17702,D3
Key=D5F3CCBC Tracer=trap_trace   00015280 c388                     EXG.L D1,A0
Key=FA4A7392 Tracer=trap_trace   00015282 2f7c d246 d046 0010      MOVE.L 0xd246d046,(A7, 0x0010) == 0x0001bbd6 # Overwrite part of trace with add.w D6, D1, add.w D6, D0.
Key=D5F3DC62 Tracer=trap_trace   0001528A c388                     EXG.L D1,A0
Key=A3E0B59C Tracer=trap_trace   0001528C 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)                # Rewrite trace vector
Key=D5F31E64 Tracer=trap_trace   00015292 5901                     SUB.B 0x00000004,D1
Key=A3E0C770 Tracer=trap_trace   00015294 90af 001c                SUB.L (A7, 0x001c) == 0x0001bbe2,D0          # Check part of trace routine.
Key=D5F3A068 Tracer=trap_trace   00015298 4005                     NEGX.B D5
Key=A3E00940 Tracer=trap_trace   0001529A e335                     ROXL.B D1,D5
Key=D5F3F22B Tracer=trap_trace   0001529C 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)
Key=A3E05B32 Tracer=trap_trace   000152A2 0744                     BCHG.L D3,D4
Key=D5F30402 Tracer=trap_trace   000152A4 4e71                     NOP                                          # Probably removed when breaking copy protection. :)
Key=A3E0ED12 Tracer=trap_trace   000152A6 e90a                     LSL.B 0x00000004,D2
Key=D5F35512 Tracer=trap_trace   000152A8 c83c 7999                AND.B 0x99,D4
Key=A3E03E07 Tracer=trap_trace   000152AC d901                     ADDX.B D1,D4
Key=D5F3E72F Tracer=trap_trace   000152AE 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check part of trace routine.
Key=A3E04027 Tracer=trap_trace   000152B2 5b84                     SUB.L 0x00000005,D4
Key=D5F32927 Tracer=trap_trace   000152B4 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=A3E0922F Tracer=trap_trace   000152BA 4003                     NEGX.B D3
Key=D5F37B2B Tracer=trap_trace   000152BC 9b43                     SUBX.W D3,D5
Key=A3E0242F Tracer=trap_trace   000152BE 2f7c 0000 0010 0020      MOVE.L trap_illegal_vector,(A7, 0x0020) == 0x0001bbe6    # Ensure trap_illegal_vector keeps getting overwritten.
Key=D5F38D2F Tracer=trap_trace   000152C6 4e71                     NOP                                          # Probably removed when breaking copy protection. :) 
Key=A3E0762F Tracer=trap_trace   000152C8 e90a                     LSL.B 0x00000004,D2
Key=D5F3DF37 Tracer=trap_trace   000152CA c802                     AND.B D2,D4
Key=A3E0B833 Tracer=trap_trace   000152CC d902                     ADDX.B D2,D4
Key=D5F3613F Tracer=trap_trace   000152CE 0844 003b                BCHG.L 0x003b,D4
Key=A3E0CA3B Tracer=trap_trace   000152D2 0105                     BTST.L D0,D5
Key=D5F3B33B Tracer=trap_trace   000152D4 2f7c d246 d046 0010      MOVE.L 0xd246d046,(A7, 0x0010) == 0x0001bbd6 # Overwrite part of trace with add.w D6, D1, add.w D6, D0.
Key=A3E01C4B Tracer=trap_trace   000152DC 4e71                     NOP                                          # Probably removed when breaking copy protection. :) 
Key=D5F3C543 Tracer=trap_trace   000152DE e3ac                     LSL.L D1,D4
Key=A3E0AE7D Tracer=trap_trace   000152E0 c204                     AND.B D4,D1
Key=D5F31700 Tracer=trap_trace   000152E2 4440                     NEG.W D0
Key=A3E0F034 Tracer=trap_trace   000152E4 0081 84d2 84d2           OR.L 0x84d284d2,D1
Key=5533D80F Tracer=trap_trace   000152EA 9780                     SUBX.L D0,D3
Key=A3E08117 Tracer=trap_trace   000152EC b781                     EOR.L D3,D1
Key=3DED797E Tracer=trap_trace   000152EE d4bc 8604 8604           ADD.L 0x86048604,D2
Key=25E4A472 Tracer=trap_trace   000152F4 e648                     LSR.W 0x00000003,D0
Key=3DED0D9A Tracer=trap_trace   000152F6 c6bc 86e1 86f2           AND.L 0x86e186f2,D3
Key=25E4F28B Tracer=trap_trace   000152FC d305                     ADDX.B D5,D1
Key=3DED5BA5 Tracer=trap_trace   000152FE 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)                # Rewrite trace vector.
Key=25E400DC Tracer=trap_trace   00015304 5901                     SUB.B 0x00000004,D1
Key=3DEDE9C0 Tracer=trap_trace   00015306 90af 001c                SUB.L (A7, 0x001c) == 0x0001bbe2,D0          # Check part of trace routine.
Key=25E44EC8 Tracer=trap_trace   0001530A 5902                     SUB.B 0x00000004,D2
Key=3DED37D4 Tracer=trap_trace   0001530C 90af 001c                SUB.L (A7, 0x001c) == 0x0001bbe2,D0          # Check part of trace routine.
Key=25E49CD0 Tracer=trap_trace   00015310 4005                     NEGX.B D5
Key=3DED45F0 Tracer=trap_trace   00015312 4240                     CLR.W D0
Key=25E42AE1 Tracer=trap_trace   00015314 c74a                     EXG.L A3,A2
Key=3DED921D Tracer=trap_trace   00015316 2f7c b386 b186 0014      MOVE.L 0xb386b186,(A7, 0x0014) == 0x0001bbda # Overwrite part of trace with eor.l D1, D6, eor.l D0, D6.
Key=ADE80879 Tracer=trap_trace   0001531E 08c5 00fe                BSET.L 0x00fe,D5
Key=3DED3A79 Tracer=trap_trace   00015322 d8c0                     ADDA.W D0,A4
Key=ADE84C39 Tracer=trap_trace   00015324 e3ac                     LSL.L D1,D4
Key=3DED0225 Tracer=trap_trace   00015326 d781                     ADDX.L D1,D3
Key=ADE8C029 Tracer=trap_trace   00015328 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check part of trace routine.
Key=6964BD78 Tracer=trap_trace   0001532C 5b84                     SUB.L 0x00000005,D4
Key=ADE8CDBE Tracer=trap_trace   0001532E bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=696499BB Tracer=trap_trace   00015334 4081                     NEGX.L D1
Key=52176021 Tracer=trap_trace   00015336 4243                     CLR.W D3
Key=6964E6C4 Tracer=trap_trace   00015338 d183                     ADDX.L D3,D0
Key=F1D864FB Tracer=trap_trace   0001533A bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=696466F7 Tracer=trap_trace   00015340 5d40                     SUB.W 0x00000006,D0
Key=F1D8E8F5 Tracer=trap_trace   00015342 0c81 8dfc 8dfc           CMP.L 0x8dfc8dfc,D1
Key=6964E6C0 Tracer=trap_trace   00015348 e648                     LSR.W 0x00000003,D0
Key=F1D8BC4D Tracer=trap_trace   0001534A c680                     AND.L D0,D3
Key=69648E55 Tracer=trap_trace   0001534C 4402                     NEG.B D2
Key=F1D85851 Tracer=trap_trace   0001534E 0043 8f72                OR.W 0x8f72,D3
Key=696489BD Tracer=trap_trace   00015352 9b43                     SUBX.W D3,D5
Key=F1D8BDC8 Tracer=trap_trace   00015354 2f7c 0004 2c6f 0004      MOVE.L 0x00042c6f,(A7,  0x0004) == 0x0001bbca # Rewrite part of eor.l D6,(0x4,A6), move.l (0x2,SP),A6
Key=69644DE3 Tracer=trap_trace   0001535C 4e71                     NOP                                          # Probably removed when breaking copy protection. :) 
Key=F1D881C3 Tracer=trap_trace   0001535E e82a                     LSR.B D4,D2
Key=6964C1B7 Tracer=trap_trace   00015360 c87c 9181                AND.W 0x9181,D4
Key=F1D88DBB Tracer=trap_trace   00015364 d901                     ADDX.B D1,D4
Key=6964BC46 Tracer=trap_trace   00015366 90af 0014                SUB.L (A7, 0x0014) == 0x0001bbda,D0          # Check part of trace routine.
Key=4D5118DB Tracer=trap_trace   0001536A 5383                     SUB.L 0x00000001,D3
Key=69644EC3 Tracer=trap_trace   0001536C bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=4D513CFF Tracer=trap_trace   00015372 4081                     NEGX.L D1
Key=969B031C Tracer=trap_trace   00015374 4243                     CLR.W D3
Key=4D514309 Tracer=trap_trace   00015376 cb44                     EXG.L D5,D4
Key=969B0B11 Tracer=trap_trace   00015378 bff9 0000 0024           CMPA.L (trap_trace_vector),A7                # Check integrity of trace vector.
Key=4D51FB19 Tracer=trap_trace   0001537E 5548                     SUBA.W 0x00000002,A0
Key=969B4B11 Tracer=trap_trace   00015380 d7c9                     ADDA.L A1,A3
Key=4D511B29 Tracer=trap_trace   00015382 0885 007c                BCLR.L 0x007c,D5
Key=969BC30D Tracer=trap_trace   00015386 4ac1                     TAS.B D1
Key=4D51026D Tracer=trap_trace   00015388 2f7c b386 b186 0014      MOVE.L 0xb386b186,(A7, 0x0014) == 0x0001bbda # Overwrite part of trace with eor.l D1, D6, eor.l D0, D6.
Key=969B0095 Tracer=trap_trace   00015390 9b42                     SUBX.W D2,D5
Key=4D51C28D Tracer=trap_trace   00015392 bb43                     EOR.W D5,D3
Key=969B1C8D Tracer=trap_trace   00015394 1a3c 989c                MOVE.B 0x9c,D5
Key=4D514AB5 Tracer=trap_trace   00015398 2f7c 0002 3c17 0008      MOVE.L 0x00023c17,(A7, 0x0008) == 0x0001bbce # Mid-instruction overwrite, ensuring it remains move.l (0x2,SP), A6, move.l (SP), D6.
Key=969BF8BD Tracer=trap_trace   000153A0 e394                     ROXL.L 0x00000001,D4
Key=4D510A92 Tracer=trap_trace   000153A2 0801 00f0                BTST.L 0x00f0,D1
Key=969B5C9C Tracer=trap_trace   000153A6 0881 0034                BCLR.L 0x0034,D1
Key=4D510282 Tracer=trap_trace   000153AA 4ac3                     TAS.B D3
Key=969BC06F Tracer=trap_trace   000153AC 2f7c 4e73 0000 0024      MOVE.L 0x4e730000,(A7, 0x0024) == 0x0001bbea # Rewrite the RTE instruction.
Key=4D51438F Tracer=trap_trace   000153B4 9305                     SUBX.B D5,D1
Key=969B0231 Tracer=trap_trace   000153B6 b305                     EOR.B D1,D5
Key=4D51DC00 Tracer=trap_trace   000153B8 323c 8b43                MOVE.W 0x8b43,D1
Key=969B0315 Tracer=trap_trace   000153BC 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)                # Rewrite the trace vector.
Key=4D51431D Tracer=trap_trace   000153C2 4243                     CLR.W D3
Key=969BC311 Tracer=trap_trace   000153C4 cb44                     EXG.L D5,D4
Key=4D510B09 Tracer=trap_trace   000153C6 007c a700                ORSR.W 0xa700
Key=969B5B11 Tracer=trap_trace   000153CA 93cc                     SUBA.L A4,A1
Key=4D510B19 Tracer=trap_trace   000153CC 0883 00cc                BCLR.L 0x00cc,D3
Key=969B3B11 Tracer=trap_trace   000153D0 2f7c 0000 0010 0020      MOVE.L trap_illegal_vector,(A7, 0x0020) == 0x0001bbe6    # Ensure trap_illegal_vector keeps getting overwritten.
Key=4D514315 Tracer=trap_trace   000153D8 0841 00ba                BCHG.L 0x00ba,D1
Key=929B0315 Tracer=trap_trace   000153DC 9781                     SUBX.L D1,D3
Key=4D51C312 Tracer=trap_trace   000153DE b781                     EOR.L D3,D1
Key=6CA5942B Tracer=trap_trace   000153E0 2609                     MOVE.L A1,D3
Key=4D51B60B Tracer=trap_trace   000153E2 e6a9                     LSR.L D3,D1
Key=6CA5B06B Tracer=trap_trace   000153E4 c681                     AND.L D1,D3
Key=4D51960B Tracer=trap_trace   000153E6 4402                     NEG.B D2
Key=6CA5D41F Tracer=trap_trace   000153E8 0805 0040                BTST.L 0x0040,D5
Key=4D51B62F Tracer=trap_trace   000153EC 5e01                     ADD.B 0x00000007,D1
Key=6CA5B82C Tracer=trap_trace   000153EE 5102                     SUB.B 0x00000008,D2
Key=4D51B6FD Tracer=trap_trace   000153F0 90af 001c                SUB.L (A7, 0x001c) == 0x0001bbe2,D0          # Check part of trace routine.
Key=6CA0B62B Tracer=trap_trace   000153F4 4005                     NEGX.B D5
Key=4D51B444 Tracer=trap_trace   000153F6 2f3c 0101 4e73           MOVE.L 0x01014e73,-(A7)                      # Install trap_trace_2 at 0x1bb78.              
Key=6CA0D66D Tracer=trap_trace   000153FC 2f3c 4e92 4cdf           MOVE.L 0x4e924cdf,-(A7)
Key=4D51904D Tracer=trap_trace   00015402 2f3c fffc 6602           MOVE.L 0xfffc6602,-(A7)
Key=6CA0B635 Tracer=trap_trace   00015408 2f3c 0c68 cf47           MOVE.L 0x0c68cf47,-(A7)
Key=4D51B5FD Tracer=trap_trace   0001540E 2f3c b198 b190           MOVE.L 0xb198b190,-(A7)
Key=6CA095C5 Tracer=trap_trace   00015414 2f3c 0000 0008           MOVE.L 0x00000008,-(A7)
Key=4D51562D Tracer=trap_trace   0001541A 2f3c fffc d0b9           MOVE.L 0xfffcd0b9,-(A7)
Key=6CA08875 Tracer=trap_trace   00015420 2f3c 000c 2028           MOVE.L 0x000c2028,-(A7)
Key=4D51B67D Tracer=trap_trace   00015426 2f3c 23c8 0000           MOVE.L 0x23c80000,-(A7)
Key=6CA0B43D Tracer=trap_trace   0001542C 2f3c 206f 000a           MOVE.L 0x206f000a,-(A7)
Key=4D51963D Tracer=trap_trace   00015432 2f3c b198 b190           MOVE.L 0xb198b190,-(A7)
Key=6CA0D0E5 Tracer=trap_trace   00015438 2f3c 0000 0008           MOVE.L 0x00000008,-(A7)
Key=4D51B6CD Tracer=trap_trace   0001543E 2f3c fffc d0b9           MOVE.L 0xfffcd0b9,-(A7)
Key=6CA0B435 Tracer=trap_trace   00015444 2f3c 000c 2028           MOVE.L 0x000c2028,-(A7)
Key=4D51D67D Tracer=trap_trace   0001544A 2f3c 2079 0000           MOVE.L 0x20790000,-(A7)
Key=6CA0987D Tracer=trap_trace   00015450 2f3c 027c ffff           MOVE.L 0x027cffff,-(A7)
Key=4D51563D Tracer=trap_trace   00015456 2f3c 48e7 8080           MOVE.L 0x48e78080,-(A7)
Key=6CA0B43D Tracer=trap_trace   0001545C 2f3c 4e71 4e71           MOVE.L 0x4e714e71,-(A7)
Key=4D51B5FD Tracer=trap_trace   00015462 2f3c 0004 4e71           MOVE.L 0x00044e71,-(A7)
Key=6CA051FD Tracer=trap_trace   00015468 2f3c bd96 bdae           MOVE.L 0xbd96bdae,-(A7)
Key=4D519025 Tracer=trap_trace   0001546E 23fc 0000 0010 0000 000c MOVE.L trap_illegal_vector,(cp_addr)         # Start cp_addr at trap_illegal_vector, to continue trashing it.
Key=6CA0B64D Tracer=trap_trace   00015478 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)                # Install new handler. On first pass, it trashes trap_trace_vector and the next.
             Tracer=trap_trace_2 0001547E 06b9 0000 000c 0000 0024 ADD.L 0x0000000c,(trap_trace_vector)         # From now on, skip the re-encode code used for the transition from trap_trace.
             Tracer=trap_trace_2 00015488 3c2f 00b8                MOVE.W (A7, 0x00b8) == 0x0001bc2e,D6         # Check saved illegal instruction SR
             Tracer=trap_trace_2 0001548C 0046 f8ff                OR.W 0xf8ff,D6
             Tracer=trap_trace_2 00015490 3f46 0012                MOVE.W D6,(A7, 0x0012) == 0x0001bb88         # Check tail of "andi #0xFFFF,SR"
             Tracer=trap_trace_2 00015494 202f 0078                MOVE.L (A7, 0x0078) == 0x0001bbee,D0         # Check saved A7/SP.
             Tracer=trap_trace_2 00015498 222f 007c                MOVE.L (A7, 0x007c) == 0x0001bbf2,D1         # Check saved A6.
             Tracer=trap_trace_2 0001549C 203c 78d4 c924           MOVE.L 0x78d4c924,D0
             Tracer=trap_trace_2 000154A2 7200                     MOVE.L 0x00000000,D1
             Tracer=trap_trace_2 000154A4 243c 8604 86f8           MOVE.L 0x860486f8,D2
             Tracer=trap_trace_2 000154AA 6000 03e0                BT .W 0x03e0 == 0x0001588c (T)               # Big jump here. Probably crack skipping actual checks?
             Tracer=trap_trace_2 0001588C 4def 0078                LEA.L (A7, 0x0078) == 0x0001bbee,A6          # Check saved A7/SP.
             Tracer=trap_trace_2 00015890 48e7 30c0                MOVEM.L D2-D3/A0-A1,-(A7)                    # Looks like a pure register save, not creating data accessed elsewhere.
             Tracer=trap_trace_2 00015894 7603                     MOVE.L 0x00000003,D3
             Tracer=trap_trace_2 00015896 2d41 0004                MOVE.L D1,(A6, 0x0004) == 0x0001bbf2         # Overwrite saved A6.
             Tracer=trap_trace_2 0001589A 4aae 000c                TST.L (A6, 0x000c) == 0x0001bbfa             # Check saved A4.
             Tracer=trap_trace_2 0001589E 6604                     BNE.B 0x00000004 == 0x000158a4 (T)           # Another jump ahead.
             Tracer=trap_trace_2 000158A4 e54b                     LSL.W 0x00000002,D3
             Tracer=trap_trace_2 000158A6 2436 3000                MOVE.L (A6, D3.W*1, 0x00) == 0x0001bbfa,D2   # Check saved A4.
             Tracer=trap_trace_2 000158AA e95a                     ROL.W 0x00000004,D2
             Tracer=trap_trace_2 000158AC 0202 000f                AND.B 0x0f,D2
             Tracer=trap_trace_2 000158B0 673c                     BEQ.B 0x0000003c == 0x000158ee (F)
             Tracer=trap_trace_2 000158B2 0476 1000 3002           SUB.W 0x1000,(A6, D3.W*1, 0x02) == 0x0001bbfc # Subtract 0x1000 from saved A4(w).
             Tracer=trap_trace_2 000158B8 2636 3000                MOVE.L (A6, D3.W*1, 0x00) == 0x0001bbfa,D3   # Check saved A4.
             Tracer=trap_trace_2 000158BC e15b                     ROL.W 0x00000008,D3
             Tracer=trap_trace_2 000158BE 3203                     MOVE.W D3,D1
             Tracer=trap_trace_2 000158C0 0241 0007                AND.W 0x0007,D1
             Tracer=trap_trace_2 000158C4 e549                     LSL.W 0x00000002,D1
             Tracer=trap_trace_2 000158C6 2076 1020                MOVEA.L (A6, D1.W*1, 0x20) == 0x0001bc1e,A0  # Check saved D3.
             Tracer=trap_trace_2 000158CA e95b                     ROL.W 0x00000004,D3
             Tracer=trap_trace_2 000158CC 3203                     MOVE.W D3,D1
             Tracer=trap_trace_2 000158CE 0241 0007                AND.W 0x0007,D1
             Tracer=trap_trace_2 000158D2 e549                     LSL.W 0x00000002,D1
             Tracer=trap_trace_2 000158D4 2236 1000                MOVE.L (A6, D1.W*1, 0x00) == 0x0001bc06,D1
             Tracer=trap_trace_2 000158D8 2258                     MOVEA.L (A0)+,A1
             Tracer=trap_trace_2 000158DA d1b1 1800                ADD.L D0,(A1, D1.L*1, 0x00) == 0x0000dcc8    # Patch: Adds 0x78D4C924 to 0x00dcc8
             Tracer=trap_trace_2 000158DE 5302                     SUB.B 0x00000001,D2
             Tracer=trap_trace_2 000158E0 66f6                     BNE.B 0xfffffff6 == 0x000158d8 (T)
             Tracer=trap_trace_2 000158D8 2258                     MOVEA.L (A0)+,A1
             Tracer=trap_trace_2 000158DA d1b1 1800                ADD.L D0,(A1, D1.L*1, 0x00) == 0x00011006    # Patch: Adds 0x78D4C924 to 0x011006
             Tracer=trap_trace_2 000158DE 5302                     SUB.B 0x00000001,D2
             Tracer=trap_trace_2 000158E0 66f6                     BNE.B 0xfffffff6 == 0x000158d8 (T)           # Jump taken. We actually loop a bit here!
             Tracer=trap_trace_2 000158D8 2258                     MOVEA.L (A0)+,A1                             # Reads from A0 = 0x000039C6
             Tracer=trap_trace_2 000158DA d1b1 1800                ADD.L D0,(A1, D1.L*1, 0x00) == 0x000025d6    # Patch: Adds 0x78D4C924 to 0x0025d6
             Tracer=trap_trace_2 000158DE 5302                     SUB.B 0x00000001,D2
             Tracer=trap_trace_2 000158E0 66f6                     BNE.B 0xfffffff6 == 0x000158d8 (F)           # Jump not taken.
             Tracer=trap_trace_2 000158E2 e95b                     ROL.W 0x00000004,D3
             Tracer=trap_trace_2 000158E4 0243 000f                AND.W 0x000f,D3
             Tracer=trap_trace_2 000158E8 b63c 0008                CMP.B 0x08,D3
             Tracer=trap_trace_2 000158EC 6db6                     BLT.B 0xffffffb6 == 0x000158a4 (T)           # Jump taken.
             Tracer=trap_trace_2 000158A4 e54b                     LSL.W 0x00000002,D3
             Tracer=trap_trace_2 000158A6 2436 3000                MOVE.L (A6, D3.W*1, 0x00) == 0x0001bbee,D2   # Reading saved SP/A7
             Tracer=trap_trace_2 000158AA e95a                     ROL.W 0x00000004,D2
             Tracer=trap_trace_2 000158AC 0202 000f                AND.B 0x0f,D2
             Tracer=trap_trace_2 000158B0 673c                     BEQ.B 0x0000003c == 0x000158ee (T)           # Jump taken.
             Tracer=trap_trace_2 000158EE 4cdf 030c                MOVEM.L (A7)+,D2-D3/A0-A1                    # Restore saved regs.
             Tracer=trap_trace_2 000158F2 7000                     MOVE.L 0x00000000,D0
             Tracer=trap_trace_2 000158F4 7200                     MOVE.L 0x00000000,D1
             Tracer=trap_trace_2 000158F6 4dfa 0010                LEA.L (PC,(0x0010)) == 0x00015908,A6
             Tracer=trap_trace_2 000158FA 2c2e fffc                MOVE.L (A6, -0x0004) == 0x00015904,D6        # Check the encrypted instuction stream.
             Tracer=trap_trace_2 000158FE dcb9 0000 0008           ADD.L (cp_key),D6
             Tracer=trap_trace_2 00015904 007c a71f                ORSR.W 0xa71f                                # Ensure trace mode is still on!
             Tracer=trap_trace_2 00015908 06b9 0000 0044 0000 0024 ADD.L 0x00000044,(trap_trace_vector)         # Switch back to trap_trace (change vector from 0x1bb82 to 0x1bbc6)
Key=B293A700 Tracer=trap_trace   00015912 dffc 0000 0050           ADDA.L 0x00000050,A7                         # Pop trap_trace_2 off the stack.
Key=B293A700 Tracer=trap_trace   00015918 2f3c 7fff 4e73           MOVE.L 0x7fff4e73,-(A7)                      # Load trap_trace_3 onto the stack.
Key=B293A700 Tracer=trap_trace   0001591E 2f3c 584f 0257           MOVE.L 0x584f0257,-(A7)
Key=B293A700 Tracer=trap_trace   00015924 2f3c 4cdf 7fff           MOVE.L 0x4cdf7fff,-(A7)
Key=B293A700 Tracer=trap_trace   0001592A 2f3c 4fee 007c           MOVE.L 0x4fee007c,-(A7)
Key=B293A700 Tracer=trap_trace   00015930 2f3c 2d4c 00be           MOVE.L 0x2d4c00be,-(A7)
Key=B293A700 Tracer=trap_trace   00015936 2f3c 5980 66fa           MOVE.L 0x598066fa,-(A7)
Key=B293A700 Tracer=trap_trace   0001593C 2f3c 6706 4299           MOVE.L 0x67064299,-(A7)
Key=B293A700 Tracer=trap_trace   00015942 2f3c 66fa 200b           MOVE.L 0x66fa200b,-(A7)
Key=B293A700 Tracer=trap_trace   00015948 2f3c 22d8 5980           MOVE.L 0x22d85980,-(A7)
Key=B293A700 Tracer=trap_trace   0001594E 2f3c 66fa 6006           MOVE.L 0x66fa6006,-(A7)
Key=B293A700 Tracer=trap_trace   00015954 2f3c 2320 5980           MOVE.L 0x23205980,-(A7)
Key=B293A700 Tracer=trap_trace   0001595A 2f3c d1c0 d3c0           MOVE.L 0xd1c0d3c0,-(A7)
Key=B293A708 Tracer=trap_trace   00015960 2f3c b3c8 6f0c           MOVE.L 0xb3c86f0c,-(A7)
Key=B293A708 Tracer=trap_trace   00015966 2f3c 200a 6720           MOVE.L 0x200a6720,-(A7)
Key=B293A700 Tracer=trap_trace   0001596C 2f3c 4e7b 0002           MOVE.L 0x4e7b0002,-(A7)
Key=B293A700 Tracer=trap_trace   00015972 2f3c 202e 00b8           MOVE.L 0x202e00b8,-(A7)
Key=B293A700 Tracer=trap_trace   00015978 2f3c 4dfa ffee           MOVE.L 0x4dfaffee,-(A7)
Key=B293A700 Tracer=trap_trace   0001597E 2f3c 0000 0010           MOVE.L 0x00000010,-(A7)
Key=B293A700 Tracer=trap_trace   00015984 2f3c 0014 23df           MOVE.L 0x001423df,-(A7)
Key=B293A700 Tracer=trap_trace   0001598A 2f3c 0004 487a           MOVE.L 0x0004487a,-(A7)
Key=B293A700 Tracer=trap_trace   00015990 2f3c bd96 bdae           MOVE.L 0xbd96bdae,-(A7)
Key=B293A708 Tracer=trap_trace   00015996 41fa 0024                LEA.L (PC,0x0024) == 0x000159bc,A0           # Set up registers before switching to trap_trace_3.
Key=B293A708 Tracer=trap_trace   0001599A 2248                     MOVEA.L A0,A1
Key=B293A708 Tracer=trap_trace   0001599C 93fc 0000 0000           SUBA.L 0x00000000,A1                         # Smells like a crack patch.
Key=B293A708 Tracer=trap_trace   000159A2 247c 0000 0000           MOVEA.L 0x00000000,A2
Key=B293A708 Tracer=trap_trace   000159A8 267c 0000 0000           MOVEA.L 0x00000000,A3
Key=B293A708 Tracer=trap_trace   000159AE 2849                     MOVEA.L A1,A4
Key=B293A708 Tracer=trap_trace   000159B0 d9fc 0000 0000           ADDA.L 0x00000000,A4
Key=B293A708 Tracer=trap_trace   000159B6 23cf 0000 0024           MOVE.L A7,(trap_trace_vector)                # Switch to trap_trace_3.
             Tracer=trap_trace_3 000159BC 4e71                     NOP                                          # The final RTE from trap_trace_3 lands here.
                                 000159be 4e73                     RTE                                          # Trace is disabled by here. Return from the F-line trap.
