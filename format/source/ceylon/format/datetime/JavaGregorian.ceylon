
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
    }
}

doc "Implementation of `Gregorian` in terms of a `java.util.Calendar`"
class JavaCalendarGregorian() satisfies Gregorian<Calendar> {
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

    shared actual Bottom timezoneAbbreviation(Calendar datetime) {
        return bottom;
    }

    shared actual Bottom timezoneName(Calendar datetime) {
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