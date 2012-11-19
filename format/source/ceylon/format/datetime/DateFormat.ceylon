import ceylon.format { Formatter, CompoundFormatter, SeparatorFormatter }

doc "Abstraction over things which can be represented in the standard Gregorian 
     terms such as year, month, day in month, hour, minute and second."
shared interface Gregorian<Datetime> {
    doc "The year"
    shared formal Integer year(Datetime datetime);
    doc "The zero-based month in the year, ranging from 0 to 11"
    shared formal Integer month(Datetime datetime);
    doc "The zero-based week in the month, ranging from 0 to 4"
    shared formal Integer weekInMonth(Datetime datetime);
    doc "The zero-based week in the year, ranging from 0 to 52"
    shared formal Integer weekInYear(Datetime datetime);
    doc "The zero-based day in the year, ranging from 0 to 365 (or 364 on a non-leap year)"
    shared formal Integer dayInYear(Datetime datetime);
    doc "The zero-based day in the month, ranging from 0 to 31 (or less, depending on the month)"
    shared formal Integer dayInMonth(Datetime datetime);
    doc "The zero-based day in the week, ranging from 0 (Sunday) to 6 (Saturday)"
    shared formal Integer dayInWeek(Datetime datetime);
    doc "The zero-based hour in the day, ranging from 0 to 23"
    shared formal Integer hour(Datetime datetime);
    doc "The zero-based minute in the hour, ranging from 0 to 59"
    shared formal Integer minute(Datetime datetime);
    doc "The zero-based second in the minute, ranging from 0 to 59"
    shared formal Integer second(Datetime datetime);
    doc "The zero-based millisecond in the second, ranging from 0 to 999"
    shared formal Integer millisecond(Datetime datetime);
    //TODO L10N of timezone name
    shared formal String timezoneName(Datetime datetime);
    shared formal String timezoneAbbreviation(Datetime datetime);
    doc "Timezone offset in minutes from GMT"
    shared formal Integer timezoneOffset(Datetime datetime);
}

doc "Baseclass for formatters using the `Gregorian` abstraction."
abstract class GregorianFormatter<Datetime>(gregorian) 
        satisfies Formatter<Datetime> {
    shared Gregorian<Datetime> gregorian;
}

doc "Formats `Gregorian` years numerically"
class NumericYearFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.year(thing);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats an era indicator based on the year 
     (for example \"AD\" or \"BC\")"
class EraIndicatorFormatter<Datetime>(
            Gregorian<Datetime> gregorian, 
            Correspondence<Integer, String> eras) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value era = eras[gregorian.year(thing)];
        assert(exists era);
        builder.append(era);
    }
}

doc "Formats `Gregorian` months numerically"
class NumericMonthFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter,
            doc "If true then the months are zero-based (so the first month 
                 of the year is month 0), otherwise months are one-based."
            Boolean zeroBased=false) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.month(thing) + (zeroBased then 0 else 1);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` months using their name (which could be an 
     abbreviation)"
class NamedMonthFormatter<Datetime>(
            Gregorian<Datetime> gregorian, 
            doc "The month names, in ascending order from the first month."
            String[] monthNames //TODO use tuple
            ) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value name = monthNames[gregorian.month(thing)];
        assert (exists name);
        builder.append(name);
    }
}

doc "Formats `Gregorian` day-in-month numerically"
class NumericDayInMonthFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter, 
            doc "If true then the days are zero-based (so the first day 
                 of the month is day 0), otherwise days are one-based."
            Boolean zeroBased=false) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        //TODO ordinal suffixes
        value num = gregorian.dayInMonth(thing) + (zeroBased then 0 else 1);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` hours numerically using a 24 hour clock, which may be 
     zero- or one-based."
class Numeric24HourFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter, 
            doc "If true then the hours are zero-based (so the first hour 
                 of the day is hour 0), otherwise hours are one-based."
            Boolean zeroBased=false) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.hour(thing) + (zeroBased then 0 else 1);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` hours numerically using a 12 hour clock, which may be 
     zero- or one-based."
class Numeric12HourFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter,
            Boolean zeroBased=false) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        variable Integer num := gregorian.hour(thing) % 12;
        if (!zeroBased) {
            num+=1;
        }
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats an am/pm indicator using a 12 hour clock"
class Numeric12HourIndicatorFormatter<Datetime>(
            Gregorian<Datetime> gregorian, 
            String[] ampm, //TODO use tuple
            Boolean zeroBased=false) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value indicator = ampm[gregorian.hour(thing) / 12];
        if (exists indicator) {
            builder.append(indicator);
        }
    }
}

doc "Formats `Gregorian` minutes numerically."
class NumericMinuteFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.minute(thing);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` seconds numerically."
class NumericSecondFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.second(thing);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` milliseconds numerically."
class NumericMillisecondFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.millisecond(thing);
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` timezones as a numerical offset from GMT"
see (TimezoneGmtMinutesInHourOffsetFormatter)
class TimezoneGmtHoursOffsetFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.timezoneOffset(thing) / 60;
        numberFormatter.formatTo(num, builder);
    }
}

doc "Formats `Gregorian` timezones as a numerical offset from GMT"
see (TimezoneGmtHoursOffsetFormatter)
class TimezoneGmtMinutesInHourOffsetFormatter<Datetime>(
            Gregorian<Datetime> gregorian,
            Formatter<Integer> numberFormatter) 
        extends GregorianFormatter<Datetime>(gregorian) {
    shared actual void formatTo(Datetime thing, StringBuilder builder) {
        value num = gregorian.timezoneOffset(thing) % 60;
        numberFormatter.formatTo(num, builder);
    }
}


