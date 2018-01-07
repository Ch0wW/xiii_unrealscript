//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Spads02a extends Map09_Spads;

VAR(Spads02aSetUp) Spads02DecoBombe BombeDeco;
VAR(Spads02aSetUp) Spads02DecoMicro MicroDeco;
VAR XIIIGoalTrigger BombeInteraction, MicroInteraction;
VAR CWndFocusTrigger BombeFocus;
VAR sound hBombReady;

//_____________________________________________________________________________
FUNCTION FirstFrame()
{
	LOCAL inventory Inv;
	LOCAL XIIIGoalTrigger xgt;
	LOCAL CWndFocusTrigger cwft;

	Super.FirstFrame();

    if ( XIIIGameInfo(Level.Game).CheckPointNumber <2 )
	{
		Inv = GiveSomething(class'Spads02Bombe', XIIIPawn);
		Inv = GiveSomething(class'Spads02Micro', XIIIPawn);
	}

	BombeDeco.bHidden=true;
	MicroDeco.bHidden=true;
	foreach DynamicActors(class'XIIIGoalTrigger', xgt )
	{
		if ( xgt.GoalNumber==99 )
		{
			BombeInteraction=xgt;
		}
		else
			if ( xgt.GoalNumber==98 )
			{
				MicroInteraction=xgt;
			}
	}

	foreach DynamicActors(class'CWndFocusTrigger', cwft )
	{
		if ( cwft.Focus==BombeDeco )
		{
			BombeFocus=cwft;
		}
	}

}

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
    LOCAL Spads02Bombe Bomb;
    LOCAL Spads02Micro Micr;

    switch(N)
    {
      case 98:
        MicroDeco.bHidden=false;
  		MicroDeco.RefreshDisplaying();
		Micr = Spads02Micro(XIIIPawn.FindInventoryType(class'Spads02Micro'));
		if ( MicroInteraction!=none )
			MicroInteraction.bInteractive=false;
        if (Micr != none )
          Micr.UsedUp();
        break;
      case 99:
//        BombeDeco.bHidden=false;
		BombeDeco.StaticMesh = StaticMesh'MeshArmesPickup.BombeMagnet';
//		BombeDeco.RefreshDisplaying();
		if ( BombeInteraction!=none )
			BombeInteraction.bInteractive=false;
		XIIIPawn.PlaySound(hBombReady);
		Bomb = Spads02Bombe(XIIIPawn.FindInventoryType(class'Spads02Bombe'));
        if (Bomb != none )
          Bomb.UsedUp();
		if ( BombeFocus!=none )
			BombeFocus.Trigger(self,none);
        break;
    }
    SUPER.SetGoalComplete(N);

    if (N==0)
      SetPrimaryGoal(1);
}



defaultproperties
{
     hBombReady=Sound'XIIIsound.Items__BombFireSub.BombFireSub__hBombFire'
     EndMapVideo="cine10"
}
