import ceylon.collection { HashMap }
import ceylon.format { Formatter }
import ceylon.format.number { PositionValueFormatter, regularDigitGrouping, signAround, Quantity, parseDecimalNotation, Digits }
import ceylon.math.whole { Whole, wholeNumber }

import com.redhat.ceylon.sdk.test { Suite, assertEquals, fail }

void integerPositionValueTests() {
    // Without digit grouping
    variable Formatter<Integer> decimal := PositionValueFormatter(
            10, "0123456789");
    for (i in (0..100).chain(999..1_010).chain(1_999..2010)
                       .chain(9_999..10_010).chain(999_999..1_000_100)) {
        value r = decimal.format(i);
        assertEquals(i.string, r, i.string);
    }
    
    // negatives
    value signed = signAround(decimal);
    for (i in (-100..0)) {
        value r = signed.format(i);
        print(r);
        assertEquals(i.string, r, i.string);
    }
    
    // thousands digit grouping with `,`
    decimal := PositionValueFormatter(
            10, "0123456789", regularDigitGrouping(",", 3));
    for (i in (0..100).chain(900..999)) {
        value r = decimal.format(i);
        assertEquals(i.string, r, i.string);
    }
    assertEquals("1,000", decimal.format(1_000));
    assertEquals("1,001", decimal.format(1_001));
    assertEquals("1,999", decimal.format(1_999));
    assertEquals("2,000", decimal.format(2_000));
    assertEquals("2,001", decimal.format(2_001));
    assertEquals("9,999", decimal.format(9_999));
    assertEquals("10,000", decimal.format(10_000));
    assertEquals("10,001", decimal.format(10_001));
    assertEquals("99,999", decimal.format(99_999));
    assertEquals("100,000", decimal.format(100_000));
    assertEquals("100,001", decimal.format(100_001));
    assertEquals("999,999", decimal.format(999_999));
    assertEquals("1,000,000", decimal.format(1_000_000));
    assertEquals("1,000,001", decimal.format(1_000_001));
    
    // Hindi-style grouping
    function hindiGrouping(Integer nd) {
        return nd != 0 && (nd == 3 || (nd > 3 && ((nd-3)%2)==0)) then "," else "";
    }
    decimal := PositionValueFormatter(
            10, "0123456789", hindiGrouping);
    assertEquals("1,000", decimal.format(1_000));
    assertEquals("10,000", decimal.format(10_000));
    assertEquals("1,00,000", decimal.format(100_000));
    assertEquals("10,00,000", decimal.format(1_000_000));
    assertEquals("1,00,00,000", decimal.format(10_000_000));
    
    // hex
    decimal := PositionValueFormatter(
            16, "0123456789abcdef");
    assertEquals("0", decimal.format(0));
    assertEquals("1", decimal.format(1));
    assertEquals("2", decimal.format(2));
    assertEquals("3", decimal.format(3));
    assertEquals("4", decimal.format(4));
    assertEquals("5", decimal.format(5));
    assertEquals("6", decimal.format(6));
    assertEquals("7", decimal.format(7));
    assertEquals("8", decimal.format(8));
    assertEquals("9", decimal.format(9));
    assertEquals("a", decimal.format(10));
    assertEquals("b", decimal.format(11));
    assertEquals("c", decimal.format(12));
    assertEquals("d", decimal.format(13));
    assertEquals("e", decimal.format(14));
    assertEquals("f", decimal.format(15));
    assertEquals("10", decimal.format(16));
    assertEquals("11", decimal.format(17));
    assertEquals("12", decimal.format(18));
    assertEquals("13", decimal.format(19));
    assertEquals("1e", decimal.format(30));
    assertEquals("1f", decimal.format(31));
    assertEquals("20", decimal.format(32));
    assertEquals("21", decimal.format(33));
    assertEquals("ff", decimal.format(255));
    assertEquals("100", decimal.format(256));
    
    // bad arguments
    try {
        decimal := PositionValueFormatter(1, "1");
        fail();
    } catch (Exception e) {
    }
    
    try {
        decimal := PositionValueFormatter(0, "1");
        fail();
    } catch (Exception e) {
    }
    
    try {
        decimal := PositionValueFormatter(-1, "1");
        fail();
    } catch (Exception e) {
    }
    
    
}

void wholePositionValueTests() {
    HashMap<Whole, Character> digits = HashMap<Whole, Character>();
    digits.put(wholeNumber(0), `0`);
    digits.put(wholeNumber(1), `1`);
    digits.put(wholeNumber(2), `2`);
    digits.put(wholeNumber(3), `3`);
    digits.put(wholeNumber(4), `4`);
    digits.put(wholeNumber(5), `5`);
    digits.put(wholeNumber(6), `6`);
    digits.put(wholeNumber(7), `7`);
    digits.put(wholeNumber(8), `8`);
    digits.put(wholeNumber(9), `9`);
    // slightly funky digit grouping
    variable PositionValueFormatter<Whole> d := 
            PositionValueFormatter<Whole>(wholeNumber(10), digits, 
                regularDigitGrouping("#", 4));
    assertEquals("1000", d.format(wholeNumber(1_000)));
    assertEquals("100#0000", d.format(wholeNumber(1_000_000)));
    assertEquals("1000#0000", d.format(wholeNumber(10_000_000)));
    assertEquals("1#0000#0000", d.format(wholeNumber(100_000_000)));
    assertEquals("10#0000#0000", d.format(wholeNumber(1_000_000_000)));
     
}

