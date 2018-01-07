//=============================================================================
// XIIIPlayerPawn.
//=============================================================================
class XIIIMPPlayerPawn extends XIIIPlayerPawn;

#exec OBJ LOAD FILE=Onomatopees.uax PACKAGE=Onomatopees

var string SkinMP[2];       // Team 0/1 (Red/Blue) skins
var byte CodeMesh;          // Used for sounds
enum eSubClass
{
  SC_Sniper,
  SC_Soldier,
  SC_Mercenary,
  SC_HeavySoldier,
  SC_Hunter,
};
var eSubClass SubClass;     // Should be used for games w/ classes (bombing)
/*
// Classes should be : + Additional equipment (9mm infinite ammo is basis)
Sniper :        · sniper rifle · mini gun · 2 flasbangs
Soldier :       · AssaultRifle · 1 AssaultRifke grenad · FGrenad · Flasbang
Mercenary :     · Kalash · MiniGun · 2 FGrenad
Heavy soldier : · M60 · Grenad
Hunter :        · ShotGun · 3 Grenads · 1 FlashBang
*/

var float SuperDamageFactor;
var int MarioBonusID;
var int SuperDamageNumber;
var bool bMarioInvisibility;
var bool HasTheDuck;
var int MarioBonusLAN;


//__________________________________________________________________
replication
{
    reliable if( Role==ROLE_Authority )
        MarioBonusLAN;
}

//_____________________________________________________________________________
// event called on skinID change by replication
simulated event ChangeSkin()
{
//    Log("SKIN"@self@"ChangeSkin new Id="$SkinID);
    ClientChangeSkin(SkinID);
}

//_____________________________________________________________________________
// not real client function but this called on the server will update SkinID wich is native-replicated
simulated function ClientChangeSkin( int NewSkinId )
{
    local int i, NbSkins;
    local mesh MeshSkin;

    if ( PlayerReplicationInfo != none )
      Log("SKIN"@self@"ClientChangeSkin new Id="$SkinID@"SkinName='"$PlayerReplicationInfo.SkinCodeName$"'");
    else
      Log("SKIN"@self@"ClientChangeSkin new Id="$SkinID@" NO PRI");

    if ( (PlayerReplicationInfo != none) && (PlayerReplicationInfo.SkinCodeName != "") )
    { // Assign new skin
      NbSkins = class'MeshSkinList'.default.MeshSkinListInfo.Length;
      i = class'MeshSkinList'.Static.StaticFindSkinIndex(PlayerReplicationInfo.SkinCodeName);
      if ( i <= NbSkins )
      {
        Log(" Found SKIN "$i$" - "$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinReadableName@"("$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode$"|"$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName$")");
        MeshSkin = mesh(DynamicLoadObject(class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName, class'Mesh'));
        if ( MeshSkin != none )
        {
          Mesh = MeshSkin;
          SkinMP[0] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinRed;
          SkinMP[1] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinBlue;
          CodeMesh = class'MeshSkinList'.default.MeshSkinListInfo[i].CodeMesh;
          bInitializeAnimation = false;
        }
      }
      else
        Log(" SKIN code"@PlayerReplicationInfo.SkinCodeName@"NOT found, Use default/Previous");
    }
    // Assign new color
    SkinID = NewSkinId;
    if ( (NewSkinId < 2) && (NewSkinId > -1) )
      skins[0] = texture(DynamicLoadObject(SkinMP[NewSkinId], class'texture'));
    else
      Skins[0] = none;
}

//_____________________________________________________________________________
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if (XIIIMPPlayerController(controller) != none && XIIIMPPlayerController(controller).bImmortal)
      return;

    if( damageType != class'DTFell')
    {
        if( damageType == class'XIII.DTSniped')
            Damage *= 2.0;

      if( XIIIMPPlayerPawn(instigatedBy) != none )
        Damage *= XIIIMPPlayerPawn(instigatedBy).SuperDamageFactor;
    }
    Damage *= 0.6;
    super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

