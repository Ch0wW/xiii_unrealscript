//=============================================================================
// Parent class of all weapons.
//=============================================================================
class Weapon extends Inventory
  abstract
  native
  nativereplication;

#exec Texture Import File=Textures\Weapon.pcx Name=S_Weapon Mips=Off MASKED=1 COMPRESS=DXT1

//_____________________________________________________________________________
// Bools
var bool bChangeWeapon;             // Used in Active State
var bool bCanThrow;                 // if true, player can toss this weapon out
var bool bRapidFire;                // used by pawn animations in determining firing animation, and for net replication
var bool bForceReload;              // used to handle reload in Finish
var bool bMeleeWeapon;              // Weapon is only a melee weapon
var bool bForceFire, bForceAltFire; // Used to handle forcing fire in Finish
var bool bHaveAltFire;              // this weapon have a AltFire
var bool bEmptyShot;                // True if we tried to shoot a weapon without ammo
var bool bAllowEmptyShot;           // some weapons don't allow empty shot.
var bool bAllowShot;                // lock Shot for Semi-auto weapons if keeping fire pressed (must press fire again)
var bool bHaveScope;                // Do we have a zoom on this weapon (used by Altfire)
var bool bZoomed;                   // to use zoom
var bool bDrawCrosshairOutZoom;     // To be used for sniping weapons (no crosshair if not in zoom)
var bool bUnderWaterWork;           // true if the weapon works underwater.
var bool bUseSilencer;              // true if the weapon can use the silencer.
var bool bShouldGoThroughTraversable; // true if we want the shoots go through the XIIIMover with bTraversable=True
var bool bTraceBullets;             // Do we trace bullets
var bool bDrawZoomedCrosshair;      // if we need to draw the zoomed crosshair (because Interaction draw after HUD = bug of zoomed CH masking everything else)
var bool bAutoReload;               // Should we reload just after firing ?
var bool bAltEmptyShot;             // True if we tried to Altshoot a weapon without ammo
var bool bDrawAltMuzzleFlash;       // enable first-person muzzle flash for AltFire
var bool bHeavyWeapon;              // Used to slow pawn when holding this
var bool bHaveBoredSfx;             // To enable bored effect
var bool bCanHaveSlave;             // Can we have a slave ? (Dual weapons)
var bool bHaveSlave;                // do the weapon have a slave ? (Dual Weapons)
var bool bIsSlave;                  // is this weapon a slave ? (dual Weapons)
var bool bEnableSlave;              // to allow use of Altfire to switch between single/dual weapon
var bool bMuzzleFlash;              // if !=0 show first-person muzzle flash
var bool bSetFlashTime;             // reset FlashTime clock when false
var bool bDrawMuzzleFlash;          // enable first-person muzzle flash
var bool bRendered;                 // used to be unhidden only when rendering overlays

var enum eWeaponHand
{
    WHA_Fist,
    WHA_1HShot,
    WHA_2HShot,
    WHA_Throw,
    WHA_Deco,
} WHand;                            // Weapon type (hand using) meant for animsations & restrictions
var enum eWeaponMode
{
    WM_Auto,
    WM_SemiAuto,
    WM_Burst,
} WeaponMode;                       // Weapon Mode for Semi-auto guns.

//_____________________________________________________________________________
// Weapon/ammo information:
var class<ammunition> AmmoName;     // Type of ammo used.
var class<ammunition> AltAmmoName;  // Type of Alt ammo used.
var int PickupAmmoCount;            // Amount of ammo initially in pick-up item.
var int AltPickupAmmoCount;         // Amount of Alt ammo initially in pick-up item.
var travel ammunition AmmoType;     // Inventory Ammo being used.
var travel ammunition	AltAmmoType;  // Inventory Alt Ammo being used.
var travel byte ReloadCount;               // Amount of ammo depletion before reloading. 0 if no reloading is done.
var travel byte AltReloadCount;            // Amount of Alt ammo depletion before reloading. 0 if no reloading is done.
var string MeshName;                // to allow dynamic load of mesh (optimize memory)
var actor Silencer;                 // the silencer object to put on weapon.
var float StopFiringTime;           // repeater weapons use this
var vector FireOffset;              // Offset from first person eye position for projectile/trace start
var vector AltFireOffset;           // Offset from first person eye position for projectile/trace start
var texture CrossHair;              // Crosshair Texture
var float TraceAccuracy;            // Accuracy of the traces (in % of TraceDist)
var int iBurstCount;                // to handle burst mode
var float fVarAccuracy;             // variable accuracy (low for First shot, up to TraceAccuracy in 5 shots)
var float ScopeFOV;                 // FOV to use in zoom
var float ShotTime;                 // How long we wait after a shoot to go again // Used by IA controllers
var name FiringMode;                // firing mode to use, sent to the pawn to play right anim
var float FireNoise;                // Noise made by the weapon when firing
var float ReLoadNoise;              // Noise made by the weapon when ReLoading
var float AltFireNoise;             // Noise made by the weapon when firing
var float fTraceBulletCount;        // to decide if we should trace the bullet using bool bTraceBullets
var texture ZCrosshair;             // texture to use for Zoomed Crosshair
var texture ZCrosshairDot;          // texture to use for Zoomed Crosshair (the dot)
var texture StabilityTex;           // texture to use for Zoomed mode to show stability
var name LoadedFiringAnim;
var name EmptyFiringAnim;
var name LoadedAltFiringAnim;
var name EmptyAltFiringAnim;
var vector ViewFeedBack;            // to make view change when firing, X = horiz, Y = Vert,
var vector AltViewFeedBack;         // to make view change when altfiring, X = horiz, Y = Vert,
var int iAltZoomLevel;              // Number of zooming levels (for Alternative zooming system)
var float fAltZoomValue[3];         // Values of the Fov factors for each levels of Alt zooming system
                                    // Should be -(85/factor - 90)/88 defaults to x3, x8 & x12
var int iBoredCount;                // For special 'i'm bored' effect :)
var int RumbleFXNum;                // Rumble FX effect to use for this weapon.
var const localized string sWeaponModeAuto, sWeaponModeSemiAuto, sWeaponModeBurst;
                                    // to display Weapon mode
var InventoryAttachment FirstPersonMF;              // FirstPerson Muzzle Flash actor
var class<InventoryAttachment> FirstPersonMFClass;  // FirstPerson Muzzle Flash actor class
var() vector FPMFRelativeLoc;       // FirstPersonMuzzleFlash relative Location
var() Rotator FPMFRelativeRot;      // FirstPersonMuzzleFlash relative Rotation
var Emitter WRE;                    // WaterRingsEmmiter, to setup the HitSoundType on the emitter.
// dual Weapon / Slave handling
var Weapon MySlave;                 // the actor being the slave if bHaveSlave.
var Weapon SlaveOf;                 // the actor being the master if bIsSlave.
var name NextSlaveState;            // Used to handle Salve unsynchronized behaviour

//_____________________________________________________________________________
// SFXs Info
var float ShakeMag;                 // used for shakes on Fire
var float ShakeTime;                // used for shakes on Fire/
var vector ShakeVert;               // used for shakes on Fire
var vector ShakeSpeed;              // used for shakes on Fire
var float ShakeCycles;              // used for shakes on Fire
var float AltShakeMag;              // used for shakes on AltFire
var float AltShakeTime;             // used for shakes on AltFire
var vector AltShakeVert;            // used for shakes on AltFire
var vector AltShakeSpeed;           // used for shakes on AltFire
var float AltShakeCycles;           // used for shakes on AltFire

