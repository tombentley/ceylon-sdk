doc "A formatter knows how to convert something to a String."
shared interface Formatter<in Item> {
    
    doc "The string representation of the given thing."
    shared String format(Item item) {
        value sb = StringBuilder();
        formatTo(item, sb);
        return sb.string;
    }
    
    doc "Appends the string representation of the given thing to the given
         builder, returning the builder."
    shared formal void formatTo(Item item, StringBuilder builder);
    
    //TODO What about a ceylon.io.CharacterBuffer, or a ceylon.file.Writer
}

doc "Formats `Object`s using their `string` attribute."
shared class ObjectFormatter() 
    satisfies Formatter<Object> {
    shared actual void formatTo(Object item, StringBuilder builder) {
        builder.append(item.string);    
    }
}

doc "Formats `null` using the given representation and delegates 
     formatting of all other values to the given formatter."
shared class NullFormatter(Formatter<Object> formatter, String nullRepresentation = "null")
    satisfies Formatter<Void> {
    shared actual void formatTo(Void item, StringBuilder builder) {
        if (exists item) {
            formatter.formatTo(item, builder);
        } else {
            builder.append(nullRepresentation);
        }
    }
}

doc "A cons cell, a singly linked list. Supports efficient 
     (non-allocating) iteration using a `while` loop:
     
         variable Cons<T>? head := list;
         while (exists h=head) {
             value x = h.element;
             head := h.rest;
         }
     "
class Cons<out Element>(element, rest) {
    doc "The head element"
    shared Element element;
    doc ""
    shared Cons<Element>? rest;
}

doc "Constructs a `Cons` from a sequence of elements, 
     or prepends the elements to the given cons list."
Cons<Element> cons<in Element>(Sequence<Element> elements, Cons<Element>? tail = null) {
    variable Cons<Element>? head := tail;
    for (element in elements.reversed) {
        head := Cons(element, head);
    }
    assert (exists result=head);
    return result;
}

doc "A Formatter which formats values by delegating to each of the 
     given `formatters`. This can be useful for constructing a formatter from
     other formatters which each output only a part of the representation of 
     the value being formatted, and allows abstraction of the order of those 
     parts."
see (compoundFormatter)
shared class CompoundFormatter<in Item>(Sequence<Formatter<Item>> formatters) satisfies Formatter<Item>{
    // We could use a sequence or a tuple, but then then every call to 
    // formatTo would result in the creation of an iterator, 
    // we can iterate a cons without allocating
    Cons<Formatter<Item>> head = cons(formatters);//TODO can we use tuple?
    shared actual void formatTo(Item item, StringBuilder builder) {
        variable Cons<Formatter<Item>>? node := head;
        while (exists cons=node) {
            cons.element.formatTo(item, builder);
            node := cons.rest;
        }
    }
}

doc "A Formatter which unconditionally appends a separator to the output, 
     irrespective of the value of the thing being formatted. This can be  
     used in conjunction with a `CompoundFormatter` to separate different 
     fields in the representation of a value being formatted."
see (CompoundFormatter)
shared class SeparatorFormatter<in Item>(
            String separator) 
        satisfies Formatter<Item> {
    shared actual void formatTo(Item item, StringBuilder builder) {
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
    value s = sb.sequence;
    assert (nonempty s);
    return CompoundFormatter<T>(s);
}

doc "Surrounds the output from another formatter with the given 
     prefix and suffix."
shared class Around<in Item>(Formatter<Item> formatter, 
        String prefix = "", 
        String suffix = "") 
    satisfies Formatter<Item> {
    shared actual void formatTo(Item item, StringBuilder builder) {
        builder.append(prefix);
        formatter.formatTo(item, builder);
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