shared Formatter<Datetime> isoDate<Datetime>(Gregorian<Datetime> gregorian,
    doc "True for *extended* format (with separators), false for *basic* format"
    Boolean extended=true,
    doc "The numer of digits in the year. Must be >=4. If `yearDigits>4` the 
         year will be signed (using `+` or `-`)"
    Integer yearDigits=4,
    doc "The number of fields, Must be between 1 and 3 inclusive"
    Integer fields=3,
    doc "The number of fractional digits in the least significant field"
    Integer fractionDigits=0) {
    
    assert (yearDigits >= 4);
    assert (fields >=1, fields <=3);
    assert (fractionDigits >= 0);
    
    value sb = SequenceBuilder<Formatter<Datetime>>();
    
    // Years
    //TODO Zero padding, and sign, fractions
    Formatter<Integer> yearFormatter;
    if (yearDigits == 4) {
        yearFormatter = bottom;
    } else {
        yearFormatter = bottom;
    }
    sb.append(NumericYearFormatter(gregorian, yearFormatter));
    
    if (extended) {
        sb.append(SeparatorFormatter<Datetime>("-"));
    }
    
    // Months
    if (fields > 1) {
        //TODO Zero padding, fractions
        Formatter<Integer> monthFormatter = bottom;
        sb.append(NumericMonthFormatter(gregorian, monthFormatter));
        
        if (extended) {
            sb.append(SeparatorFormatter<Datetime>("-"));
        }
    }
    
    // Days
    if (fields > 2) {
        //TODO Zero padding, fractions
        Formatter<Integer> dayFormatter = bottom;
        sb.append(NumericDayInMonthFormatter(gregorian, dayFormatter));
    }
    assert (nonempty parts=sb.sequence);
    return CompoundFormatter<Datetime>(parts);
}

shared Formatter<Datetime> isoTime<Datetime>(Gregorian<Datetime> gregorian,
    doc "True for *extended* format (with separators), false for *basic* format"
    Boolean extended=true,
    doc "The number of fields, Must be between 1 and 3 inclusive"
    Integer fields=3,
    doc "The number of fractional digits in the least significant field"
    Integer fractionDigits=0) {
    
    assert (fields >=1, fields <=3);
    assert (fractionDigits >= 0);
    
    value sb = SequenceBuilder<Formatter<Datetime>>();
    
    // Hours
    //TODO Zero padding, and sign, fractions
    Formatter<Integer> hourFormatter = bottom;
    
    sb.append(Numeric24HourFormatter(gregorian, hourFormatter));
    
    if (extended) {
        sb.append(SeparatorFormatter<Datetime>(":"));
    }
    
    // Minutes
    if (fields > 1) {
        //TODO Zero padding, fractions
        Formatter<Integer> minuteFormatter = bottom;
        sb.append(NumericMinuteFormatter(gregorian, minuteFormatter));
        
        if (extended) {
            sb.append(SeparatorFormatter<Datetime>(":"));
        }
    }
    
    // Seconds
    if (fields > 2) {
        //TODO Zero padding, fractions
        Formatter<Integer> secondFormatter = bottom;
        sb.append(NumericSecondFormatter(gregorian, secondFormatter));
    }
    assert (nonempty parts=sb.sequence);
    return CompoundFormatter<Datetime>(parts);
    
}

doc "Returns a `Formatter` for ISO 8601 date and time representations, for 
     example *2012-11-15T11:25:34*. 
     
     More formally, the format is of the form *YYYY*[*dMM*[*dDD*[Thht[mm[tss]]]]], where:
       
     * the *Y*s are the arabic numerals for the year,
     * the *M*s are the 1-based arabic numerals for the month,
     * the *D*s are the arabic numerals for the day in  the month,
     * the *h*s are the arabic numerals for the hour in the day,
     * the *m*s are the arabic numerals for the minute in the hour,
     * the *s*s are the arabic numerals for the second in the minute
     * the *d*s are date field separators and is 
       `-` if `extended` is true, otherwise the empty string,
     * the *T* separators the date fields from the time fields and it 
       `T` if `extended` is true, otherwise the empty string,
     * the *t*s are time field separators and is 
       `:` if `extended` is true, otherwise the empty string,
     * the `[]` are delimiting fields which may be omitted (according to 
       `fields`), and are not part of the output, and
     * the least significant field may include a decimal fraction part if
       `fractionDigits>0`
     "
shared Formatter<Datetime> isoDateTime<Datetime>(Gregorian<Datetime> gregorian,
    doc "True for *extended* format (with separators), false for *basic* format"
    Boolean extended=true,
    doc "The numer of digits in the year. Must be >=4. If `yearDigits>4` the 
         year will be signed (using `+` or `-`)"
    Integer yearDigits=4,
    doc "The number of fields, Must be between 1 and 6 inclusive"
    Integer fields=6,
    doc "The number of fractional digits in the least significant field"
    Integer fractionDigits=0) {
    
    assert(yearDigits >= 4);
    assert(fields>= 1, fields <= 6);
    assert(fractionDigits >= 0);

    value sb = SequenceBuilder<Formatter<Datetime>>();
    value dateFormatter = isoDate(gregorian, extended, 
        fields <= 3 then fields else 3, 
        fields <= 3 then fractionDigits else 0);
    sb.append(dateFormatter);
    if (fields >= 4) {
        if (extended) {
            sb.append(SeparatorFormatter<Datetime>("T"));
        }
        value timeFormatter = isoTime(gregorian, extended, fields-3, fractionDigits);
        sb.append(timeFormatter);
    }
    assert (nonempty parts=sb.sequence);
    return CompoundFormatter<Datetime>(parts);

}
//TODO iso time (time only) formatter
//TODO iso with timezone
//TODO iso durations
//TODO US-style dates
//TODO RFC-style dates?
//TODO XMLSchema-style dates?
