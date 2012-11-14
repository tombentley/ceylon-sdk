import ceylon.format { Formatter, CompoundFormatter }
import ceylon.math.whole { Whole }
import ceylon.math.decimal { Decimal }
import ceylon.collection { HashMap }

shared abstract class Quantity() {
}

shared object undefinedQuantity extends Quantity() {
}

shared class Digits(String digit, 
            doc "true to trim leading zeros, false to trim trailing zeros"
            Boolean stripLeading) 
        extends Quantity() {
    //TODO a ceylon.math::Decimal may have significant digits
    //in which case we should not be trimming them
    doc "The digits sequence"
    shared String digits;
    
    variable Integer index := 0;
    value chars = stripLeading then digit else digit.reversed;
    for (ch in chars) {
        if (ch != `0`) {
            break;
        }
        index+=1;
    }
    if (index == digit.size) {
        digits="0";
    } else if (stripLeading) {
        digits = digit.span(index, digit.size);
    } else {
        digits = digit.span(0, digit.size-index-1);
    }
    
    doc "Another instance with the given digits appended"
    shared Digits append(String digits) {
        return Digits(this.digits + digits, stripLeading);
    }
    
    doc "Another instance with the given digits prepended"
    shared Digits prepend(String digits) {
        return Digits(digits + this.digits, stripLeading);
    }
    
    shared String initialDigits(Integer n) {
        value result = digits.segment(0, n);
        //TODO what if there are not enough initial digits?
        return result;
    }
    
    doc "Another instance the initial `n` (most significant) digits removed"
    shared Digits initialDropped(Integer n) {
        //TODO what if there are not enough initial digits?
        return Digits(digits.terminal(digits.size - 1), stripLeading);
    }
    
    shared String terminalDigits(Integer n) {
        //TODO what if there are not enough terminal digits?
        value result = digits.segment(digits.size - n, n);
        return result;
    }
    
    doc "Another the the terminal (least significant) digit removed"
    shared Digits terminalDropped(Integer n) {
        //TODO what if there are not enough terminal digits?
        return Digits(digits.initial(digits.size - 1), stripLeading);
    }
}

shared abstract class SignedQuantity(negative) 
        of infiniteQuantity|negativeInfiniteQuantity|DecimalQuantity 
        extends Quantity() {
    shared Boolean negative;
}

shared object infiniteQuantity extends SignedQuantity(false) {
}
shared object negativeInfiniteQuantity extends SignedQuantity(true) {
}

shared class DecimalQuantity(Boolean negative, wholeDigits, fractionDigits) extends SignedQuantity(negative) {
    shared Digits wholeDigits;
    shared Digits fractionDigits;
    
    doc "Another instance with the radix point shifted `n` digits to the right. 
         Equivalently `this × baseⁿ`"
    shared DecimalQuantity scaled(Integer n) {
        if (n == 0) {
            return this;
        }
        return DecimalQuantity(negative,
            wholeDigits.append(fractionDigits.initialDigit),
            fractionDigits.initialDropped);
    }
    
}

shared class ExponentialQuantity(Boolean negative, Digits wholeDigits, Digits fractionDigits, negativeExponent, exponentDigits) extends DecimalQuantity(negative, wholeDigits, fractionDigits) {
    shared Boolean negativeExponent;
    shared Digits exponentDigits;
    
    shared ExponentialQuantity exponentIncremented(Integer increment) {
        
    }

}


doc "A contract for things which can be formatted in 
     a standardized decimal notation. This is used to abstract over
     Integer, Float and other numeric types to allow them for be formatted in 
     decimal notation"
//see (DecimalNotation::decimalNotation)
//see (DecimalFormatter)
shared interface DecimalNotation<T> {
    doc "The decimal representation of the given number. The values returned 
         by this method must conform to the following grammar:
         
             decimal-notation ::= nan | signMag;
             nan              ::= \"NaN\";
             signMag          ::= minus? mag;
             minus            ::= '-';
             mag              ::= infinity | decimal;
             infinity         ::= \"Infinity\";
             decimal          ::= digits ( fractionalPart (E exponent)? )?;
             fractionalPart   ::= dot digits
             exponent         ::= minus? digits;
             digits           ::= digits+;
             digit            ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';
             dot              ::= '.';
             E                ::= 'E';
         "
         //TODO make sure the grammar works with the JS representation as well!
    shared formal Quantity decimalNotation(T number);
}

doc "Parses the notation produced by `DecimalNotation`.
     This class is Thread Safe."
