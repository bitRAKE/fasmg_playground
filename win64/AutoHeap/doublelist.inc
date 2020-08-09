struc DOUBLELIST p=?,n=?
label .:16
namespace .
	prev dq p
	next dq n
end namespace
end struc

virtual at 0
DOUBLELIST DOUBLELIST
end virtual

macro DOUBLELIST__REMOVE node*,reg0=RAX,reg1=RDX
	mov reg0,[node + DOUBLELIST.next]
	mov reg1,[node + DOUBLELIST.prev]
	mov [reg1 + DOUBLELIST.next],reg0
	mov [reg0 + DOUBLELIST.prev],reg1
end macro

macro DOUBLELIST__REINSERT node*,reg0=RAX,reg1=RDX
	mov reg0,[node + DOUBLELIST.next]
	mov reg1,[node + DOUBLELIST.prev]
	mov [reg0 + DOUBLELIST.prev],node
	mov [reg1 + DOUBLELIST.next],node
end macro

macro DOUBLELIST__INSERT parent*,child*,reg0=RAX
	mov reg0,[parent + DOUBLELIST.next]
	mov [parent + DOUBLELIST.next],child
	mov [child + DOUBLELIST.prev],parent
	mov [child + DOUBLELIST.next],reg0
	mov [reg0 + DOUBLELIST.prev],child
end macro