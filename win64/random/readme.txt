TODO:

Make macro wrappers to convert PRNG's into other types. Each PRNG create different size data each invocation: the macros will use this size specification along with PRNG context to generate code.

Some types to support:
	double, float
	dword, qword, byte array

Could also create a macro for PRNG initialization of PRNG context, but this will require specifying size of context in multiple parts: random data and context data.


PRNG			period

pmc_prng		2^31
taus88			2^88
taus113			2^113
mwc256			2^8222
mt19937			2^19937
kiss
cmwc4096		2^131086
superkiss		2^1337279 * 54767
pcg
ca_prng			unknown




Question and Answer:

Q. Which PRNG should I use?
A. Dependant on use. That is why so many exist.

Q. Why use such exotic PRNG's?
A. Some problems spaces would colapse to a smaller sub-region when the input is of a low dimension. Examples, include monte-carlo methods.

Q. Why aren't my random numbers distributed evenly?
A. Because it's random. You want to smooth the number within your domain (a relaxation),
or look at https://wikipedia.org/wiki/Low-discrepancy_sequence



REFERENCES:

Compendium of PRNG variations
https://github.com/eddelbuettel/dieharder/tree/master/libdieharder
https://arvid.io/2018/07/02/better-cxx-prng/

Using randomness to solve problems:
https://arxiv.org/abs/2007.10254
