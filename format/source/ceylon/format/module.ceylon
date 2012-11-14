doc "Facilities for formatting objects, with particular support for formatting 
     numbers and dates.
     
     The `Formatter` interface provides an abstraction that allows objects 
     to be formatted in arbitrary ways. A few general purpose Formatters are 
     provided in the `ceylon.format` package.
     
     The `ceylon.format.number` package provides `Formatter`s and factories for
     `Formatter`s which handle numbers, including but not limited to 
     `Integer`, `Float`, `Whole` and `Decimal` numbers."
see(Formatter)
module ceylon.format '0.1.0' {
    import ceylon.math '0.4';
    import ceylon.collection '0.4';
} 
