//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPFlag extends Decoration;

var TeamInfo Team;
var byte TeamNum;
var bool bHome;
var bool bHeld;
var XIIIPawn Holder;
var XIIIPlayerReplicationInfo HolderPRI;
var XIIIGameReplicationInfo GRI;
var XIIIMPFlagBase HomeBase;
//var rotator FlagRotation;

//_____________________________________________________________________________
replication
{
    reliable if ( Role == ROLE_Authority )
      Team, bHome, bHeld;
}

//_____________________________________________________________________________
function GiveHarnaisCTFAndFlag( XIIIPawn P)
{
    local Inventory NewItem;

    if( P.FindInventoryType(Class'XIIIMP.BlueHarnaisCTF')==None )
    {
        NewItem = Spawn(Class'XIIIMP.BlueHarnaisCTF',,,P.Location);

        if( NewItem != None )
            NewItem.GiveTo(P);
    }
}
//_____________________________________________________________________________
function RemoveHarnaisCTFAndFlag( XIIIPawn P)
{
    local Inventory NewItem;

    NewItem = P.FindInventoryType(Class'XIIIMP.HarnaisCTF');

    if( NewItem != none )
        NewItem.Destroy();

    NewItem = P.FindInventoryType(Class'XIIIMP.HarnaisCTFAttachment');

    if( NewItem !=None )
        NewItem.Destroy();

    NewItem = P.FindInventoryType(Class'XIIIMP.BlueHarnaisCTF');

    if( NewItem != none )
        NewItem.Destroy();

    NewItem = P.FindInventoryType(Class'XIIIMP.BlueHarnaisCTFAttachment');

    if( NewItem !=None )
        NewItem.Destroy();
}

//_____________________________________________________________________________
function PostBeginPlay()
{
    Super.PostBeginPlay();
    log("Flag Game: "$Level.Game);
    Team = XIIIMPCTFGameInfo(Level.Game).GameReplicationInfo.Teams[TeamNum];
    Team.Flag = self;
    LoopAnim('pflag');
    GRI = XIIIGameReplicationInfo(Level.Game.GameReplicationInfo);
}

//_____________________________________________________________________________
event FellOutOfWorld()
{
    Log("FLAG"@TeamNum@"Returned");
    if ( TeamNum == 0 )
      GRI.SoundFlagState0=1;
    else
      GRI.SoundFlagState1=1;
    SendHome();
}

//_____________________________________________________________________________
function SendHome(optional int iNewSoundState)
{
    local Controller aPawn;

    if ( Holder != None )
    {
      holderPRI.HasFlag = None;
      if ( Holder.Inventory != None )
        Holder.Inventory.SetOwnerDisplay();
      Holder = None;
    }
    if ( iNewSoundState != 0 )
    {
      if ( TeamNum == 0 )
        GRI.SoundFlagState0=iNewSoundState;
      else
        GRI.SoundFlagState1=iNewSoundState;
    }
    GotoState('Home');
    SetPhysics(PHYS_None);
    bCollideWorld = false;
    SetLocation(HomeBase.Location);
    SetRotation(HomeBase.Rotation);
    SetBase(None);
    SetCollision(true,false,false);
}

//_____________________________________________________________________________

function Drop(vector newVel)
{
    Log("FLAG"@TeamNum@"Drop by "$Holder@"PRI="$HolderPRI);
    if( HolderPRI != none )
    {
//        GRI.SoundFlagState[TeamNum]=2;
        if ( TeamNum == 0 )
          GRI.SoundFlagState0=2;
        else
          GRI.SoundFlagState1=2;
        BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 2, HolderPRI, None, Team );

        if (Level.Game.StatLog != None)
          Level.Game.StatLog.LogSpecialEvent("flag_dropped", HolderPRI.PlayerID, Team.TeamIndex);

        HolderPRI.HasFlag = None;
    }

    LightType = LT_Steady;
    RefreshLighting();

//    if ( Holder.Inventory != None )
//      Holder.Inventory.SetOwnerDisplay();

    Holder = None;
    HolderPRI = none;

    bCollideWorld = true;
    SetPhysics(PHYS_Falling);
    SetBase(None);
    SetCollision(true, false, false);

    GotoState('Dropped');
}

