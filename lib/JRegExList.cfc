component
	output = false
	hint = "I provide methods for parsing lists using Java-based Regular Expression delimiters. There are no 'NoCase' methods here since Java's RegEx Patterns can all be made case-insensitive by starting them with a case-insensitive (?i) flag."
	{

	/**
	* I initialize the component.
	*/
	public void function init() {

		CollectionsClass = createObject( "java", "java.util.Collections" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the first item in the list using the given RegEx delimiter pattern.
	*/
	public string function jreListFirst(
		required string list,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		for ( var segment in jreSegment( list, delimiterPattern ) ) {

			if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

				return( segment.text );

			}

		}

		return( "" );

	}


	/**
	* I return the item at the given position in the list using the given RegEx delimiter
	* pattern. If the position is out-of-bounds, the empty string is returned.
	* 
	* CAUTION: ColdFusion's native listGetAt() function throws an error for out-of-bounds
	* positions. As such, this is an intentional deviation from that approach.
	*/
	public string function jreListGetAt(
		required string list,
		required numeric position,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var itemCount = 0;

		for ( var segment in jreSegment( list, delimiterPattern ) ) {

			if (
				segment.isItem &&
				( segment.text.len() || includeEmptyFields ) &&
				( ++itemCount == position )
				) {

				return( segment.text );

			}

		}

		return( "" );

	}


	/**
	* I return the last item in the list using the given RegEx delimiter pattern. If the
	* list is empty, the empty string is returned.
	*/
	public string function jreListLast(
		required string list,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		// CAUTION: We are calling reverseOrder() on the segments. This means that by
		// finding the FIRST item in the resultant array, we're actually finding the LAST
		// item in the original array.
		for ( var segment in reverseOrder( jreSegment( list, delimiterPattern ) ) ) {

			if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

				return( segment.text );

			}

		}

		return( "" );

	}


	/**
	* I return the length of the list using the given RegEx delimiter pattern.
	*/
	public numeric function jreListLen(
		required string list,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var itemCount = 0;

		for ( var segment in jreSegment( list, delimiterPattern ) ) {

			if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

				itemCount++;

			}

		}

		return( itemCount );

	}


	/**
	* I return the mapped list using the given RegEx delimiter pattern and operator.
	*/
	public string function jreListMap(
		required string list,
		required function callback,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var segments = jreSegment( list, delimiterPattern );
		var itemCount = 0;

		for ( var segment in segments ) {

			if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

				segment.text = callback( segment.text, ++itemCount, list, delimiterPattern, includeEmptyFields );

			}

		}

		return( joinSegments( segments ) );

	}


	/**
	* I return the list without the first item (and its surrounding delimiters) using the
	* given RegEx delimiter pattern.
	*/
	public string function jreListRest(
		required string list,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var itemCount = 0;
		// When getting the "rest" of the list items, we want to drop the first item and
		// its surrounding delimiters. As such, we only want to start collecting segments
		// when we find our SECOND item.
		var restOfSegments = jreSegment( list, delimiterPattern ).filter(
			( segment ) => {

				if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

					itemCount++;

				}

				return( itemCount >= 2 );

			}
		);

		return( joinSegments( restOfSegments ) );

	}


	/**
	* I set the item at the given position in the list using the given RegEx delimiter
	* pattern. If the position is out-of-bounds, the original list is returned.
	* 
	* CAUTION: ColdFusion's native listSetAt() function throws an error for out-of-bounds
	* positions. As such, this is an intentional deviation from that approach.
	*/
	public string function jreListSetAt(
		required string list,
		required numeric position,
		required string value,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var segments = jreSegment( list, delimiterPattern );
		var itemCount = 0;

		for ( var segment in segments ) {

			if (
				segment.isItem &&
				( segment.text.len() || includeEmptyFields ) &&
				( ++itemCount == position )
				) {

				segment.text = value;
				break;

			}

		}

		return( joinSegments( segments ) );

	}


	/**
	* I extract the items from the list using the given RegEx delimiter pattern.
	*/
	public array function jreListToArray(
		required string list,
		required string delimiterPattern,
		boolean includeEmptyFields = false
		) {

		var items = [];

		for ( var segment in jreSegment( list, delimiterPattern ) ) {

			if ( segment.isItem && ( segment.text.len() || includeEmptyFields ) ) {

				items.append( segment.text );

			}

		}

		return( items );

	}


	/**
	* I split the given list into segments using the given delimiter RegEx pattern. Empty
	* items are always collected between neighboring delimiters. It is up to the calling
	* context to exclude empty items if desired.
	*/
	public array function jreSegment(
		required string list,
		required string delimiterPattern
		) {

		testDelimiterPattern( delimiterPattern );

		var matcher = createObject( "java", "java.util.regex.Pattern" )
			.compile( delimiterPattern )
			.matcher( list )
		;
		var segments = [];

		// NOTE: Technically, CFML Strings are Java Strings; however, since we're going to
		// dip down into the Java layer methods, it's comforting to explicitly cast the
		// value to the native Java type if nothing else to provide some documentation as
		// to where those method are coming from.
		var input = javaCast( "string", list );
		var endOfLastMatch = 0;

		// Search for list delimiters.
		while ( matcher.find() ) {

			// If the start of the current match lines-up with the end of the previous
			// match, it means that there was no non-delimiter value between the two
			// matched delimiters. As such, we need to insert an empty-item.
			if ( matcher.start() == endOfLastMatch ) {

				segments.append({
					isItem: true,
					isDelimiter: false,
					text: ""
				});

			// If the start of the current match does NOT line-up with the end of the
			// previous match, it means we have a non-delimiter value to collect from
			// between the two matched delimiters.
			} else {

				segments.append({
					isItem: true,
					isDelimiter: false,
					text: input.substring( endOfLastMatch, matcher.start() )
				});

			}

			segments.append({
				isItem: false,
				isDelimiter: true,
				text: matcher.group()
			});

			endOfLastMatch = matcher.end();

		}

		// If the last match ended before the end of the input, it means that we have some
		// non-delimiter text at the end of the list to collect.
		if ( endOfLastMatch < input.length() ) {

			segments.append({
				isItem: true,
				isDelimiter: false,
				text: input.substring( endOfLastMatch )
			});

		// If the last delimiter match also hit the end of the input, it means that we
		// have to append an empty item after the last delimiter.
		} else {

			segments.append({
				isItem: true,
				isDelimiter: false,
				text: ""
			});

		}

		return( segments );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I collapse the given list segments down into a single string value.
	*/
	private string function joinSegments( required array segments ) {

		var list = segments
			.map(
				( segment ) => {

					return( segment.text );

				}
			)
			.toList( "" )
		;

		return( list );

	}


	/**
	* I reverse the order of the items in the given array.
	*/
	private array function reverseOrder( required array values ) {

		CollectionsClass.reverse( values );
		return( values );

	}


	/**
	* I test the given delimiter pattern. If it is empty, an error is thrown.
	*/
	private void function testDelimiterPattern( required string delimiterPattern ) {

		if ( ! delimiterPattern.len() ) {

			throw(
				type = "JRegExList.EmptyPattern",
				message = "The Regular Expression pattern for delimiters cannot be empty."
			);

		}

	}

}
