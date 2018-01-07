// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIFont extends GUI
	Native;

var(Menu) string		KeyName;
var(Menu) bool			bFixedSize;		// If true, only FontArray[0] is used
var(Menu) localized array<String>	FontArrayNames;	// Holds all of the names of the fonts 		
var(Menu) array<Font>	FontArrayFonts;	// Holds all of the fonts

native event Font GetFont(int XRes);			// Returns the font for the current resolution

// Dynamically load font.
static function Font LoadFontStatic(int i)
{
	if( i>=default.FontArrayFonts.Length || default.FontArrayFonts[i] == None )
	{
		default.FontArrayFonts[i] = Font(DynamicLoadObject(default.FontArrayNames[i], class'Font'));
		if( default.FontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.FontArrayNames[i]);
	}

	return default.FontArrayFonts[i];
}

function Font LoadFont(int i)
{
	if( i>=FontArrayFonts.Length || FontArrayFonts[i] == None )
	{
		FontArrayFonts[i] = Font(DynamicLoadObject(FontArrayNames[i], class'Font'));
		if( FontArrayFonts[i] == None )
			Log("Warning: "$Self$" Couldn't dynamically load font "$FontArrayNames[i]);
	}
	return FontArrayFonts[i];
}



defaultproperties
{
}