//_____________________________________________________________________________
// AI information
var float AIRating;
var float TraceDist;                // how far instant hit trace fires go (Units = Meters sorry for the non-metric system guys)
var float AltTraceDist;             // how far instant hit trace Altfires go (Units = Meters sorry for the non-metric system guys)
var Rotator AdjustedAim;

//-----------------------------------------------------------------------------
// Sound Assignments
var() sound hFireSound;             // Playing on Fire
var() sound hReloadSound;           // Playing on Reload
var() sound hNoAmmoSound;           // Playing on EmptyFire
var() sound hSelectWeaponSound;     // Playing on SelectWeapon
var() sound hZoomSound;             // Playing on Zooming (params for zoom/unzoom/stop)
//var() sound hShellsSound;           // Playing on spawning shells
var() sound hAltFireSound;          // Playing on AltFire
var() sound hActWaitSound;          // Playing on Active Waiting

// messages
var() Localized string MessageNoAmmo;

//_____________________________________________________________________________
// first person Muzzle Flash
// weapon is responsible for setting and clearing bMuzzleFlash whenever it wants the
// MFTexture drawn on the canvas (see RenderOverlays() )
var float FlashTime;                    // time when muzzleflash will be cleared (set in RenderOverlays())
var(MuzzleFlash) float MuzzleScale;     // scaling of muzzleflash
var(MuzzleFlash) float FlashOffsetY;    // flash center offset from centered Y (as pct. of Canvas Y size)
var(MuzzleFlash) float FlashOffsetX;    // flash center offset from centered X (as pct. of Canvas X size)
var(MuzzleFlash) float FlashLength;     // How long muzzle flash should be displayed in seconds
var(MuzzleFlash) float MuzzleFlashSize; // size of (square) texture
var texture MFTexture;                  // first-person muzzle flash sprite
var byte FlashCount;                    // when incremented, draw muzzle flash for current frame (on-line used)
var byte AltFlashCount;                 // when incremented, draw alt muzzle flash for current frame (on-line used)
var byte ReloadClientCount;             // when incremented, reload for clients

var bool DBDual;
var bool DBWeap;
CONST BOREDSFXTHRESHOLD=10;

//_____________________________________________________________________________
// Network replication !! NATIVEREPLICATION !!
replication
{
    // Things the server should send to the client.
    reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
      AmmoType, ReloadCount, bAllowShot, AltAmmoType, AltReloadCount;

    // Functions called by server on client
    reliable if( Role==ROLE_Authority )
      ClientWeaponSet, ClientForceReload, ClientReload;

    // functions called by client on server
    reliable if( Role<ROLE_Authority )
      ServerForceReload, ServerFire, ServerAltFire, ServerRapidFire, ServerStopFiring, ServerReload;
}

//_____________________________________________________________________________
Static function StaticParseDynamicLoading(LevelInfo MyLI)
{
    Log("Weapon StaticParseDynamicLoading class="$default.class);
    Super.StaticParseDynamicLoading(MyLI);
    if ( default.AmmoName != none )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = default.AmmoName;
      (default.AmmoName).Static.StaticParseDynamicLoading(MyLI);
    }
    if ( default.AltAmmoName != none )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = default.AltAmmoName;
      (default.AltAmmoName).Static.StaticParseDynamicLoading(MyLI);
    }
    MyLI.ForcedMeshes[MyLI.ForcedMeshes.Length] =
      Mesh(DynamicLoadObject(default.MeshName, class'mesh'));
}

//_____________________________________________________________________________
simulated event PostBeginPlay()
{
    // Convert TraceDist from meters to Unreal Engine Units
    TraceDist = TraceDist * 200.0 / 2.54;
    AltTraceDist = AltTraceDist * 200.0 / 2.54;
//    Log("PostBeginPlay for"@self@"TraceDist="$TraceDist@"altTraceDist="$AltTraceDist);
    Super.PostBeginPlay();
    // Optimize using dynamicload (the real dynamicload should have happened in the mutator at the map init)
    if ( (Mesh == none) && (MeshName != "") )
    {
      Mesh = Skeletalmesh(dynamicloadobject(MeshName, class'mesh')); // ParseDynMade
      default.mesh = mesh;
    }
    if ( (AttachmentClass != none) && (AttachmentClass.default.StaticMeshName != "") )
      DynamicLoadObject(AttachmentClass.default.StaticMeshName, class'StaticMesh'); // ParseDynLoad Made
    iAltZoomLevel = 0; // Initialize because default is used for max zoom level
    bRendered = false;
    bHidden = true;
    Refreshdisplaying();
    if ( MySlave != none )
    {
      MySlave.bRendered = false;
      MySlave.bHidden = true;
      MySlave.RefreshDisplaying();
    }
}

//_____________________________________________________________________________
simulated event PostNetBeginPlay()
{
    if ( Role == ROLE_Authority )
      return;
    if ( (Instigator == None) || (Instigator.Controller == None) )
      SetHand(0);
    else
      SetHand(Instigator.Controller.Handedness);
}

//_____________________________________________________________________________
simulated function string GetAmmoText(out int bDrawbulletIcon);

//_____________________________________________________________________________
// Used to handle unsynchronized behaviour of slaves.
// not simulated because should not be used in multiplayer
event Timer2()
{
    switch (NextSlaveState)
    {
      Case 'BringUp':
        bRendered = true;
//        bHidden = false;
//        RefreshDisplaying();
        BringUp();
        break;
      Case 'Fire':
        Fire(0.0);
        break;
    }
}

//_____________________________________________________________________________
//Tell WeaponAttachment to cause client side weapon firing effects
simulated function IncrementReloadClientCount()
{
    ReloadClientCount++;
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
      WeaponAttachment(ThirdPersonActor).ReloadClientCount = ReloadClientCount;
      WeaponAttachment(ThirdPersonActor).ThirdPersonReload();
    }
}

//_____________________________________________________________________________
//Tell WeaponAttachment to cause client side weapon firing effects
// 473 탎
simulated function IncrementFlashCount()
{
    FlashCount++;
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
      WeaponAttachment(ThirdPersonActor).FlashCount = FlashCount;
      WeaponAttachment(ThirdPersonActor).ThirdPersonEffects(); // 420 탎
    }
    RumbleFX();
}

//_____________________________________________________________________________
//Tell WeaponAttachment to cause client side weapon firing effects
simulated function IncrementAltFlashCount()
{
    AltFlashCount++;
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
      WeaponAttachment(ThirdPersonActor).AltFlashCount = AltFlashCount;
      WeaponAttachment(ThirdPersonActor).ThirdPersonAltEffects();
    }
    RumbleFX();
}

//_____________________________________________________________________________
simulated function SetupMuzzleFlash();

//_____________________________________________________________________________
// Prototype
simulated function RumbleFX();

/* Force reloading even though clip isn't empty.  Called by player controller exec function,
and implemented in idle state */
simulated function ForceReload();

function ServerForceReload()
{
	bForceReload = true;
}

function ClientForceReload()
{
	bForceReload = true;
}

//_____________________________________________________________________________
// list important controller attributes on canvas
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local string T;
    local name Anim;
    local float frame,rate;

