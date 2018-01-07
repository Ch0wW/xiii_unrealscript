//-----------------------------------------------------------
// DialogueManager
// Created by iKi
//-----------------------------------------------------------
class DialogueManager extends Info
	HideCategories(Advanced,Display)
	placeable;

#exec Texture Import File=Textures\dialman_ico.tga Name=DialMan_ico Mips=Off

struct SLine
{
	VAR()	int		SpeakerIndex;
	VAR()	int		SentenceIndex;
	VAR()	float	TimeBeforeSentence;
	VAR()	name	ExpectedEventBeforeNext;
	VAR()	string	SpeakersToWarnAtTheEndOfThisLine;
};

STRUCT SSpeaker
{
	VAR()	String					PawnName;
	var()	Actor					Pawn;
	VAR()	localized Array<String>	Sentences;
};

VAR(Dialog)		bool					BreathSteam;
VAR				bool					bSpeaking, bPaused, bDialoguePlaying, mustStopDialogue, bStarted, bPostPonedDialogue ;
VAR(Dialog)		localized Array<SSpeaker>			Speakers;
VAR(Dialog)		Array<SLine>			Lines;
VAR				Array<BreathSteamEmitter> BSE;
VAR				Array<byte>				bGivenSpeaker;
VAR	TRANSIENT	int						LineIndex;
VAR TRANSIENT	XIIIPlayerController	PC;
VAR TRANSIENT	Pawn					CurrentSpeakerPawn;
VAR TRANSIENT	name					OriginalTag;

//VAR TRANSIENT	vector					InitialLocation;

STRUCT structInterpol
{
    VAR float Alpha;
    VAR float Temps;
    VAR float TempsPauseFerme;
    VAR rotator Ouverture;	// TOREMOVE !!!
    VAR name Bone;
    VAR float Pause;
    VAR bool bStop;
};

VAR rotator JawRotator;
VAR structInterpol Machoire, Levre;

CONST NoSoundTime = 2.0;

// MLK: Allows the DialogueManager to r/w data to the right place
//var int DlgMgrListIndex;
//var MapInfo MI;

var bool bAfficheVignette;


//-----------------------------------------------------------
EVENT PostBeginPlay()
{
	LOCAL int i;

	bGivenSpeaker.Insert( 0, Speakers.Length );

	for ( i = 0; i < Speakers.Length; ++i )
		bGivenSpeaker[ i ] = byte( Speakers[ i ].Pawn!=none && ( Speakers[ i ].Pawn.IsA('Pawn') || Speakers[ i ].Pawn.IsA('GenNMI') ) );

	OriginalTag = Tag;
}

EVENT Trigger(actor Other,pawn EventInstigator)
{
	if ( CineController2( other )!=none )
		CineController2( other ).dm = self;
	tag = '';

	StartDialogue( );
}

FUNCTION ForceLine(coerce int line)
{
	if ( PC == none )
		PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;

	if ( MustBeStop( ) )
	{
		Destroy( );
		return;
	}

	LineIndex = line;
	Disable( 'Trigger' );
	tag = '';
	Speak( );
}

FUNCTION StartDialogue( optional int firstline )
{
	LOCAL int i;

	if ( !bStarted )
	{
		if ( PC == none )
			PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;

		if ( MustBeStop( ) )
		{
			Destroy( );
			return;
		}

		if ( BreathSteam )
		{
			BSE.Insert( 0, Speakers.Length );
			for ( i = 0; i < Speakers.Length; ++i )
			{
				if ( Speakers[ i ].Pawn.IsA('Pawn') )
				{
					BSE[ i ] = Spawn( class'BreathSteamEmitter' );
					Speakers[ i ].Pawn.AttachToBone( BSE[ i ], 'X Lips' );
				}
				else
					if ( Left( Speakers[ Lines[ i ].SpeakerIndex ].PawnName, 4 ) ~= "XIII" )
					{
						BSE[ i ] = Spawn( class'BreathSteamEmitter',,, PC.Pawn.Location+PC.Pawn.EyePosition() + 20*vector(PC.Rotation));
						BSE[ i ].SetBase( PC.Pawn ); //.AttachToBone( , 'X Lips' );
	//					PC.Pawn.AttachToBone( BSE[ i ], 'X Lips' );
					}
			}
		}

		// MLK: {-1, DialNumber} begin a new 'scene' & used as a separator
	//    MI._Dial.Lineind = -1; MI._dial.Speakerind = DlgMgrListIndex;
	//    MI.DialogToSave[MI.DialogToSave.Length] = MI._Dial;

		LineIndex = firstline;
		bStarted = true;
		GotoState( 'STA_PlayingDialogue' );
	}
	else
	{
		ForceLine( firstline );
	}
}