object decimalNotationParser {
    class Tokenizer(notation) {
        shared String notation;
        variable Integer index := 0;
        shared Integer currentIndex {
            return index;
        }
        shared Character currentToken {
            if (exists ch = notation[index]) {
                return ch;
            }
            throw Exception("Unexpected end of input");
        }
        
        shared Boolean hasNext {
            return index +1 < notation.size;
        }
    
        shared void eat() {
            if (!hasNext) {
                throw Exception("Unexpected end of input");
            }
            index++;
        }
    }
 
    Quantity parseNaN(Tokenizer tokenizer) {
        if (tokenizer.notation == "NaN") {
            return undefinedQuantity;
        }
        throw Exception("Expected `NaN`");
    }
    
    SignedQuantity parseInfinity(Tokenizer tokenizer, Boolean neg) {
        if ("Infinity" == tokenizer.notation.span(tokenizer.currentIndex, tokenizer.notation.size)) {
            return neg then negativeInfiniteQuantity else infiniteQuantity;
        }
        throw Exception("Expecting \"Infinity\" at index " tokenizer.currentIndex "");
    }
    
    String parseDigits(Tokenizer tokenizer, Boolean expectSome) {
        Integer start = tokenizer.currentIndex;
        variable Character t := tokenizer.currentToken;
        while (true) {
            if (t == `0` || t == `1` || t == `2`
                || t == `3` || t == `4` || t == `5`
                || t == `6` || t == `7` || t == `8` || t == `9`) {
                if (!tokenizer.hasNext) {
                    break;
                }
                tokenizer.eat();
                t := tokenizer.currentToken;
                continue;
            }
            if (expectSome && start == tokenizer.currentIndex) {
                throw Exception("Expected at least one digit at index " start " of input '" tokenizer.notation "'");
            }
            break;
        }
        return tokenizer.notation.span(start, tokenizer.currentIndex);
    }
    
    String parseFractionalPart(Tokenizer tokenizer) {
        if (tokenizer.currentToken == `.`) {
            tokenizer.eat();
            return parseDigits(tokenizer, true);
        }
        throw Exception("Expected `.` at index" tokenizer.currentIndex "");
    }
    
    DecimalQuantity parseDecimal(Tokenizer tokenizer, Boolean neg) {
        String wholeDigits = parseDigits(tokenizer, true);
        String fractionDigits;
        Boolean negativeExponent;
        String exponentDigits;
        if (tokenizer.hasNext) {
            fractionDigits = parseFractionalPart(tokenizer);
            if (tokenizer.hasNext) {
                if (tokenizer.currentToken == `E`) {
                    tokenizer.eat();
                    if (tokenizer.currentToken == `-`) {
                        negativeExponent = true;
                        tokenizer.eat();
                    } else {
                        negativeExponent = false;
                    }
                    exponentDigits = parseDigits(tokenizer, true);
                } else {
                    throw Exception("Expected `E` at index" tokenizer.currentIndex "");
                }
            } else {
                negativeExponent = false;
                exponentDigits = "";
            }
        } else {
            fractionDigits = "";
            negativeExponent = false;
            exponentDigits = "";
        }
        return ExponentialQuantity(neg, Digits(wholeDigits, true), Digits(fractionDigits, false), negativeExponent, Digits(exponentDigits, true));
    }
    
    SignedQuantity parseMag(Tokenizer tokenizer, Boolean neg) {
        if (tokenizer.currentToken == 'I') {
            return parseInfinity(tokenizer, neg);
        }
        return parseDecimal(tokenizer, neg);
    }
    
    SignedQuantity parseSignMag(Tokenizer tokenizer) {
        Boolean neg; 
        if (tokenizer.currentToken == `-`) {
            tokenizer.eat();
            neg = true;
        } else {
            neg = false;
        }
        return parseMag(tokenizer, neg);
    }
    
    
    shared Quantity parse(String notation) {
        Tokenizer tokenizer = Tokenizer(notation);
        if (tokenizer.currentToken == `N`) {
            return parseNaN(tokenizer);
        }
        return parseSignMag(tokenizer);
    }
}

shared Quantity parseDecimalNotation(String notation) {
    return decimalNotationParser.parse(notation);
}

//TODO rounding
//TODO exponents
//TODO control over max digits
//TODO control over what to do when number too big for max digits

doc "`DecimalNotation` implementation for `Float`"
shared object floatDecimalNotation satisfies DecimalNotation<Float> {
    shared actual Quantity decimalNotation(Float number) {
        return parseDecimalNotation(number.string);
    }
}