//    Super.DisplayDebug(Canvas, YL, YPos);

    Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText("WEAPON "$GetItemName(string(self)));
    YPos += YL;
    Canvas.SetPos(4,YPos);
    Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter@"bChangeWeapon: "$bChangeWeapon, false);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    if ( Default.ReloadCount > 0 )
    {
      Canvas.DrawText("Reload Count: "$ReloadCount);
      YPos += YL;
      Canvas.SetPos(4,YPos);
    }

    if ( DrawType == DT_StaticMesh )
      Canvas.DrawText("     StaticMesh "$StaticMesh$" AmbientSound "$AmbientSound, false);
    else
      Canvas.DrawText("     Mesh "$Mesh$" AmbientSound "$AmbientSound, false);
    YPos += YL;
    Canvas.SetPos(4,YPos);
    if ( Mesh != None )
    {
      // mesh animation
      GetAnimParams(0,Anim,frame,rate);
      T = "     AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
      if ( bAnimByOwner )
        T= T$" Anim by Owner";
      Canvas.DrawText(T, false);
      YPos += YL;
      Canvas.SetPos(4,YPos);
    }

    if ( AmmoType == None )
    {
      Canvas.DrawText("ERROR - NO AMMUNITION");
      YPos += YL;
      Canvas.SetPos(4,YPos);
    }
    else
      AmmoType.DisplayDebug(Canvas,YL,YPos);
}

//_____________________________________________________________________________
// Inventory travelling across servers.
event TravelPostAccept()
{
    if ( Pawn(Owner) == None )
    if ( Pawn(Owner).IsPlayerPawn() )
    {
      DebugLog(self@"TravelPostAccept");
    }
    Super.TravelPostAccept();
      return;
    if ( AmmoType == none )
      GiveAmmo(Pawn(Owner));
    if ( self == Pawn(Owner).Weapon )
      BringUp();
    else
      GotoState('');
    if ( Pawn(Owner).IsPlayerPawn() )
    {
      DebugLog("    after TravelPostAccept AmmoAmount="$AmmoType.AmmoAmount);
    }
}

//_____________________________________________________________________________
simulated event Destroyed()
{
    Super.Destroyed();
    if( (Pawn(Owner)!=None) && (Pawn(Owner).Weapon == self) )
      Pawn(Owner).Weapon = None;
    else if( (Instigator!=None) && (Instigator.Weapon == self) )
      Pawn(Owner).Weapon = None;

    if ( bTossedOut )
      return; // to avoid destroying our 'inventory' in a loop that would have memorized it (thus breaking the destruction loop)

    if ( AmmoType != none )
      AmmoType.Destroy();
    if ( AltAmmoType != none )
      AltAmmoType.Destroy();
    if ( Silencer != None )
      Silencer.Destroy();
}

//_____________________________________________________________________________
function SetUpDual(Weapon Dual, Pawn other);

//_____________________________________________________________________________
function GiveTo(Pawn Other)
{
    Local Weapon Dual;

    if ( Other.IsPlayerPawn() )
    {
      DebugLog("GIVETO (weapon)"@self@"to"@Other@"InventorySetUp ? "$Level.Game.bInventorySetUp);
    }

    // convert class if needed
    if ( (PlayerTransferClass == none) && (PlayerTransferClassName != "") )
      PlayerTransferClass = class<Inventory>(DynamicLoadObject(PlayerTransferClassName, class'class'));

    if ( (PlayerTransferClass != none) && Other.IsHumanControlled() && !Other.Controller.bIsBot )
    {
      Dual = Weapon(Spawn(PlayerTransferClass,,,Other.Location));
      Dual.GiveTo(Other);
      Destroy();
      return;
    }
    // convert class if needed
    if ( (NonPlayerTransferClass == none) && (NonPlayerTransferClassName != "") )
      NonPlayerTransferClass = class<Inventory>(DynamicLoadObject(NonPlayerTransferClassName, class'class'));

    if ( (NonPlayerTransferClass != none) && (!Other.IsHumanControlled() || Other.Controller.bIsBot) )
    {
      Dual = Weapon(Spawn(NonPlayerTransferClass,,,Other.Location));
      Dual.GiveTo(Other);
      Destroy();
      return;
    }

    Dual = Weapon(Other.FindInventoryType(class));
    if ( Dual == none )
    { // currently not owning weapon of this class, Std giveTo
      NewWeaponNotify(Other);
      Super.GiveTo(Other);
      bTossedOut = false;
      GiveAmmo(Other); // include GiveAltAmmo(Other);
      if ( Default.ReloadCount > 0 )
      {
        if ( !Other.IsPlayerPawn() || !Level.bLonePlayer || Level.Game.bInventorySetUp || bMeleeWeapon )
        {
          if ( Other.IsPlayerPawn() )
          {
            DebugLog("       after GiveAmmo, Ammo Addin ReloadCount "$ReloadCount@"for"@self);
          }
          AmmoType.AddAmmo(ReloadCount);
        }
        else // don't add anything as we just received inventory from save/last map
          if ( Other.IsPlayerPawn() )
          {
            DebugLog("       don't add ammo as we just travelled");
          }
      }
      else
      {
        if ( !Other.IsPlayerPawn() || !Level.bLonePlayer || Level.Game.bInventorySetUp || bMeleeWeapon  )
        {
          if ( Other.IsPlayerPawn() )
          {
            DebugLog("       after GiveAmmo, Ammo Addin PickUpAmmoCount "$PickUpAmmoCount@"for"@self);
          }
          AmmoType.AddAmmo(PickUpAmmoCount);
        }
        else if ( Other.IsPlayerPawn() )// don't add anything as we just received inventory from save/last map
        {
          DebugLog("       don't add ammo as we just travelled");
        }
      }
      ClientWeaponSet(true);
      bRendered = false;
      bHidden = true;
      RefreshDisplaying();
    }
    else if (Dual == self)
    { // can happen when loading a game w/ two weapons in inventory
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("END GIVETO (weapon) Cancel because Dual == self");
      }
      return;
    }
    else if ( Dual.bCanHaveSlave && !Dual.bHaveSlave && (Other.CanHoldDualWeapons() || !Level.Game.bInventorySetUp ) )
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("       Setting Up Dual for"@Dual@"&"@self);
      }
      SetUpDual(Dual, Other);
    }
    else if ( Dual == SlaveOf )
    { // can happen when loading a game w/ two weapons in inventory
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("END GIVETO (weapon) Cancel because Dual == SlaveOf");
      }
      return;
    }
    else
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("       Already Owned"@dual@".bCanHaveSlave="$Dual.bCanHaveSlave@"., Take ammo then Destroy");
      }
      if ( ReloadCount != 0 )
        Dual.AmmoType.AddAmmo(ReloadCount);
      else
        Dual.AmmoType.AddAmmo(PickupAmmoCount);
      Destroy();
    }
    if ( Other.IsPlayerPawn() )
    {
      DebugLog("END GIVETO (Weapon)"@self@"(Owner="$Owner$") Ammo="@AmmoType@"(Owner="$AmmoType.Owner$")");
    }
}

