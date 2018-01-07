//=============================================================================
// SeenTrigger.
// Created by iKi
// Last Modification by iKi
//=============================================================================
class SeenTrigger extends Trigger
	HideCategories(force,lightcolor,lighting,rolloff,sound);

#exec Texture Import File=Textures\seen_ico.pcx Name=Seen_ico Mips=Off Masked=1

VAR()	float CheckInterval;
VAR()	bool bInitiallyActive;
VAR()	float MinimalDistance;

STATE() SeenTrigger
{
	EVENT BeginState()
	{
		bHidden=false;
		SetDrawType(DT_Sprite);
		Texture=None;
		RefreshDisplaying();
		if ( bInitiallyActive )
			SetTimer( CheckInterval, true );
	}

	EVENT Timer( )
	{
		if ( PlayerCanSeeMe() )
			DebugLog( "SeenTrigger::Timer::LastRenderDist"@ LastRenderDist );
		if ( PlayerCanSeeMe() && LastRenderDist<MinimalDistance )
		{
			TriggerEvent( event, self, none );
			if ( bTriggerOnceOnly )
				Destroy();
		}
	}

	EVENT Trigger( actor a, pawn p )
	{
		SetTimer( CheckInterval, true );
	}

}



defaultproperties
{
     CheckInterval=0.300000
     MinimalDistance=1000.000000
     bTriggerOnceOnly=True
     bCollideActors=False
     InitialState="SeenTrigger"
     Texture=Texture'XIDCine.Seen_ico'
}
