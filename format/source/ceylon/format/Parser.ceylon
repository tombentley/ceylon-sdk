shared interface Parser<out Thing> given Thing satisfies Object {
    doc "The thing represented by the given String representation, or null if 
         the given String was not a valid representation."
    shared formal Thing? parse(String input);
}
