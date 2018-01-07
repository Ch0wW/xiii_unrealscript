//-----------------------------------------------------------
// DialogueManagerRandom
// Created by iKi
//-----------------------------------------------------------
class DialogueManagerRandom extends DialogueManager;

#exec Texture Import File=Textures\dialman2_ico.tga Name=DialMan2_ico Mips=Off
//VAR bool bNotFirst;
VAR int LastLineIndex;
VAR Pawn LastSpeaker;

EVENT PostBeginPlay()
{
}

FUNCTION StartDialogue( optional int firstline )
{
	LOCAL int i;
	
	if ( !bStarted )
	{
		if ( PC == none )
			PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;

		LineIndex = firstline;
		bStarted = true;
		GotoState( 'STA_PlayingDialogue' );
	}
	else
	{
		ForceLine( firstline );
	}
}

FUNCTION ForceLine(coerce int line)
{
	if ( PC == none )
		PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;

	LineIndex = line;
	tag = '';
	Speak( );
}

EVENT Trigger( actor Other, pawn EventInstigator )
{
//	if ( bNotFirst )
//		Lines.Remove( LineIndex, 1 ); // Remove used sentence in random mode
	if ( Timer2Rate==0 )
		SetTimer2(0.05,true);
//	LOG ( "DMR Triggered !" );
	LineIndex = Rand( Lines.Length ); // choose a random lines in random mode
	if ( LastLineIndex==LineIndex )
	{
		LineIndex = (LineIndex+1)%(Lines.Length);
	}
	LastLineIndex=LineIndex;
	Lines[ LineIndex ].ExpectedEventBeforeNext = Tag;
	Speakers[ Lines[ LineIndex ].SpeakerIndex ].Pawn = EventInstigator;
//	bNotFirst = true;
	StartDialogue( LineIndex );
	
}

EVENT Timer2()
{
	if ( bSpeaking && CurrentSpeakerPawn!=none && CurrentSpeakerPawn.bIsDead )
	{
		StopVoice();
		XIIIBaseHud( PC.MyHud ).HudDlg.RemoveMe();
		SetTimer2(0,false);
		bSpeaking = false;
	}
}

FUNCTION bool MustBeStop( )
{
	return false;
}

FUNCTION bool WarnIfAVoiceIsAlreadyRunning()
{
	LOCAL DialogueManager dm;

	foreach DynamicActors( class'DialogueManager', dm )
	{
		if ( dm.bSpeaking )
		{
			StopVoice( );
			XIIIBaseHud( PC.MyHud ).HudDlg.RemoveMe();
//			dm.Destroy();
			break;
		}
	}
	return false;
}
/*
FUNCTION NextSentence()
{
	Log ( "DMR NextSentence" );	
}*/

STATE STA_PlayingDialogue
{
	EVENT BeginState( )
	{
		if ( !bDialoguePlaying )
		{
			Speak( );
			bDialoguePlaying = true;
		}
	}
	
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		Global.Trigger( Other, EventInstigator );
	}
}
	


defaultproperties
{
     LastLineIndex=-1
     Texture=Texture'XIDCine.DialMan2_ico'
}
