
; After lexer functions have been defined this just creates the interface needed by Scintilla.
; Must include this prior to definition of any lexer functions.


; initialize some globals
LEXERS equ
LexerCount = 0
ILexer4_VTable.bytes := 8*25

struc ILexer4
namespace .
VTable:
dq Version			; int () const;
dq Release			; void ();
dq PropertyNames		; const char * ();
dq PropertyType			; int (const char *name);
dq DescribeProperty		; const char * (const char *name);
dq PropertySet			; Sci_Position (const char *key, const char *val);
dq DescribeWordListSets		; const char * ();
dq WordListSet			; Sci_Position (int n, const char *wl);
dq Lex				; void (Sci_PositionU startPos, Sci_Position lengthDoc, int initStyle, IDocument *pAccess);
dq Fold				; void (Sci_PositionU startPos, Sci_Position lengthDoc, int initStyle, IDocument *pAccess);
dq PrivateCall			; void * (int operation, void *pointer);
dq LineEndTypesSupported	; int ();
dq AllocateSubStyles		; int (int styleBase, int numberStyles);
dq SubStylesStart		; int (int styleBase);
dq SubStylesLength		; int (int styleBase);
dq StyleFromSubStyle		; int (int subStyle);
dq PrimaryStyleFromStyle	; int (int style);
dq FreeSubStyles		; void ();
dq SetIdentifiers		; void (int style, const char *identifiers);
dq DistanceToSecondaryStyles	; int ();
dq GetSubStyleBases		; const char * ();
dq NamedStyles			; int ();
dq NameOfStyle			; const char * (int style);
dq TagsOfStyle			; const char * (int style);
dq DescriptionOfStyle		; const char * (int style);
end namespace
end struc