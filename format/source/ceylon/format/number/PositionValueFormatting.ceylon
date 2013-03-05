import ceylon.format{Formatter}

doc "Digit grouping function which never inserts separators."
shared String noDigitGrouping(Integer nd) {
    return "";
}

doc "Factory method for digit grouping functions which use a constant group size."
shared String(Integer) regularDigitGrouping(String separator, Integer groupSize=3) {
    String regularSeparator(Integer nd) {
        return nd != 0 && nd % groupSize == 0 then separator else ""; 
    }
    return regularSeparator;
}

doc "A formatter for `Integer`-likes which outputs the number in 
     a position-value notation using some set of digit symbols 
     in some base."
shared class PositionValueFormatter<Num>(
            doc "The radix"
            Num base, 
            doc "The digit symbols to use. There must be a digit for every number from `0` to `base-1`"
            Correspondence<Num, Character> digits,
            doc "A digit grouping function. Returns the separator to use after printing the `n`<sup>th</sup> digit"
            String digitGrouping(Integer n) => noDigitGrouping(n))
        satisfies Formatter<Num> 
        given Num satisfies Integral<Num>&Number&Invertable<Num> {
    // TODO base and digits should really be declared Integer to be more useful to the caller
    // (after all how can I promise to support bases > Integer), but then i need 
    // a way to convert them to Num in order to do arithmetic here. In 
    // particular division and remainder  
    Character digit(Num i) {
        Character? d = digits[i];
        assert(exists d);
        return d;
    }
    
    doc "Recursive method to print a digit"
    void formatInternal(Num number, Integer nd, StringBuilder builder) {
        value y = number / base;
        if (!y.zero) {
            formatInternal(y, nd+1, builder);
        }
        builder.appendCharacter(digit(number % base));
        builder.append(digitGrouping(nd));
    }
    shared actual void formatTo(Num number, StringBuilder builder) {
        Num positive;
        if (number.positive) {
            positive = number;
        } else {
            positive = number.negativeValue;
        }
        formatInternal(positive, 0, builder);
    }
    
    assert(!base.negative, !base.zero, !base.unit);
    //assert(digits.size == base);
    //TODO negative numbers
    //TODO decimal numbers (fractions)
    //TODO rounding
    //TODO exponents
    //TODO control over max digits
    //TODO control over what to do when number too big for max digits
    //TODO configuring all this shit from a locale
}

doc "A decorating Formatter which adds a prefix and/or suffix to a formatted 
     number if that number is negative"
shared Formatter<Num> signAround<in Num>(Formatter<Num> next, 
        String negativePrefix="-", 
        String positivePrefix="",
        String negativeSuffix="", 
        String positiveSuffix="") given Num satisfies Number {
    class Around() satisfies Formatter<Num> {
        shared actual void formatTo(Num number, StringBuilder builder) {
            builder.append(number.negative then negativePrefix else positivePrefix);
            next.formatTo(number, builder);
            builder.append(number.negative then negativeSuffix else positiveSuffix);
        }
    }
    return Around();
}