doc "`DecimalNotation` implementation for `Integer`"
shared object integerDecimalNotation satisfies DecimalNotation<Integer> {
    shared actual Quantity decimalNotation(Integer number) {
        return parseDecimalNotation(number.string);
    }
}

doc "`DecimalNotation` implementation for `Whole`"
shared object wholeDecimalNotation satisfies DecimalNotation<Whole> {
    shared actual Quantity decimalNotation(Whole number) {
        return parseDecimalNotation(number.string);
    }
}

doc "`DecimalNotation` implementation for `Decimal`"
shared object decimalDecimalNotation satisfies DecimalNotation<Decimal> {
    shared actual Quantity decimalNotation(Decimal number) {
        return parseDecimalNotation(number.string);
    }
}

doc "Formatter for a goup of digits"
class DigitsFormatter(numerals = decimalDigits,
                            digitGrouping = noDigitGrouping) satisfies Formatter<Digits> {
    doc "Invoked with an argument `n` to obtain the separator to use 
         between the `n`th numeral and the `n+1`th numeral (counting away 
         from the radix point)."
    shared Callable<String, Integer> digitGrouping;
    doc "The digits"
    shared Sequence<Character> numerals;
    shared DigitsFormatter withDigits(Sequence<Character> digits) {
        return DigitsFormatter(digits, digitGrouping);
    }
    shared DigitsFormatter withDigitGrouping(Callable<String, Integer> digitGrouping) {
        return DigitsFormatter(numerals, digitGrouping);
    }
    shared actual void formatTo(Digits thing, StringBuilder builder) {
        for (d in thing.digits) {
            value digit = d.distanceFrom(`0`);
            value numeral = numerals[digit];
            if (exists numeral) {
                builder.appendCharacter(numeral); 
            } else {
               throw Exception("No numeral for digit " digit "");
            }
        }
    }
}

class StandardFormatter<T>(DecimalNotation<T> notation,
undefinedSymbol,
positivePrefix="",
negativePrefix="-",
positiveSuffix="",
negativeSuffix="",
infiniteSymbol="∞",
radixPoint=".",
wholeFormatter=DigitsFormatter(decimalDigits, noDigitGrouping),
fractionFormatter=DigitsFormatter(decimalDigits, noDigitGrouping),
exponentPrefix="E",
exponentSuffix="",
exponentFormatter=DigitsFormatter(decimalDigits, noDigitGrouping)) satisfies Formatter<T> {
    String undefinedSymbol;
    String positivePrefix;
    String negativePrefix;
    String positiveSuffix;
    String negativeSuffix;
    String infiniteSymbol;
    String radixPoint;
    DigitsFormatter wholeFormatter;
    DigitsFormatter fractionFormatter;
    String exponentPrefix;
    String exponentSuffix;
    DigitsFormatter exponentFormatter;
    
    void formatDecimal(DecimalQuantity quantity, StringBuilder builder) {
        wholeFormatter.formatTo(quantity.wholeDigits, builder);
        builder.append(radixPoint);
        fractionFormatter.formatTo(quantity.fractionDigits, builder);
        if (is ExponentialQuantity quantity) {
            formatExponential(quantity, builder);
        }
    }
   
    void formatExponential(ExponentialQuantity quantity, StringBuilder builder) {
        builder.append(exponentPrefix);
        builder.append(quantity.negativeExponent then negativePrefix else positivePrefix);
        exponentFormatter.formatTo(quantity.exponentDigits, builder);
        builder.append(quantity.negativeExponent then negativeSuffix else positiveSuffix);
        builder.append(exponentSuffix);
    }
    
    void formatMagnitude(SignedQuantity quantity, StringBuilder builder) {
        switch (quantity) 
        case (infiniteQuantity, negativeInfiniteQuantity) { 
            builder.append(infiniteSymbol);
        } 
        case (is DecimalQuantity) {
            formatDecimal(quantity, builder);
        }
    }

    shared actual void formatTo(T thing, StringBuilder builder) {
        value quantity = notation.decimalNotation(thing);
        if (quantity == undefinedQuantity) {
            builder.append(undefinedSymbol);
            return;
        } 
        assert (is SignedQuantity quantity);
        builder.append(quantity.negative then negativePrefix else positivePrefix);
        formatMagnitude(quantity, builder);
        builder.append(quantity.negative then negativeSuffix else positiveSuffix);
    }
    
}

