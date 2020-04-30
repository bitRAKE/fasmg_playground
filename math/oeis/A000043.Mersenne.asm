include 'helpers.asm'
; Mersenne number tools:


macro Lucas_Lehmer_Test P*
	; allow special case for two, otherwise P must be odd
	assert P and 1 | P = 2

	local S,M
	M := (1 shl P) - 1
	S = 4 ; A003010, A018844

	repeat P-2
		S = S * S - 2
		S = (S shr P) + (S and M)
		if S > M
			S = S - M	; S = (S and M) + 1
		end if
	end repeat

	display '2^'
	DisplayNumber P
	display '-1 is '

	if S = M | P = 2
		display 'prime'
	else
		display 'composite'
	end if

	display '.',13,10
end macro

; A000043
iterate p, 2,3,5,7,13,17,19,31,61,89,107,127,521,607,1279,2203,2281,3217,4253,4423,9689,9941,11213,19937,21701,23209,44497,86243,110503,132049,216091,756839,859433,1257787,1398269,2976221,3021377,6972593,13466917,20996011,24036583,25964951,30402457,32582657,37156667,42643801,43112609,57885161,74207281,77232917,82589933
;	indx 23
	Lucas_Lehmer_Test p
	if % > 21
		display 13,10,'Verified '
		DisplayNumber %
		display ' of '
		DisplayNumber %%
		display ' known Mersenne primes.'
		break
	end if
end iterate
;	flat assembler  version g.igd4j
;	2^11213-1 is prime.
;	1 pass, 62.4 seconds, 0 bytes.

;	flat assembler  version g.igd4j
;	2^19937-1 is prime.
;	1 pass, 319.3 seconds, 0 bytes.

;	flat assembler  version g.igd4j
;	Verified 22 of 51 known Mersenne primes.
;	1 pass, 117.9 seconds, 0 bytes.





macro VerifyFactors N*,FF&
	local temp
	temp = 1
	iterate F,FF
		temp = temp * F
	end iterate
	assert temp = ((1 shl N) - 1)
	repeat 1,d:N
		display 'M',`d,' factors confirmed.',13,10
	end repeat
end macro


VerifyFactors 113,\
3391,23279,65993,1868569,1066818132868207

VerifyFactors 397,\
2383,6353,50023,53993,202471,5877983,814132872808522587940886856743,\
1234904213576000272542841146073,6597485910270326519900042655193

VerifyFactors 431,\
863,3449,36238481,76859369,558062249,4642152737,142850312799017452169,\
1807482391092819529831423005040763105191863029850140579776353298087457

VerifyFactors 701,\
796337,2983457,28812503,1073825104511,9983923992673,15865578195367,40686928318417,\
22206681732300686559830164931393965396408838897922182477635701769356115170703313643368016416398879761353787885396721401460120094241214356289



; is F a factor of 2^N-1
macro MFactorQ N*,F*
	local B,T,D
	D = 1 + bsr F
	B = 1
	T = 1
	; if N > F then reduce, N = N mod F
	while B < N & T
		if (B+D) <= N
			B = B + D
			T = ((T+1) shl D)-1
			T = T mod F
		else
			B = B + 1
			T = T + T + 1
			if T >= F
				T = T - F
			end if
		end if
	end while
	repeat 1,t:T,b:B,f:F
		if T = 0
			display `f,' divides 2^',`b,'-1.',13,10
		else
			display '2^',`b,'-1 mod ',`f,' = ',`t,13,10
		end if
	end repeat
end macro

; some test cases, 2 minutes each
;MFactorQ 1001664179, 1878753956886303627167
;MFactorQ 1001686351, 1536815651565249722663
;MFactorQ 1010518297, 612488459774717575447
;MFactorQ 1010528143, 1126257609175874438833
;MFactorQ 1010529409, 604303036158626236967
;MFactorQ 1010530043, 1137802782160888887647
;MFactorQ 1010531147, 824789749922393096713
;MFactorQ 1010534743, 1104426736343997175673
;MFactorQ 1010539679, 1074707660107671497471
;MFactorQ 1010543881, 1029845494969509789167
;MFactorQ 1010546857, 678409215294807266519
MFactorQ 1010555309, 1178013656502956313881


if 0
MFactorQ 3930621659, 7861243319
MFactorQ 3930621659, 125779893089
MFactorQ 3930621659, 1257798930881
MFactorQ 3930621659, 62331798268423
MFactorQ 3930621659, 98234096501729
MFactorQ 3930621659, 120284884008719
MFactorQ 3930621659, 646971363254017481
MFactorQ 3930621659, 5009336781794942473
MFactorQ 3930621659, 48911599538580170479
MFactorQ 3930621659, 9496577237212398703537
MFactorQ 3930621659, 6134708376727152865752497
end if
