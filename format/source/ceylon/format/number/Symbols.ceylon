doc "The Arabic numerals, 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9"
Sequence<Character> decimalDigits = {`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`};

shared class DigitSymbols(digits = decimalDigits,
                            digitGrouping = noDigitGrouping) {
    shared String(Integer) digitGrouping;
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

doc "The symbols needed to construct a signed non-fractional number in 
     position-value format."
shared class IntegerSymbols(
            Sequence<Character> digits = decimalDigits,
            String(Integer) digitGrouping = noDigitGrouping,
            positiveSignPrefix = "",
            negativeSignPrefix = "-",
            positiveSignSuffix = "",
            negativeSignSuffix = "") 
        extends DigitSymbols(digits, digitGrouping){
    shared String positiveSignPrefix;
    shared String negativeSignPrefix;
    shared String positiveSignSuffix;
    shared String negativeSignSuffix;
}

doc "The symbols needed to construct a signed number in position-value format."
shared class FractionSymbols(
            Sequence<Character> digits = decimalDigits,
            String(Integer) digitGrouping = noDigitGrouping,
            String positiveSignPrefix = "",
            String negativeSignPrefix = "-",
            String positiveSignSuffix = "",
            String negativeSignSuffix = "",
            point = ".") 
        extends IntegerSymbols(digits, digitGrouping, positiveSignPrefix, negativeSignPrefix, positiveSignSuffix, negativeSignSuffix) {
    doc "The symbol used to indicate the radix point"
    shared String point;
    //TODO Actually there might be two distinct digit grouping, for before and after the radix point 
}


doc "The symbols needed to construct a number in exponential position-value 
     format, such as 1.0E6"
shared class ExponentialSymbols(mantissaSymbols = FractionSymbols(), 
        exponentSymbol = "E", exponentSymbols = IntegerSymbols()) {
    
    doc "The symbols used to format the mantissa"
    shared FractionSymbols mantissaSymbols;
    
    doc "The symbol which separates the mantissa from the exponent"
    shared String exponentSymbol;
    
    doc "The symbols used to format the exponent. The `point` isn't be used."
    shared IntegerSymbols exponentSymbols;   
}

doc "The symbols needed to format a number"
shared class NumberSymbols(
// We use Unicode "REPLACEMENT CHARACTER" which seems to be the 
// "standard"
// see http://www.unicode.org/review/resolved-pri.html#pri74
            undefined = "�", 
            infinity = "∞") 
        extends ExponentialSymbols() {
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

Prefix decimalPrefix(Integer power) => selectPrefix(decimalPrefixes)(power);

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

Prefix binaryPrefix(Integer power) => selectPrefix(binaryPrefixes)(power);

//TODO For formatting dates it would be really useful to be able to append 
//ordinal abbreviations such as st, nd rd, th (1st, 2nd, 3rd and 4th)

doc "For a given ordinal number, produces the corresponding standard 
     English ordinal indicator suffix. That is one of 
     'st', 'nd', 'rd' or 'th'."
String ordinalEn(Integer i) {
    if (i % 10 == 1 && i % 100 != 11) {
        return "st";
    } else if (i % 10 == 2 && i % 100 != 12) {
        return "nd";
    } else if (i % 10 == 3 && i % 100 != 13) {
        return "rd";
    }
    return "th";
}
/*
scaled{
    unit="meters/second";
    prefix=decimalPrefixes;
    rounding=
    quantityFormatter=decimal{
        
    }
};
 */