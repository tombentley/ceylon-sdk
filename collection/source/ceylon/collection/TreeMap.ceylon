class Node<Key,Value>(Node<Key,Value>? left = null, Node<Key,Value>? right = null) {
    shared variable Node<Key,Value>? l := left;
    shared variable Node<Key,Value>? r := right;
}

doc "A Map implementation what uses a Reb-Black tree"
shared class RedBlackMap<Key,Value>(comparator, Entry<Key,Value>... initialEntries) 
        satisfies MutableMap<Key,Value> 
        given Key satisfies Object
        given Value satisfies Object {
    
    variable Node<Key,Value>? root := null;
    variable Integer _size := 0;
    doc "The comparator function used by this map"
    shared Comparison(Key,Key) comparator; 
    
    shared actual Map<Key,Value> clone = bottom;//TODO

    shared actual Value? item(Object key) {
        return bottom;//TODO
    }

    shared actual Iterator<Entry<Key,Value>> iterator = bottom;//TODO

    shared actual Integer size {
        return _size;
    }

    shared actual Integer hash = bottom;//TODO

    shared actual Boolean equals(Object other) {
        return bottom;//TODO
    }
    shared actual void clear() {
        root := null;
        _size := 0;
    }
    shared actual void put(Key key, Value item) {
        //TODO
    }
    shared actual void putAll(Entry<Key,Value>... entries) {
        //TODO
    }
    shared actual void remove(Key key) {
        //TODO
    }
    
    putAll(initialEntries...);
}