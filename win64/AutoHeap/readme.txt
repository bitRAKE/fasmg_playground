Brief description of interfaces:


AutoHeap__Create_Basic
	RCX: bytes to reserve
	Returns same as AutoHeap__Create.

	Reserves read/write address range.


AutoHeap__Create
	RCX: bytes to reserve
	RDX: bytes of reserved to commit
	R8: function to initialize memory
	R9: desired protection for memory (see API docs)
	[RSP+32]: desired base address for memory (or zero for any)
	Returns CF=1 and [RSP+32]==0 if an error. Otherwise stack
	contains updated valid parameters of heap created.


(initialization function):
	RAX: start address
	RDX: bytes to initialize
	Called whenever new memory is committed or during reset. This
	function must not read beyond memory range.


AutoHeap__Destroy
	RCX: an address within the Heap to destroy
	Returns nothing.


AutoHeaps__Reset
	Doesn't take or return anything.
	Reduce and re-initialize heaps created. Note: doesn't clear
	heap to zero automatically - must pass function that clears
	during heap creation.










Use case:

Algorithms needing several growing buffers. Reserve available address ranges in proportion to needs of the algorithm to provide maximum utility of memory.

The failure process for an auto heap:
	- no failure
	- multiple EXCEPTION_GUARD_PAGE, okay
	- last EXCEPTION_GUARD_PAGE, early warning
	- EXCEPTION_ACCESS_VIOLATION, no recovery (other handler)

Why not just catch EXCEPTION_ACCESS_VIOLATION exceptions?

Complex algorithms can be problematic. So, the added layers of scrutiny are desirable. Memory granularity makes sparse random access overly wasteful. Other code is running in our process and protections prevent unintended access.






Additional Features:

	An initialization function can insure various known states as buffer grows.
	Buffer group can be reset to initial commit state.



Coding Methodology:

All of this code falls within the category of initialization code, and as such is coded to be small. Initializing heaps to a particular memory set can be expensive. Ideally, it would be best set initial state on use - to minimize cache polution.



To Do:

Generalize to any combination of heaps and stacks - with guard pages on both ends of address range possible.

Make the handler thread-safe. VEH's are process wide, but two threads could hit the same guard page. Could lock on guard page address, but second thread wouldn't be able to verify exception is "good" -- okaying anything in reserve range isn't very good protection. If guard page address is locked, second thread could spin until first thread updates and then verify address in commit range (below guard page), then return.