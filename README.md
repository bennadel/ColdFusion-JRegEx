
# [WIP] JRegExp - A ColdFusion Wrapper Around Java's Regular Expression Patterns

by [Ben Nadel][bennadel] (on [Google+][googleplus])

This is a work in progress ...

This is a ColdFusion wrapper around Java's Regular Expression pattern matching and
replacing functionality.

* jreFind( targetText, patternText [, startingAt = 1 ] ) :: number
* jreMatch( targetText, patternText ) :: array[string]
* jreMatchGroups( targetText, patternText ) :: array[struct]
* jreReplaceAll( targetText, patternText, replacementText [, quoteReplacement = false ] ) :: string
* jreReplaceEach( targetText, patternText, operator ) :: string
* jreReplaceFirst( targetText, patternText, replacementText [, quoteReplacement = false ] ) :: string
* jreSplit( targetText, patternText [, limit = 0 ] ) :: array[string]
* jreTest( targetText, patternText ) :: boolean


[bennadel]: http://www.bennadel.com
[googleplus]: https://plus.google.com/108976367067760160494?rel=author
