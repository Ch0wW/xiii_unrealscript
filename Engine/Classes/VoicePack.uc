//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
	abstract;
	
/* 
ClientInitialize() sets up playing the appropriate voice segment, and returns a string
 representation of the message
*/
function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex);
function PlayerSpeech(int Type, int Index, int Callsign);
	

defaultproperties
{
     RemoteRole=ROLE_None
     LifeSpan=10.000000
}
