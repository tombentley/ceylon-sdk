doc "A formatter knows how to convert something to a String."
shared interface Formatter<in Thing> {
    
    doc "The string representation of the given thing."
    shared String format(Thing thing) {
        value sb = StringBuilder();
        formatTo(thing, sb);
        return sb.string;
    }
    
    doc "Appends the string representation of the given thing to the given
         builder, returning the builder."
    shared formal void formatTo(Thing thing, StringBuilder builder);
    
    //TODO What about a ceylon.io.CharacterBuffer, or a ceylon.file.Writer
}

doc "Formats `Object`s using their `string` attribute."
shared class ObjectFormatter() 
    satisfies Formatter<Object> {
    shared actual void formatTo(Object thing, StringBuilder builder) {
        builder.append(thing.string);    
    }
}

doc "Formats `null` using the given representation and delegates 
     formatting of all other values to the given formatter."
shared class NullFormatter(Formatter<Object> formatter, String nullRepresentation = "null")
    satisfies Formatter<Void> {
    shared actual void formatTo(Void thing, StringBuilder builder) {
        if (exists thing) {
            formatter.formatTo(thing, builder);
        } else {
            builder.append(nullRepresentation);
        }
    }
}

doc "A Formatter which formats values by delegating to each of the 
     given `formatters`. This can be useful for constructing a formatter from
     other formatters which each output only a part of the representation of 
     the value being formatted, and allows abstraction of the order of those 
     parts."
see (compoundFormatter)
shared class CompoundFormatter<in T>(formatters) satisfies Formatter<T>{
    shared Formatter<T>[] formatters;//TODO can we use tuple?
    shared actual void formatTo(T thing, StringBuilder builder) {
        for (formatter in formatters) {
            formatter.formatTo(thing, builder);
        }
    }
}

doc "A Formatter which unconditionally appends a separator to the output, 
     irrespective of the value of the thing being formatted. This can be  
     used in conjunction with a `CompoundFormatter` to separate different 
     fields in the representation of a value being formatted."
see (CompoundFormatter)
shared class SeparatorFormatter<in T>(
            String separator) 
        satisfies Formatter<T> {
    shared actual void formatTo(T thing, StringBuilder builder) {
        builder.append(separator);
    }
}

doc "Factory method for producing a compound formatter from a series of 
     separator strings and other formatters."
see (CompoundFormatter)
see (SeparatorFormatter)
CompoundFormatter<T> compoundFormatter<T>(String|Formatter<T>... xs) {
    value sb = SequenceBuilder<Formatter<T>>();
    for (x in xs) {
        if (is String x) {
            sb.append(SeparatorFormatter<T>(x));
        } else if (!is String x) { // Thanks Tako!
            sb.append(x);
        }
    } 
    return CompoundFormatter<T>(sb.sequence);
}

doc "Surrounds the output from another formatter with the given 
     prefix and suffix."
shared class Around<in Thing>(Formatter<Thing> formatter, 
        String prefix = "", 
        String suffix = "") 
    satisfies Formatter<Thing> {
    shared actual void formatTo(Thing thing, StringBuilder builder) {
        builder.append(prefix);
        formatter.formatTo(thing, builder);
        builder.append(suffix);
    }
}

/*String emptyString<T>(T t) {
    return "";
}

doc "A decorating `Formatter` which puts strings before and 
     after the output from another `Formatter`"
shared class Around<in Thing>(Formatter<Thing> next, 
        String before(Thing thing) = emptyString<Thing>, 
        String after(Thing thing) = emptyString<Thing>) satisfies Formatter<Thing> {
    shared actual void formatTo(Thing thing, StringBuilder builder) {
        builder.append(before(thing));
        next.formatTo(thing, builder);
        builder.append(after(thing));
    }
}
*/