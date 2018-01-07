//=============================================================================
// XBOXClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class XBOXClientBeaconReceiver extends UdpBeacon
	native
	transient;

var BYTE m_CurrentNonce[4];

var struct XBoxBeaconInfo
{
	var IpAddr      Addr;
	var float       Time;
	var string      ParamMenuAsText;
	var string      xnaddrAsStr;
	var string      xnkeyAsStr;
	var string      xnkidAsStr;
} XBoxBeacons[7];

function string GetBeaconAddress( int i )
{
	return XBoxBeacons[i].xnaddrAsStr; //IpAddrToString(XBoxBeacons[i].Addr);
}

function string GetBeaconText(int i)
{
	return XBoxBeacons[i].ParamMenuAsText;
}

function string GetXNADDR( int i )
{
	return XBoxBeacons[i].xnaddrAsStr;
}

function string GetXNKEY( int i )
{
	return XBoxBeacons[i].xnkeyAsStr;
}

function string GetXNKID( int i )
{
	return XBoxBeacons[i].xnkidAsStr;
}



native function bool QueryForHosts();
native function bool DecodeBuffer(IpAddr Addr, int Count, byte B[255], out string ParamMenuAsText, out string xnAddrAsText, out string xnkeyAsStr, out string xnkidAsStr );



event ReceivedBinary( IpAddr Addr, int Count, byte B[255] )
{
	local int i, j;
	local string ParamMenuAsText, xnaddrAsStr, xnkeyAsStr, xnkidAsStr;

	DecodeBuffer(Addr, Count, B, ParamMenuAsText, xnaddrAsStr, xnkeyAsStr, xnkidAsStr);

	for( i=0; i<arraycount(XBoxBeacons); i++ )
		if( XBoxBeacons[i].xnaddrAsStr==xnaddrAsStr )
			break;
	if( i==arraycount(XBoxBeacons) )
		for( i=0; i<arraycount(XBoxBeacons); i++ )
			if( XBoxBeacons[i].xnaddrAsStr=="" )
				break;
	if( i==arraycount(XBoxBeacons) )
		return;

	XBoxBeacons[i].ParamMenuAsText = ParamMenuAsText;
	XBoxBeacons[i].xnaddrAsStr     = xnaddrAsStr;
	XBoxBeacons[i].xnkeyAsStr      = xnkeyAsStr;
	XBoxBeacons[i].xnkidAsStr      = xnkidAsStr;
	XBoxBeacons[i].Addr	           = Addr;
	XBoxBeacons[i].Time            = Level.TimeSeconds;
}


function BeginPlay()
{
	log("XBOXClientBeaconReceiver started !!!");
	LinkMode = MODE_Binary;

	if( BindPort( 1002, true ) > 0 )
	{
		SetTimer( 1.0, true );
		log( "XBOXClientBeaconReceiver initialized." );
	}
	else
	{
		log( "XBOXClientBeaconReceiver failed: Beacon port in use." );
	}
}

function Destroyed()
{
	log( "ClientBeaconReceiver finished." );
}

function BroadcastBeacon(IpAddr Addr)
{
	QueryForHosts();	
}

function Timer()
{
	local int i, j;
    local IpAddr Addr;

	for( i=0; i<arraycount(XBoxBeacons); i++ )
		if
		(	XBoxBeacons[i].xnaddrAsStr!=""
		&&	Level.TimeSeconds-XBoxBeacons[i].Time<BeaconTimeout )
			XBoxBeacons[j++] = XBoxBeacons[i];
	for( j=j; j<arraycount(XBoxBeacons); j++ )
		XBoxBeacons[j].xnaddrAsStr="";

	Addr.Addr = BroadcastAddr;		// useless
	Addr.Port = ServerBeaconPort;	// useless
	
	BroadcastBeacon(Addr);
}



defaultproperties
{
    ReceivedText=0
}
