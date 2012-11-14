shared interface Input<State> satisfies Iterator<Character> {
    shared formal State mark();
    shared formal void restore(State state);
}

shared interface Parser<out Thing> given Thing satisfies Object {
    doc "The thing represented by the given String representation, or null if 
         the given String was not a valid representation."
    shared formal Thing? parse(Iterator<Character> input);
}
/*
shared class Concatenation<out Things, out First, out Rest> satisfies Parser<First> 
    given Things satisfies Tuple<Things, First, Rest>
    given First satisfies Object
    given Rest satisfies Sequential<Things> {
    
}

shared class Alternation<out Thing>(Parser<Thing>[] p) satisfies Parser<Thing> given Thing satisfies Object{
    shared actual Thing? parse(Iterator<Character> input) {
        //TODO mark
        for (parser in p) {
            value result = parser.parse(input);
            if (exists result) {
                return result;
            }
            //TODO reset
        }
        return null;
    }
}

shared class Repetition<out Thing>(Parser<Thing> parser) satisfies Parser<Thing[]> given Thing satisfies Object{
    
    shared actual Nothing|Empty|Sequence<Thing> parse(Iterator<Character> input) {
        SequenceBuilder<Thing> b = SequenceBuilder<Thing>();
        while (true) {
            //TODO mark
            value result = parser.parse(input);
            if (exists result) {
                b.append(result);
                continue;
            }
            //TODO reset
            break;
            
        }
        return b.sequence;
    }
}*/