EVENT Tick( float dt)
{
//	LOG(" Coucou"@self );
	if ( bPostPonedDialogue )
		Speak();
}

FUNCTION Speak( )
{
	LOCAL int TextIndex, i;
	LOCAL SSpeaker SpeakingSpeaker;	// :)
	LOCAL float WaveLength;
	LOCAL string SoundName;

	if ( WarnIfAVoiceIsAlreadyRunning() )
		bPostPonedDialogue=true;
	else
	{
		bPostPonedDialogue=false;
		if ( ( Lines[ LineIndex ].SpeakerIndex == -1 ) || ( Lines[ LineIndex ].SentenceIndex == -1 ) )
		{
			EndOfLine( );
			return;
		}
		SpeakingSpeaker = Speakers[ Lines[ LineIndex ].SpeakerIndex ];
		TextIndex = Lines[ LineIndex ].SentenceIndex;

		// Compute Sound Name
		if ( TextIndex < 10 )
			SoundName = "0" $ string( TextIndex );
		else if ( TextIndex < 100 )
			SoundName = string( TextIndex );
		//	else
		//		SoundName = "xx";

		if ( Left( SpeakingSpeaker.PawnName, 2) ~= "HF" )
		{
			// sfx window display for HF dialogue
			bAfficheVignette = true;
			TriggerEvent( name(SpeakingSpeaker.PawnName), self, none );
			// HF letters is used to recognize HF dialogue, they won't be present in SoundName
			SoundName = Level.Title $ "_" $ Mid(SpeakingSpeaker.PawnName,2) $ "_" $ SoundName;
		}
		else
			if ( Left( SpeakingSpeaker.PawnName, 4) ~= "NORM" )
			{
				// sfx window display for NORM dialogue
				bAfficheVignette = true;
				TriggerEvent( name(SpeakingSpeaker.PawnName), self, none );
				// NORM letters is used to recognize NORM dialogue, they won't be present in SoundName
				SoundName = Level.Title $ "_" $ Mid(SpeakingSpeaker.PawnName,4) $ "_" $ SoundName;
			}
			else
				SoundName = Level.Title $ "_" $ SpeakingSpeaker.PawnName $ "_" $ SoundName;

		// DisplaySentence
		WaveLength = GetWaveDuration( SoundName ) + 1.0;

		if ( WaveLength==0 ) // If no sound display sentence NoSoundTime seconds
			WaveLength = NoSoundTime + 1.0;

		if ( (Speakers[ Lines[ LineIndex ].SpeakerIndex ].Pawn == none) && ( Left(Speakers[ Lines[ LineIndex ].SpeakerIndex ].PawnName, 4) ~= "XIII") )
			PC.MyHud.LocalizedMessage( class'XIIIDialogMessage', 1, none, none, none, SpeakingSpeaker.Sentences[ TextIndex ] );
		else if ( ( (Speakers[ Lines[ LineIndex ].SpeakerIndex ].Pawn == none) && !WaveHasPosition(SoundName) ) || ( Left(Speakers[ Lines[ LineIndex ].SpeakerIndex ].PawnName, 2) ~= "HP") || ( Left(Speakers[ Lines[ LineIndex ].SpeakerIndex ].PawnName, 2) ~= "HF") )
			PC.MyHud.LocalizedMessage( class'XIIIDialogMessage', 2, none, none, Speakers[ Lines[ LineIndex ].SpeakerIndex ].Pawn, SpeakingSpeaker.Sentences[ TextIndex ] );
		else
			PC.MyHud.LocalizedMessage( class'XIIIDialogMessage', 0, none, none, Speakers[ Lines[ LineIndex ].SpeakerIndex ].Pawn, SpeakingSpeaker.Sentences[ TextIndex ] );

		// :: iKi :: beurk... not clean...
		XIIIBaseHud( PC.MyHud ).HudDlg.MyMessage.EndOfLife = WaveLength + Level.TimeSeconds;
		XIIIBaseHud( PC.MyHud ).HudDlg.MyMessage.LifeTime = WaveLength;

		//	Play Speaker Voice
		if ( SpeakingSpeaker.Pawn!=none && SpeakingSpeaker.Pawn.IsA('GenNMI') )
		{
			CurrentSpeakerPawn = SpeakingSpeaker.Pawn.Instigator;
		}
		else
		{
			CurrentSpeakerPawn = Pawn(SpeakingSpeaker.Pawn);
		}

		if ( BreathSteam && BSE[ Lines[ LineIndex ].SpeakerIndex ]!=none )
			BSE[ Lines[ LineIndex ].SpeakerIndex ].Trigger( none, none );

		if ( PlayStrVoice( SoundName, SpeakingSpeaker.Pawn ) )
		{
//			Log( "DIALOGMANAGER PLAYSTRVOICE ~~~"@self@":"@SpeakingSpeaker.Sentences[ TextIndex ]);
			GotoState( 'STA_HeadAnimation' );
		}
		else
		{
//			Log( "DIALOGMANAGER PLAYSTRVOICE ~~~ ECHEC"@self);
			GotoState( 'STA_HeadAnimation','NoSound' );
		}
	}
}

