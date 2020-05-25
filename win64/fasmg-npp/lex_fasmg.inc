; interfaces that need to be implemented elsewhere ...

; LexAccessor.inc ; interface between Scintilla and lexers.
;	pAccess	*IDocument

struc LexicalClass
label .:32
namespace .
	value		rd 2
	name		rq 1
	tags		rq 1
	description	rq 1
end namespace
end struc

virtual at 0
LexicalClass LexicalClass
end virtual

;-------------------------------------------------------------------------------
;									       ;
; This lexer follows the syntax highlighting of FASMW: number, string, symbol, ;
; and comment; get colors -- everthing else is the default color.              ;
;									       ;
;-------------------------------------------------------------------------------

LEXERS equ LEXERS,fasmg
LexerCount = LexerCount + 1

fasmg::
namespace fasmg
Name	= "fasmg"
Status	= "fasmg assembly engine"


if 0
.WordListDesc WordListDesc \
	"symbol",\		; $ $@ % %% ; evaluates to a value
	"operator",\		; ` # = =: := + - shr shl bswap bsr bsf ; needs parameters
	"data directives",\	; db emit dbx
	"control directives",\	; match outscope if end else postpone
	"instructions",\	; iterate irpv esc struc macro ; sometimes called "command" in the manual
	"calm instructions"	; local initsym stringify assemble



.lexicalClasses LexicalClasses \
	0, "SCE_H_DEFAULT",	"default",		"Default",\
	1, "SCE_H_NUMBER",	"literal numeric",	"Numbers",\
	2, "SCE_H_STRING",	"literal string",	"Quoted strings",\
	3, "SCE_H_SYMBOL",	"symbol",		"Symbols",\
	4, "SCE_H_COMMENT",	"comment",		"Comments"
end if



; create 31 word lists, null terminated
; create LexicalClasses


	lexClasses	rq 1		; pointer to array of classes
	nClasses	rd 2		; does this NEED to be qword?
;	props		PropSetSimple	; Get/Set key/value pairs

	numWordLists = 31
	keyWordLists	rq 32
ptr2null rq 1
; setup word lists


Version:; int () const;
	push 2 ; lvRelease4, interface version
	pop rax
	retn


Release:; void ();
	; release buffers
	retn


PropertyNames:; const char * ();
	lea rax,[ptr2null]
	retn


PropertyType:; int (const char *name);
	mov eax,SC_TYPE_BOOLEAN
	retn


DescribeProperty:; const char * (const char *name);
	lea rax,[ptr2null]
	retn


PropertySet:; Sci_Position (const char *key, const char *val);
	; if the value changed
	; set to new value
	retn


DescribeWordListSets:; const char * ();
	lea rax,[ptr2null]
	retn


WordListSet:; Sci_Position (int n, const char *wl);
	or eax,-1
	cmp ecx,numWordLists
	jnc .fail
	mov rcx,[rcx*8 + keyWordLists]

	; add word to word list, return zero if word present in list

	xor eax,eax
.fail:	retn


Lex:; void (Sci_PositionU startPos, Sci_Position lengthDoc, int initStyle, IDocument *pAccess);
;	Accessor astyler(pAccess, &props);
;	Lex
;	astyler.Flush();
	retn


Fold:; void (Sci_PositionU startPos, Sci_Position lengthDoc, int initStyle, IDocument *pAccess);

; look at ruby lexer which folds based on indentation

	retn


PrivateCall:; void * (int operation, void *pointer);
	xor eax,eax
	retn


LineEndTypesSupported:; int ();
	xor eax,eax ; SC_LINE_END_TYPE_DEFAULT
	retn


AllocateSubStyles:; int (int styleBase, int numberStyles);
	or eax,-1
	retn


SubStylesStart:; int (int styleBase);
	or eax,-1
	retn


SubStylesLength:; int (int styleBase);
	xor eax,eax
	retn


StyleFromSubStyle:; int (int subStyle);
	xchg eax,ecx
	retn


PrimaryStyleFromStyle:; int (int style);
	xchg eax,ecx
	retn


FreeSubStyles:; void ();
	retn


SetIdentifiers:; void (int style, const char *identifiers);
	retn


DistanceToSecondaryStyles:; int ();
	xor eax,eax
	retn


GetSubStyleBases:; const char * ();
	lea rax,[ptr2null]
	retn


NamedStyles:; int ();
	mov eax,[nClasses]
	retn


NameOfStyle:; const char * (int style);
	lea rax,[ptr2null]
	cmp [nClasses],ecx
	jc .fail
	imul eax,ecx,sizeof LexicalClass
	mov rax,[lexClasses + rax + LexicalClass.name]
.fail:	retn


TagsOfStyle:; const char * (int style);
	lea rax,[ptr2null]
	cmp [nClasses],ecx
	jc .fail
	imul eax,ecx,sizeof LexicalClass
	mov rax,[lexClasses + rax + LexicalClass.tags]
.fail:	retn


DescriptionOfStyle:; const char * (int style);
	lea rax,[ptr2null]
	cmp [nClasses],ecx
	jc .fail
	imul eax,ecx,sizeof LexicalClass
	mov rax,[lexClasses + rax + LexicalClass.description]
.fail:	retn


end namespace ; fasmg