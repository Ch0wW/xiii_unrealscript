//=============================================================================
// InternetLink: Parent class for Internet connection classes
//=============================================================================
class InternetLink extends InternetInfo
	native
	transient;

//-----------------------------------------------------------------------------
// Types & Variables.

// An IP address.
struct IpAddr
{
	var int Addr;
	var int Port;
};

// Data receive mode.
// Cannot be set in default properties.
var enum ELinkMode
{
	MODE_Text, 
	MODE_Line,
	MODE_Binary
} LinkMode;

// Internal
var	const int Socket;
var const int Port;
var	const int RemoteSocket;
var private native const int PrivateResolveInfo;
var const int DataPending;

// Receive mode.
// If mode is MODE_Manual, received events will not be called.
// This means it is your responsibility to check the DataPending
// var and receive the data.
// Cannot be set in default properties.
var enum EReceiveMode
{
	RMODE_Manual,
	RMODE_Event
} ReceiveMode;

//-----------------------------------------------------------------------------
// Natives.

// Returns true if data is pending on the socket.
native(681) static final function bool IsDataPending();

// Parses an Unreal URL into its component elements.
// Returns false if the URL was invalid.
native(680) static final function bool ParseURL
(
	coerce string URL, 
	out string Addr, 
	out int Port, 
	out string LevelName,
	out string EntryName
);

// Resolve a domain or dotted IP.
// Nonblocking operation.  
// Triggers Resolved event if successful.
// Triggers ResolveFailed event if unsuccessful.
native(679) static final function Resolve( coerce string Domain );

// Returns most recent winsock error.
native(678) static final function int GetLastError();

// Convert an IP address to a string.
native(677) static final function string IpAddrToString( IpAddr Arg );

// Convert a string to an IP
native(676) static final function bool StringToIpAddr( string Str, out IpAddr Addr );

// Validate: Takes a challenge string and returns an encoded validation string.
native(675) static final function string Validate( string ValidationString, string GameName );

native(674) static final function GetLocalIP(out IpAddr Arg );

//-----------------------------------------------------------------------------
// Events.

// Called when domain resolution is successful.
// The IpAddr struct Addr contains the valid address.
event Resolved( IpAddr Addr );

// Called when domain resolution fails.
event ResolveFailed();

defaultproperties
{
}
