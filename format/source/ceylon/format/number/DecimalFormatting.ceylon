import ceylon.math.decimal { Decimal }
import ceylon.math.whole { Whole }
import ceylon.format { Formatter }

doc "A contract for things which can be formatted in 
     a standardized decimal notation. This is used to abstract over
     Integer, Float and other numeric types to allow them for be formatted in 
     decimal notation"
//see (DecimalNotation::decimalNotation)
see (DecimalFormatter)
shared interface DecimalNotation<T> satisfies Formatter<T>{
    doc "The decimal representation of the given number. The values returned 
         by this method must conform to the following grammar:
         
             decimal-notation ::= nan | signMag;
             nan              ::= \"NaN\";
             signMag          ::= minus? mag;
             minus            ::= '-';
             mag              ::= infinity | zero | normal | scientific;
             infinity         ::= \"Infinity\";
             zero             ::= \"0.0\";
             normal           ::= zeroToNine+ (fractionalPart)?;
             fractionalPart   ::= dot zeroToNine+
             scientific       ::= zeroToNine fractionalPart E exponent;
             exponent         ::= minus? zeroToNine+;
             zeroToNine       ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';
             dot              ::= '.';
             E                ::= 'E';
         "
         //TODO make sure the grammar works with the JS representation as well!
    shared formal String decimalNotation(T number);
    shared actual void formatTo(T thing, StringBuilder builder) {
        builder.append(decimalNotation(thing));
    }
}

//TODO rounding
//TODO exponents
//TODO control over max digits
//TODO control over what to do when number too big for max digits
shared class DecimalFormatter<T>(DecimalNotation<T> dn,
ExponentialSymbols symbols) satisfies Formatter<T> given T satisfies Object {
    shared actual void formatTo(T thing, StringBuilder builder) {
        value decimal = dn.decimalNotation(thing);
        Boolean negativeMantissa = decimal.startsWith("-");
        if (decimal== "NaN") {
            builder.append(symbols.undefined);
            return;
        }
        if (negativeMantissa) {
            builder.append(symbols.mantissaSymbols.negativeSignPrefix);
        } else {
            builder.append(symbols.mantissaSymbols.positiveSignPrefix);
        }
        variable Boolean exponent := false;
        variable Boolean fraction := false;
        variable Boolean negativeExponent := false;
        variable value index := -1;
        variable value mantissaDigits := 0;
        variable value exponentDigits := 0;
        for (Character c in decimal) {
            index++;
            if (c == `-`) {
                if (exponent) {
                    negativeExponent := true;
                }
                continue;
            } else if (c == `I`) { // infinity
                if (exponent) {
                    throw;    
                }
                //TODO gobble the "nfinity"
                builder.append(symbols.infinity);
                break;
            } else if (c == `.`) {
                if (fraction) {
                    throw;
                }
                fraction := true;
                builder.append(symbols.mantissaSymbols.point);
            } else if (c == `E`) {
                if (exponent) {
                    throw;
                }
                exponent := true;
                if (negativeMantissa) {
                    builder.append(symbols.mantissaSymbols.negativeSignPrefix);
                } else {
                    builder.append(symbols.mantissaSymbols.positiveSignPrefix);
                }
                builder.append(symbols.exponentSymbol);
            } else if (c == `0`
                        || c == `1`
                        || c == `2`
                        || c == `3`
                        || c == `4`
                        || c == `5`
                        || c == `6`
                        || c == `7`
                        || c == `8`
                        || c == `9`) {
                if (exponent && exponentDigits == 0) {
                    if (negativeExponent) {
                        builder.append(symbols.exponentSymbols.negativeSignPrefix);
                    } else {
                        builder.append(symbols.exponentSymbols.positiveSignPrefix);
                    }
                }
                if (exponent) {
                    builder.appendCharacter(symbols.exponentSymbols.digit(c.distanceFrom(`0`)));
                } else {
                    builder.appendCharacter(symbols.mantissaSymbols.digit(c.distanceFrom(`0`)));
                }
                if (exponent) {
                    exponentDigits++;
                } else {
                    mantissaDigits++;
                }
            } else {
                throw Exception("Unexpected character " c " at index " index " of decimal notation " decimal " returned by " dn " for input " thing "");
            }
        }
        if (!exponent) {
            if (negativeMantissa) {
                builder.append(symbols.mantissaSymbols.negativeSignPrefix);
            } else {
                builder.append(symbols.mantissaSymbols.positiveSignPrefix);
            }
        }
    }
}

doc "DecimalNotation implementation for Float"
shared object floatDecimalNotation satisfies DecimalNotation<Float> {
    shared actual String decimalNotation(Float number) {
        return number.string;
    }
}

doc "DecimalNotation implementation for Integer"
shared object integerDecimalNotation satisfies DecimalNotation<Integer> {
    shared actual String decimalNotation(Integer number) {
        return number.string;
    }
}

doc "DecimalNotation implementation for Whole"
shared object wholeDecimalNotation satisfies DecimalNotation<Whole> {
    shared actual String decimalNotation(Whole number) {
        return number.string;
    }
}

doc "DecimalNotation implementation for Decimal"
shared object decimalDecimalNotation satisfies DecimalNotation<Decimal> {
    shared actual String decimalNotation(Decimal number) {
        return number.string;
    }
}
