
Integer[][] daysInMonth = {
    {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
    {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
};

Integer[][] cumulativeDaysInMonth = {
    {31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 },
    {31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 }
};

doc "A simple implementation of `Gregorian`, using the usual Integer 
     representation of a date time as the number of milliseconds since 00:00 
     January 1, 1970, ignoring things like leap seconds and timezones"
object integerGregorian satisfies Gregorian<Integer> {
    doc "Returns 1 if the given datetime is in a leapyear, otherwise 0"
    Integer leap(Integer datetime) {
        value y = year(datetime);
        return  y % 4 == 0 
            && ! (( y % 100 == 0) || !( y % 400 == 0)) then 1 else 0;
    }
    shared actual Integer dayInMonth(Integer datetime) {
        value v = daysInMonth[leap(datetime)];
        assert (exists v);
        value x = v[month(datetime)];
        assert (exists x);
        return x;
    }

    shared actual Integer dayInWeek(Integer datetime) {
        // 1st Jan 1970 was a Thursday
        return (datetime/(1000*60*60*24))// days since 1970 
                    % 7 + 4;
    }

    shared actual Integer dayInYear(Integer datetime) {
        value v = cumulativeDaysInMonth[leap(datetime)];
        assert (exists v);
        value x = v[month(datetime)];
        assert (exists x);
        return x;
    }

    shared actual Integer hour(Integer datetime) {
        return datetime/(1000*60*60);
    }

    shared actual Integer millisecond(Integer datetime) {
        return datetime%1000;
    }

    shared actual Integer minute(Integer datetime) {
        return datetime%(1000*60*60);
    }

    shared actual Integer month(Integer datetime) {
        return bottom;
    }

    shared actual Integer second(Integer datetime) {
        return datetime%(1000*60);
    }

    shared actual Integer weekInMonth(Integer datetime) {
        return bottom;
    }

    shared actual Integer weekInYear(Integer datetime) {
        return bottom;
    }

    shared actual Integer year(Integer datetime) {
        return datetime/(1000*60*60*24*365);
        //TODO need to adjust for leap years
    }
    
    shared actual String timezoneAbbreviation(Integer datetime) {
        return bottom;
    }

    shared actual String timezoneName(Integer datetime) {
        return bottom;
    }

    shared actual Integer timezoneOffset(Integer datetime) {
        return bottom;
    }
}

void main() {
    print("Year: " integerGregorian.year(process.milliseconds) "");
    print("Day in week: " integerGregorian.dayInWeek(process.milliseconds) "");
    
}