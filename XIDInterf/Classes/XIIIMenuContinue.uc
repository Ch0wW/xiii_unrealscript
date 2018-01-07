//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuContinue extends XIIIWindowMainMenu;


var XIIITextureButton ConspiracyButton, CompetencesButton, DocumentsButton, StoryButton, PlayButton;
var XIIILabel ConspiracyLabel, CompetencesLabel, DocumentsLabel, StoryLabel, PlayLabel;
var localized string ConspiracyText, CompetencesText, DocumentsText, StoryText, PlayText;
var localized string LoadingPS2Text, LoadingText, ErrorText;

var texture tBackGround[5], tHighlight[5], tOnomatopee[5];
var string sBackGround[5], sHighlight[5], sOnomatopee[5], TransitText;

var int MaxSlots;
var int ReturnCode;
var int IsEmpty;
var int i;
var int Year;
var byte Month, Day, Hour, Min;

var string Description, Transmitted, Message;

var int Time;
var int MyLastTime, timer;
var int MyLastSlot;
var int SenderButton;

var XIIIMsgBox MsgBox;

var string sVideo;					// video filename
var VideoPlayer VP;                 // to play video

var bool bIgnoreKeys;


//============================================================================
function Created()
{
    local int i;

    Super.Created();

    for (i=0; i<5; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }
    for (i=0; i<5; i++)
       tOnomatopee[i] = texture(DynamicLoadObject(sOnomatopee[i], class'Texture'));

    ConspiracyButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 144, 19*fScaleTo, 229, 243*fScaleTo));
    ConspiracyButton.tFirstTex[0]=tBackGround[0];
    ConspiracyButton.tFirstTex[1]=tHighlight[0];

    CompetencesButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 384, 19*fScaleTo, 229, 161*fScaleTo));
    CompetencesButton.tFirstTex[0]=tBackGround[1];
    CompetencesButton.tFirstTex[1]=tHighlight[1];

    DocumentsButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 27, 273*fScaleTo, 346, 161*fScaleTo));
    DocumentsButton.tFirstTex[0]=tBackGround[2];
    DocumentsButton.tFirstTex[1]=tHighlight[2];

    StoryButton = XIIITexturebutton(CreateControl(class'XIIITextureButton', 384, 191*fScaleTo, 229, 243*fScaleTo));
    StoryButton.tFirstTex[0]=tBackGround[3];
    StoryButton.tFirstTex[1]=tHighlight[3];

    PlayButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 27, 19*fScaleTo, 106, 243*fScaleTo));
    PlayButton.tFirstTex[0]=tBackGround[4];
    PlayButton.tFirstTex[1]=tHighlight[4];

    Controls[0]=PlayButton; 
    Controls[1]=ConspiracyButton; 
    Controls[2]=CompetencesButton; 
    Controls[3]=DocumentsButton; 
    Controls[4]=StoryButton; 

    InitLabel(ConspiracyLabel, 116, 32*fScaleTo, 128, 32*fScaleTo, ConspiracyText);
    InitLabel(CompetencesLabel, 350, 142*fScaleTo, 128, 32*fScaleTo, CompetencesText);
    InitLabel(DocumentsLabel, 16, 390*fScaleTo, 128, 32*fScaleTo, DocumentsText);
    InitLabel(StoryLabel, 350, 320*fScaleTo, 128, 32*fScaleTo, StoryText);
    InitLabel(PlayLabel, 72, 212*fScaleTo, 96, 32*fScaleTo, PlayText);

	OnReOpen = InternalOnOpen;

	GotoState('ReinitMusic');
}


//============================================================================
function ShowWindow()
{
    Super.ShowWindow();
    bShowBCK = true;
    bShowSEL = true;
}

/*
//============================================================================
function Paint(Canvas C, float X, float Y)
{
     Super.Paint(C, X, Y);

     C.bUseBorder = true;
     DrawStretchedTexture(C, 25*fRatioX, 19*fScaleTo*fRatioY, 206*fRatioX, 163*fScaleTo*fRatioY, tBackGround[4]);
     C.bUseBorder = false;
     timer=31;
}
*/