void assertWontParse(String s) {
    try {
        parseDecimalNotation(s);
        fail("Unexpectedly parsed as a decimal: '" s "'");
    } catch (Exception e) {
    }
}

void parseDecimalNotationTests() {
     assertWontParse("");
     assertWontParse("x");
     assertWontParse("nan");
     assertWontParse("Na");
     assertWontParse("infinity");
     assertWontParse("+Infinity");
     assertWontParse("+0");
     assertWontParse("--0");
     assertWontParse("--1");
     assertWontParse("+0.0");
     assertWontParse("0.0e0");
     assertWontParse("1.0e10");
     assertWontParse("1.0EE10");
     assertWontParse("0.0e-0");
     assertWontParse("0.0e--0");
     assertWontParse("0.0E-0");
     assertWontParse("1.0E-0");
     assertWontParse("1.0e-10");
     assertWontParse("1.0.0");
     assertWontParse("1.0.0E1");
     assertWontParse("0.0E+0");
     assertWontParse("1.0E+0");
     assertWontParse("0.0E1.0");
     assertWontParse("1.0E1.0");
     assertWontParse(".");
     assertWontParse(".0");
     assertWontParse("0.");
     assertWontParse("1E10");
     parseDecimalNotation("0");
     parseDecimalNotation("1");
     parseDecimalNotation("2");
     parseDecimalNotation("3");
     parseDecimalNotation("4");
     parseDecimalNotation("5");
     parseDecimalNotation("6");
     parseDecimalNotation("7");
     parseDecimalNotation("8");
     parseDecimalNotation("9");
     parseDecimalNotation("10");
     parseDecimalNotation("00");
     parseDecimalNotation("-0");
     parseDecimalNotation("-00");
     parseDecimalNotation("-1");
     parseDecimalNotation("-01");
     parseDecimalNotation("-10");
     parseDecimalNotation("0.0");
     parseDecimalNotation("-0.0");
     parseDecimalNotation("1.0");
     parseDecimalNotation("-1.0");
     parseDecimalNotation("1.1");
     parseDecimalNotation("-1.1");
     parseDecimalNotation("10.01");
     parseDecimalNotation("-10.01");
     parseDecimalNotation("1.0E0");
     parseDecimalNotation("1.0E1");
     parseDecimalNotation("1.0E-0");
     parseDecimalNotation("1.0E-1");
     parseDecimalNotation("-1.0E0");
     parseDecimalNotation("-1.0E1");
     parseDecimalNotation("-1.0E-0");
     parseDecimalNotation("-1.0E-1");
     parseDecimalNotation("-1.0E-0");
     parseDecimalNotation("-1.0E-100000000000000000000000000000000000000000000000000000000");
}

void digitsTest() {
    assertEquals("0", Digits("", true).digits);
    assertEquals("0", Digits("0", true).digits);
    assertEquals("0", Digits("00", true).digits);
    assertEquals("0", Digits("000", true).digits);
    assertEquals("1", Digits("001", true).digits);
    assertEquals("10", Digits("0010", true).digits);
    assertEquals("100", Digits("00100", true).digits);
    
    assertEquals("0", Digits("", false).digits);
    assertEquals("0", Digits("0", false).digits);
    assertEquals("0", Digits("00", false).digits);
    assertEquals("0", Digits("000", false).digits);
    assertEquals("001", Digits("001", false).digits);
    assertEquals("001", Digits("0010", false).digits);
    assertEquals("001", Digits("00100", false).digits);
}

/*void decimalFormatterTests() {
    value formatter = DecimalFormatter(floatDecimalNotation, ExponentialSymbols(PositionValueSymbols{point=",";}));
    assertEquals("123,4", formatter.format(123.4));
    assertEquals("1,234e12", formatter.format(123.4E10));
}

void decimalFormatterTestsNiceScientific() {
    value formatter = DecimalFormatter(floatDecimalNotation, ExponentialSymbols{
        exponentSymbols=PositionValueSymbols{
            digits = {`⁰`, `ⁱ`, `²`, `³`, `⁴`, `⁵`, `⁶`, `⁷`, `⁸`, `⁹`};
            negativeSignPrefix = "⁻";
        };
        exponentSymbol = "×10";
    });
    assertEquals("123.4", formatter.format(123.4));
    assertEquals("1.234×10ⁱ²", formatter.format(123.4E10));
    assertEquals("1.234×10⁻⁸", formatter.format(123.4E-10));
}*/

class FormatSuite() extends Suite("ceylon.format") {
    shared actual Iterable<String->Void()> suite = {
        "integerFormatting" -> integerPositionValueTests,
        "wholeFormatting" -> wholePositionValueTests,
        "parserTests" -> parseDecimalNotationTests,
        "digitsTest" -> digitsTest
        //"decimalFormatterTests" -> decimalFormatterTests,
        //"decimalFormatterTestsNiceScientific" -> decimalFormatterTestsNiceScientific
    };
}

shared void run() {
    FormatSuite().run();
}