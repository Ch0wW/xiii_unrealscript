//=============================================================================
// TeamInfo.
//=============================================================================
class TeamInfo extends ReplicationInfo
	native
	nativereplication;

var string TeamName;
var int Size; //number of players on this team in the level
var float Score;
var int TeamIndex;
var color TeamColor, AltTeamColor;
var texture TeamIcon;
var Actor Flag;			// key objective associated with this team
var string DefaultPlayerClassName;

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		Score, Flag;
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		TeamName, TeamColor, AltTeamColor, TeamIcon, TeamIndex;
}

function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	return true;
}

simulated function string GetHumanReadableName()
{
	return TeamName;
}

function bool AddToTeam( Controller Other )
{
	local Controller P;
	local bool bSuccess;

	// make sure loadout works for this team
	if ( Other == None )
	{
		log("Added none to team!!!");
		return false;
	}

	Size++;
	Other.PlayerReplicationInfo.Team = self;
	if (Level.Game.StatLog != None)
		Level.Game.StatLog.LogTeamChange(Other);
	bSuccess = false;
	if ( Other.IsA('PlayerController') )
		Other.PlayerReplicationInfo.TeamID = 0;
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
            if ( P.bIsPlayer && (P != Other) 
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID = Other.PlayerReplicationInfo.TeamID + 1;
	}
	return true;
}

function RemoveFromTeam(Controller Other)
{
	Size--;
}

defaultproperties
{
     TeamColor=(R=255,A=255)
     AltTeamColor=(R=200,A=255)
     TeamIcon=Texture'Engine.S_Actor'
}
