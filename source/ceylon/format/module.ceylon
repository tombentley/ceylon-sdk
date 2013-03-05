doc "Facilities for formatting objects, with particular support for formatting 
     numbers and dates.
     
     The `Formatter` interface provides an abstraction that allows objects 
     to be formatted in arbitrary ways. A few general purpose Formatters are 
     provided in the `ceylon.format` package.
     
     The `ceylon.format.number` package provides `Formatter`s and factories for
     `Formatter`s which handle numbers, including but not limited to 
     `Integer`, `Float`, `Whole` and `Decimal` numbers.
     
     The `ceylon.format.datetime` package provides `Formatter`s and factories 
     for `Formatter`s which handle dates and times."
see("ceylon.format.Formatter")
module ceylon.format '0.5' {
    shared import ceylon.math '0.5';
    import java.base '7';
} 
