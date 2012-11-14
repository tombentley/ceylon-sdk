doc "Provides support for formatting numbers. 
     
     ## Terminology
     
     * A *number system* is a Ceylon type which repesents a number, including
       `Integer`, `Float`, `Whole` and `Decimal`.
     * A *number* is an instance of a *number system* type, such as the `Integer` 1,
       for the `Float` 3.4. This includes special values such as the 
       `undefined` `Float`.  
     * A *numeral system* is a way of converting a *number* to a sequence of 
       `Characters`. Concretely it can be represented as a `Formatter`.
     * A *positional numeral system* (or just *positional system*) is a *numeral system*
       where numbers are represented as a 
       sequence of distinct *numerals* and the position of a numeral in the 
       formatted number signifies an order of magnitude. The Arabic numeral 
       system is an example of a positional numeral system which uses a base of 
       ten and the numerals 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9. Many cultures used 
       the same decimal system as the Arabic system, but using a different set 
       of numerals. 
       Roman numerals are an example of a non-positional system.
     * A *digit* is a integer between zero and one-less-than the *base* of 
       a positional numeral system 
     * A *numeral* is the `Character` used to represent a particular *digit*. 
       For example nine has the numeral 9 in the Arabic numeral 
       system. 
     * A *radix point* is a separator used in a positional numeral system 
       to distinguish the whole part of a number from its fractional part. 
     "
// see(Formatter)
shared package ceylon.format.number;
