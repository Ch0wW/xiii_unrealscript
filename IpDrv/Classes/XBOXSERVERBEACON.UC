//=============================================================================
// XBOXServerBeacon: The classe that listens for server request on the lan
//=============================================================================
class XBOXServerBeacon extends UdpBeacon
	native
	config
	transient;

// <RSCODEXBOX> lbouchard
native function bool DecodeBuffer(IpAddr Addr, int Count, byte B[255]);
native function bool Initialize();
native function bool Uninitialize();

event StartServer()
{
	BeginPlay();
}
// </RSCODEXBOX>

function BeginPlay()
{
    local string URLOptions;
    //local bool bIsOnLAN;
    local int iIsOnLANStr;

    URLOptions = Level.getLocalURL();
    URLOptions = Mid(URLOptions, InStr( URLOptions, "?" ));
	//if (Level.Game.ParseOption ( URLOptions, "LAN" ) != "")

    iIsOnLANStr = InStr(URLOptions, "?LAN?");
    if (iIsOnLANStr<0)
    {
        Destroy();
    }
    else
    {
 		//Super.BeginPlay();
		log("XBOXServerBeacon started !!!");
		boundport = BindPort(1002, True);
		if ( boundport == 0 )
		{
			log( "XBOXServerBeacon failed to bind a port." );
			return;
		}
		Initialize();
		LinkMode = MODE_Binary;
	}
}


// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary( IpAddr Addr, int Count, byte B[255] )
{
	DecodeBuffer(Addr,Count,B);
}

function Destroyed()
{
	Super.Destroyed();

	log( "XBOXServerBeacon finished." );
	Uninitialize();
}



defaultproperties
{
     ServerBeaconPort=1002
}