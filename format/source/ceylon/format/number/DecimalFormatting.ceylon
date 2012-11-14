import ceylon.format { Formatter, CompoundFormatter }
import ceylon.math.whole { Whole }
import ceylon.math.decimal { Decimal }
import ceylon.collection { HashMap }

shared abstract class Quantity() {
    //shared formal void formatTo(Symbols symbols, StringBuilder builder);
}

shared object undefinedQuantity extends Quantity() {
    //shared actual void formatTo(NumberSymbols symbols, StringBuilder builder) {
    //    builder.append(symbols.undefined);
    //}
}

shared class Digits(String digit, 
            doc "true to trim leading zeros, false to trim trailing zeros"
            Boolean stripLeading) 
        extends Quantity() {
    
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
    
    doc "Another instance with the given digit appended"
    shared Digits append(Character digit) {
        return Digits(digits + digit.string, stripLeading);
    }
    
    doc "Another instance with the given digit prepended"
    shared Digits prepend(Character digit) {
        return Digits(digit.string + digits, stripLeading);
    }
    
    shared Character initialDigit {
        value result = digits[0];
        assert(exists result);
        return result;
    }
    
    doc "Another the the initial (most significant) digit removed"
    shared Digits initialDropped {
        return Digits(digits.terminal(digits.size - 1), stripLeading);
    }
    
    shared Character terminalDigit {
        value result = digits[digits.size - 1];
        assert(exists result);
        return result;
    }
    
    doc "Another the the terminal (least significant) digit removed"
    shared Digits terminalDropped {
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
    //shared actual void formatTo(NumberSymbols symbols, StringBuilder builder) {
    //    builder.append(negative then symbols.mantissaSymbols.negativeSignPrefix else symbols.mantissaSymbols.positiveSignPrefix)
    //        .append(symbols.infinity)
    //        .append(negative then symbols.mantissaSymbols.negativeSignSuffix else symbols.mantissaSymbols.positiveSignSuffix);            
    //}
shared class DecimalQuantity(Boolean negative, wholeDigits, fractionDigits) extends SignedQuantity(negative) {
    shared Digits wholeDigits;
    shared Digits fractionDigits;
    
    doc "An instance with the radix point shifted to the right one digit"
    shared default DecimalQuantity scaledUp {
        return DecimalQuantity(negative,
            wholeDigits.append(fractionDigits.initialDigit),
            fractionDigits.initialDropped);
    }
    
    doc "An instance with the radix point shifted to the left one digit"
    shared default DecimalQuantity scaledDown {
        return DecimalQuantity(negative,
            wholeDigits.terminalDropped,
            fractionDigits.prepend(wholeDigits.terminalDigit));
    }
}

shared class ExponentialQuantity(Boolean negative, Digits wholeDigits, Digits fractionDigits, negativeExponent, exponentDigits) extends DecimalQuantity(negative, wholeDigits, fractionDigits) {
    shared Boolean negativeExponent;
    shared Digits exponentDigits;
    
    /*void formatMantissaTo(ExponentialSymbols symbols, StringBuilder builder) {
        symbols.mantissaSymbols.digit(digit)
        if (exists fractionDigits) {
            
        }
    }
    void formatExponentTo(ExponentialSymbols symbols, StringBuilder builder) {
        //TODO
    }
    shared actual void formatTo(NumberSymbols symbols, StringBuilder builder) {
        //TODO This is assuming the mantissa comes before the exponent
        //which might not be true, though I don't know of a counter example
        builder.append(negative then symbols.mantissaSymbols.negativeSignPrefix else symbols.mantissaSymbols.positiveSignPrefix);
        formatMantissaTo(symbols, builder);
        formatExponentTo(symbols, builder);
        builder.append(negative then symbols.mantissaSymbols.negativeSignSuffix else symbols.mantissaSymbols.positiveSignSuffix);
    }*/
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
/*
shared class DecimalFormatter<T>(DecimalNotation<T> dn,
ExponentialSymbols symbols) satisfies Formatter<T> given T satisfies Object {

    shared actual void formatTo(T thing, StringBuilder builder) {
        value notation = dn.decimalNotation(thing);
        value parser = DecimalNotationParser(notation);
        value rep = parser.parse();
        rep.formatTo(symbols, builder);
    }
}*/

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
/*
doc "Formatter for the `undefinedQuantity`"
see (undefinedQuantity)
class UndefinedFormatter(String undefinedSymbol, Formatter<SignedQuantity> signed) satisfies Formatter<Quantity> {
    
    shared actual void formatTo(Quantity thing, StringBuilder builder) {
        if (thing==undefinedQuantity) {
            builder.append(undefinedSymbol);
        } else {
            assert (is SignedQuantity thing);
            signed.formatTo(thing, builder);
        }
    }
}

class SpecialCaseFormatter(Correspondence<Quantity, String> symbols, Formatter<Quantity> alternative) satisfies Formatter<Quantity> {
    
    shared actual void formatTo(Quantity thing, StringBuilder builder) {
        if (exists symbol=symbols[thing]) {
            builder.append(symbol);
        } else {
            alternative.formatTo(thing, builder);
        }
    }
}

doc "Formatter for signed quantities"
class SignFormatter(String negative, String positive="") satisfies Formatter<SignedQuantity> {
    shared SignFormatter withNegative(String negative) {
        return SignFormatter(negative, positive);
    }
    shared SignFormatter withPositive(String negative) {
        return SignFormatter(negative, positive);
    }
    shared actual void formatTo(SignedQuantity thing, StringBuilder builder) {
        builder.append(thing.negative then negative else positive);
    }
}

doc "Formatter for infinite and finite magnitudes"
class MagnitudeFormatter(String infinitySymbol, Formatter<SignedQuantity> alt) satisfies Formatter<SignedQuantity>{
    shared actual void formatTo(SignedQuantity thing, StringBuilder builder) {
        if (thing == infiniteQuantity) {
            builder.append(infinitySymbol);
        } else {
            alt.formatTo(thing, builder);
        }
    }
}
*/
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
/*
class ExponentialFormatter(wholeFormatter, radixPoint=".", fractionFormatter=wholeFormatter) satisfies Formatter<ExponentialQuantity> {
    DigitsFormatter wholeFormatter;
    String radixPoint;
    DigitsFormatter fractionFormatter;
    shared ExponentialFormatter withRadixPoint(String radixPoint) {
        return ExponentialFormatter(wholeFormatter, radixPoint, fractionFormatter);
    }
    shared actual void formatTo(ExponentialQuantity thing, StringBuilder builder) {
        wholeFormatter.formatTo(thing.wholeDigits, builder);
        builder.append(radixPoint);
        fractionFormatter.formatTo(thing.fractionDigits, builder);
    }
}

class DecimalFormatter<T>(DecimalNotation<T> notation, Formatter<Quantity> formatter) satisfies Formatter<T> {
    shared actual void formatTo(T thing, StringBuilder builder) {
        formatter.formatTo(notation.decimalNotation(thing), builder);
    }
}

Formatter<Quantity> arabic() {
    return UndefinedFormatter("NaN", 
        CompoundFormatter<SignedQuantity>({SignFormatter("-"),
            MagnitudeFormatter("Infinity", 
                ExponentialFormatter(DigitsFormatter()))}));
}*/

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

/*
doc "A decorating Formatter which adds a prefix and/or suffix to a formatted 
     number if that number is negative"
shared Formatter<DecimalRepresentation> signAroundDecimal(
            IntegerSymbols symbols,
            Formatter<DecimalRepresentation> next) {
    class Around() satisfies Formatter<DecimalRepresentation> {
        shared actual void formatTo(DecimalRepresentation number, StringBuilder builder) {
            builder.append(number.negative then symbols.negativeSignSuffix else symbols.positiveSignPrefix);
            next.formatTo(number, builder);
            builder.append(number.negative then symbols.negativeSignSuffix else symbols.positiveSignSuffix);
        }
    }
    return Around();
}


shared Formatter<DecimalRepresentation> fff<T>(NumberSymbols symbols) {
    return signAroundDecimal(symbols.mantissaSymbols, CompoundFormatter<DecimalRepresentation>(formatters));
}*/