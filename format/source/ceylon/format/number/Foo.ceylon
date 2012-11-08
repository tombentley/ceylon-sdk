class Foo(String s="") {
    shared default void m(Integer i = 0) {}
}

class Bar(String s) extends Foo(s) {
    shared actual default void m(Integer i) {
    }
}

void x() {
    Bar f = Bar("");
    f.m();
}