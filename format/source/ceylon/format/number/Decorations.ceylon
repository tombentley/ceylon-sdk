import ceylon.format{Formatter}

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


/*
doc "A decorating Formatter which appends a unit (possibly with a prefix for 
     multiples or submultiples) to a formatted number"
see(decimalPrefixes, binaryPrefixes)
shared Formatter<Num> unit<in Num>(String unit, Correspondence<Integer,String> prefixes, Formatter<Num> next) 
        given Num satisfies Number&Numeric<Num>&Integral<Num> {
    class Around() satisfies Formatter<Num> {
        // TODO support binary suffixes too
        shared actual void formatTo(Num number, StringBuilder builder) {
            // TODO figure out order of thing
            variable Integer order := 0;
            if (number.magnitude.sign == 1) {
                // how many divisions by ten do we need?
                variable Num n := number;
                while (!n.zero) {
                    order++;
                    //TODO It's impossible to abstract algorithms without knowing
                    //the value for 0 and 1. 
                    n /= 10;
                }
            } else {
                // how many multiplications by ten do we need?
            }
            //TODO can't use []
            value prefix = prefixes[order];
            next.formatTo(number, builder);
            builder.append(prefix);
        }
    }
    return Around();
}

*/