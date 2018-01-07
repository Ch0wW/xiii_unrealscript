//
//-----------------------------------------------------------
class TheDuck extends Pawn native;

#exec OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound

var int FullDamage;
var int OldLoopAnimID, LoopAnimID;
var byte soundcounter0,soundcounter1,soundcounter2,soundcounter3,soundcounter4;
var byte Oldsoundcounter0,Oldsoundcounter1,Oldsoundcounter2,Oldsoundcounter3,Oldsoundcounter4;

//__________________________________________________________________

replication
{
    reliable if( Role==ROLE_Authority )
        LoopAnimID, FullDamage, soundcounter0 ,soundcounter1 ,soundcounter2 ,soundcounter3 ,soundcounter4 ;
}

//__________________________________________________________________

event Attach( Actor Other )
{
    if( Pawn(Other ) != none )
    {
        log("[ HUNT ] Detachage De Cadavre");
        Other.SetBase( none );
    }
}

//__________________________________________________________________

simulated function PostBeginPlay()
{
    SetBoneScale(32,3,'X Head');
//    SetBoneScale(31,0.66,'X Pelvis');
    super.PostBeginPlay();
}

//__________________________________________________________________

simulated event LaunchSound()
{
    PlaySoundOfTheDeath();
}

//__________________________________________________________________

simulated function PlaySoundOfTheDeath()
{
    if( soundcounter0 != Oldsoundcounter0 )
    {
        Oldsoundcounter0 = soundcounter0;
        //PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntKilled')
        ;
    }

    if( soundcounter1 != Oldsoundcounter1 )
    {
        Oldsoundcounter1 = soundcounter1;
        //PlaySound( Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntPafed' );
    }

    if( soundcounter2 != Oldsoundcounter2 )
    {
        Oldsoundcounter2 = soundcounter2;
        //playsound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntKill');
    }

    if( soundcounter3 != Oldsoundcounter3 )
    {
        Oldsoundcounter3 = soundcounter3;
        //PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntLoop');
    }

    if( soundcounter4 != Oldsoundcounter4 )
    {
        Oldsoundcounter4 = soundcounter4;
        //PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntStopLoop');
    }
}

//__________________________________________________________________

function ChangeLoopAnimation( int ID )
{
    LoopAnimID = ID;
    ApplyLoopAnimation( ID );
}

//__________________________________________________________________

simulated event SetLoopAnimation( int ID )
{
    ApplyLoopAnimation( ID );
}

//__________________________________________________________________

simulated function ApplyLoopAnimation( int ID )
{
    local float fScale3D;
    local vector vScale3D;

    fScale3D = 0.8- FullDamage*0.02;

    vScale3D.X=fScale3D;
    vScale3D.Y=fScale3D;
    vScale3D.Z=fScale3D;

    SetDrawScale3D( vScale3D );
    SetCollisionSize(20,78*fScale3D);
    //SetBoneScale(32,1+FullDamage*0.1,'X Head');

    switch( ID )
    {
        case 0: LoopAnim('affole') ; break;
        case 1: LoopAnim('run') ; break;
        case 2: LoopAnim('walk') ; break;
        case 3: LoopAnim('AttenteGrenade') ; break;
        case 4: LoopAnim('MigBoxeProvoc') ; break;
    }
}

//_____________________________________________________________________________

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,vector momentum, class<DamageType> damageType)
{
    local int TmpDamage;

    if( damageType == class'XIII.DTShotGunned' )
        Damage *= 2;

    TmpDamage = Max(1,Damage/25);
    instigatedBy.Controller.PlayerReplicationInfo.Score += TmpDamage;
    FullDamage += TmpDamage;

    if( FullDamage > 30 )
    {
        Spawn(class'BlastDuck',,, Location);
        Spawn(class'XIIIMPDeathExplosionEmitter',,, Location);

        if( instigatedBy != none )
        {
            instigatedBy.Controller.PlayerReplicationInfo.Score += 30;
            BroadcastLocalizedMessage( class'XIIIMPDuckMessage', -2, instigatedBy.Controller.PlayerReplicationInfo);
        }

        FullDamage = 0;

        // ----------- Lauch Sound for the Death ---------------------
        // 0 :PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntKilled');
        soundcounter0++;
        if( soundcounter0 == 255 )
            soundcounter0 =0;
        PlaySoundOfTheDeath();
        // ------------------------------------------------------------

        Controller.GotoState('ReInitWithTeleport');
    }
    else
    {
        XIIIMPDuckController(controller).Damaged(instigatedBy);
        Spawn(class'BlastDuckBlow',,, Location);

        // ----------- Lauch Sound for the Death ---------------------
        // 1: PlaySound( Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntPafed' );
        soundcounter1++;
        if( soundcounter1 == 255 )
            soundcounter1 =0;
        PlaySoundOfTheDeath();
        // ------------------------------------------------------------
    }

    level.Game.CheckScore(instigatedBy.PlayerReplicationInfo);


    return;
}

//_____________________________________________________________________________





defaultproperties
{
     OldLoopAnimID=-1
     bBoss=True
     GroundSpeed=1200.000000
     ControllerClass=Class'XIIIMP.XIIIMPDuckController'
     Mesh=SkeletalMesh'XIIIPersos.DeathM'
     SaturationDistance=600.000000
     StabilisationDistance=2000.000000
     CollisionRadius=20.000000
     CollisionHeight=45.000000
}