//_____________________________________________________________________________
function Transfer(Pawn Other)
{
    Local Weapon Dual;

    if ( Other.IsPlayerPawn() )
    {
      DebugLog("TRANSFER (weapon)"@self@"to"@Other);
    }

    // detach from old owner
    if ( Instigator != none )
    {
  		DetachFromPawn(Instigator);
      Instigator.DeleteInventory(self);
    }

    // Don't care about transfering ammo before weapon because GiveAmmo will reinsert them after weapon
    if ( AmmoType != none )
    {
      if ( (AmmoType.AmmoAmount > 0) && (AmmoType.PickupClass != none) && (class<Ammo>(AmmoType.PickupClass) != none) ) // last test to avoid double message for ammos that have weapon as pickup (knives, grenads)
      {
        Other.PlaySound(AmmoType.PickupClass.default.PickupSound);
        Other.ReceiveLocalizedMessage( AmmoType.PickupClass.default.MessageClass, 0, None, None, AmmoType.PickupClass );
      }
      if ( Other.IsHumanControlled() )
      {
        if ( default.ReloadCount != 0 )
          AmmoType.AmmoAmount = 0; // for weapons w/ reload count, don't transfer more than reload count
        // when transfering cap the amount of ammo pickable
        else if ( (AmmoType.PickupClass != none) &&  (class<Ammo>(AmmoType.PickupClass) != none) )
          AmmoType.AmmoAmount = class<Ammo>(AmmoType.PickupClass).default.AmmoAmount;
        else
          AmmoType.AmmoAmount = PickupAmmoCount;
      }

      AmmoType.Transfer(Other);
      AmmoType = none;
    }
    if ( AltAmmoType != none )
    {
/* not done w/ alt ammo
      // when transfering cap the amount of ammo pickable
      if ( AltAmmoType.PickupClass != none )
        AltAmmoType.AmmoAmount = class<Ammo>(AltAmmoType.PickupClass).default.AmmoAmount;
      else
        AltAmmoType.AmmoAmount = AltPickupAmmoCount;
*/
      if ( (AltAmmoType.AmmoAmount > 0) && (AltAmmoType.PickupClass != none) && (class<Ammo>(AltAmmoType.PickupClass) != none) ) // last test to avoid double message for ammos that have weapon as pickup (knives, grenads)
      {
        Other.PlaySound(AltAmmoType.PickupClass.default.PickupSound);
        Other.ReceiveLocalizedMessage( AltAmmoType.PickupClass.default.MessageClass, 0, None, None, AltAmmoType.PickupClass );
      }
      AltAmmoType.Transfer(Other);
      AltAmmoType = none;
    }

    // convert class if needed
    if ( (PlayerTransferClass == none) && (PlayerTransferClassName != "") )
      PlayerTransferClass = class<Inventory>(DynamicLoadObject(PlayerTransferClassName, class'class'));

    if ( (PlayerTransferClass != none) && Other.IsHumanControlled() )
    {
      Dual = Weapon(Spawn(PlayerTransferClass,,,Other.Location));
      if ( Default.ReloadCount != 0 )
        Dual.ReloadCount = ReloadCount;
      Dual.Transfer(Other);
      Destroy();
      return;
    }
    // convert class if needed
    if ( (NonPlayerTransferClass == none) && (NonPlayerTransferClassName != "") )
      NonPlayerTransferClass = class<Inventory>(DynamicLoadObject(NonPlayerTransferClassName, class'class'));

    if ( (NonPlayerTransferClass != none) && !Other.IsHumanControlled() )
    {
      Dual = Weapon(Spawn(NonPlayerTransferClass,,,Other.Location));
      if ( Default.ReloadCount != 0 )
        Dual.ReloadCount = ReloadCount;
      Dual.Transfer(Other);
      Destroy();
      return;
    }

    Dual = Weapon(Other.FindInventoryType(class));
    if ( Dual == none )
    { // currently not owning weapon of this class
      NewWeaponNotify(Other);
      Other.PlaySound(PickupClass.default.PickupSound);
      Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
//      GiveTo(Other);
      Super.GiveTo(Other);
      bTossedOut = false;
      GiveAmmo(Other); // include GiveAltAmmo(Other);
      ClientWeaponSet(true);
      bRendered = false;
      bHidden = true;
      RefreshDisplaying();
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("         (weapon)"@self@"to"@Other@"GiveTo because not owned, AmmoAmount="$AmmoType.AmmoAmount);
      }
      if ( default.ReLoadCount != 0 )
        AmmoType.AddAmmo(ReLoadCount);
    }
    else if ( Dual.bCanHaveSlave && !Dual.bHaveSlave && Other.CanHoldDualWeapons() )
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("         (weapon)"@self@"to"@Other@"GiveTo because Dual allowed");
      }
      Other.PlaySound(PickupClass.default.PickupSound);
      Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
      SetUpDual(Dual, Other);
    }
    else
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("         (weapon)"@self@"to"@Other@" Add ReloadCount then Destroy because owned");
      }
      if ( Default.ReloadCount > 0 )
        Dual.AmmoType.AddAmmo(ReloadCount);
      if ( Default.AltReloadCount > 0 )
        Dual.AmmoType.AddAmmo(ReloadCount);
      if ( class<Ammo>(Dual.AmmoType.PickupClass) == none )
      { // Send message because picking weapon w/out ammo pickup
        Other.PlaySound(PickupClass.default.PickupSound);
        Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
      }
//      else // else do nothing as ammo should have been transfered w/ the ammotype
//        Dual.AmmoType.AddAmmo(PickupAmmoCount);
      Destroy();
    }
}

//_____________________________________________________________________________
function NewWeaponNotify(Pawn Other);

/*
//_____________________________________________________________________________
// Weapon rendering
// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
    local rotator NewRot;
    local bool bPlayerOwner;
    local int Hand;
    local PlayerController PlayerOwner;
    local float ScaledFlash;

    if ( Instigator == None )
      return;

    PlayerOwner = PlayerController(Instigator.Controller);

    if ( PlayerOwner != None )
    {
      bPlayerOwner = true;
      Hand = PlayerOwner.Handedness;
      if (  Hand == 2 )
        return;
    }

    if ( bMuzzleFlash && bDrawMuzzleFlash && (MFTexture != None) )
    {
      if ( !bSetFlashTime )
      {
        bSetFlashTime = true;
        FlashTime = Level.TimeSeconds + FlashLength;
      }
      else if ( FlashTime < Level.TimeSeconds )
        bMuzzleFlash = false;
      if ( bMuzzleFlash )
      {
        ScaledFlash = 0.5 * MuzzleFlashSize * MuzzleScale * Canvas.ClipX/640.0;
        Canvas.SetPos(0.5*Canvas.ClipX - ScaledFlash + Canvas.ClipX * Hand * FlashOffsetX, 0.5*Canvas.ClipY - ScaledFlash + Canvas.ClipY * FlashOffsetY);
      //			DrawMuzzleFlash(Canvas);
      }
    }
    else
      bSetFlashTime = false;

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    NewRot = Instigator.GetViewRotation();

    if ( Hand == 0 )
      newRot.Roll = 2 * Default.Rotation.Roll;
    else
      newRot.Roll = Default.Rotation.Roll * Hand;

    setRotation(newRot);
    Canvas.DrawActor(self, false, false);
}
*/

//_____________________________________________________________________________
// If this is called then just setup pos & render because primary weapon is already rendered
simulated function RenderSlaveOverlays( canvas Canvas );

//_____________________________________________________________________________
simulated function bool ShouldDrawCrosshair(optional Canvas C)
{
    return ( !bZoomed && (Pawn(Owner).IsPlayerPawn() && !PlayerController(Pawn(Owner).Controller).bZooming) );
}

//_____________________________________________________________________________
//return percent of full ammo (0 to 1 range)
function float AmmoStatus()
{
    return float(AmmoType.AmmoAmount)/AmmoType.MaxAmmo;
}

