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
     formatters in a given sequence."
shared class CompoundFormatter<in T>(Formatter<T>[] formatters) satisfies Formatter<T>{
    shared actual void formatTo(T thing, StringBuilder builder) {
        for (formatter in formatters) {
            formatter.formatTo(thing, builder);
        }
    }
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