FUNCTION bool WarnIfAVoiceIsAlreadyRunning()
{
	LOCAL DialogueManager dm;
//	LOCAL bool bFirst;

//	bFirst=true;
	foreach DynamicActors( class'DialogueManager', dm )
	{
//		if ( dm==self )
//			continue;
		if ( dm.bSpeaking )
		{
/*			if ( bFirst )
			{
				LOG( "#####################################" );
				LOG( "##                                 ##" );
				LOG( "## DIALOGUE INTERROMPU SAUVAGEMENT ##" );
				LOG( "##                                 ##" );
				LOG( "#####################################" );
				LOG( "DATE:"@Level.TimeSeconds );
				bFirst=false;
			}

			LOG( self@"INTERROMPT"@dm );*/
//			LOG( "######################################################################" );
//			LOG( "##                                                                  ##" );
//			LOG( "## DIALOGUE EN COURS : DEMANDE DE VOIX REPOUSSEE A PLUS TARD        ##" );
//			LOG( "##                                                                  ##" );
//			LOG( "## LE LEVEL-DESIGN EST GROS MECHANT QUI NE FAIT CE QU'ON LUI DIT !! ##" );
//			LOG( "##                                                                  ##" );
//			LOG( "######################################################################" );
			return true;
		}
	}
//	if ( !bFirst )
//		LOG( "-------------------------------------" );
	return false;
}

FUNCTION EndOfLine( )
{
}

//##############################################################################
function InterpolTick( out structInterpol ri, float dt )
{
	if ( bPaused )
	{
		if ( ri.alpha == 0 )
			return;
		if ( ri.Temps > 0 )
			ri.Temps = -ri.Temps;
		ri.Pause = 0;
	}
	ri.Pause -= dt;
	if ( ri.Pause < 0 )
	{
		if ( ! ri.bStop || (ri.alpha!=0) )
			ri.alpha += dt / ri.Temps;
		if ( ri.alpha > 1.0 )
		{
			ri.alpha = 1.0;
			ri.Temps = -ri.Temps;
			ri.Pause = 0.0; // ri.TempsPauseOuvert;
		}
		else if ( ri.alpha < 0.0 )
		{
			ri.alpha = 0.0;
			ri.Temps = -ri.Temps;
			ri.Pause = ri.TempsPauseFerme;
		}
	}
}