//_____________________________________________________________________________

function SetHolderLighting()
{
    Holder.AmbientGlow = 254;
    Holder.LightEffect=LE_NonIncidence;
    Holder.LightBrightness=255;
    Holder.LightHue=LightHue;
    Holder.LightRadius=6;
    Holder.LightSaturation=LightSaturation;
    Holder.LightType=LT_Steady;
    Holder.RefreshLighting();
}

//_____________________________________________________________________________
//                                DROPPED
//_____________________________________________________________________________


state Dropped
{
    event BeginState()
    {
        SetTimer2( 15.0, true);
        bCollideWorld = true;
        //PlayMenu(sndFlagDropped);
    }

    //------------------------------------------

    function EndState()
    {
        SetTimer2( 0.0, false);
    }

    //------------------------------------------

    event Timer2()
    {
        BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 3, None, None, Team );

        if (Level.Game.StatLog != None)
            Level.Game.StatLog.LogSpecialEvent("flag_returned_timeout", Team.TeamIndex);

        Log("FLAG"@TeamNum@"Returned");
//        GRI.SoundFlagState[TeamNum]=1;
        if ( TeamNum == 0 )
          GRI.SoundFlagState0=1;
        else
          GRI.SoundFlagState1=1;
        SendHome();
    }

    //------------------------------------------

    function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,Vector momentum, class<DamageType> damageType)
    {
      if ( PhysicsVolume.bPainCausing && (PhysicsVolume.DamagePerSec > 0) )
        timer2();
    }

    //------------------------------------------

    singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
    {
      Super.PhysicsVolumeChange(NewVolume);

      if ( NewVolume.bPainCausing && (NewVolume.DamagePerSec > 0) )
        timer2();
    }

    //------------------------------------------

    function Touch(Actor Other)
    {
        local XIIIMPFlag aFlag;
        local XIIIPawn aPawn;
        local Controller C;
        local NavigationPoint N;
        local int num, i;

        aPawn = XIIIPawn(Other);

        if ( aPawn == None )
            return;

        C = aPawn.Controller;

        if( C == none )
            return;

        if( ! C.bIsPlayer )
            return;

        C.MoveTimer = -1;

        if ( C.PlayerReplicationInfo.Team == Team )
        {
            //log("-----flag has returned");
            //PlayMenu(sndFlagReturn);
            Log("FLAG"@TeamNum@"Returned");
//        GRI.SoundFlagState[TeamNum]=1;
        if ( TeamNum == 0 )
          GRI.SoundFlagState0=1;
        else
          GRI.SoundFlagState1=1;
            XIIIMPCTFGameInfo(Level.Game).ScoreFlag(C, self);
            SendHome();

            return;
        }
        else
        {
            //log("-----flag taken from dropped");

            Holder = aPawn;
            HolderPRI = XIIIPlayerReplicationInfo(aPawn.PlayerReplicationInfo);
            C.PlayerReplicationInfo.HasFlag = self;
            C.SendMessage(None, 'OTHER', 2, 10, 'TEAM');
        }

        BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 4, C.PlayerReplicationInfo, None, Team );

        if (Level.Game.StatLog != None)
            Level.Game.StatLog.LogSpecialEvent("flag_pickedup", C.PlayerReplicationInfo.PlayerID, Team.TeamIndex);

        GotoState('Held');
    }

begin:

    if ( PhysicsVolume.bPainCausing && (PhysicsVolume.DamagePerSec > 0) )
        timer2();
}


//_____________________________________________________________________________
//                                HELD
//_____________________________________________________________________________