//============================================================================
function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    Super.AfterPaint(C, X, Y);

    C.Style = 5;
    if (ConspiracyButton.bDisplayTex) {
        zoom = ConspiracyButton.zoom;
        DrawStretchedTexture(C, (205*fRatioX+112-112*zoom), (123*fRatioY+50-50*zoom), 112*zoom, 50*zoom, tOnomatopee[0]);
        DrawLabel(C, ConspiracyLabel);
    }
    if (CompetencesButton.bDisplayTex) {
        zoom = CompetencesButton.zoom;
        DrawStretchedTexture(C, (525*fRatioX+100-100*zoom), (84*fRatioY+100-100*zoom), 100*zoom, 100*zoom, tOnomatopee[1]);
        DrawLabel(C, CompetencesLabel);
    }
    if (DocumentsButton.bDisplayTex) {
        zoom = DocumentsButton.zoom;
        DrawStretchedTexture(C, (252*fRatioX+160-160*zoom), (270*fRatioY+74-74*zoom), 160*zoom, 74*zoom, tOnomatopee[2]);
        DrawLabel(C, DocumentsLabel);
    }
    if (StoryButton.bDisplayTex) {
        zoom = StoryButton.zoom;
        DrawStretchedTexture(C, (469*fRatioX+166-166*zoom), (160*fRatioY+66-66*zoom), 133*zoom, 66*zoom, tOnomatopee[3]);
        DrawLabel(C, StoryLabel);
    }
    if (PlayButton.bDisplayTex){
        zoom = PlayButton.zoom;
        DrawStretchedTexture(C, (39*fRatioX+166-166*zoom), (40*fRatioY+66-66*zoom), 133*zoom, 66*zoom, tOnomatopee[4]);
        DrawLabel(C, PlayLabel);
    }
    C.Style = 1;
    //timer++;
    //if (timer > 600)
    //	timer=31;

}


//============================================================================
// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    

    if (Sender == ConspiracyButton)
	{
	MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
	SenderButton = 4;
	GotoState('STA_CheckDocument');		
	}  
    if (Sender == CompetencesButton)
        {
	  Controller.OpenMenu("XIDInterf.XIIIMenuSkill");
	  timer = 0;
	  GotoState('');
	}
    if (Sender == DocumentsButton)
	{
		MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
		SenderButton = 3;
		GotoState('STA_CheckDocument');		
	}
    if (Sender == StoryButton)
	{
		MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
		SenderButton = 2;
		GotoState('STA_CheckDocument');		
	}
	//Controller.OpenMenu("XIDInterf.XIIIMenuStory");    
	if (Sender == PlayButton)
	{
		// on cherche si une sauvegarde recente existe
		MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
		GotoState('STA_GetSlotDescription');
	}
    return true;
}


/*
function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;

    Super.Paint(C,X,Y);

    // main design
    if (!myRoot.GetLevel().bCineFrame)
	{
		C.DrawMsgboxBackground(false, 120*fRatioX, 50*fRatioY*fScaleTo, 10, 10, 420*fRatioX, 350*fRatioY*fScaleTo);
	}
    else
    {
		C.DrawMsgboxBackground(false, 0.09*C.ClipX*fRatioX, 0.2*C.ClipY*fRatioY*fScaleTo, 10, 10, 0.82*C.ClipX*fRatioX, 0.6*C.ClipY*fRatioY*fScaleTo);
    }

    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(Caps(TitleText), W, H);
    DrawStretchedTexture(C, 80, 110*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(90*fRatioX, (125*fScaleTo*fRatioY)-H/2);
    C.DrawText(Caps(TitleText), false);
    
    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(Caps("PRESS START"), W, H);
    DrawStretchedTexture(C, 280, 250*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(290*fRatioX, (265*fScaleTo*fRatioY)-H/2);
    C.DrawText(Caps("PRESS START"), false);

    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}
*/


//============================================================================
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
   local int index;
   local bool bLeft, bRight, bUp, bDown;
	timer=31;
	if (( timer > 30 ) && ( !bIgnoreKeys ))
	{
		if (State==1)// IST_Press // to avoid auto-repeat
		{
			if ( VP != none )
			{
				if
					(
					( ( myRoot.CurrentPF == 2 ) && (Key==0xD4/*IK_Joy13*/) )
					||
					( ( myRoot.CurrentPF != 2 ) && ((Key==0x0D/*IK_Enter*/) || (Key==0x1B /*IK_Escape*/)) )
					)
				{
					VP.stop();
					EndOfVideo();
				}
			}
			else
			{
				if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
				{
					return InternalOnClick(FocusedControl);//true;
				}

				else if ((Key==0x08/*IK_Escape*/) || (Key==0x1B))
				{
					myRoot.CloseMenu(true);
    				return true;
				}


				bUp = (Key==0x26);
				bDown = (Key==0x28);
				bLeft = (Key==0x25);
				bRight = (Key==0x27);

				// controls are
				//   0   1
				//	   4
				//   2   3
				if ( bUp || bDown || bLeft || bRight )
				{
					index = FindComponentIndex(FocusedControl);
					switch (index)
					{
						case 0 :
							if ( bRight ) Controls[1].FocusFirst(Self,false);
							if (bUp || bDown) Controls[3].FocusFirst(Self,false);
					if ( bLeft ) Controls[2].FocusFirst(Self,false);
						break;
						case 1 : 
							if ( bUp || bDown ) Controls[3].FocusFirst(Self,false);
					if ( bLeft ) Controls[0].FocusFirst(Self,false);
							if ( bRight ) Controls[2].FocusFirst(Self,false);
						break;
						case 2 : 
							if ( bUp || bDown) Controls[4].FocusFirst(Self,false);
							if ( bLeft ) Controls[1].FocusFirst(Self,false);
					if ( bRight ) Controls[0].FocusFirst(Self,false);
				break;
						case 3 : 
							if ( bUp || bDown ) Controls[0].FocusFirst(Self,false);
							if ( bLeft || bRight) Controls[4].FocusFirst(Self,false);
						break;
						case 4 : 
							if ( bUp || bDown) Controls[2].FocusFirst(Self,false);
							if ( bLeft || bRight ) Controls[3].FocusFirst(Self,false);
						break;
					}
					return true;
				}
			}
		}
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}


