component
	extends = "TestCase"
	output = false
	hint = "I test JRegEx."
	{

	public void function testJreEscape() {

		var jre = new lib.JRegEx();

		assert( jre.jreFind( "**++??", jre.jreEscape( "**++??" ) ) == 1 );
		
	}


	public void function testJreFind() {

		var jre = new lib.JRegEx();

		assert( jre.jreFind( "abc", "d" ) == 0 );
		assert( jre.jreFind( "abc", "a" ) == 1 );
		assert( jre.jreFind( "abc", "b" ) == 2 );
		assert( jre.jreFind( "abc", "c" ) == 3 );
		assert( jre.jreFind( "abc", "^abc$" ) == 1 );
		assert( jre.jreFind( "aabbbcc", "b{3}" ) == 3 );

		assert( jre.jreFind( "abc", "d" ) == reFind( "d", "abc" ) );
		assert( jre.jreFind( "abc", "a" ) == reFind( "a", "abc" ) );
		assert( jre.jreFind( "abc", "b" ) == reFind( "b", "abc" ) );
		assert( jre.jreFind( "abc", "c" ) == reFind( "c", "abc" ) );
		assert( jre.jreFind( "abc", "^abc$" ) == reFind( "^abc$", "abc" ) );
		assert( jre.jreFind( "aabbbcc", "b{3}" ) == reFind( "b{3}", "aabbbcc" ) );
		
	}


	public void function testJreMap() {

		var jre = new lib.JRegEx();

		var results = jre.jreMap(
			"abcdef",
			"(\w)",
			function( $0, $1, start, targetText ) {

				assert( $0 == $1 );
				assert( targetText == "abcdef" );

				if ( jre.jreTest( $1, "[aeiouy]" ) ) {

					return( ucase( $1 ) );

				}

			}
		);

		assert( arrayLen( results ) == 2 );
		assert( ! compare( results[ 1 ], "A" ) );
		assert( ! compare( results[ 2 ], "E" ) );
	
	}


	public void function testJreMatch() {

		var jre = new lib.JRegEx();

		var matches = jre.jreMatch( "aabbcc", "(\w)\1" );

		assert( arrayLen( matches ) == 3 );
		assert( matches[ 1 ] == "aa" );
		assert( matches[ 2 ] == "bb" );
		assert( matches[ 3 ] == "cc" );
		
	}


	public void function testJreMatchGroups() {

		var jre = new lib.JRegEx();

		var matches = jre.jreMatchGroups( "aabbccz", "(\w)\1(z)?" );

		assert( arrayLen( matches ) == 3 );
		assert( matches[ 1 ][ 0 ] == "aa" );
		assert( matches[ 1 ][ 1 ] == "a" );
		assert( matches[ 1 ][ 2 ] == "" );

		assert( matches[ 2 ][ 0 ] == "bb" );
		assert( matches[ 2 ][ 1 ] == "b" );
		assert( matches[ 2 ][ 2 ] == "" );

		assert( matches[ 3 ][ 0 ] == "ccz" );
		assert( matches[ 3 ][ 1 ] == "c" );
		assert( matches[ 3 ][ 2 ] == "z" );

	}


	public void function testJreReplace() {

		var jre = new lib.JRegEx();

		var result = jre.jreReplace(
			"abcde",
			"(b)|(d)",
			function( $0, $1, $2, start, targetText ) {

				if ( $0 == "b" ) {

					assert( $0 == "b" );
					assert( $1 == "b" );
					assert( isNull( $2 ) );
					assert( start == 2 );
					assert( targetText == "abcde" );

				} else {

					assert( $0 == "d" );
					assert( isNull( $1 ) );
					assert( $2 == "d" );
					assert( start == 4 );
					assert( targetText == "abcde" );

				}

				return( ucase( $0 ) );

			}
		);

		assert( ! compare( result, "aBcDe" ) );

		var result = jre.jreReplace(
			"abc",
			".",
			function( $0, start, targetText ) {

				if ( $0 == "a" ) {

					assert( start == 1 );
					assert( targetText == "abc" );

				} else if ( $0 == "b" ) {

					assert( start == 2 );
					assert( targetText == "abc" );

				} else {

					assert( start == 3 );
					assert( targetText == "abc" );

				}

			}
		);

		assert( result == "" );

	}


	public void function testJreReplaceAll() {

		var jre = new lib.JRegEx();

		assert( jre.jreReplaceAll( "abbcdde", "(b|d)\1", "$1" ) == "abcde" );
		assert( jre.jreReplaceAll( "abbcdde", "(b|d)\1", "[$1]" ) == "a[b]c[d]e" );

		assert( jre.jreReplaceAll( "abbcdde", "(b|d)\1", "$1", true ) == "a$1c$1e" );
		assert( jre.jreReplaceAll( "abbcdde", "(b|d)\1", "[$1]", true ) == "a[$1]c[$1]e" );

	}


	public void function testJreReplaceFirst() {

		var jre = new lib.JRegEx();

		assert( jre.jreReplaceFirst( "abbcdde", "(b|d)\1", "$1" ) == "abcdde" );
		assert( jre.jreReplaceFirst( "abbcdde", "(b|d)\1", "[$1]" ) == "a[b]cdde" );

		assert( jre.jreReplaceFirst( "abbcdde", "(b|d)\1", "$1", true ) == "a$1cdde" );
		assert( jre.jreReplaceFirst( "abbcdde", "(b|d)\1", "[$1]", true ) == "a[$1]cdde" );

	}


	public void function testJreSegment() {

		var jre = new lib.JRegEx();

		var targetText = "abcde";
		var segments = jre.jreSegment( targetText, "[aeiou]" );

		assert( arrayLen( segments ) == 3 );
		assert( segments[ 1 ].text == "a" );
		assert( mid( targetText, segments[ 1 ].offset, len( segments[ 1 ].text ) ) == "a" );
		assert( segments[ 2 ].text == "bcd" );
		assert( mid( targetText, segments[ 2 ].offset, len( segments[ 2 ].text ) ) == "bcd" );
		assert( segments[ 3 ].text == "e" );
		assert( mid( targetText, segments[ 3 ].offset, len( segments[ 3 ].text ) ) == "e" );

		var targetText = "zaabcdeez";
		var segments = jre.jreSegment( targetText, "[aeiou]" );

		assert( arrayLen( segments ) == 7 );
		assert( segments[ 1 ].text == "z" );
		assert( mid( targetText, segments[ 1 ].offset, len( segments[ 1 ].text ) ) == "z" );
		assert( segments[ 2 ].text == "a" );
		assert( mid( targetText, segments[ 2 ].offset, len( segments[ 2 ].text ) ) == "a" );
		assert( segments[ 3 ].text == "a" );
		assert( mid( targetText, segments[ 3 ].offset, len( segments[ 3 ].text ) ) == "a" );
		assert( segments[ 4 ].text == "bcd" );
		assert( mid( targetText, segments[ 4 ].offset, len( segments[ 4 ].text ) ) == "bcd" );
		assert( segments[ 5 ].text == "e" );
		assert( mid( targetText, segments[ 5 ].offset, len( segments[ 5 ].text ) ) == "e" );
		assert( segments[ 6 ].text == "e" );
		assert( mid( targetText, segments[ 6 ].offset, len( segments[ 6 ].text ) ) == "e" );
		assert( segments[ 7 ].text == "z" );
		assert( mid( targetText, segments[ 7 ].offset, len( segments[ 7 ].text ) ) == "z" );

	}


	public void function testJreSplit() {

		var jre = new lib.JRegEx();

		var results = jre.jreSplit( "abcde", "[bd]" );

		assert( arrayLen( results ) == 3 );
		assert( results[ 1 ] == "a" );
		assert( results[ 2 ] == "c" );
		assert( results[ 3 ] == "e" );

		var results = jre.jreSplit( "abcde", "[bd]", 2 );

		assert( arrayLen( results ) == 2 );
		assert( results[ 1 ] == "a" );
		assert( results[ 2 ] == "cde" );

	}


	public void function testJreTest() {

		var jre = new lib.JRegEx();

		assert( jre.jreTest( "", "" ) );
		assert( jre.jreTest( "abc", ".{3}" ) );
		assert( ! jre.jreTest( "abc", ".{4}" ) );

		assert( jre.jreTest( "aabbcc", "aa\w{2}cc" ) );
		assert( ! jre.jreTest( "aabbcc", "bb" ) );

	}

}
