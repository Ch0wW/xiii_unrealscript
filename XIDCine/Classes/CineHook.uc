//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineHook extends Actor;

/*var HookPoint PotHookPoint;     // If there is a Hookpoint in the Crosshair

var HookProjectile MyHook;
var HookLink MyLink;
//var FreeHookLink MyFHLink;

var vector HookPointPosition;           // Hooking point
var float HookLength;           // Position on the Rope to the HookPoint
var float MaxHookLength;        // Max Lenght of the Hook Rope
var float HookUpSpeed, HookDownSpeed;   // Speed we are climbing/dropping while hooked
var bool bGoUp, bGoDown;

var array<hookpoint> PotentialHP;   // Array of potentials HP in the level
var texture PotHookIcon;            // Icon to use to display the potential hook points on screen

var sound hHookMoveSound;
var sound hHookEndSound;
var sound hHookFireSound;
var sound hHookReleaseSound;
var sound hHookClik;

var bool bHooked;               // used for playing right animations
var int AnimState;              // used for playing animation chain (firing then down then selectcommande)

var bool ActivatedByJump;
var bool ActivatedByDuck;
var bool ActivatedByAltFire;
var bool ActivatedByFire;

VAR Pawn User;
//_____________________________________________________________________________
Simulated function CastHook(HookPoint PotHookPoint)
{
	HookPointPosition = PotHookPoint.Location;
	HookLength = VSize(HookPointPosition - User.Location ) + 50.0;
//	MaxHookLength = PotHookPoint.RopeLength;
//	if ( MaxHookLength < HookLength )
//		return;

	MyHook=Spawn(class'CineHookProjectile',,, Owner.Location + Instigator.CalcDrawOffset(self),Rotator(HookPointPosition-Location));
	if (MyHook != none)
	{
		MyHook.SetOwner(self);
		MyLink=Spawn(class'HookLink',,, Owner.Location + Instigator.CalcDrawOffset(self),Rotator(HookPointPosition-Location));
		if (MyLink != none)
		{
			MyLink.HStart=self;
			MyLink.HEnd=MyHook;
			MyLink.LinkIndex = 0;
		}
	}
	PlayRolloffSound(hHookFireSound, self);
	XIIIPawn(Owner).GoHooking(self);
//	SetTimer(0.25, false);
//	bHooked=true;
//	PlayUsing();
//	GotoState('HookInUse');
}

FUNCTION ReduceRopeLength(float DT)
{
	if ( HookLength>150 )
	{
		HookLength = vSize(HookPointPosition - Pawn(Owner).Location); // don't allow teleports
		HookLength -= (DT * HookUpSpeed);
		if ( HookLength<150 )
			HookLength = 150;
	}
}

//_____________________________________________________________________________

STATE Activated
{
    simulated function BeginState()
    {
      Instigator = Pawn(Owner);
      if ( DBHook ) Log("  > Activated BeginState for "$self@"Instigator="$Instigator);
      PlaySelect();
      InitPotentialTargets();
      bHidden = false;
      RefreshDisplaying();
    }
}

FUNCTION IncreaseRopeLength(float DT)
{
	if ( (HookLength<(100+vSize(HookPointPosition - Pawn(Owner).Location))) && (HookLength < MaxHookLength) )
	{
		HookLength += (DT * HookDownSpeed);
		if (HookLength > MaxHookLength)
			HookLength = MaxHookLength;
	}
}

FUNCTION Release()
{
	if (MyHook != none)
		MyHook.Destroy();
	if (MyLink != none)
		MyLink.Destroy();
	Disable('tick');
	GoToState('Idle');
	StopSound(hHookMoveSound);
	PlayRolloffSound(hHookReleaseSound,self);
	if (AnimState != 0)
		TweenDown();
	else
		PlayDown();
	bHooked=false;
}

FUNCTION Activate()
{
	SetTimer(0.25, false);
	PlaySound(hHookClik);
}

//_____________________________________________________________________________
// In Use
STATE HookInUse
{

//_____________________________________________________________________________
simulated function TweenDown()
{
//    Log(self@"TweenDown, bHooked="$bHooked@"AnimState="$AnimState);
    if ( AnimState == 1 )
    {
      bHooked=false;
      PlaySelect();
      AnimState = 0;
    }
    else
    {
      PlayAnim('DownCommande',3.0,0.2);
      AnimState = 3;
    }
}

//_____________________________________________________________________________
simulated function PlayIdle()
{
//    Log(self@"PlayIdle, bHooked="$bHooked);
    if ( bHooked )
    {
      PlayAnim('WaitCommande',1.0);
    }
    else
      PlayAnim('Wait', 1.0);
}

//_____________________________________________________________________________
simulated function PlayUsing()
{
//    Log(self@"PlayUsing");
    PlayAnim('Fire', 2.0);
    AnimState = 1;
}

//_____________________________________________________________________________
simulated function PlayClimbUp()
{
//    Log(self@"PlayClimbUp");
    if ( AnimState == 0 )
      PlayAnim('ClimbUp', 2.0);
}
//_____________________________________________________________________________
simulated function PlayClimbDown()
{
//    Log(self@"PlayClimbDown");
    if ( AnimState == 0 )
      PlayAnim('ClimbDown', 2.0);
}
//_____________________________________________________________________________
simulated function PlayStop()
{
//    Log(self@"PlayStop");
    PlayAnim('Stop', 2.0);
}

    InventoryGroup=5
    bCanHaveMultipleCopies=true
    bAutoActivate=True
    bActivatable=True
    ExpireMessage="Hook was used."
    bDisplayableInv=True
    Charge=1
    ItemName="HOOK"
    PlayerViewOffset=(X=5.00,Y=6.00,Z=-5.80)
    BobDamping=0.975000
    PickupClassName="XIII.HookPick"
    HookUpSpeed=150.0
    HookDownSpeed=300.0
    IHand=IH_2H
    PotHookIcon=texture'XIIIMenu.Hand_GrapplePoint'
    Icon=texture'XIIIMenu.GrappinIcon'
    CrossHair=Texture'XIIIMenu.MireGrappin'
    hSelectItemSound=Sound'XIIIsound.SpecActions.HookSel'
    hHookMoveSound=Sound'XIIIsound.SpecActions.HookMov'
    hHookEndSound=Sound'XIIIsound.SpecActions.HookEnd'
    hHookFireSound=sound'XIIIsound.SpecActions.HookFire'
    hHookReleaseSound=Sound'XIIIsound.SpecActions.HookLet'
    hHookClik=Sound'XIIIsound.SpecActions.HookClick'
    bHooked=false
    AnimState=0
	LifeSpan=+00140.000000
	NetPriority=+00002.500000
	MyDamageType=class'DamageType'
	RemoteRole=ROLE_SimulatedProxy
	TossZ=+100.0
*/


defaultproperties
{
     bNetTemporary=True
     bReplicateInstigator=True
     bUnlit=True
     bGameRelevant=True
     bCollideActors=True
     bCollideWorld=True
     Physics=PHYS_Projectile
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.grappin'
     DrawScale=0.600000
}
