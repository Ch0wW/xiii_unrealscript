//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Usa02 extends Map12_PortUSA;

var (USA02SetUp) USA02HelicoBossPoint HelicoBossStart;            // The location the helico is spawned
var (USA02SetUp) USA02HelicoBossPoint HelicoBossNavigationPoint1, HelicoBossNavigationPoint2;  // making a line for the boss path
var (USA02SetUp) USA02HelicoBossPoint HelicoBossEndPoint;         // Point aroudn which the helico will move (but not far away)
var (USA02SetUp) USA02HelicoBossPoint HelicoBossCrashPoint;         // Point aroudn which the helico will move (but not far away)
var USA02HelicoBoss HelicoBoss;
var USA02HelicoBossController HelicoBossC;

var (USA02SetUp) float fMinAcquisitionTime;
var (USA02SetUp) float fStabilityBeforeMissileDelay;
var (USA02SetUp) float fCollisionHeight;
var (USA02SetUp) float fCollisionRadius;
var (USA02SetUp) float fDelaiRengaineArme;
var (USA02SetUp) int eNbTouches;
var (USA02SetUp) PhysicsVolume FirewallVolume;

var XIIIPlayerController PC;

// Use a XIIIGoalTrigger 90 To spawn HelicoBoss.

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
	switch ( N )
	{
	case 90:
		GotoState( 'STA_PostponeChopperSpawn' );
		break;
	}
	Super.SetGoalComplete(N);
}

FUNCTION SpawnChopper( )
{
	// Spawn HelicoBoss
	HelicoBoss = Spawn(class'USA02HelicoBoss', self,, HelicoBossStart.Location, HelicoBossStart.Rotation);
	HelicoBossC = Spawn(class'USA02HelicoBossController', self,, HelicoBossStart.Location, HelicoBossStart.Rotation);
	HelicoBossC.Possess(HelicoBoss);
	HelicoBossC.NavPoint1 = HelicoBossNavigationPoint1;
	HelicoBossC.NavPoint2 = HelicoBossNavigationPoint2;
	HelicoBossC.EndPoint = HelicoBossEndPoint;
	HelicoBossC.CrashPoint = HelicoBossCrashPoint;
	HelicoBossC.MinAcquisitionTime = fMinAcquisitionTime;
	HelicoBossC.fStabilityBeforeMissileDelay = fStabilityBeforeMissileDelay;
	HelicoBoss.bUseCylinderCollision = true;
	HelicoBoss.SetCollisionSize( fCollisionRadius, fCollisionHeight );
	HelicoBoss.Health = eNbTouches;
	HelicoBoss.default.Health= eNbTouches;
	XIIIBaseHud(XIIIController.MyHud).AddBossBar( HelicoBoss );
}

state STA_PostponeChopperSpawn
{
begin:
	sleep( 0.5 );
	SpawnChopper( );
}

event Trigger( actor Other, pawn EventInstigator )
{
	SetTimer2(fDelaiRengaineArme,false);
	if ( FirewallVolume != none )
		FirewallVolume.bPainCausing = true;
}

event Timer2()
{
	PC = XIIIGameInfo(Level.Game).MapInfo.XIIIController;
	if ( PC.bWeaponMode )
	{
		PC.OldWeap = PC.Pawn.Weapon.InventoryGroup;
		PC.Pawn.Weapon.PutDown();
	}
	else
	{
		PC.OldItem = XIIIItems(PC.Pawn.SelectedItem);
		PC.OldItem.PutDown();
	}
	PC.bWeaponBlock = true;
	PC.Pawn.PendingWeapon = none;
//	PawnOwner.PendingItem = none;
}




defaultproperties
{
     fMinAcquisitionTime=1.500000
     fStabilityBeforeMissileDelay=1.000000
     fCollisionHeight=200.000000
     fCollisionRadius=250.000000
     fDelaiRengaineArme=2.000000
     eNbTouches=3
     EndMapVideo="cine12"
}
