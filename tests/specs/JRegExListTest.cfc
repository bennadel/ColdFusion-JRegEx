component
	extends = "TestCase"
	output = false
	hint = "I test JRegExList."
	{

	public void function test_jreListFirst() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListFirst( "", "-" ) == "" );
		assert( jreList.jreListFirst( "-------", "-" ) == "" );
		assert( jreList.jreListFirst( "-------", "-", true ) == "" );
		assert( jreList.jreListFirst( "--abc--", "-" ) == "abc" );
		assert( jreList.jreListFirst( "--abc--", "-+" ) == "abc" );
		assert( jreList.jreListFirst( "--abc--", "-", true ) == "" );
		assert( jreList.jreListFirst( "--abc--", "-+", true ) == "" );
		assert( jreList.jreListFirst( "abc----", "-" ) == "abc" );
		assert( jreList.jreListFirst( "abc----", "-", true ) == "abc" );

	}


	public void function test_jreListGetAt() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListGetAt( "", 1, "-" ) == "" );
		assert( jreList.jreListGetAt( "", 2, "-" ) == "" );
		assert( jreList.jreListGetAt( "", 1, "-", true ) == "" );
		assert( jreList.jreListGetAt( "", 2, "-", true ) == "" );
		assert( jreList.jreListGetAt( "a", 1, "-" ) == "a" );
		assert( jreList.jreListGetAt( "a", 2, "-" ) == "" );
		assert( jreList.jreListGetAt( "---", 1, "-" ) == "" );
		assert( jreList.jreListGetAt( "---", 1, "-", true ) == "" );
		assert( jreList.jreListGetAt( "-a-", 1, "-" ) == "a" );
		assert( jreList.jreListGetAt( "-a-", 1, "-", true ) == "" );
		assert( jreList.jreListGetAt( "---a---", 1, "-+" ) == "a" );
		assert( jreList.jreListGetAt( "---a---", 1, "-+", true ) == "" );

	}


	public void function test_jreListLast() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListLast( "", "-" ) == "" );
		assert( jreList.jreListLast( "-", "-" ) == "" );
		assert( jreList.jreListLast( "-", "-", true ) == "" );
		assert( jreList.jreListLast( "a-", "-" ) == "a" );
		assert( jreList.jreListLast( "a-", "-", true ) == "" );
		assert( jreList.jreListLast( "a-b-c", "-" ) == "c" );

	}


	public void function test_jreListLen() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListLen( "", "-" ) == 0 );
		assert( jreList.jreListLen( "", "-", true ) == 1 );
		assert( jreList.jreListLen( "-", "-" ) == 0 );
		assert( jreList.jreListLen( "-", "-", true ) == 2 );
		assert( jreList.jreListLen( "--abc--", "-" ) == 1 );
		assert( jreList.jreListLen( "--abc--", "-", true ) == 5 );
		assert( jreList.jreListLen( "--abc--", "-+", true ) == 3 );
		assert( jreList.jreListLen( "-a--b--c-", "-" ) == 3 );
		assert( jreList.jreListLen( "-a--b--c-", "-", true ) == 7 );
		assert( jreList.jreListLen( "-a--b--c-", "-+", true ) == 5 );

	}


	public void function test_jreListMap() {

		var jreList = new lib.JRegExList();

		var op = ( item ) => {
			return( item.len() );
		};

		assert( jreList.jreListMap( "", op, "-" ) == "" );
		assert( jreList.jreListMap( "", op, "-", true ) == "0" );
		assert( jreList.jreListMap( "-a--bb--ccc-", op, "-+" ) == "-1--2--3-" );
		assert( jreList.jreListMap( "-a--bb--ccc-", op, "-+", true ) == "0-1--2--3-0" );
		assert( jreList.jreListMap( "-a--bb--ccc-", op, "-", true ) == "0-1-0-2-0-3-0" );

	}


	public void function test_jreListRest() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListRest( "", "-" ) == "" );
		assert( jreList.jreListRest( "-------", "-" ) == "" );
		assert( jreList.jreListRest( "-------", "-", true ) == "------" );
		assert( jreList.jreListRest( "-------", "-+", true ) == "" );
		assert( jreList.jreListRest( "--abc--", "-" ) == "" );
		assert( jreList.jreListRest( "--abc--", "-", true ) == "-abc--" );
		assert( jreList.jreListRest( "--abc--", "-+", true ) == "abc--" );
		assert( jreList.jreListRest( "abc----", "-" ) == "" );
		assert( jreList.jreListRest( "abc----", "-", true ) == "---" );
		assert( jreList.jreListRest( "----abc", "-" ) == "" );
		assert( jreList.jreListRest( "----abc", "-", true ) == "---abc" );
		assert( jreList.jreListRest( "--abc--def--", "-" ) == "def--" );
		assert( jreList.jreListRest( "--abc--def--", "-", true ) == "-abc--def--" );
		assert( jreList.jreListRest( "--abc--def--", "-+", true ) == "abc--def--" );
		assert( jreList.jreListRest( "abc", "-", true ) == "" );

	}


	public void function test_jreListSetAt() {

		var jreList = new lib.JRegExList();

		assert( jreList.jreListSetAt( "", 1, "a", "-" ) == "" );
		assert( jreList.jreListSetAt( "", 1, "a", "-", true ) == "a" );
		assert( jreList.jreListSetAt( "", 2, "a", "-", true ) == "" );
		assert( jreList.jreListSetAt( "--", 1, "a", "-" ) == "--" );
		assert( jreList.jreListSetAt( "--", 1, "a", "-", true ) == "a--" );
		assert( jreList.jreListSetAt( "-a-", 1, "b", "-" ) == "-b-" );
		assert( jreList.jreListSetAt( "-a-", 1, "b", "-", true ) == "b-a-" );
		assert( jreList.jreListSetAt( "-a-", 10, "b", "-", true ) == "-a-" );

	}


	public void function test_jreListToArray() {

		var jreList = new lib.JRegExList();

		assert( serializeJson( jreList.jreListToArray( "--", "-" ) ) == '[]' );
		assert( serializeJson( jreList.jreListToArray( "--", "-+", true ) ) == '["",""]' );
		assert( serializeJson( jreList.jreListToArray( "-a-", "-" ) ) == '["a"]' );
		assert( serializeJson( jreList.jreListToArray( "-a-", "-", true ) ) == '["","a",""]' );
		assert( serializeJson( jreList.jreListToArray( "-a-----b-", "-" ) ) == '["a","b"]' );
		assert( serializeJson( jreList.jreListToArray( "-a-----b-", "-", true ) ) == '["","a","","","","","b",""]' );

	}

}
