//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIAccessControl extends AccessControl;

//_____________________________________________________________________________
function Kick( string S )
{
    local PlayerController P;

    Log("ACCESS KICK '"$s$"'");

    ForEach DynamicActors(class'PlayerController', P)
      if ( P.PlayerReplicationInfo.PlayerName~=S
        &&  (NetConnection(P.Player) != None) )
      {
        ConsoleCommand("KICKPLAYER "$P);
        return;
      }
}



defaultproperties
{
     AdminClass=Class'XIIIMP.XIIIAdmin'
}
