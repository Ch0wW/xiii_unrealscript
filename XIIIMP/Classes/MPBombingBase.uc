//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPBombingBase extends NavigationPoint
    placeable;

//var byte Team;              // Should be 1 by default (not destroyed)
var byte CurrentTeam;         // Should be 1 by default (not destroyed)
var() localized string sBaseName;
var() int BombPointID;
var float BombTime;
var int BombingCount;         // used to initiate counting on clients from good ref (avoid fast fire/unfire Bug)
var sound sndBomdDesactived;
//var float ClientBombTime;

//_____________________________________________________________________________
replication
{
    reliable if ( Role == ROLE_Authority )
      CurrentTeam, BombTime, BombingCount;
}

//_____________________________________________________________________________
function MatchStarting()
{
    CurrentTeam = 1;
}

//_____________________________________________________________________________
event Trigger( Actor Other, Pawn EventInstigator )
{
    local SabotageBotController Bot;


//    Log(self@"TRIGGERED by"@other@"/"@EventInstigator);
    if ( vSize(Other.Location - Location) < CollisionRadius )
    {
      //if ( FastTrace(Other.location, Location) )
      //{
        if (CurrentTeam != 0)
        {
            foreach DynamicActors(class'SabotageBotController', BOT)
            {
                BOT.ObjectifIsDestroyed( self );
            }

            BombTime = -1;
            //BroadcastLocalizedMessage( class'XIIIMPSabotageMessage', 2, none, None, self );
            //EventInstigator.PlayMenu(sndBomdDesactived);

            CurrentTeam = 0;
            //log("BOMB ->"@self@CurrentTeam@"role="@role);
            XIIIMPBombGame(Level.Game).ScoreObjective(EventInstigator.PlayerReplicationInfo, 1);
            TriggerEvent(Event, Self, EventInstigator);
        }
      //}
    }
}

//    Team=1
//    ClientBombTime=-1


defaultproperties
{
     CurrentTeam=1
     sBaseName="Bombing Point"
     BombTime=-1.000000
     sndBomdDesactived=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombOut'
     bStatic=False
     bHidden=False
     bNoDelete=True
     bAlwaysRelevant=True
     bCollideActors=True
     bUseCylinderCollision=True
     CollisionRadius=200.000000
     CollisionHeight=60.000000
     NetUpdateFrequency=3.000000
}
