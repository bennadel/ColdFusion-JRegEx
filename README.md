
# JRegEx - A ColdFusion Wrapper Around Java's Regular Expression Patterns

by [Ben Nadel][bennadel]

This is a ColdFusion wrapper around Java's Regular Expression pattern matching and
replacing functionality. The native ColdFusion POSIX Regular Expression support is
slow and somewhat limited. By using Java's Patterns, we can create faster, more robust
pattern-matching solutions.

Since ColdFusion uses 1-based offsets and Java uses 0-based offsets, any method that 
returns an Offset will be adjusted to use ColdFusion's 1-based offsets.

There are no `*NoCase()` versions of these methods. If you want to run a case-insensitive
pattern match, simply prepend the case-insensitivity flag `(?i)` to your Regular 
Expression pattern.

## `JRegEx.cfc`

This ColdFusion component provides generic Regular Expression support.

### `jreAfter( targetText, patternText )` :: String

I return the trailing portion of the string starting after the first match of the given pattern. If the pattern cannot be matched, the empty string is returned.

### `jreAfterLast( targetText, patternText )` :: String

I return the trailing portion of the string starting after the last match of the given pattern. If the pattern cannot be matched, the empty string is returned.

### `jreBefore( targetText, patternText )` :: String

I return the leading portion of the string up until first match of the given pattern. If the pattern cannot be matched, the entire string is returned.

### `jreBeforeLast( targetText, patternText )` :: String

I return the leading portion of the string up until last match of the given pattern. If the pattern cannot be matched, the entire string is returned.

### `jreEndingWith( targetText, patternText )` :: String

I return the leading portion of the string ending with the first match of the given pattern. If the pattern cannot be matched, the empty string is returned.

### `jreEndsWith( targetText, patternText )` :: Boolean

I determine if the given pattern can be matched at the end of the input.

### `jreEscape( patternText )` :: string

This takes a Java Regular Expression pattern and returns a literal version of it. This 
literal version can then be used in other JRegEx methods. This is essentially what the 
`quoteReplacement` argument is doing in some of the other methods.

### `jreFind( targetText, patternText [, startingAt = 1 ] )` :: number

This finds the offset of the first Java Regular Expression pattern match in the given 
target text. Returns zero if no match is found.

### `jreForEach( targetText, patternText, operator )` :: void

This iterates over each match of the given Java Regular Expression pattern found within 
the given target text. Each match and its captured groups are passed to the operator 
function. All operator function return values are ignored.

```cfc
// Count the number of matched patterns.
var count = 0;
jre.jreForEach(
	"hello there",
	"\b\w+\b",
	function( $0, start, targetText ) {

		count++;

	}
);
```

### `jreMap( targetText, patternText, operator )` :: array[any]

This iterates over each match of the given Java Regular Expression pattern found within 
the given target text. Each match and its captured groups are passed to the operator 
function which can return a mapped value. The mapped values are then aggregated and 
returned in an array. If the operator returns an undefined value, the match is omitted
from the results.

```cfc
// Capture each word and return it with an upper-case first letter.
var results = jre.jreMap(
	"hello there",
	"(\w)(\w*)",
	function( $0, head, tail, start, targetText ) {

		return( ucase( head ) & tail );

	}
);
```

### `jreMatch( targetText, patternText )` :: array[string]

This takes the given Java Regular Expression pattern and collects all matches of it 
that can be found within the given target text. That matches are returned as an array
of strings.

### `jreMatchGroups( targetText, patternText )` :: array[struct]

This takes the given Java Regular Expression pattern and collects all matches of it 
that can be found within the given target text. That matches are returned as an array
of structs in which each struct holds the captured groups of the match. The struct is
keyed based on the index of the captured group, within the pattern, with the `0` key 
containing the entire match text.

### `jreReplace( targetText, patternText, operator )` :: string

This iterates over each match of the given Java Regular Expression pattern found within
the given target text and passes the match to the operator function / closure. The 
operator function / closure can then return a replacement value that will be merged into
the resultant text. This is based on JavaScript's String.prototype.replace() method.

```cfc
// Replace each first letter with an upper-case letter.
var result = jre.jreReplace(
	"hello there",
	"\b[a-z]",
	function( $0, start, targetText ) {

		return( ucase( $0 ) );

	}
);
```

### `jreReplaceAll( targetText, patternText, replacementText [, quoteReplacement = false ] )` :: string

I replace all matches of the given Java Regular Expression pattern found within the given
target text with the given replacement text. The replacement text can contain `$N` 
references to captured groups within the pattern.

### `jreReplaceFirst( targetText, patternText, replacementText [, quoteReplacement = false ] )` :: string

I replace the first match of the given Java Regular Expression pattern found within the 
given target text with the given replacement text. The replacement text can contain `$N`
references to captured groups within the pattern.

### `jreSegment( targetText, patternText )` :: array[struct]

I use the given Java Regular Expression pattern to break the given target text up into 
segments. Unlike the `jreSplit()` method, this method returns both the pattern matches as
well as the text in between the matches. The resultant array contains a heterogeneous mix
of match and non-match structs. Each struct contains the following properties:

* `Match`: Boolean
* `Offset`: Numeric
* `Text`: String

Match structs also contain the property:

* `Groups`: Struct[Numeric] :: String

... which contains the captured groups of the match.

### `jreSplit( targetText, patternText [, limit = 0 ] )` :: array[string]

I use the given Java Regular Expression pattern to split the given target text. The 
resultant portions of the target text are returned as an array of strings.

### `jreStartingWith( targetText, patternText )` :: String

I return the trailing portion of the string starting with the first match of the given pattern. If the pattern cannot be matched, the empty string is returned.

### `jreStartsWith( targetText, patternText )` :: Boolean

I determine if the given pattern can be matched at the start of the input.

### `jreTest( targetText, patternText )` :: boolean

I test to see if the given Java Regular Expression pattern matches the entire target 
text. You can think of this as wrapping your pattern with `^` and `$` boundary sequences.


## `JRegExList.cfc`

This ColdFusion component provides list parsing functions in which the list delimiter is provided as a Regular Expression.

* `jreListFirst( list, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListGetAt( list, position, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListLast( list, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListLen( list, delimiterPattern [, includeEmptyFields] )` :: Number
* `jreListMap( list, callback, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListRest( list, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListSetAt( list, position, value, delimiterPattern [, includeEmptyFields] )` :: String
* `jreListToArray( list, delimiterPattern [, includeEmptyFields] )` :: Array
* `jreSegment( list, delimiterPattern )` :: Array


[bennadel]: https://www.bennadel.com/
