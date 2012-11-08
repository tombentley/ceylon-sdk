
doc "The symbols needed to construct a number in position-value format."
shared class PositionValueSymbols(positiveSignPrefix = "",
                                    negativeSignPrefix = "-",
                                    positiveSignSuffix = "",
                                    negativeSignSuffix = "",
                                    digitGrouping = noDigitGrouping,
                                    point = ".",
                                    digits = {`0`, `1`, `2`, `3`, `4`, 
                                                 `5`, `6`, `7`, `8`, `9`}) {
    shared String positiveSignPrefix;
    shared String negativeSignPrefix;
    shared String positiveSignSuffix;
    shared String negativeSignSuffix;
    shared Callable<String, Integer> digitGrouping;
    doc "The symbol used to indicate the radix point"
    shared String point;
    doc "The digits"
    shared Sequence<Character> digits;
    shared Character digit(Integer digit) {
        value r = digits[digit];
        assert(exists r);
        return r;
    }
    doc "The radix"
    shared Integer radix {
        return digits.size;
    }
}


doc "The symbols needed to construct a number in exponential format"
// We use Unicode "REPLACEMENT CHARACTER" which seems to be the 
// "standard"
// see http://www.unicode.org/review/resolved-pri.html#pri74
shared class ExponentialSymbols(mantissaSymbols = PositionValueSymbols(), 
        exponentSymbol = "e", exponentSymbols = PositionValueSymbols(),
        undefined = "�", infinity = "∞") {
    
    doc "The symbols used to format the mantissa"
    shared PositionValueSymbols mantissaSymbols;
    
    doc "The symbol which separates the mantissa from the exponent"
    shared String exponentSymbol;
    
    doc "The symbols used to format the exponent. The `point` isn't be used."
    shared PositionValueSymbols exponentSymbols;
    
    doc "The symbol to output when the value is undefined."
    shared String undefined;
    
    doc "The symbol to output when the value is infinity."
    shared String infinity;
}

//TODO This often comes with a rounding and implies a scaling
doc "A prefix to some unit of a quantity. When formatted, the prefix and unit 
     usually follow the quantity.
     
     For example in the length 
     \"10.5cm\", the quantity is *10.5*, the prefix is *c* (centi) and the 
     unit is *m* (metres)."
class Prefix(base, power, symbol, name) satisfies Comparable<Prefix> {
    shared Integer base;
    shared Integer power;
    shared String symbol;
    shared String name;
    shared actual Comparison compare(Prefix other) {
        value cmp = base.compare(other.base);
        if (cmp != equal) {
            return cmp;
        }
        return power.compare(other.power);
    }
}

doc "The prefixes used to form decimal multiples and submultiples of SI units"
see(binaryPrefixes)
Prefix[] decimalPrefixes = sort( 
    Prefix(10,   2, "h", "hecto"),
    Prefix(10,   3, "k", "kilo"),
    Prefix(10,   6, "M", "mega"),
    Prefix(10,   9, "G", "giga"),
    Prefix(10,  12, "T", "tera"),
    Prefix(10,  15, "P", "peta"),
    Prefix(10,  18, "E", "exa"),
    Prefix(10,  21, "Z", "zetta"),
    Prefix(10,  24, "Y", "yotta"),
    
    Prefix(10,  -1, "d", "deci"),
    Prefix(10,  -2, "c", "centi"),
    Prefix(10,  -3, "m", "milli"),
    Prefix(10,  -6, "μ", "micro"),
    Prefix(10,  -9, "n", "nano"),
    Prefix(10, -12, "p", "pico"),
    Prefix(10, -15, "f", "femto"),
    Prefix(10, -18, "a", "atto"),
    Prefix(10, -21, "z", "zepto"),
    Prefix(10, -24, "y", "yocto")
);

Prefix selectPrefix(Prefix[] prefixes)(Integer power) {
    //1e3, 1e4, 1e5 should all use kilo
    assert(nonempty prefixes);
    variable Prefix best := prefixes.first;
    for (prefix in prefixes) {
        if (prefix.power >= power) {
            if (prefix < best) {
                best := prefix;
            } else {
                best := prefix;
            }
        }
    }
    return best;
}

Prefix decimalPrefix(Integer power) = selectPrefix(decimalPrefixes);

doc "The prefixes used to form binary multiples"
see(decimalPrefixes)
Prefix[] binaryPrefixes = sort(
    Prefix(2, 10, "Ki", "kibi"),
    Prefix(2, 20, "Mi", "mebi"),
    Prefix(2, 30, "Gi", "gibi"),
    Prefix(2, 40, "Ti", "tebi"),
    Prefix(2, 50, "Pi", "pebi"),
    Prefix(2, 60, "Ei", "exbi")
);

Prefix binaryPrefix(Integer power) = selectPrefix(binaryPrefixes);


/*
scaled{
    unit="meters/second";
    prefix=decimalPrefixes;
    rounding=
    quantityFormatter=decimal{
        
    }
};
 */