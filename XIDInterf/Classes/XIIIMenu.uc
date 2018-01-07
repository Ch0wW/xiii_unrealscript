class XIIIMenu extends XIIIWindowMainMenu;

var XIIITextureButton ContinueButton, MultiButton, LoadButton, OptionsButton, NewButton/*, WorkButton*/;
var XIIILabel ContinueLabel, MultiLabel, LoadLabel, OptionsLabel, NewLabel, WorkLabel;
var  localized string    ContinueText, MultiplayerText, LoadGameText, OptionsText, NewGameText;
var(StartMap)  string    URL;

var XboxLiveManager xboxlive;

var texture tBackGround[14];
var texture tHighlight[14];
var texture tOnomatopee[5];
var string sBackGround[14], sHighlight[14], sOnomatopee[5];

var XIIIMsgBox msgbox;
var localized string pendingInviteString;

var string sVideo;					// video filename
var VideoPlayer VP;                 // to play video


function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    break;
    case QBTN_Cancel:
      xboxlive.ResetJoiningAfterBoot();
    break;
  }
}

function Created()
{
    local int i;


    super.Created();

    for (i=0; i<14; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }
    for (i=0; i<5; i++)
        tOnomatopee[i] = texture(DynamicLoadObject(sOnomatopee[i], class'Texture'));

    ContinueButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 30, int(30*fScaleTo), 410, int(140*fScaleTo)));
    ContinueButton.tFirstTex[0]=tBackGround[0];
    ContinueButton.tSecondTex[0]=tBackGround[2];
    ContinueButton.tThirdTex[0]=tBackGround[3];
 	ContinueButton.tFourthTex[0]=tBackGround[1];
	ContinueButton.tFirstTex[1]=tHighlight[0];
    ContinueButton.tSecondTex[1]=tHighlight[2];
    ContinueButton.tThirdTex[1]=tHighlight[3];
	ContinueButton.tFourthTex[1]=tHighlight[1];
    ContinueButton.xOff = 256;
    ContinueButton.yOff = 128;

    MultiButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 450, 30*fScaleTo, 160, 280*fScaleTo));
    MultiButton.tFirstTex[0]=tBackGround[4];
    MultiButton.tSecondTex[0]=tBackGround[5];
    MultiButton.tFirstTex[1]=tHighlight[4];
    MultiButton.tSecondTex[1]=tHighlight[5];
    MultiButton.yOff = 256;

    LoadButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 30, 180*fScaleTo, 240, 250*fScaleTo));
    LoadButton.tFirstTex[0]=tBackGround[6];
    LoadButton.tSecondTex[0]=tBackGround[7];
    LoadButton.tThirdTex[0]=tBackGround[8];
    LoadButton.tFourthTex[0]=tBackGround[9];
    LoadButton.tAdjustTex[0]=tBackGround[10];
    LoadButton.tFirstTex[1]=tHighlight[6];
    LoadButton.tSecondTex[1]=tHighlight[7];
    LoadButton.tThirdTex[1]=tHighlight[8];
    LoadButton.tFourthTex[1]=tHighlight[9];
    LoadButton.tAdjustTex[1]=tHighlight[10];
    LoadButton.xOff = 256;
    LoadButton.yOff = 256;

    OptionsButton = XIIITexturebutton(CreateControl(class'XIIITextureButton', 280, 180*fScaleTo, 160, 250*fScaleTo));
    OptionsButton.tFirstTex[0]=tBackGround[11];
    OptionsButton.tSecondTex[0]=tBackGround[12];
    OptionsButton.tFirstTex[1]=tHighlight[11];
    OptionsButton.tSecondTex[1]=tHighlight[12];
    OptionsButton.yOff = 256;

    NewButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 450, 320*fScaleTo, 160, 110*fScaleTo));
    NewButton.tFirstTex[0]=tBackGround[13];
    NewButton.tFirstTex[1]=tHighlight[13];

//    WorkButton = XIIITexturebutton(CreateControl(class'XIIITextureButton', 357, 440*fScaleTo, 155, 30*fScaleTo));

	Controls[0]=ContinueButton;
	Controls[1]=MultiButton;
    Controls[2]=LoadButton;
    Controls[3]=OptionsButton;
    Controls[4]=NewButton;