//_____________________________________________________________________________
native function bool HasAmmo();
/*
simulated function bool HasAmmo()
{
// should be useless
  if ( AmmoType == none )
    AmmoType = Ammunition(Pawn(Owner).FindInventoryType(AmmoName));

  if ( MySlave != none )
    return ( (AmmoType.AmmoAmount - MySlave.ReloadCount) > 0);
  else if ( SlaveOf != none )
    return ( (AmmoType.AmmoAmount - SlaveOf.ReloadCount) > 0);
  else
    return AmmoType.HasAmmo();
}
*/

//_____________________________________________________________________________
simulated function bool HasAltAmmo()
{
    if ( AltAmmoType == none )
      return false;
    return AltAmmoType.HasAmmo();
}

//_____________________________________________________________________________
simulated function bool HasSilencer();

//_____________________________________________________________________________
// sets appropriate weapon configuration, and returns rating based on that configuration
function float RateSelf()
{
    if ( !HasAmmo() )
      return -2;
    return (AIRating + FRand() * 0.05);
}

//_____________________________________________________________________________
// If picking up another weapon of the same class, add its ammo.
// If ammo count was at zero, check if should auto-switch to this weapon.
function bool HandlePickupQuery( Pickup Item )
{
    local int OldAmmo, NewAmmo;
    local Pawn P;

//    if ( DBDual )
    if ( Pawn(Owner).IsPlayerPawn() )
    {
      DebugLog(">> HandlePickupQuery for "$self);
    }
    if (Item.InventoryType == Class)
    {
      if ( Level.bLonePlayer && bCanHaveSlave && !bHaveSlave )
      {
        if ( DBDual ) Log(" > we are accepting picking up a weapon to be used for dual wielding");
        return false;
      }
    }
    if (Item.InventoryType == Class)
    {
      if ( (WeaponPickup(item) != none) && WeaponPickup(item).bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
        return true;
      P = Pawn(Owner);
      if ( AmmoType != None )
      {
        OldAmmo = AmmoType.AmmoAmount;
        if ( Item.Inventory != None )
          NewAmmo = Weapon(Item.Inventory).PickupAmmoCount;
        else
          NewAmmo = class<Weapon>(Item.InventoryType).Default.PickupAmmoCount;
        if ( AmmoType.AddAmmo(NewAmmo) && (OldAmmo == 0)
          && (P.Weapon.class != item.InventoryType) )
          ClientWeaponSet(true);
      }
      Item.AnnouncePickup(Pawn(Owner));
      return true;
    }
    if ( Inventory == None )
      return false;
    return Inventory.HandlePickupQuery(Item);
}

//_____________________________________________________________________________
// set which hand is holding weapon
simulated function SetHand(float Hand)
{
    Hand = 1;
/*
    if ( Hand == 2 )
    {
      PlayerViewOffset.Y = 0;
      FireOffset.Y = 0;
      return;
    }

    Mesh = Default.Mesh;
    if ( Hand == 0 )
    {
      PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
      PlayerViewOffset.Y = -0.2 * Default.PlayerViewOffset.Y;
      PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
    }
    else
    {
      PlayerViewOffset.X = Default.PlayerViewOffset.X;
      PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
      PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
    }
    FireOffset.Y = Default.FireOffset.Y * Hand;
*/
}

//_____________________________________________________________________________
// Change weapon to that specificed by F matching inventory weapon's Inventory Group.
simulated function Weapon WeaponChange( byte F )
{
    local Weapon newWeapon;

    if ( InventoryGroup == F )
    {
      if ( !HasAmmo() )
      {
        if ( Inventory == None )
          newWeapon = None;
        else
          newWeapon = Inventory.WeaponChange(F);
        return newWeapon;
      }
      else
        return self;
    }
    else if ( Inventory == None )
      return None;
    else
      return Inventory.WeaponChange(F);
}

//_____________________________________________________________________________
// ELR New function from WeaponChange to avoid potential bugs (this is to be used for SelectWeapon bind)
simulated function Weapon WeaponSelect( byte F )
{
    local Weapon newWeapon;

    if ( InventoryGroup == F )
    {
      if (!( (HasAmmo() || (bHaveAltFire && HasAltAmmo()) || (bHaveSlave && (MySlave.ReloadCount > 0)))
        && !bIsSlave && !(Pawn(Owner).bHaveOnlyOneHandFree && (WHand == WHA_2HShot)) ))
      {
        if ( Inventory == None )
          newWeapon = None;
        else
          newWeapon = Inventory.WeaponSelect(F);
        return newWeapon;
      }
      else
        return self;
    }
    else if ( Inventory == None )
      return None;
    else
      return Inventory.WeaponSelect(F);
}

//_____________________________________________________________________________
// Find the previous weapon (using the Inventory group)
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
//	if ( AmmoType.HasAmmo() )
    if ( (HasAmmo() || (bHaveAltFire && HasAltAmmo()) || (bHaveSlave && (MySlave.ReloadCount > 0)))
      && !bIsSlave && !(Pawn(Owner).bHaveOnlyOneHandFree && (WHand == WHA_2HShot)) )
    {
      if ( (CurrentChoice == None) )
      {
        if ( CurrentWeapon != self )
          CurrentChoice = self;
      }
      else if ( InventoryGroup == CurrentChoice.InventoryGroup )
      {
        if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
          if ( (GroupOffset < CurrentWeapon.GroupOffset)
            && (GroupOffset > CurrentChoice.GroupOffset) )
            CurrentChoice = self;
        }
        else if ( GroupOffset > CurrentChoice.GroupOffset )
          CurrentChoice = self;
      }
      else if ( InventoryGroup > CurrentChoice.InventoryGroup )
      {
        if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
          || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
        CurrentChoice = self;
      }
      else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
        && (InventoryGroup < CurrentWeapon.InventoryGroup) )
        CurrentChoice = self;
    }
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

//_____________________________________________________________________________
simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
//	if ( AmmoType.HasAmmo() )
    if ( (HasAmmo() || (bHaveAltFire && HasAltAmmo()) || (bHaveSlave && (MySlave.ReloadCount > 0)) )
      && !bIsSlave && !(Pawn(Owner).bHaveOnlyOneHandFree && (WHand == WHA_2HShot)) )
    {
      if ( (CurrentChoice == None) )
      {
        if ( CurrentWeapon != self )
          CurrentChoice = self;
      }
      else if ( InventoryGroup == CurrentChoice.InventoryGroup )
      {
        if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
          if ( (GroupOffset > CurrentWeapon.GroupOffset)
            && (GroupOffset < CurrentChoice.GroupOffset) )
            CurrentChoice = self;
        }
        else if ( GroupOffset < CurrentChoice.GroupOffset )
          CurrentChoice = self;
      }
      else if ( InventoryGroup < CurrentChoice.InventoryGroup )
      {
        if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
          || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
          CurrentChoice = self;
      }
      else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
        && (InventoryGroup > CurrentWeapon.InventoryGroup) )
        CurrentChoice = self;
    }
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function AnimEnd(int Channel)
{
	if ( Level.NetMode == NM_Client )
		PlayIdleAnim();
}

