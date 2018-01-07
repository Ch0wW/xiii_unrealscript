class CreditsManager extends Info
	hidecategories(Advanced,Collision,Display,LightColor,Lighting,MOvement,Object,RollOff,Sound)
	placeable;

VAR()			Array<name>		CreditsParadeTags;
VAR				int				ParadeIndex;
VAR				Array<CreditsParade> RunningCreditsParades;
VAR				XIIIBaseHUD HUD;
//VAR				bool bEnded;
		//**VAR				Array<float>	LineHeights, LineWidths;
//VAR				Array<int>		LineCodes;
VAR TRANSIENT	XIIIPlayerController PC;
/*VAR TRANSIENT	Canvas			Canvas;
VAR TRANSIENT	float			YStart;
VAR TRANSIENT	M16Pick			pi;*/
//VAR TRANSIENT	float			LargeFontHeight, BigFontHeight, MedFontHeight, SmallFontHeight;			
//VAR TRANSIENT	float			MyYL, Highest;

// 0 -  Default text ( BigFont - Blanc )
// 1 - Titre ( LargeFont - Jaune )

AUTO STATE STA_Credits
{
	EVENT BeginState()
	{
		Level.InitialCartoonEffect = 0;
		SetTimer( 0.1, false );
	}

	EVENT Timer( )
	{
		PC = XIIIPlayerController(PlayerController(Level.ControllerList));
		HUD = XIIIBaseHud(PC.myHud);
		PC.SetViewTarget( self );
		PC.GotoState('NoControl');
		HUD.bShowDebugInfo = true;
		HUD.ShowDebugActor = none;
	}

	FUNCTION DisplayDebug(Canvas Canvas, out float YL, out float YPos)
	{
		LOCAL CreditsParade cp;

		XIIIGameInfo(Level.Game).MapInfo.EndCartoonEffect=true;
		if ( PC.ViewTarget==self)
		{
			foreach DynamicActors(class'CreditsParade',CP)
			{
				CP.Init(Canvas, HUD);
				CP.CM = self;
			}
			ShowNextParade();
			TriggerEvent( Event, self, none );
			GotoState('');
		}
	}
}

FUNCTION DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	LOCAL int i;

	for( i=0;i<RunningCreditsParades.Length;i++)
		RunningCreditsParades[i].DisplayCredits(Canvas);
}

FUNCTION ShowNextParade()
{
	LOCAL CreditsParade cp;
	LOCAL bool bSkip;

	do
	{
		switch (caps(left(string(CreditsParadeTags[ParadeIndex]),2)))
		{
		case "PC":
			bSkip = ( XIIIGameInfo(Level.Game).Plateforme!=PF_PC );
			break;
		case "PS":
			bSkip = ( XIIIGameInfo(Level.Game).Plateforme!=PF_PS2 );
			break;
		case "GC":
			bSkip = ( XIIIGameInfo(Level.Game).Plateforme!=PF_GC );
			break;
		case "XB":
			bSkip = ( XIIIGameInfo(Level.Game).Plateforme!=PF_XBOX );
			break;
		default:
			bSkip = false;
		}

		if ( bSkip )
			ParadeIndex++;

	} until ( !bSkip || ParadeIndex >= CreditsParadeTags.Length )


	if ( ParadeIndex < CreditsParadeTags.Length )
	{
		foreach DynamicActors(class'CreditsParade',CP,CreditsParadeTags[ParadeIndex])
		{
			RunningCreditsParades.Insert( 0, 1 );
			RunningCreditsParades[0]=CP;
			LOG ( "START CREDIT "@CP.Tag@"("$CP$")"$ParadeIndex );
			CP.Start();
			ParadeIndex++;
			return;
		}
	}
}

FUNCTION StopParade( )
{
//	if ( !bEnded )
//	{
		RunningCreditsParades.Remove( RunningCreditsParades.Length-1, 1 );
		if ( RunningCreditsParades.Length==0 )
			Level.ServerTravel("mapmenu.unr", true);
//			TriggerEvent('Helico', self, none);
//	}
}
/*
EVENT Trigger(actor Other, pawn EventInstigator )
{
	bEnded=true;
	SetTimer( 0.06, false );
}

EVENT Timer()
{
	Level.ServerTravel("mapmenu.unr", true);
}
*/


defaultproperties
{
     Texture=Texture'Engine.S_Pawn'
     bDirectional=True
}