//##############################################################################
function bool MustBeStop( )
{
	LOCAL int i;
	LOCAL Pawn p;

	for ( i = 0; i < Speakers.Length; ++i )
	{
		if	( bGivenSpeaker[ i ] != 0 )
		{
			if ( Speakers[i].Pawn.IsA('GenNMI') )
				p = Speakers[i].Pawn.Instigator;
			else
				p = Pawn(Speakers[i].Pawn);

			if	(
					( p==none )	||	( p.bDeleteMe )	||	p.bIsDead	// Pawn only conditions
				||
					( p.Controller==none )
				||
					( p.Controller.IsA( 'IAController' ) && ( p.controller.Enemy!=none ) )
				)
			{
//				LOG ("========================================================");
//				LOG ( self@"STOPPED on actor"@i@"("@Speakers[i].PawnName@")");
//				LOG ("--------------------------------------------------------");
//				if ( Speakers[i].Pawn.IsA('GenNMI') )
//					LOG( "PAWN ="@p@"FROM GENNMI"@Speakers[i].Pawn );
//				else
//					LOG( "PAWN ="@p );
//				if ( p!=none )
//				{
//					if ( p.bDeleteMe )
//						LOG ( "bDeleteMe = TRUE" );
//					if ( p.bIsDead )
//						LOG ( "bIsDead = TRUE" );
//					if ( p.Controller==none )
//						LOG ( "HAS NO CONTROLLER !!" );
//					else
//					{
//						if ( p.Controller.IsA( 'IAController' ) && ( p.controller.Enemy!=none ) )
//							LOG ( "HAS AN ENEMY :"@p.controller.Enemy );
//					}
//				}
//				else
//					LOG ( "PAWN IS NONE" );
//				LOG ("--------------------------------------------------------");


//				DebugLog("MUST BE STOPPED !!!");
				return true;
			}
		}
	}
	return false;
}

event Destroyed( )
{
    local int i, Dialind;

	StopVoice( );
	XIIIBaseHud( PC.MyHud ).HudDlg.RemoveMe();
}

FUNCTION bool IsSpeaking()
{
	return bDialoguePlaying;
}