//_____________________________________________________________________________
function GiveAmmo( Pawn Other )
{
    if ( AmmoName == None )
      return;

    if ( Default.ReloadCount != 0 )
      ReLoadCount = min(ReLoadCount, PickUpAmmoCount);
    else
      ReLoadCount = PickUpAmmoCount;

    AmmoType = Ammunition(Other.FindInventoryType(AmmoName));
    if ( AmmoType == none )
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("GiveAmmo to"@other@", Ammo NOT Already owned, reseting to AmmoAmount = 0");
      }
      AmmoType = Spawn(AmmoName);	// Create ammo type required
      Other.AddInventory(AmmoType);		// and add to player's inventory
      AmmoType.AmmoAmount = 0;
    }
    else
    { // AmmoType must be after self in inventory, can happen when grabing some ammo before weapon
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("GiveAmmo to"@other@", Ammo Already owned, not adding any ammo");
      }

      if ( Level.NetMode == NM_StandAlone )
        Other.InsertInventory(AmmoType, self);
/*
      if ( Default.ReloadCount > 0 )
      {
        Log("GiveAmmo to"@other@", Ammo Already owned, Addin ReloadCount "$ReloadCount);
        AmmoType.AddAmmo(ReloadCount);
      }
      else
      {
        Log("GiveAmmo to"@other@", Ammo Already owned, Addin PickUpAmmoCount "$PickUpAmmoCount);
        AmmoType.AddAmmo(PickUpAmmoCount);
      }
*/
    }
    if ( bHaveAltFire )
      GiveAltAmmo(other);
}

//_____________________________________________________________________________
// ELR ADD Possibility that PickUpAmmoCount < ReLoadCount (else Bug)
simulated function GiveAltAmmo( Pawn Other )
{
    if ( AltAmmoName == None )
      return;
    AltAmmoType = Ammunition(Other.FindInventoryType(AltAmmoName));
    if ( AltAmmoType == none )
    {
      AltAmmoType = Spawn(AltAmmoName);	// Create ammo type required
      Other.AddInventory(AltAmmoType);		// and add to player's inventory
      AltAmmoType.AmmoAmount = AltPickUpAmmoCount;
      if ( default.AltReloadCount != 0 )
        AltReLoadCount = min(AltReLoadCount, AltPickUpAmmoCount);
      else
        AltReLoadCount = AltPickUpAmmoCount;
    }
    else
    { // AmmoType must be after self in inventory, can happen when grabing some ammo before weapon
      if ( Level.NetMode == NM_StandAlone )
        Other.InsertInventory(AltAmmoType, self);
      AltAmmoType.AddAmmo(AltPickUpAmmoCount);
    }
}

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
simulated function float SwitchPriority()
{
	local float temp;

	if ( !Instigator.IsHumanControlled() )
		return RateSelf();
	else if ( !AmmoType.HasAmmo() )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else
    	return 1;
}

//_____________________________________________________________________________
// Compare self to current weapon.  If better than current weapon, then switch
simulated function ClientWeaponSet(bool bOptionalSet)
{
	local weapon W;

	Instigator = Pawn(Owner); //weapon's instigator isn't replicated to client
	if ( Instigator == None )
	{
		GotoState('PendingClientWeaponSet');
		return;
	}
	else if ( IsInState('PendingClientWeaponSet') )
		GotoState('');
	if ( Instigator.Weapon == self )
		return;

	if ( Instigator.Weapon == None )
	{
		Instigator.PendingWeapon = self;
		Instigator.ChangedWeapon();
		return;
	}

    if ( bOptionalSet && Instigator.IsHumanControlled() )
		return;
/* ELR XIIIUNUSED no auto switch
	if ( Instigator.Weapon.SwitchPriority() < SwitchPriority() )
	{
		W = Instigator.PendingWeapon;
		Instigator.PendingWeapon = self;
		GotoState('');

		if ( !Instigator.Weapon.PutDown() )
			Instigator.PendingWeapon = W;
		return;
	}
*/
	GotoState('');
}

simulated function Weapon RecommendWeapon( out float rating )
{
	local Weapon Recommended;
	local float oldRating, oldFiring;
	local int oldMode;

	if (Instigator.bisdead || Instigator.Controller.bIsBot || Instigator.Controller.Enemy == None)   //fouille sur cadavre,  bot ou basesoldier sans enemmi
   {
       if( HasAmmo() )
           rating = AIRating;
       else
           rating=-1;
   }
   else if ( Instigator.IsHumanControlled() )   //XIII
    	rating = SwitchPriority();
	else //basesoldier avec ennemi
	{
		rating = RateSelf();
		if (self == Instigator.Weapon && AmmoType.HasAmmo())
			rating += 0.05; // tend to stick with same weapon
		//rating += Instigator.Controller.WeaponPreference(self);
	}
	if ( inventory != None )
	{
		Recommended = inventory.RecommendWeapon(oldRating);
		if ( (Recommended != None) && (oldRating > rating) )
		{
			rating = oldRating;
			return Recommended;
		}
	}
	return self;
}

//_____________________________________________________________________________
// Toss this weapon out
function DropFrom(vector StartLocation)
{
    AIRating = Default.AIRating;
    bMuzzleFlash = false;
    if ( AmmoType != None )
    {
      PickupAmmoCount = AmmoType.AmmoAmount;
      AmmoType.AmmoAmount = 0;
    }
    else if ( default.ReloadCount != 0 )
    {
      PickupAmmoCount = reloadCount;
    }
    GotoState('');
    Super.DropFrom(StartLocation);
}

//_____________________________________________________________________________
simulated function BringUp()
{
    if ( DBWeap )
      Log(self@"BringUp");
    if ( Instigator.IsHumanControlled() )
    {
      if( ! Instigator.Controller.bIsBot )
      {
        SetHand(PlayerController(Instigator.Controller).Handedness);
        PlayerController(Instigator.Controller).EndZoom();
      }
    }
    PlaySelect();
    bRendered = true;
//    bHidden = false;
//    RefreshDisplaying();
    GotoState('Active');
    if ( (MySlave != none) && bEnableSlave )
      MySlave.SlaveBringUp();
}

//_____________________________________________________________________________
simulated function BringUpNoSlave()
{
//    Log("BringUp Call for"@self);

    if ( Instigator.IsHumanControlled() )
    {
      SetHand(PlayerController(Instigator.Controller).Handedness);
      PlayerController(Instigator.Controller).EndZoom();
    }
    PlaySelect();
    GotoState('Active');
}

//_____________________________________________________________________________
simulated function SlaveBringUp()
{
    NextSlaveState = 'BringUp';
    SetTimer2(0.2 + fRand()*0.2, false);
}

//_____________________________________________________________________________
// Need this to force the server to reload.
function ServerReLoad()
{
//    Log(" ServerReLoad called");
    GotoState('ReLoading');
}

//_____________________________________________________________________________
// Need this to force the server to reload.
function ClientReLoad()
{
//    Log(" ClientReLoad called");
    GotoState('ReLoading');
}

//**************************************************************************************
//
// Firing functions and states
//
simulated function bool RepeatFire()
{
	return bRapidFire;
}

function ServerStopFiring()
{
	StopFiringTime = Level.TimeSeconds;
}

function ServerRapidFire()
{
	ServerFire();
	if ( IsInState('NormalFire') )
		StopFiringTime = Level.TimeSeconds + 0.6;
}

function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.HasAmmo() )
	{
		GotoState('NormalFire');
		if ( default.ReloadCount > 0 )
  		ReloadCount--;
		LocalFire();
		if ( AmmoType.bInstantHit )
			TraceFire(TraceAccuracy,0,0);
		else
			ProjectileFire();
	}
}

