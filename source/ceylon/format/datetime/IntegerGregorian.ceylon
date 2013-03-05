
Integer[][] daysInMonth = [
    [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
    [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
];

Integer[][] cumulativeDaysInMonth = [
    [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 ],
    [31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 ]
];

doc "A simple implementation of `Gregorian`, using the usual Integer 
     representation of a date time as the number of milliseconds since 00:00 
     January 1, 1970, ignoring things like leap seconds and timezones"
object integerGregorian satisfies Gregorian<Integer> {
    
    doc "Returns true if the given year is a leap year"
    function isLeap(Integer year) {
        return year % 4 == 0 
            && ! (( year % 100 == 0) || !( year % 400 == 0)) then 1 else 0;
    }
    
    doc "Returns 1 if the given datetime is in a leapyear, otherwise 0."
    Integer inLeap(Integer datetime) {
        return isLeap(year(datetime));
    }
    shared actual Integer dayInMonth(Integer datetime) {
        value v = daysInMonth[inLeap(datetime)];
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
        value v = cumulativeDaysInMonth[inLeap(datetime)];
        assert (exists v);
        value x = v[month(datetime)];
        assert (exists x);
        return x;
    }

    shared actual Integer hour(Integer datetime) {
        return (datetime - (datetime/(1000*60*60))*(1000*60*60))/1000*60*60;
        //value hoursSinceMidnight = datetime%(1000*60*60);
        //return (datetime - hoursSinceEpoch*1000*60*60)%(1000*60*60);
        //return (datetime - (hoursSinceEpoch * 1000*60*60);
    }

    shared actual Integer millisecond(Integer datetime) {
        return datetime%1000;
    }

    shared actual Integer minute(Integer datetime) {
        return datetime%(1000*60*60);
    }

    shared actual Integer month(Integer datetime) {
        value millisSinceNewYear = datetime - (year(datetime)-1970)*(1000*60*60*24*365);
        return nothing;
    }

    shared actual Integer second(Integer datetime) {
        return datetime/1000 - (datetime/(1000))*1000;
    }

    shared actual Integer weekInMonth(Integer datetime) {
        return nothing;
    }

    shared actual Integer weekInYear(Integer datetime) {
        return nothing;
    }

    shared Integer leaps(Integer datetime) {
        // '72 was a leap year
        // need to know leap year rule
        return (datetime - (1000*60*60*24*365)*2)/((1000*60*60*24*365)*4 + (1000*60*60*24)); 
    }

    shared actual Integer year(Integer datetime) {
        
        return datetime/(1000*60*60*24*365) + 1970;
        //TODO need to adjust for leap years
        //value daysSinceEpoch = datetime/(1000*60*60*24);
        //value daysSinceLeapAfterEpoch = daysSinceEpoch - (1000*60*60*24*365)*2;
    }
    
    shared actual String timezoneAbbreviation(Integer datetime) {
        return nothing;
    }

    shared actual String timezoneName(Integer datetime) {
        return nothing;
    }

    shared actual Integer timezoneOffset(Integer datetime) {
        return nothing;
    }
}

void main() {
    value t = process.milliseconds;
    
    
    print("Millisecond: `` integerGregorian.millisecond(t) ``");
    print("Second: `` integerGregorian.second(t) ``");
    print("Minute: `` integerGregorian.minute(t) ``");
    print("Hour: `` integerGregorian.hour(t) ``");
    //print("Day in month: `` integerGregorian.dayInMonth(t) ``");
    print("Day in week: `` integerGregorian.dayInWeek(t) ``");
    //print("Day in year: `` integerGregorian.dayInYear(t) ``");
    //print("Week in month: `` integerGregorian.weekInMonth(t) ``");
    //print("Week in year: `` integerGregorian.weekInYear(t) ``");
    //print("Month: `` integerGregorian.month(t) ``");
    print("Year: `` integerGregorian.year(t) ``");
    print("Leaps: `` integerGregorian.leaps(t) ``");
}