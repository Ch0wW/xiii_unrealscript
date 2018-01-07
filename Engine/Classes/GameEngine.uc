//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>    ServerActors,
					        ServerPackages;

var const byte ConnectionFailure;  // used in net code: when a connection failed with the server, detect and display a message for a while
var const float TimeToWaitUpTo;

var bool			FramePresentPending;

defaultproperties
{
     ServerActors(0)="IpDrv.UdpBeacon"
     ServerActors(1)="IpDrv.UdpServerQuery"
     ServerActors(2)="IpDrv.RegisterServerToUbiCom"
     ServerPackages(0)="GamePlay"
     ServerPackages(1)="XIII"
     ServerPackages(2)="XIIIMP"
     CacheSizeMegs=1
}