STATE STA_HeadAnimation
{
	EVENT BeginState( )
	{
		bSpeaking = true;

		Machoire.Alpha = 0;
		Machoire.bStop = false;
		Levre.Alpha = 0;
		Levre.bStop = false;
		bPaused = false;
		enable( 'Tick' );
	}
/*
	EVENT Untrigger( actor a, pawn p )
	{
		StopVoice( );
	}
*/
	EVENT EndOfVoice( )
	{
//		Log( "DIALOGMANAGER ENDOFVOICE ~~~"@self);
		Machoire.bStop = true;
		Levre.bStop = true;
		bSpeaking = false;
	}

	EVENT PauseVoice( )
	{
//		Log( "DIALOGMANAGER PAUSE ~~~"@self);
		bPaused = true;
	}

	EVENT UnpauseVoice( )
	{
//		Log( "DIALOGMANAGER UNPAUSE ~~~"@self);
		bPaused = false;
	}

    EVENT Tick( float dt )
    {
		LOCAL int i;

		if ( MustBeStop( ) )
		{
			StopVoice( );
			XIIIBaseHud( PC.MyHud ).HudDlg.RemoveMe();

			if ( BreathSteam )
				for ( i = 0; i < BSE.length; ++i )
				{
					if ( BSE[ i ]!=none )
					{
						BSE[i].AutoDestroy = true;
						// to work, AutoDestroy require the particles emitters not to be disabled
						BSE[i].Emitters[0].Disabled = false;  // it would be nicer to ask the emitter to enable its own emitters (whatever their number)
					}
				}

				if ( CurrentSpeakerPawn!=none )
				{
					CurrentSpeakerPawn.SetBoneDirection( Machoire.Bone, rot( 0, 0, 0 ), vect( 0, 0, 0 ), 0.0 );
					CurrentSpeakerPawn.SetBoneScale( 0 );
				}
				// Beurk
				XIIIBaseHud( PC.MyHud ).HudDlg.MyMessage.EndOfLife = Level.TimeSeconds;
				XIIIBaseHud( PC.MyHud ).HudDlg.MyMessage.LifeTime = 1.0;

				Destroy( );
		}

		if ( !( bSpeaking || Machoire.Alpha!=0 || Levre.Alpha!=0 ) )
		{
			//				if (CurrentSpeakerPawn!=none)
			//				{
			if ( CurrentSpeakerPawn!=none )
			{
				CurrentSpeakerPawn.SetBoneDirection( Machoire.Bone, rot( 0, 0, 0 ), vect( 0, 0, 0 ), 0.0 );
				CurrentSpeakerPawn.SetBoneScale( 0 );
			}
			//				}
			// sfx window display is no more
			if ( bAfficheVignette )
			{
				bAfficheVignette = false;
				TriggerEvent('DeadVignAlpha',self,none);
			}

			GotoState( 'STA_PlayingDialogue', 'EOL' );
			return;
		}

		if ( CurrentSpeakerPawn!=none )
		{
			if ( Levre.alpha==0 )
			{
				if ( bPaused )
				{
					Levre.Temps = 0;
					Levre.TempsPauseFerme = 0;
					//					Levre.TempsPauseOuvert = 0;
				}
				else
				{
					Levre.Temps = FRand() * 0.100 + 0.200;// 0.250; //(FRand()*0.2+0.1)*0.85; 	// TEST POUR ALKIS 0.0; //
					Levre.TempsPauseFerme = FRand( ) * 0.17; //0.2 * 0.85; 	// TEST POUR ALKIS 1.0; //
					//					Levre.TempsPauseOuvert = 0.0; //FRand()*0.1*0.85; 	// TEST POUR ALKIS 1.0; //
				}
			}
			InterpolTick( Levre, dt );
			if ( !Levre.bStop )
				CurrentSpeakerPawn.SetBoneScalePerAxis( 0, ( 1.0 - 0.80 * Levre.Alpha ), , , Levre.Bone );

			if ( Machoire.alpha==0 )
			{
				if ( bPaused )
				{
					Machoire.Temps = 0;
					Machoire.TempsPauseFerme = 0;
					//					Machoire.TempsPauseOuvert = 0;
					JawRotator = rot( 0, 0, 0 );
				}
				else
				{
					if ( BreathSteam && BSE[ Lines[ LineIndex ].SpeakerIndex ]!=none )
						BSE[ Lines[ LineIndex ].SpeakerIndex ].Trigger( none, none );
					Machoire.Temps = FRand() * 0.100 + 0.200; //0.250; //(FRand()*0.0625+0.0625)*0.85; 	// TEST POUR ALKIS 0.0; //
					Machoire.TempsPauseFerme = FRand( ) * 0.1; //053125; //0.0625*0.85;	// TEST POUR ALKIS 1.0; //
					//					Machoire.TempsPauseOuvert = 0.0; //FRand()*0.0625*0.85;	// TEST POUR ALKIS 1.0; //
					JawRotator = -( FRand( ) * 500 + 750 ) * rot( 0, 0, 1 );	// TEST POUR ALKIS -1200;//
				}
			}
			InterpolTick( Machoire, dt );
			CurrentSpeakerPawn.SetBoneRotation( Machoire.Bone, JawRotator, , Machoire.Alpha );
		}
	}

	EVENT Timer( )
	{
		EndOfVoice( );
	}
NoSound:
	SetTimer( NoSoundTime, false );
}

