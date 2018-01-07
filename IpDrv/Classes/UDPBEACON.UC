//=============================================================================
// UdpBeacon: Base class of beacon sender and receiver.
//=============================================================================
class UdpBeacon extends UdpLink
	native
	config
	transient;

var() globalconfig bool       DoBeacon;
var() globalconfig int        ServerBeaconPort;		// Listen port
var() globalconfig int        BeaconPort;			// Reply port
var() globalconfig float      BeaconTimeout;
var() globalconfig string     BeaconProduct;

var int	UdpServerQueryPort;
var int boundport;

function BeginPlay()
{
	//local IpAddr Addr;

	boundport = BindPort(ServerBeaconPort, True);
	if ( boundport == 0 )
	{
		log( "UdpBeacon failed to bind a port." );
		return;
	}

    // Useless to broadcast now, since a lot is yet to be done before the level is running ! 
    // (it avoids an annoying flick in join lan game menu (server appears-disappears-appears while loading))
	/*
	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;
	BroadcastBeacon(Addr); // Initial notification.
    */
}

function BroadcastBeacon(IpAddr Addr)
{
    local string S;
    S = Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1);
	SendText( Addr, BeaconProduct @ S @ Level.Game.GetBeaconText() );
	//Log( "UdpBeacon: BroadcastBeacon("$BeaconProduct @ S @ Level.Game.GetBeaconText()$") to "$IpAddrToString(Addr) );
}

function BroadcastBeaconQuery(IpAddr Addr)
{
	SendText( Addr, BeaconProduct @ UdpServerQueryPort );
	//Log( "UdpBeacon: BroadcastBeaconQuery("$BeaconProduct @ UdpServerQueryPort$") to "$IpAddrToString(Addr) );
}

event ReceivedText( IpAddr Addr, string Text )
{
	if( Text == "REPORT" )
		BroadcastBeacon(Addr);

	if( Text == "REPORTQUERY" )
		BroadcastBeaconQuery(Addr);
}

function Destroyed()
{
	Super.Destroyed();
	//Log("ServerBeacon Destroyed");
}

defaultproperties
{
     DoBeacon=True
     ServerBeaconPort=8777
     BeaconPort=9777
     BeaconTimeout=5.000000
     BeaconProduct="XIII"
     RemoteRole=ROLE_None
}
