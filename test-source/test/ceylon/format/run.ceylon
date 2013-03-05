import ceylon.test {suite}

shared void run() {
    suite("ceylon.format", 
        "integerFormatting" -> integerPositionValueTests,
        "wholeFormatting" -> wholePositionValueTests,
        "parserTests" -> parseDecimalNotationTests,
        "digitsTest" -> digitsTest,
        "formattingSpecialCases" -> formattingSpecialCases,
        "formattingInteger" -> formattingInteger
        //"decimalFormatterTests" -> decimalFormatterTests,
        //"decimalFormatterTestsNiceScientific" -> decimalFormatterTestsNiceScientific
        );
}