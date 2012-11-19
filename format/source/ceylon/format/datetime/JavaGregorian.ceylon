
import java.util{ 
    Calendar {
        jYear=\iYEAR,
        jMonth=\iMONTH,
        
        jDayInMonth=\iDAY_OF_MONTH,
        jDayInWeek=\iDAY_OF_WEEK,
        jDayInYear=\iDAY_OF_YEAR,
        
        jWeekInYear=\iWEEK_OF_YEAR,
        jWeekInMonth=\iWEEK_OF_MONTH,
        
        jHour=\iHOUR_OF_DAY,
        jMinute=\iMINUTE,
        jSecond=\iSECOND,
        jMillisecond=\iMILLISECOND,
        
        jZoneOffset=\iZONE_OFFSET
    },
    GregorianCalendar,
    Date,
    TimeZone { defaultTimeZone=default }
}

doc "Implementation of `Gregorian` in terms of a `java.util.Calendar`"
object javaCalendarGregorian satisfies Gregorian<Calendar> {
    shared actual Integer dayInMonth(Calendar datetime) {
        return datetime.get(jDayInMonth)-1;
    }

    shared actual Integer dayInWeek(Calendar datetime) {
        return datetime.get(jDayInWeek)-1;
    }

    shared actual Integer dayInYear(Calendar datetime) {
        return datetime.get(jDayInYear)-1;
    }

    shared actual Integer hour(Calendar datetime) {
        return datetime.get(jHour);
    }

    shared actual Integer millisecond(Calendar datetime) {
        return datetime.get(jMillisecond);
    }

    shared actual Integer minute(Calendar datetime) {
        return datetime.get(jMinute);
    }

    shared actual Integer month(Calendar datetime) {
        return datetime.get(jMonth);
    }

    shared actual Integer second(Calendar datetime) {
        return datetime.get(jSecond);
    }

    shared actual String timezoneAbbreviation(Calendar datetime) {
        return bottom;
    }

    shared actual String timezoneName(Calendar datetime) {
        return bottom;
    }

    shared actual Integer timezoneOffset(Calendar datetime) {
        return datetime.get(jZoneOffset);
    }

    shared actual Integer weekInMonth(Calendar datetime) {
        return datetime.get(jWeekInMonth);
    }

    shared actual Integer weekInYear(Calendar datetime) {
        return datetime.get(jWeekInYear);
    }

    shared actual Integer year(Calendar datetime) {
        return datetime.get(jYear);
    }
}

doc "Implementation of `Gregorian` in terms of a `java.util.Date`, using a 
    `java.util.GregorianCalendar`. 
     
     Not thread safe."
class JavaDateGregorian(TimeZone timezone=defaultTimeZone) satisfies Gregorian<Date> {
    GregorianCalendar cal = GregorianCalendar(timezone);
    shared actual Integer dayInMonth(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.dayInMonth(cal);
    }
    shared actual Integer dayInWeek(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.dayInWeek(cal);
    }
    shared actual Integer dayInYear(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.dayInYear(cal);
    }
    shared actual Integer hour(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.hour(cal);
    }
    shared actual Integer millisecond(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.millisecond(cal);
    }
    shared actual Integer minute(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.minute(cal);
    }
    shared actual Integer month(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.month(cal);
    }
    shared actual Integer second(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.second(cal);
    }
    shared actual String timezoneAbbreviation(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.timezoneAbbreviation(cal);
    }
    shared actual String timezoneName(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.timezoneName(cal);
    }
    shared actual Integer timezoneOffset(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.timezoneOffset(cal);
    }
    shared actual Integer weekInMonth(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.weekInMonth(cal);
    }
    shared actual Integer weekInYear(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.weekInYear(cal);
    }
    shared actual Integer year(Date datetime) {
        cal.time := datetime;
        return javaCalendarGregorian.year(cal);
    }
}