//    Controls[5]=WorkButton;

    InitLabel(ContinueLabel, 16, 32*fScaleTo, 128, 32*fScaleTo, ContinueText);
    InitLabel(MultiLabel, 420, 220*fScaleTo, 128, 32*fScaleTo, MultiplayerText);
    InitLabel(LoadLabel, 16, 350*fScaleTo, 128, 32*fScaleTo, LoadGameText);
    InitLabel(OptionsLabel, 350, 320*fScaleTo, 128, 32*fScaleTo, OptionsText);
    InitLabel(NewLabel, 500, 350*fScaleTo, 128, 32*fScaleTo, NewGameText);
//    InitLabel(WorkLabel, 350, 420*fScaleTo, 128, 32*fScaleTo, "DEBUG ONLY");

	OnReOpen = InternalOnOpen;

	GotoState('ReinitMusic');
}


function ShowWindow()
{
    super.ShowWindow();
    bShowBCK = true;
    bShowSEL = true;

    if (xboxLive == none) // SouthEnd
      xboxLive = new class'xboxlivemanager';
    if (xboxLive.IsLoggedIn(xboxLive.GetCurrentUser()))
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveMainWindow", false);

    // Added support for pending invites (from other xbox titles)
    if (xboxlive.IsJoiningAfterBoot())
    {
      Log("[XIIIMenu] Joining Invite?");
      Controller.OpenMenu("XIDInterf.XIIIMsgBox");
      msgbox = XIIIMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(pendingInviteString, QBTN_Ok|QBTN_Cancel, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120, 130, 10, 10, 400, 230);
    }
}


function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    super.AfterPaint(C, X, Y);

    C.Style = 5;
    if (ContinueButton.bDisplayTex) {
        zoom = ContinueButton.zoom;
        DrawStretchedTexture(C, (205*fRatioX+223-223*zoom), (23*fRatioY+73-73*zoom), 223*zoom, 73*zoom, tOnomatopee[0]);
        DrawLabel(C, ContinueLabel);
    }
    if (MultiButton.bDisplayTex) {
        zoom = MultiButton.zoom;
        DrawStretchedTexture(C, (525*fRatioX+100-100*zoom), (84*fRatioY+100-100*zoom), 100*zoom, 100*zoom, tOnomatopee[1]);
        DrawLabel(C, MultiLabel);
    }
    if (LoadButton.bDisplayTex) {
        zoom = LoadButton.zoom;
        DrawStretchedTexture(C, (162*fRatioX+160-160*zoom), (160*fRatioY+74-74*zoom), 160*zoom, 74*zoom, tOnomatopee[2]);
        DrawLabel(C, LoadLabel);
    }
    if (OptionsButton.bDisplayTex) {
        zoom = OptionsButton.zoom;
        DrawStretchedTexture(C, (159*fRatioX+193-193*zoom), (279*fRatioY+48-48*zoom), 193*zoom, 96*zoom, tOnomatopee[3]);
        DrawLabel(C, OptionsLabel);
    }
    if (NewButton.bDisplayTex) {
        zoom = NewButton.zoom;
        DrawStretchedTexture(C, (385*fRatioX+223-223*zoom), (270*fRatioY+63-63*zoom), 223*zoom, 63*zoom, tOnomatopee[4]);
        DrawLabel(C, NewLabel);
    }