simulated function Fire( float Value )
{
	if ( !AmmoType.HasAmmo() )
		return;

	if ( !RepeatFire() )
		ServerFire();
	else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
	{
		StopFiringTime = Level.TimeSeconds + 0.6;
		ServerRapidFire();
	}
	if ( Role < ROLE_Authority )
	{
	  if ( default.ReloadCount > 0 )
  		ReloadCount--;
		LocalFire();
		GotoState('ClientFiring');
	}
}

//_____________________________________________________________________________
simulated function SlaveFire()
{
    NextSlaveState = 'Fire';
    SetTimer2(0.1+fRand()*0.10, false);
}

simulated function LocalFire()
{
	local PlayerController P;

//	bPointing = true;

	if ( (Instigator != None) && Instigator.IsLocallyControlled() )
	{
		P = PlayerController(Instigator.Controller);
		if (P!=None)
		{
//			if ( InstFlash != 0.0 )
//				P.ClientInstantFlash( InstFlash, InstFog);

			P.ShakeView(ShakeTime, ShakeMag, ShakeVert, 120000, ShakeSpeed, 1);
		}
	}
//	if ( Affector != None )
//		Affector.FireEffect();
	PlayFiring();
}

function ServerAltFire()
{
	if ( !IsInState('Idle') )
		GotoState('Idle');
}

/* AltFire()
Weapon mode change.
*/
simulated function AltFire( float Value )
{
	if ( !IsInState('Idle') )
		GotoState('Idle');
	ServerAltFire();
}

/*
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	return (Instigator.Location + Instigator.EyePosition() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z);
}
*/
native function vector GetFireStart(vector X, vector Y, vector Z);
/*
//_____________________________________________________________________________
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    if ( bZoomed )
      return (Instigator.Location + Instigator.EyePosition() + FireOffset.X * X);
    else
      return (Instigator.Location + Instigator.EyePosition() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z);
}
*/

function ProjectileFire()
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	Start = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, Start, 0);
	AmmoType.SpawnProjectile(Start,AdjustedAim);
}

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 0);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X);
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);
}

simulated function bool NeedsToReload()
{
	return ( bForceReload || (Default.ReloadCount > 0) && (ReloadCount == 0) );
}

// Finish a sequence
function Finish()
{
	local bool bForce, bForceAlt;

	if ( NeedsToReload() && AmmoType.HasAmmo() )
	{
		GotoState('Reloading');
		return;
	}

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}

	if ( !Instigator.IsHumanControlled() )
	{
		if ( !AmmoType.HasAmmo() )
		{
			Instigator.Controller.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}
		if ( Instigator.PressingFire() )
			Global.ServerFire();
		else if ( Instigator.PressingAltFire() )
			CauseAltFire();
		else
		{
			Instigator.Controller.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( !AmmoType.HasAmmo() && Instigator.IsLocallyControlled() )
	{
		// if local player, switch weapon
		Instigator.Controller.SwitchToBestWeapon();
		if ( bChangeWeapon )
		{
			GotoState('DownWeapon');
			return;
		}
		else
			GotoState('Idle');
	}
	if ( Instigator.Weapon != self )
		GotoState('Idle');
	else if ( (StopFiringTime > Level.TimeSeconds) || bForce || Instigator.PressingFire() )
		Global.ServerFire();
	else if ( bForceAlt || Instigator.PressingAltFire() )
		CauseAltFire();
	else
		GotoState('Idle');
}

function CauseAltFire()
{
	Global.ServerAltFire();
}

simulated function ClientFinish()
{
	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}
	if ( NeedsToReload() && AmmoType.HasAmmo() )
	{
		GotoState('Reloading');
		return;
	}
	if ( !AmmoType.HasAmmo() )
	{
		Instigator.Controller.SwitchToBestWeapon();
		if ( !bChangeWeapon )
		{
			PlayIdleAnim();
			GotoState('Idle');
			return;
		}
	}
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Instigator.PressingFire() )
		Global.Fire(0);
	else
	{
		if ( Instigator.PressingAltFire() )
			Global.AltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('Idle');
		}
	}
}

//_____________________________________________________________________________
state NormalFire
{
    function ServerFire()
    {
      bForceFire = true;
    }

    function ServerAltFire()
    {
      bForceAltFire = true;
    }

    function Fire(float F) {}
    function AltFire(float F) {}

    function AnimEnd(int Channel)
    {
      Finish();
    }

    function EndState()
    {
      StopFiringTime = Level.TimeSeconds;
    }
Begin:
  Sleep(0.0);
}

//_____________________________________________________________________________
state NormalAltFire
{
    function ServerFire()
    {
      bForceFire = true;
    }

    function ServerAltFire()
    {
      bForceAltFire = true;
    }

    function Fire(float F) {}
    function AltFire(float F) {}

    function AnimEnd(int Channel)
    {
      Finish();
    }

    function EndState()
    {
      StopFiringTime = Level.TimeSeconds;
    }
Begin:
  Sleep(0.0);
}

/*
Weapon is up and ready to fire, but not firing.
*/
state Idle
{
	simulated function ForceReload()
	{
		ServerForceReload();
	}

	function ServerForceReload()
	{
		if ( AmmoType.HasAmmo() )
			GotoState('Reloading');
	}

	simulated function AnimEnd(int Channel)
	{
		PlayIdleAnim();
	}

	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
//	bPointing=False;
	if ( NeedsToReload() && AmmoType.HasAmmo() )
		GotoState('Reloading');
	if ( !AmmoType.HasAmmo() )
		Instigator.Controller.SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Instigator.PressingFire() ) Fire(0.0);
	if ( Instigator.PressingAltFire() ) AltFire(0.0);
	PlayIdleAnim();
}

state Reloading
{
	function ServerForceReload() {}
	function ClientForceReload() {}
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		if ( !bForceReload )
		{
			if ( Role < ROLE_Authority )
				ServerForceReload();
			else
				ClientForceReload();
		}
		bForceReload = false;
		PlayReloading();
	}

	simulated function AnimEnd(int Channel)
	{
		ReloadCount = Default.ReloadCount;
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
	}
}


/* Active
Bring newly active weapon up.
The weapon will remain in this state while its selection animation is being played (as well as any postselect animation).
While in this state, the weapon cannot be fired.
*/
state Active
{
  simulated function BringUp() { bRendered = true; }
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		local name anim;
		local float frame,rate;
		GetAnimParams(0,anim,frame,rate);
  	bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		Instigator = Pawn(Owner);
		bForceFire = false;
		bForceAltFire = false;
		bChangeWeapon = false;
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function AnimEnd(int Channel)
	{
		if ( bChangeWeapon )
			GotoState('DownWeapon');
		if ( Owner == None )
		{
			log(self$" no owner");
			Global.AnimEnd(0);
			GotoState('');
		}
		else
		{
			if ( Role == ROLE_Authority )
				Finish();
			else
				ClientFinish();
		}
	}
}

/* DownWeapon
Putting down weapon in favor of a new one.  No firing in this state
*/
State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function bool PutDown()
	{
		return true; //just keep putting it down
	}

	simulated function AnimEnd(int Channel)
	{
		Pawn(Owner).ChangedWeapon();
	}

	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;
		TweenDown();
	}
}

//_____________________________________________________________________________
//Fire on the client side. This state is only entered on the network client of the player that is firing this weapon.
state ClientFiring
{
    function Fire( float Value ) {}
    function AltFire( float Value ) {}

    simulated function AnimEnd(int Channel)
    {
      ClientFinish();
    }

    simulated function EndState()
    {
      AmbientSound = None;
      if ( RepeatFire() && !bPendingDelete )
        ServerStopFiring();
    }
}

