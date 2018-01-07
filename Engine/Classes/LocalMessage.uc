//=============================================================================
// LocalMessage
//
// LocalMessages are abstract classes which contain an array of localized text.  
// The PlayerController function ReceiveLocalizedMessage() is used to send messages 
// to a specific player by specifying the LocalMessage class and index.  This allows 
// the message to be localized on the client side, and saves network bandwidth since 
// the text is not sent.  Actors (such as the GameInfo) use one or more LocalMessage 
// classes to send messages.  The BroadcastHandler function BroadcastLocalizedMessage() 
// is used to broadcast localized messages to all the players.
//
//=============================================================================
class LocalMessage extends Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsSpecial;										// If true, don't add to normal queue.
var bool	bIsUnique;										// If true and special, only one can be in the HUD queue at a time.
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bFadeMessage;									// If true, use fade out effect on message.
var bool	bBeep;											// If true, beep!
var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var int		Lifetime;										// # of seconds to stay in HUD message queue.

var class<LocalMessage> ChildMessage;						// In some cases, we need to refer to a child message.

// Canvas Variables
var bool	bFromBottom;									// Subtract YPos.
var color	DrawColor;										// Color to display message with.
var float	XPos, YPos;										// Coordinates to print message at.
var bool	bCenter;										// Whether or not to center the message.

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional String MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	);

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( class<Actor>(OptionalObject) != None )
		return class<Actor>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
	return "";
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return "";
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

	if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
		P.Player.Console.Message(Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ), 6.0);
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.DrawColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos;
}

static function int GetFontSize( int Switch );

defaultproperties
{
     Lifetime=3
     DrawColor=(B=255,G=255,R=255,A=255)
}
