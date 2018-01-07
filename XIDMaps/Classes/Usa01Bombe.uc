//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Usa01Bombe extends EventItem;

var actor BombInteraction;

//_____________________________________________________________________________
simulated function PlayUsing()
{
//    Log(self@"PlayUsing");
    PlayAnim('Fire', 2.0);
	SetTimer2(0.7, false);
//    PlaySound(ActivateSound); // not playing sound when using, only when efficiently using
}


//_____________________________________________________________________________
event Timer2()
{
  XIIIGameInfo(Level.Game).MapInfo.SetGoalComplete(97);
}


//_____________________________________________________________________________
state idle
{
	simulated function Activate()
	{
		local actor A;

		A = XIIIPlayercontroller(Pawn(Owner).controller).MyInteraction.TargetActor;

		if (( A == none ) || ( A != BombInteraction ))
			return;

		if ( XIIIPawn(Owner).bHaveOnlyOneHandFree && (IHand == IH_2H) )
			PlayerController(Pawn(owner).controller).MyHud.LocalizedMessage(class'XIIISoloMessage', 8);
		else
			GotoState('InUse');
	}
}


//_____________________________________________________________________________


defaultproperties
{
     MeshName="XIIIArmes.fpsBombeMagnetM"
     hSelectItemSound=Sound'XIIIsound.Items.BombSubSel1'
     IconNumber=24
     sItemName="Bomb"
     PickupClassName="XIDMaps.Usa01BombePick"
     ItemName="Bomb"
     Event="BombUse"
}