/* PendingClientWeaponSet
Weapon on network client side may be set here by the replicated function ClientWeaponSet(), to wait,
if needed properties have not yet been replicated.  ClientWeaponSet() is called by the server to
tell the client about potential weapon changes after the player runs over a weapon (the client
decides whether to actually switch weapons or not.
*/
State PendingClientWeaponSet
{
	simulated function Timer()
	{
		if ( Pawn(Owner) != None )
			ClientWeaponSet(false);
	}

	simulated function BeginState()
	{
		SetTimer(0.05, true);
	}

	simulated function EndState()
	{
		SetTimer(0.0, false);
	}
}

simulated function bool PutDown()
{
	bChangeWeapon = true;
	return true;
}

simulated function zoom();

//_____________________________________________________________________________
simulated function PlayIdleAnim()
{
    if ( bHaveBoredSfx && (Instigator != none) && Instigator.IsPlayerPawn() && (iBoredCount > BOREDSFXTHRESHOLD) )
    {
      iBoredCount = 0;
      if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone) )
        Instigator.PlayRolloffSound(hActWaitSound, self, 0, int(Instigator.IsPlayerPawn()), 0 );
      PlayAnim('WaitAct', 1.0, 0.3);
    }
    else
      PlayAnim('Wait', 1.0, 0.3);
}

//_____________________________________________________________________________
// 738 탎
simulated function PlayFiring()
{
//    Log("PlayFiring call for"@self@"w/FiringMode="$FiringMode);
    if ( HasAmmo() )
      PlayAnim(LoadedFiringAnim, 1.0);
    else
      PlayAnim(EmptyFiringAnim, 1.0);

    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone) )
      PlayFiringSound(HasSilencer()); // 184탎

    if ( !HasAmmo() )
      return;

    IncrementFlashCount(); // 473 탎
    if ( bDrawMuzzleflash )
      SetUpMuzzleFlash();
}

//_____________________________________________________________________________
simulated function PlayAltFiring()
{
//    Log("PlayAltFiring call for"@self@"w/FiringMode="$FiringMode);
    if ( HasAltAmmo() )
      PlayAnim(LoadedAltFiringAnim, 1.0);
    else
      PlayAnim(EmptyAltFiringAnim, 1.0);

    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      PlayAltFiringSound();

    if ( !HasAltAmmo() )
      return;

    IncrementAltFlashCount();
    if ( bDrawAltMuzzleflash )
      SetUpMuzzleFlash();
}

native function PlayFiringSound(optional bool bHasSilencer);
/*
//_____________________________________________________________________________
simulated function PlayFiringSound()
{
    if ( bEmptyShot )
      Instigator.PlayRolloffSound(hNoAmmoSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
    else
    {
      if ( HasSilencer() )
        Instigator.PlayRolloffSound(hFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 0 );
      else
        Instigator.PlayRolloffSound(hFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
    }
}
*/

//_____________________________________________________________________________
simulated function PlayAltFiringSound()
{
    if ( bAltEmptyShot )
      Instigator.PlayRolloffSound(hNoAmmoSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
    else
    {
      if ( HasSilencer() )
        Instigator.PlayRolloffSound(hAltFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 0 );
      else
        Instigator.PlayRolloffSound(hAltFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
    }
}

//_____________________________________________________________________________
simulated function TweenDown()
{
//    log("TweenDown call for"@self);
    PlayAnim('Down', 1.0);
}

//_____________________________________________________________________________
simulated function PlaySelect()
{
    if ( DBWeap )
      log("PlaySelect call for"@self@"w/ mesh="$Mesh);
    bForceFire = false;
    bForceAltFire = false;
    PlayAnim('Select',1.0);
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hSelectWeaponSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
}

//_____________________________________________________________________________
simulated function PlayReloading()
{
    PlayAnim('ReLoad',1.0);
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hReloadSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 0 );
    MakeNoise(ReLoadNoise);
}

//_____________________________________________________________________________
// Reload Notifies
simulated function FPSRelNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hReloadSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 1 );
}
simulated function FPSRelNote2()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hReloadSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 2 );
}
simulated function FPSRelNote3()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hReloadSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 3 );
}

//_____________________________________________________________________________
// Select Notifies
simulated function FPSSelWPNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hSelectWeaponSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 1 );
}
simulated function FPSSelWPNote2()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hSelectWeaponSound, self, 2, int(Pawn(Owner).IsPlayerPawn()), 2 );
}
simulated function FPSSelWPNote3()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hSelectWeaponSound, self, 3, int(Pawn(Owner).IsPlayerPawn()), 3 );
}

//_____________________________________________________________________________
// Dry Notifies
simulated function FPSDryNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hNoAmmoSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 1 );
}
simulated function FPSDryNote2()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hNoAmmoSound, self, 2, int(Pawn(Owner).IsPlayerPawn()), 2 );
}
simulated function FPSDryNote3()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hNoAmmoSound, self, 3, int(Pawn(Owner).IsPlayerPawn()), 3 );
}

//_____________________________________________________________________________
// Firing Notifies
simulated function FPSFireNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
    {
      if ( HasSilencer() )
        Instigator.PlayRolloffSound(hFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 1 );
      else
        Instigator.PlayRolloffSound(hFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 1 );
    }
}
simulated function FPSFireNote2()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
    {
      if ( HasSilencer() )
        Instigator.PlayRolloffSound(hFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 2 );
      else
        Instigator.PlayRolloffSound(hFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 2 );
    }
}
simulated function FPSFireNote3()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
    {
      if ( HasSilencer() )
        Instigator.PlayRolloffSound(hFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 3 );
      else
        Instigator.PlayRolloffSound(hFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 3 );
    }
}

//_____________________________________________________________________________
// AltFiring Notifies
simulated function FPSFireAltNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hAltFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 1 );
}
simulated function FPSFireAltNote2()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hAltFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 2 );
}

//_____________________________________________________________________________
// Active waiting Notifies
simulated function FPSFireWaitActNote1()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone)  )
      Instigator.PlayRolloffSound(hActWaitSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 1 );
}

defaultproperties
{
     bCanThrow=True
     LoadedFiringAnim="Fire"
     EmptyFiringAnim="Firevide"
     LoadedAltFiringAnim="Fire"
     EmptyAltFiringAnim="Firevide"
     iAltZoomLevel=2
     fAltZoomValue(0)=0.700800
     fAltZoomValue(1)=0.884800
     fAltZoomValue(2)=0.942300
     sWeaponModeAuto="Auto"
     sWeaponModeSemiAuto="Single"
     sWeaponModeBurst="Burst"
     ShakeMag=300.000000
     shaketime=5.000000
     ShakeVert=(Z=5.000000)
     ShakeSpeed=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeCycles=1.000000
     AIRating=0.500000
     TraceDist=1.270000
     AltTraceDist=1.270000
     MessageNoAmmo=" has no ammo."
     MuzzleScale=1.000000
     FlashLength=0.100000
     InventoryGroup=1
     PlayerViewOffset=(X=30.000000,Z=-5.000000)
     AttachmentClass=Class'Engine.WeaponAttachment'
     Icon=Texture'Engine.S_Weapon'
     ItemName="Weapon"
     bReplicateInstigator=True
     bIgnoreDynLight=False
     DrawType=DT_Mesh
     SaturationDistance=800.000000
     StabilisationDistance=3000.000000
     StabilisationVolume=-10.000000
}