function EndOfVideo()
{
	bPlayingVideo = false;
	if ( myRoot.CurrentPF == 2 )
		bNeedRawKey = false;
	myRoot.CloseAll(true);
	myRoot.gotostate('');
	GetPlayerOwner().ClientTravel("Plage00", TRAVEL_Absolute, false);
}


//============================================================================
State STA_GetSlotDescription
{
Begin:
	bIgnoreKeys = true;
	MyLastTime = 0;
	if ( myRoot.bSavingPossible )
	{
		for (i=0; i<MaxSlots; i++)
		{
			if ( myRoot.RequestIsSlotEmpty(i) )
			{
				while ( !myRoot.IsSlotEmptyFinished(ReturnCode, IsEmpty) )
				{
					Sleep(0.01);
				}
				if (( ReturnCode >= 0 ) && ( !bool(IsEmpty) ))
				{
					if (myRoot.RequestGetSlotContentDescription(i))
					{
						while (!myRoot.IsGetSlotContentDescriptionFinished(ReturnCode, Description))
						{
							Sleep(0.01);
						}
						if (ReturnCode >= 0)
						{
							if (myRoot.RequestGetSlotContentDateAndTime(i))
							{
								while (!myRoot.IsGetSlotContentDateAndTimeFinished(ReturnCode, Year, Month, Day, Hour, Min))
								{
									Sleep(0.01);
								}
								if (ReturnCode >= 0)
								{
									// on compare les sauvegardes (d abord YEAR, puis MONTH, DAY, HOUR et MIN)
									Time = Min + 60*Hour + 1440*Day + 43200*Month + 518400*Year;
									if ( Time > MyLastTime )
									{
										MyLastTime = Time;
										MyLastSlot = i;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if ( MyLastTime == 0 )
	{
		if ( VP == none )
			VP = new class'VideoPlayer';
		if ( VP != none )
		{
			bIgnoreKeys = false;
			bPlayingVideo = true;
			if ( myRoot.CurrentPF == 2 )
				bNeedRawKey = true;
			VP.Open(sVideo);
			VP.Play();
			GetPlayerOwner().StopAllSounds();
			GetPlayerOwner().GotoState('NoControl');
			GotoState('PlayingVideo');
		}
	}
	else
    {
        if (!myRoot.RequestReadSlot(MyLastSlot))
        {
            log("Unable to load from slot "$MyLastSlot);
        }
        else
        {
            while (!myRoot.IsReadSlotFinished(ReturnCode))
            {
                Sleep(0.01);
            }
			if (ReturnCode < 0)
			{
				myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
				MsgBox = XIIIMsgBox(myRoot.ActivePage);
				MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
				if ( myRoot.CurrentPF == 1 )
					MsgBox.SetupQuestion(LoadingPS2Text, QBTN_Ok, QBTN_Ok, ErrorText);
				else
					MsgBox.SetupQuestion(LoadingText, QBTN_Ok, QBTN_Ok, ErrorText);
			}
			else
			{
				myRoot.CloseAll(true);
				myRoot.gotostate('');
			}
        }
		bIgnoreKeys = false;
        GotoState('');
	}
}


//============================================================================
State STA_CheckDocument
{
Begin:
 if (timer > 30)
 {
	for (i=0; i<MaxSlots; i++)
	{
		if ( myRoot.RequestIsSlotEmpty(i) )
		{
			while ( !myRoot.IsSlotEmptyFinished(ReturnCode, IsEmpty) )
			{
				Sleep(0.01);
			}
			//log("ReturnCode = "$ReturnCode);
			if (( ReturnCode >= 0 ) && ( !bool(IsEmpty) ))
			{
				if (myRoot.RequestGetSlotContentDescription(i))
				{
					while (!myRoot.IsGetSlotContentDescriptionFinished(ReturnCode, Description))
					{
						Sleep(0.01);
					}
					if (ReturnCode >= 0)
					{
						if (myRoot.RequestGetSlotContentDateAndTime(i))
						{
							while (!myRoot.IsGetSlotContentDateAndTimeFinished(ReturnCode, Year, Month, Day, Hour, Min))
							{
								Sleep(0.01);
							}
							if (ReturnCode >= 0)
							{
								// on compare les sauvegardes (d abord YEAR, puis MONTH, DAY, HOUR et MIN)
								Time = Min + 60*Hour + 1440*Day + 43200*Month + 518400*Year;
								if ( Time > MyLastTime )
								{
									MyLastTime = Time;
									MyLastSlot = i;
									TransitText=Description;
								}
							}
						}					
						//TransitText=Description;
					}
					else
					{
						TransitText=Description;					
					}
				}
			
			}
			//else
			//{
			//	// Game without save
			//
			//	TransitText="Bove President";
			//}
		}
	}

   if (TransitText!="")
   {
	if (SenderButton == 4)
	{
		Controller.OpenMenu("XIDInterf.XIIIMenuConspiracy",,TransitText);
		timer = 0;
		GotoState('');
	}
	if (SenderButton == 3)
	{
		Message = "?Transmitted="$TransitText;
	        //log("SenderButton="$SenderButton ); 
		Controller.OpenMenu("XIDInterf.XIIIMenuDocument",,Message);
		timer = 0;
		GotoState('');
	}
	if (SenderButton == 2)
	{
		Controller.OpenMenu("XIDInterf.XIIIMenuStory",,TransitText);
		timer = 0;
		GotoState('');
	}
   }
   else
   {
        // game without save
	if (SenderButton == 2)
	{
		TransitText="Bove President";
		timer = 0;
		Controller.OpenMenu("XIDInterf.XIIIMenuStory",,TransitText);
		GotoState('');
	}
        // game without save
	if (SenderButton == 4)
	{
		TransitText="Bove President";
		timer = 0;
		Controller.OpenMenu("XIDInterf.XIIIMenuConspiracy",,TransitText);
		GotoState('');
	}
	if (SenderButton == 3)
	{
		TransitText="Bove President";
		Message = "?Transmitted="$TransitText;
		timer = 0;
	        //log("SenderButton="$SenderButton ); 
	   	Controller.OpenMenu("XIDInterf.XIIIMenuDocument",,Message);
		GotoState('');
	}    
   }
 }
 sleep(0.1);
 goto('begin');
}

//============================================================================
State PlayingVideo
{
	event Tick(float dt)
	{
		if (( VP != none ) && ( VP.GetStatus() == 0 ))
		{
			EndOfVideo();
		}
	}
}

//============================================================================


defaultproperties
{
     ConspiracyText="Conspiracy"
     CompetencesText="Skills"
     DocumentsText="Documents"
     StoryText="Story"
     PlayText="PLAY"
     LoadingPS2Text="Unable to read file on memory card (8MB) (for PlayStation®2) in MEMORY CARD slot 1"
     LoadingText="Unable to read slot"
     ErrorText="Loading error"
     sBackground(0)="XIIIMenuStart.conspiracygris"
     sBackground(1)="XIIIMenuStart.competencegris"
     sBackground(2)="XIIIMenuStart.dossiergris"
     sBackground(3)="XIIIMenuStart.storygris"
     sBackground(4)="XIIIMenuStart.playgris"
     sHighlight(0)="XIIIMenuStart.conspiracy"
     sHighlight(1)="XIIIMenuStart.competence"
     sHighlight(2)="XIIIMenuStart.dossier"
     sHighlight(3)="XIIIMenuStart.story"
     sHighlight(4)="XIIIMenuStart.play"
     sOnomatopee(0)="XIIIMenuStart.newgameWoowoo"
     sOnomatopee(1)="XIIIMenuStart.multiplayerBam"
     sOnomatopee(2)="XIIIMenuStart.optionBrrrr"
     sOnomatopee(3)="XIIIMenuStart.loadgameSlam"
     sOnomatopee(4)="XIIIMenuStart.bang"
     sVideo="cine00"
     hSoundMenu1=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hContinu'
     hSoundMenu2=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hContinu2'
}