/*    if (WorkButton.bDisplayTex) {
        DrawLabel(C, WorkLabel);
    }*/
    C.Style = 1;
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    if (Sender == ContinueButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuContinue");
    if (Sender == MultiButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuMultiplayer");
    if (Sender == LoadButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuLoadGameWindow");
    if (Sender == OptionsButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuOptions");
    if (Sender == NewButton)
    {
		GetPlayerOwner().PlayMenu(hSoundNewGame);
		if ( VP == none )
			VP = new class'VideoPlayer';
		if ( VP != none )
		{
			bPlayingVideo = true;
			bNeedRawKey = true;
			VP.Open(sVideo);
			VP.Play();
			GetPlayerOwner().StopAllSounds();
			GotoState('PlayingVideo');
		}
    }
/*    if (Sender == WorkButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuChooseMap");*/
    return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeft, bRight, bUp, bDown;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
      if ( VP != none )
		{
			if (Key==0xD4/*IK_Joy13*/)
			{
				VP.stop();
				EndOfVideo();
			}
		}
		else
		{
			if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
			{
				return InternalOnClick(FocusedControl);
			}
			bUp = (Key==0x26);
			bDown = (Key==0x28);
			bLeft = (Key==0x25);
			bRight = (Key==0x27);
			// controls are
			//   0   1
			//   2 3 4
			//     5 -> will disappear in master
			if (bUp ||bDown || bLeft ||bRight)
			{
				index = FindComponentIndex(FocusedControl);
				switch (index)
				{
					case 0 :
						if (bUp || bDown) Controls[2].SetFocus(none);
						if (bLeft || bRight) Controls[1].SetFocus(none);
					break;
					case 1 :
						if (bUp || bDown) Controls[4].SetFocus(none);
						if (bLeft || bRight) Controls[0].SetFocus(none);
					break;
					case 2 :
						if (bUp || bDown) Controls[0].SetFocus(none);
						if (bLeft) Controls[4].SetFocus(none);
						if (bRight) Controls[3].SetFocus(none);
					break;
					case 3 :
						if (bUp || bDown) Controls[0].SetFocus(none);
//						if (bDown) Controls[0].SetFocus(none);
						if (bLeft) Controls[2].SetFocus(none);
						if (bRight) Controls[4].SetFocus(none);
					break;
					case 4 :
						if (bUp || bDown) Controls[1].SetFocus(none);
						if (bLeft) Controls[3].SetFocus(none);
						if (bRight) Controls[2].SetFocus(none);
					break;
/*					case 5 :
						if (bUp) Controls[3].SetFocus(none);
						if (bDown) Controls[0].SetFocus(none);
					break;*/
				}
    			return true;
			}
			else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
			{
				myRoot.CloseMenu(true);
    			return true;
			}
		}
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

function EndOfVideo()
{
	bPlayingVideo = false;
	bNeedRawKey = false;
	myRoot.CloseAll(true);
	myRoot.gotostate('');
	GetPlayerOwner().ClientTravel("Plage00", TRAVEL_Absolute, false);
}

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




defaultproperties
{
     ContinueText="Continue"
     QuitText="Quit"
     MultiplayerText="Multiplayer"
     LoadGameText="Load game"
     OptionsText="Options"
     NewGameText="New game"
     ConfirmQuitText="Do you really want to quit ?"
     ConfirmQuitTitle="Quit game"
     sBackground(0)="XIIIMenuStart.continue01gris"
     sBackground(1)="XIIIMenuStart.continue02gris"
     sBackground(2)="XIIIMenuStart.continue03gris"
     sBackground(3)="XIIIMenuStart.continue04gris"
     sBackground(4)="XIIIMenuStart.multiplayer01gris"
     sBackground(5)="XIIIMenuStart.multiplayer02gris"
     sBackground(6)="XIIIMenuStart.loadgame01gris"
     sBackground(7)="XIIIMenuStart.loadgame02bgris"
     sBackground(8)="XIIIMenuStart.loadgame03gris"
     sBackground(9)="XIIIMenuStart.loadgame04gris"
     sBackground(10)="XIIIMenuStart.loadgame02agris"
     sBackground(11)="XIIIMenuStart.options01gris"
     sBackground(12)="XIIIMenuStart.options02gris"
     sBackground(13)="XIIIMenuStart.newgame01gris"
     sBackground(14)="XIIIMenuStart.sortiegris"
     sHighlight(0)="XIIIMenuStart.continue01"
     sHighlight(1)="XIIIMenuStart.continue02"
     sHighlight(2)="XIIIMenuStart.continue03"
     sHighlight(3)="XIIIMenuStart.continue04"
     sHighlight(4)="XIIIMenuStart.multiplayer01"
     sHighlight(5)="XIIIMenuStart.multiplayer02"
     sHighlight(6)="XIIIMenuStart.loadgame01"
     sHighlight(7)="XIIIMenuStart.loadgame02b"
     sHighlight(8)="XIIIMenuStart.loadgame03"
     sHighlight(9)="XIIIMenuStart.loadgame04"
     sHighlight(10)="XIIIMenuStart.loadgame02a"
     sHighlight(11)="XIIIMenuStart.options01"
     sHighlight(12)="XIIIMenuStart.options02"
     sHighlight(13)="XIIIMenuStart.newgame01"
     sHighlight(14)="XIIIMenuStart.sortie"
     sOnomatopee(0)="XIIIMenuStart.newgameWoowoo"
     sOnomatopee(1)="XIIIMenuStart.multiplayerBam"
     sOnomatopee(2)="XIIIMenuStart.loadgameSlam"
     sOnomatopee(3)="XIIIMenuStart.optionBrrrr"
     sOnomatopee(4)="XIIIMenuStart.newgameksshhh"
     sOnomatopee(5)="XIIIMenuStart.bang"
     sVideo="cine00"
     hSoundMenu1=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMainPage'
     hSoundMenu2=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMainPage'
}