//_____________________________________________________________________________
// Not Simulated, Server call only
function DropMyWeapon()
{
    local inventory Inv, InvD;
    local weapon MyTossedWeapon;
    local MPBomb TheBomb;

//    LOG("DROPWEAPON"@Weapon);
    // bombing mode code
    TheBomb = MPBomb(FindInventoryType(class'MPBomb'));
    if ( TheBomb != none )
    {
/*
      if ( Level.NetMode == NM_Client )
        TheBomb.ServerResetPickupSource();
      else
        TheBomb.PickupSource.GotoState('DelayBeforePickable');
*/
      TheBomb.Destroy();
    }

    if ( Weapon != none )
    {
      if( MPBomb(Weapon) == none )
      {
          if ( (BerettaMulti(Weapon) == none) && Weapon.HasAmmo() ) // no need to check for bomb because already destroyed
          {
            MyTossedWeapon = Weapon;
            Weapon.bTossedOut = true;
            TossWeapon(Vector(Rotation) * 500 + vect(0,0,220));
          }
      }
    }

/* // ELR Will be done at pawn destruction.
    inv = Inventory;
    while ( Inv != none )
//    for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
    { // destroy anything left in inventory after dropping weapon & bomb
//      LOG("  > DESTROY"@Inv@"BECAUSE DEAD");
      InvD = Inv;
      Inv = Inv.Inventory;
      InvD.Destroy();
    }
*/
}

//_____________________________________________________________________________
simulated function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
    if ( (Level.NetMode == NM_Client) || (Level.NetMode == NM_ListenServer) )
    { // only for on-line, not against bots
//      Log("MPANIM PlayTakeHit for "$self);
      //PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',CodeMesh,0);
    }
    Super.PlayTakeHit(HitLoc, Damage, DamageType);
}

//_____________________________________________________________________________
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
//    Log("ANIM PlayDyingAnim for"@self@"Weapon="@Weapon@"NetMode="$Level.NetMode@"Local ?"@IsLocallyControlled());
    if ( Weapon != none )
    {
      Weapon.instigator = self;
      Weapon.NotifyOwnerKilled(none);
    }
    // ELR On clients, must reset these because bug if we pick it up again
    if ( (Level.NetMode == NM_Client) /*&& IsLocallyControlled()*/ && (Weapon != none) )
    { // ELR IsLocallycontrolled don't work anymore, reason : no more controller when PlayDyingAnim is called.
      // solution : remove IsLocallycontrolled test, if have weapon then must be locally controlled.
//      LOG("REINITWEAPON"@Weapon);
      Weapon.Instigator = none;
      Weapon.SetOwner(none);
      Weapon.SetBase(none);
      Weapon.StopAnimating();
      Weapon.GotoState('');
      Weapon.bRendered = false;
      Weapon.bHidden = true;
      Weapon.RefreshDisplaying();
      Weapon.DetachFromPawn(self);
      DeleteInventory(Weapon);
    }
    else
      DropMyWeapon(); // on Server call only

    super.PlayDyingAnim(DamageType, HitLoc);
    //PlaySndDeathOno(deathono'Onomatopees.hPNJDeath1',CodeMesh,0);
}

//_____________________________________________________________________________
simulated function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
//  Log("ClientDying Weapon="$Weapon);
  if ( Weapon != none )
    Weapon.NotifyOwnerKilled(none);
	if ( Controller != None )
		Controller.ClientDying(DamageType, HitLocation);
}

//_____________________________________________________________________________
state Dying
{
    simulated event BeginState()
    {
//      Log("Dying BeginState");
      MarioBonusLAN = 0;
      if( ( PlayerController(Controller) != none ) && ( XIIIMPHud(PlayerController(Controller).MyHUD) != none ) )
      {
        XIIIMPHud(PlayerController(Controller).MyHUD).MarioBonus=0;
        XIIIMPHud(PlayerController(Controller).MyHUD).FragCount=0;
      }
      if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
        LifeSpan = 1.0;
      SetTimer2(10.0, false); // leave enough time to see in bombing mode while waiting for respawn

      SetPhysics(PHYS_Falling);
      bInvulnerableBody = true;
      if ( Controller != none )
        Controller.PawnDied();
    }

    simulated event Timer2()
    {
      local XIIIGameReplicationInfo XGRI;

      foreach allactors(class'XIIIGameReplicationInfo', XGRI)
        break;
//      Log("Dying Timer");
      if ( XGRI.iGameState == 2 )
        Destroy(); // only destroy while playing game, not when game ended
      else
        SetTimer2(3.0, false);
    }
    simulated event Timer()
    {
      Global.Timer();
    }
}



defaultproperties
{
     SuperDamageFactor=1.000000
     GroundSpeed=567.000000
     Health=250
     hHitSound=Sound'XIIIsound.Impacts__ImpFlesh.ImpFlesh__hPlayImpFlesh'
     HeadShotFactor=5.000000
     bIgnoreVignetteAlpha=False
     bHasRollOff=True
     bHasPosition=True
}
