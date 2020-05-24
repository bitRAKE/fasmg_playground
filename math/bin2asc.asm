; by THEWizardGenius, El Tangas, Terje Mathisen
;https://board.flatassembler.net/topic.php?p=30196#30196
magic1	equ	0a7c5ac47h
magic2	equ	068db8badh

bin2ascii_test:
	mov	eax,magic1
	mul	esi
	shr	esi,3
	add	esi,eax
	adc	edx,0
	shr	esi,20			;separate remainder
	mov	ebx,edx
	shl	ebx,12
	and	edx,0FFFF0000h		;mask quotient
	and	ebx,0FFFFFFFh		;remove quotient nibble from remainder.
	mov	eax,magic2
	mul	edx
	add	esi,ebx
	mov	eax,edx
	shr	edx,28
	and	eax,0FFFFFFFh
	lea	esi,[4*esi+esi+5]	;multiply by 5 and round up
	add	dl,'0'
	mov	ebx,esi
	and	esi,07FFFFFFh
	shr	ebx,27
	mov	[edi],dl
	add	bl,'0'
	lea	eax,[4*eax+eax+5]	;mul by 5 and round up
	mov	[edi+5],bl
	lea	esi,[4*esi+esi]
	mov	edx,eax
	and	eax,07FFFFFFh
	shr	edx,27
	lea	ebx,[esi+0c0000000h]
	shr	ebx,26
	and	esi,03FFFFFFh
	add	dl,'0'
	lea	eax,[4*eax+eax]
	mov	[edi+1],dl
	lea	esi,[4*esi+esi]
	mov	[edi+6],bl
	lea	edx,[eax+0c0000000h]
	shr	edx,26
	and	eax,03FFFFFFh
	lea	ebx,[esi+60000000h]
	and	esi,01FFFFFFh
	shr	ebx,25
	lea	eax,[4*eax+eax]
	mov	[edi+2],dl
	lea	esi,[4*esi+esi]
	mov	[edi+7],bl
	lea	edx,[eax+60000000h]
	shr	edx,25
	and	eax,01FFFFFFh
	lea	ebx,[esi+30000000h]
	mov	[edi+3],dl
	shr	ebx,24
	and	esi,00FFFFFFh
	mov	[edi+8],bl
	lea	edx,[4*eax+eax+30000000h]
	shr	edx,24
	lea	ebx,[4*esi+esi+18000000h]
	shr	ebx,23
	mov	[edi+4],dl
	mov	[edi+9],bl
	ret