STATE STA_PlayingDialogue
{
	EVENT BeginState( )
	{
		LOCAL int i;
		if ( !bDialoguePlaying )
		{
			Disable( 'Trigger' );
			if ( Lines[LineIndex].TimeBeforeSentence!=0 )
				SetTimer( Lines[LineIndex].TimeBeforeSentence, false );
			else
				Speak( );
			bDialoguePlaying = true;
		}
	}

	EVENT Timer( )
	{
		if ( MustBeStop( ) )
		{
			Destroy( );
			return;
		}
		Speak( );
	}

	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		Disable( 'Trigger' );
		tag = '';
		NextSentence( );
	}

	FUNCTION EndOfLine( )
	{
		LOCAL string strTemp,strTemp2;
		LOCAL int index;

		strTemp = Lines[ LineIndex ].SpeakersToWarnAtTheEndOfThisLine;

		while( strTemp != "" )
		{
			index = InStr( strTemp, " " );
			if ( index == -1 )	{	strTemp2 = "";	}
			else				{	strTemp2 = Mid( strTemp, index + 1 );	strTemp = Left( strTemp, index );	}

//			Log( "DIALOGMANAGER"@self@"Warn Actor"@Speakers[ int( strTemp ) ].Pawn );

			if ( Cine2( Speakers[ int( strTemp ) ].Pawn )!=none )
				Cine2( Speakers[ int( strTemp ) ].Pawn ).CineController.CineWarn( self );
			strTemp = strTemp2;
		}

		if ( Lines[ LineIndex ].ExpectedEventBeforeNext != '' )
		{
			tag = Lines[ LineIndex ].ExpectedEventBeforeNext;
			if ( !RestoreCineEvents( ) )
			{
//				Log( "DIALOGMANAGER::Waiting event"@tag );
				Enable( 'Trigger' );
			}
			else
				NextSentence( );
		}
		else
			NextSentence( );

	}

	FUNCTION bool RestoreCineEvents( )
	{
		LOCAL int i, n;
		LOCAL CineController2 C;

		ForEach DynamicActors( class 'CineController2', C )
		{
			for ( i=0; i<8 /*MAX_EVENT*/; i++ )
			{
				if ( C.EventNamesTab[i]==Tag )
				{
//					Log( "DIALOGMANAGER::RESTORING CINE EVENT"@tag );
//					Trigger( C.EventOthersTab[i], C.EventInstigatorsTab[i] );
					return true;
				}

			}
		}
		return false;
	}
EOL:
	EndOfLine( );
	stop;
}

FUNCTION NextSentence()
{
	LOCAL int i;

	LineIndex++;

	if ( LineIndex < Lines.length )
	{
		if ( Lines[LineIndex].TimeBeforeSentence!=0 )
		{
//				Log( "DIALOGMANAGER::Waiting time"@Lines[LineIndex].TimeBeforeSentence );
			SetTimer( Lines[LineIndex].TimeBeforeSentence, false );
		}
		else
			Speak( );
	}
	else
	{
//			Log( "DIALOGMANAGER::Warn ENDOFDIALOG" );
		for ( i = 0; i < Speakers.Length; ++i )
		{
			if ( Speakers[i].Pawn!=none && Speakers[i].Pawn.IsA('Cine2') )
				Cine2( Speakers[i].Pawn ).CineController.EndOfDial( self );
			if ( BreathSteam && BSE[ i ]!=none )
			{
				BSE[ i ].AutoDestroy = true;
				// to work, AutoDestroy require the particles emitters not to be disabled
				BSE[ i ].Emitters[ 0 ].Disabled = false;  // it would be nicer to ask the emitter to enable its own emitters (whatever their number)
			}
		}
		bDialoguePlaying = false;
		if ( event != '' )
			TriggerEvent( event, self, none );
		GotoState( '' );
	}
}



defaultproperties
{
     Machoire=(Bone="X Jaw")
     Levre=(Bone="X Lips")
     Texture=Texture'XIDCine.DialMan_ico'
}