state Held
{
    event FellOutOfWorld();

    //------------------------------------------

    event BeginState()
    {
        local TeamBotController Bot;

        bHeld = true;

        bCollideWorld = false;
        HomeBase.PlayAlarm();
        SetPhysics(PHYS_None);
        SetCollision(false, false, false);
        SetDrawType(DT_None);

        if( CTFBotController( Holder.Controller ) != none )
            CTFBotController( Holder.Controller ).CatchFlag();
        else
        {
            foreach DynamicActors(class'TeamBotController', BOT)
            {
                if( Bot.TeamID == Holder.Controller.PlayerReplicationInfo.Team.TeamIndex )
                {
                    CTFBotController( BOT ).ForceTheBotToHelpTheHumanFlagHolder();
                }
            }
        }

        Log("FLAG"@TeamNum@"Held BeginState");
//        GRI.SoundFlagState[TeamNum]=4;
        if ( TeamNum == 0 )
          GRI.SoundFlagState0=4;
        else
          GRI.SoundFlagState1=4;

        GiveHarnaisCTFAndFlag( Holder );
    }

    //------------------------------------------

    event EndState()
    {
        SetDrawType(DT_StaticMesh);
        bHeld = false;
    }

    //------------------------------------------

    event Tick(float DeltaTime)
    {
        if ( Holder != none )
        {
            if( Holder.bIsDead )
            {
                RemoveHarnaisCTFAndFlag( Holder );
                Drop(Holder.Location);
            }
            else
                SetLocation(Holder.Location);
        }
        else
        {
            RemoveHarnaisCTFAndFlag( Holder );
            Drop(Holder.Location);
        }
    }

    //------------------------------------------
}

//_____________________________________________________________________________
//
auto state Home
{
    event BeginState()
    {
      //log("!!!! BeginState HOME");
      bHome = true;
      bCollideWorld = false;
      if ( HomeBase != None ) // will be none when flag is created
        HomeBase.AmbientSound = None;

      SetCollisionSize(Default.CollisionRadius, Default.CollisionHeight);
    }
    event EndState()
    {
      bHome = false;
      //SetTimer(0.0, false);
    }
    event Touch(Actor Other)
    {
      local XIIIMPFlag aFlag;
      local XIIIPawn aPawn;
      local NavigationPoint N;
      local int i;
      local float totalweight, selection, PartialWeight;
      local Controller C;

      aPawn = XIIIPawn(Other);

      if ( aPawn == None )
          return;

      C = aPawn.Controller;

      if( C == none )
          return;

      if( ! C.bIsPlayer )
          return;

      if ( C.PlayerReplicationInfo.Team == Team )
      {
        if ( C.PlayerReplicationInfo.HasFlag != None )
        {
          Log("FLAG"@TeamNum@"Score");
          GRI.SoundFlagState0=3; // need to put both to update states ok.
          GRI.SoundFlagState1=3;
          RemoveHarnaisCTFAndFlag( aPawn );
          aFlag = XIIIMPFlag(C.PlayerReplicationInfo.HasFlag);
          XIIIMPCTFGameInfo(Level.Game).ScoreFlag(C, aFlag);
          aFlag.SendHome();
        }
      }
      else
      {
        Holder = aPawn;
        HolderPRI = XIIIPlayerReplicationInfo(aPawn.PlayerReplicationInfo);
        C.MoveTimer = -1;
        C.PlayerReplicationInfo.HasFlag = self;
        Holder.MakeNoise(2.0);
        C.SendMessage(None, 'OTHER', 2, 10, 'TEAM');
        if (Level.Game.StatLog != None)
            Level.Game.StatLog.LogSpecialEvent("flag_taken", HolderPRI.PlayerID, Team.TeamIndex);
        BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 6, holderPRI, None, Team );
        GotoState('Held');
      }
    }
begin:
//  FlagRotation.Roll = 32768+16380;
  SetRotation(rotation - rot(0,0,1)*(Rotation.Roll - 32768 - 16380));
}


defaultproperties
{
     TeamNum=1
     bStatic=False
     bStasis=False
     bAlwaysRelevant=True
     bUnlit=True
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
     bFixedRotationDir=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_communs.flagblue'
     CollisionRadius=70.000000
     CollisionHeight=30.000000
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightRadius=6
     Mass=30.000000
     Buoyancy=20.000000
     RotationRate=(Pitch=30000,Roll=30000)
     NetPriority=3.000000
}
