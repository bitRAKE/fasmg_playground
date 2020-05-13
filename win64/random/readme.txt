TODO:

Make macro wrappers to convert PRNG's into other types. Each PRNG create different size data each invocation: the macros will use this size specification along with PRNG context to generate code.

Some types to support:
	double, float
	dword, qword, byte array

Could also create a macro for PRNG initialization of PRNG context, but this will require specifying size of context in multiple parts: random data and context data.
