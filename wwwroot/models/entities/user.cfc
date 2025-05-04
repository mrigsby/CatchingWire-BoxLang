component table="users"  extends="quick.models.BaseEntity" accessors="true" {

	property name="bcrypt" 					inject="@BCrypt" 									persistent="false";
	// property name="coldThumbs" 				inject="ColdThumbs@ColdThumbs" 						persistent="false";
	property name="wirebox"	 				inject="wirebox" 									persistent="false";
	property name="userPreferenceDefaults"	inject="coldbox:setting:userPreferenceDefaults"		persistent="false";

	property name="id";
	property name="accountType";
	property name="active" 			casts="BooleanCast@quick" default=0;
	property name="email";
	property name="password";
	property name="fname";
	property name="lname";
	property name="title";
	property name="permissions" 	type="array"	casts="JsonCast@quick";
	property name="roles" 			type="array" 	casts="JsonCast@quick";
	property name="prefs" 			type="struct" 	casts="JsonCast@quick";
	property name="dt_lastlogin";
	property name="dt_created";

	public boolean function isActive() {
		return ( active ) ? true : false;
	}

	public User function setPassword( required string password ){
		return assignAttribute( "password", bcrypt.hashPassword( arguments.password ) );
	}

	public boolean function hasPermission( required string permission ){
		// if no permissions then we need to init the permissions array as an empty array
		if( !isDefined("permissions") ){
			assignAttribute( "permissions", [] );
		}
		var accountTypes = [];
		for( struct IN application.cbController.getSetting("accountTypes") ){
			accountTypes.append( struct.key );
		}
		if( accountTypes.findNoCase( permission ) ){
			return ( accountType == permission ) ? true : false;
		}else{
			return permissions.findNoCase( permission );
		}
	}

    boolean function hasRole( required string role ){
		// if no roles then we need to init the roles array as an empty array
		if( !isDefined("roles") ) assignAttribute( "roles", [] );
		// have not implimented roles yet, so just always return false until we do
		return false;
	}

	public string function getProfilePicURL( numeric imgWidth = 0 ){
		var baseProfilePicPath = application.cbController.getSetting("profilePicPath");
		var baseProfilePicURL = application.cbController.getSetting("profilePicURL");

		var profilePicPath = baseProfilePicPath & id & ".jpg";
		var profilePicURL = baseProfilePicURL & id & ".jpg";
		var profilePicExists = fileExists( profilePicPath );

		// if no image width is defined then return the original image
		if( imgWidth == 0 ) return ( isDefined("id") && isNumeric(id) && id > 0 && profilePicExists ? profilePicURL : baseProfilePicURL & "default.jpg" );

		if( isDefined("id") && isNumeric(id) && id > 0 && profilePicExists ){
			var resizedProfilePicPath = baseProfilePicPath & id & "_" & imgWidth & ".jpg";
			var resizedProfilePicURL = baseProfilePicURL & id & "_" & imgWidth & ".jpg";
			if( fileExists( resizedProfilePicPath ) ) return resizedProfilePicURL;
			// resize the image to the correct size
			// TODO: maybe add threading to handle high load?
			var oProfilePic = ImageRead( profilePicPath )
				.scaleToFit( imgWidth, "", "mediumQuality" )
				.write( resizedProfilePicPath );
			return resizedProfilePicURL;
		}

		return baseProfilePicURL & "default.jpg";
	}

}