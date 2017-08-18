component
	output = false
	semvar = "0.0.1"
	hint = "I provide a simplified API around the Regular Expression power of the underlying Java platform. There are no 'NoCase' method since Java RegEx Patterns can be made case-insensitive by start with a (?i) flag."
	{

	/**
	* I return an initialized Java RegEx utility library.
	*/
	public any function init() {

		// ... nothing to do here.

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I determine the index of the first Java Regular Expression pattern within the given
	* target text. If no match can be found, returns zero.
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate the first match.
	* @startingAt I am the offset (default 1) at which to start searching.
	* @output false
	*/
	public numeric function jreFind(
		required string targetText,
		required string patternText,
		numeric startingAt = 1
		) {

		var matcher = createMatcher( targetText, patternText );

		// NOTE: We're subtracting -1 to comply with Java's 0-based indexing.
		if ( matcher.find( javaCast( "int", ( startingAt - 1 ) ) ) ) {

			// NOTE: We're adding +1 to comply with ColdFusion's 1-based indexing.
			return( matcher.start() + 1 );

		}

		return( 0 );

	}


	/**
	* I return all of the Java Regular Expression pattern matches in the given target
	* text. The matches are returned as an array of strings.
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @output false
	*/
	public array function jreMatch(
		required string targetText,
		required string patternText
		) {

		var matcher = createMatcher( targetText, patternText );
		var results = [];

		// Iterate over each pattern match in the target text.
		while ( matcher.find() ) {

			arrayAppend( results, matcher.group() );

		}

		return( results );

	}


	/**
	* I return all of the Java Regular Expression pattern matches in the given target
	* text. Unlike the .jreMatch() method, this method returns the matches as an array
	* of structures in which the captured-group index (0..N) is the key of the struct.
	* If a captured-group failed to match, its index will hold an empty string.
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @output false
	*/
	public array function jreMatchGroups(
		required string targetText,
		required string patternText
		) {

		var matcher = createMatcher( targetText, patternText );
		var results = [];

		// Iterate over each pattern match in the target text.
		while ( matcher.find() ) {

			// Each result will be a structure in which the keys correspond to the index
			// of the captured groups with the zero-key being the entire match.
			var groups = {};
			var groupCount = matcher.groupCount();

			// Add each captured group to the resultant struct.
			for ( var i = 0 ; i <= groupCount ; i++ ) {

				groups[ i ] = matcher.group( javaCast( "int", i ) );

				// If the group failed to match, it will be undefined. In order to make
				// this easier to consume, let's report it as the empty string.
				if ( ! structKeyExists( groups, i ) ) {

					groups[ i ] = "";

				}

			}

			arrayAppend( results, groups );

		}

		return( results );

	}


	/**
	* I replace all instances of the given Java Regular Expression pattern matches with
	* the given replacement text.
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @replacementText I am the text replacing the pattern matches. I can use $ to reference captured groups.
	* @quoteReplacement I determine if the replacement text should be escaped (so as not to accidentally reference captured groups).
	* @output false
	*/
	public string function jreReplaceAll(
		required string targetText,
		required string patternText,
		required string replacementText,
		boolean quoteReplacement = false
		) {

		var matcher = createMatcher( targetText, patternText );

		var result = quoteReplacement
			? matcher.replaceAll( matcher.quoteReplacement( javaCast( "string", replacementText ) ) )
			: matcher.replaceAll( javaCast( "string", replacementText ) )
		;

		return( result );

	}


	/**
	* I use Java's Pattern / Matcher libraries to replace matched patterns using the
	* given operator function or closure.
	*
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @operator I am the Function or Closure used to provide the match replacements.
	* @output false
	*/
	public string function jreReplaceEach(
		required string targetText,
		required string patternText,
		required function operator
		) {

		var matcher = createMatcher( targetText, patternText );
		var buffer = createBuffer();

		// Iterate over each pattern match in the target text.
		while ( matcher.find() ) {

			// When preparing the arguments for the operator, we need to construct an
			// argumentCollection structure in which the argument index is the numeric
			// key of the argument offset. In order to simplify overlaying the pattern
			// group matching over the arguments array, we're simply going to keep an
			// incremented offset every time we add an argument.
			var operatorArguments = {};
			var operatorArgumentOffset = 1; // Will be incremented with each argument.

			var groupCount = matcher.groupCount();

			// NOTE: Calling .group(0) is equivalent to calling .group(), which will
			// return the entire match, not just a capturing group.
			for ( var i = 0 ; i <= groupCount ; i++ ) {

				operatorArguments[ operatorArgumentOffset++ ] = matcher.group( javaCast( "int", i ) );

			}

			// Including the match offset and the original content for parity with the
			// JavaScript String.replace() function on which this algorithm is based.
			// --
			// NOTE: We're adding 1 to the offset since ColdFusion starts offsets at 1
			// where as Java starts offsets at 0.
			operatorArguments[ operatorArgumentOffset++ ] = ( matcher.start() + 1 );
			operatorArguments[ operatorArgumentOffset++ ] = targetText;

			var replacement = operator( argumentCollection = operatorArguments );

			// In the event the operator doesn't return a value, we'll assume that the
			// intention is to replace the match with nothing.
			if ( isNull( replacement ) ) {

				replacement = "";

			}

			// Since the operator is providing the replacement text based on the
			// individual parts found in the match, we are going to assume that any
			// embedded group reference is coincidental and should be consumed as a
			// string literal.
			matcher.appendReplacement(
				buffer,
				matcher.quoteReplacement( javaCast( "string", replacement ) )
			);

		}

		matcher.appendTail( buffer );

		return( buffer.toString() );

	}


	/**
	* I replace the first instance of the given Java Regular Expression pattern match
	* with the given replacement text, 
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @replacementText I am the text replacing the first pattern match. I can use $ to reference captured groups.
	* @quoteReplacement I determine if the replacement text should be escaped (so as not to accidentally reference captured groups).
	* @output false
	*/
	public string function jreReplaceFirst(
		required string targetText,
		required string patternText,
		required string replacementText,
		boolean quoteReplacement = false
		) {

		var matcher = createMatcher( targetText, patternText );

		var result = quoteReplacement
			? matcher.replaceFirst( matcher.quoteReplacement( javaCast( "string", replacementText ) ) )
			: matcher.replaceFirst( javaCast( "string", replacementText ) )
		;

		return( result );

	}


	/**
	* I split the given target text using the given Java Regular Expression pattern.
	* 
	* @targetText I am the text being split.
	* @patternText I am the Java Regular Expression pattern used to split.
	* @limit I am the limit of the splits (zero means no limit).
	* @output false
	*/
	public array function jreSplit(
		required string targetText,
		required string patternText,
		numeric limit = 0
		) {

		var results = limit
			? javaCast( "string", targetText ).split( javaCast( "string", patternText ), javaCast( "int", limit ) )
			: javaCast( "string", targetText ).split( javaCast( "string", patternText ) )
		;

		return( results );

	}


	/**
	* I determine if the entire target text can be matched by the given Java Regular
	* Expression pattern.
	* 
	* @targetText I am the text being tested.
	* @patternText I am the Java Regular Expression pattern used to test.
	* @output false
	*/
	public boolean function jreTest(
		required string targetText,
		required string patternText
		) {

		return( createMatcher( targetText, patternText ).matches() );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I create a Java String Buffer used to incrementally gather pattern replacements.
	* 
	* @output false
	*/
	private any function createBuffer() {

		return( createObject( "java", "java.lang.StringBuffer" ).init() );

	}


	/**
	* I create a Java Pattern Matcher for the given target text and pattern text.
	* 
	* @targetText I am the text being scanned.
	* @patternText I am the Java Regular Expression pattern used to locate matches.
	* @output false
	*/
	private any function createMatcher(
		required string targetText,
		required string patternText 
		) {

		var matcher = createObject( "java", "java.util.regex.Pattern" )
			.compile( javaCast( "string", patternText ) )
			.matcher( javaCast( "string", targetText ) )
		;

		return( matcher );

	}

}