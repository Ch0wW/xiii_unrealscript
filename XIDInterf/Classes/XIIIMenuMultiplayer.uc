//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuMultiplayer extends XIIIWindowMainMenu;

var XIIITextureButton SplitButton, LANJoinButton, LANHostButton, GSButton, ProfileButton;
var XIIILabel SplitLabel, LANJoinLabel, LANHostLabel, GSLabel, ProfileLabel;
var localized string    SplitText, LANJoinText, LANHostText, XBoxLiveText, ProfileXBoxText;

var localized string networkcableDisconnectedString;

var texture tBackGround[9];
var texture tHighlight[9];
var texture tOnomatopee[5];
var string sBackGround[9], sHighlight[9], sOnomatopee[5];
var XIIIMsgBox msgbox;

function Created()
{
    local int i;

    super.Created();

    for (i=0; i<9; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }
    for (i=0; i<5; i++)
        tOnomatopee[i] = texture(DynamicLoadObject(sOnomatopee[i], class'Texture'));

    SplitButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 30, 30*fScaleTo, 270, 140*fScaleTo));
    SplitButton.tFirstTex[0]=tBackGround[0];
    SplitButton.tFirstTex[1]=tHighlight[0];

    LANJoinButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 310, 30*fScaleTo, 145, 250*fScaleTo));
    LANJoinButton.tFirstTex[0]=tBackGround[1];
    LANJoinButton.tSecondTex[0]=tBackGround[2];
    LANJoinButton.tThirdTex[0]=tBackGround[3];
    LANJoinButton.tFirstTex[1]=tHighlight[1];
    LANJoinButton.tSecondTex[1]=tHighlight[2];
    LANJoinButton.tThirdTex[1]=tHighlight[3];
    LANJoinButton.yOff = 256;

    LANHostButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 465, 30*fScaleTo, 145, 250*fScaleTo));
    LANHostButton.tFirstTex[0]=tBackGround[4];
    LANHostButton.tSecondTex[0]=tBackGround[5];
    LANHostButton.tThirdTex[0]=tBackGround[6];
    LANHostButton.tFirstTex[1]=tHighlight[4];
    LANHostButton.tSecondTex[1]=tHighlight[5];
    LANHostButton.tThirdTex[1]=tHighlight[6];
    LANHostButton.yOff = 256;

    GSButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 30, 180*fScaleTo, 270, 250*fScaleTo));
    GSButton.tFirstTex[0]=tBackGround[7];
    GSButton.tFirstTex[1]=tHighlight[7];

    ProfileButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 310, 290*fScaleTo, 300, 140*fScaleTo));
    ProfileButton.tFirstTex[0]=tBackGround[8];
    ProfileButton.tFirstTex[1]=tHighlight[8];

	Controls[0]=SplitButton; 
	Controls[1]=LANJoinButton; 
    Controls[2]=LANHostButton; 
    Controls[3]=GSButton;
    Controls[4]=ProfileButton; 
    
    InitLabel(SplitLabel, 16, 128*fScaleTo, 208, 32*fScaleTo, SplitText);
    InitLabel(LANJoinLabel, 256, 192*fScaleTo, 192, 32*fScaleTo, LANJoinText);
    InitLabel(LANHostLabel, 416, 48*fScaleTo, 192, 32*fScaleTo, LANHostText);
    InitLabel(GSLabel, 80, 200*fScaleTo, 240, 32*fScaleTo, XBoxLiveText);
    InitLabel(ProfileLabel, 256, 380*fScaleTo, 256, 32*fScaleTo, ProfileXBoxText);

	OnReOpen = InternalOnOpen;

	GotoState('ReinitMusic');
}

function bool InternalOnPreDraw(Canvas C)
{
	local int index;
	index = FindComponentIndex(FocusedControl);
	if (myRoot.CableDisconnected )
	{
		Controls[1].bNeverFocus=true; 
		Controls[2].bNeverFocus=true; 
		if ((index>0) && (index<3))
			Controls[0].SetFocus(none);
	}
	else
	{
		Controls[1].bNeverFocus=false; 
		Controls[2].bNeverFocus=false; 
	}
    return super.InternalOnPreDraw(C);
}

function ShowWindow()
{
    super.ShowWindow();
    bShowBCK = true;
    bShowSEL = true;
}


function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    super.AfterPaint(C, X, Y);

    C.Style = 5;
    if (SplitButton.bDisplayTex) {
        zoom = SplitButton.zoom;
        DrawStretchedTexture(C, (160*fRatioX+224-224*zoom), (23*fRatioY+64-64*zoom), 224*zoom, 64*zoom, tOnomatopee[0]);
        DrawLabel(C, SplitLabel);
    }
    if (LANJoinButton.bDisplayTex) {
        zoom = LANJoinButton.zoom;
        DrawStretchedTexture(C, (304*fRatioX+96-96*zoom), (32*fRatioY+64-64*zoom), 96*zoom, 64*zoom, tOnomatopee[1]);
        DrawLabel(C, LANJoinLabel);
    }
    if (LANHostButton.bDisplayTex) {
        zoom = LANHostButton.zoom;
        DrawStretchedTexture(C, (480*fRatioX+142-142*zoom), (196*fRatioY+64-64*zoom), 142*zoom, 64*zoom, tOnomatopee[2]);
        DrawLabel(C, LANHostLabel);
    }
    if (GSButton.bDisplayTex) {
        zoom = GSButton.zoom;
        DrawStretchedTexture(C, (159*fRatioX+193-193*zoom), (279*fRatioY+48-48*zoom), 193*zoom, 96*zoom, tOnomatopee[3]);
        DrawLabel(C, GSLabel);
    }
    if (ProfileButton.bDisplayTex) {
        zoom = ProfileButton.zoom;
        DrawStretchedTexture(C, (512*fRatioX+128-128*zoom), (256*fRatioY+64-64*zoom), 128*zoom, 64*zoom, tOnomatopee[4]);
        DrawLabel(C, ProfileLabel);
    }
    C.Style = 1;
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    if (Sender == SplitButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuSplitSetupClient");
    else if (Sender == ProfileButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuMultiProfile");
    else if (Sender == GSButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow");//XIIIMenuLiveMainWindow");
	/*else if (myRoot.CableDisconnected )
	{
        Controller.OpenMenu("XIDInterf.XIIIMsgBox");
        msgbox = XIIIMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(networkcableDisconnectedString, QBTN_Ok, QBTN_Ok);
        msgbox.InitBox(120, 130, 10, 10, 400, 230);
	}*/
	else if (Sender == LANJoinButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuMultiLANJoin");
    else if (Sender == LANHostButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuMultiLANHost");

    return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeft, bRight, bUp, bDown;

    if (State==1)// IST_Press // to avoid auto-repeat
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
        //   0 1 2
        //   3  4
	    if (bUp ||bDown || bLeft ||bRight)
	    {
	        index = FindComponentIndex(FocusedControl);
			if (myRoot.CableDisconnected )
			{
				switch (index)
				{
					case 0 :
						if (bUp || bDown) Controls[3].SetFocus(none);
						if (bLeft || bRight) Controls[4].SetFocus(none);
					break;
					case 3 : 
						if (bUp || bDown) Controls[0].SetFocus(none);
						if (bLeft || bRight) Controls[4].SetFocus(none);
					break;
					case 4 : 
						if (bUp || bDown) Controls[0].SetFocus(none);
						if (bLeft || bRight) Controls[3].SetFocus(none);
					break;
					default : 
						Controls[0].SetFocus(none);
					break;
				}
				return true;
			}
			else
			{            
				switch (index)
				{
					case 0 :
						if (bUp || bDown) Controls[3].SetFocus(none);
						if (bLeft) Controls[2].SetFocus(none);
						if (bRight) Controls[1].SetFocus(none);
					break;
					case 1 : 
						if (bUp || bDown) Controls[4].SetFocus(none);
						if (bLeft) Controls[0].SetFocus(none);
						if (bRight) Controls[2].SetFocus(none);
					break;
					case 2 : 
						if (bUp || bDown) Controls[4].SetFocus(none);
						if (bLeft) Controls[1].SetFocus(none);
						if (bRight) Controls[0].SetFocus(none);
					break;
					case 3 : 
						if (bUp || bDown) Controls[0].SetFocus(none);
						if (bLeft || bRight) Controls[4].SetFocus(none);
					break;
					case 4 : 
						if (bUp || bDown) Controls[1].SetFocus(none);
						if (bLeft || bRight) Controls[3].SetFocus(none);
					break;
				}
    			return true;
    		}
	    }
        else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     TitleText="Multiplayer"
     BotChallengeText="Bot Challenge"
     LANJoinPCText="Join a LAN game"
     LANHostPCText="Host a LAN game"
     GameServiceText="UbiSoft's Online Game Service"
     ProfileText="Online Multiplayer profile"
     sBackground(0)="XIIIMenuStart.Multi_rules.multi_splittergris"
     sBackground(1)="XIIIMenuStart.Multi_rules.multi_BG01gris"
     sBackground(2)="XIIIMenuStart.Multi_rules.multi_BG02gris"
     sBackground(3)="XIIIMenuStart.Multi_rules.multi_BG03gris"
     sBackground(4)="XIIIMenuStart.Multi_rules.multi_BG01gris"
     sBackground(5)="XIIIMenuStart.Multi_rules.multi_BG02gris"
     sBackground(6)="XIIIMenuStart.Multi_rules.multi_BG03gris"
     sBackground(7)="XIIIMenuStart.Multi_rules.multilive01gris"
     sBackground(8)="XIIIMenuStart.Multi_rules.multi_profilegris"
     sHighlight(0)="XIIIMenuStart.Multi_rules.multi_splitter"
     sHighlight(1)="XIIIMenuStart.Multi_rules.multi_BG01"
     sHighlight(2)="XIIIMenuStart.Multi_rules.multi_BG02"
     sHighlight(3)="XIIIMenuStart.Multi_rules.multi_BG03"
     sHighlight(4)="XIIIMenuStart.Multi_rules.multi_BG01_1"
     sHighlight(5)="XIIIMenuStart.Multi_rules.multi_BG02_2"
     sHighlight(6)="XIIIMenuStart.Multi_rules.multi_BG03_3"
     sHighlight(7)="XIIIMenuStart.Multi_rules.multilive01"
     sHighlight(8)="XIIIMenuStart.Multi_rules.multi_profile"
     sOnomatopee(0)="XIIIMenuStart.onlineBaomm"
     sOnomatopee(1)="XIIIMenuStart.Controle_PC.Bang"
     sOnomatopee(2)="XIIIMenuStart.Controle_PC.Crash"
     sOnomatopee(3)="XIIIMenuStart.Controle_PC.ksshss"
     sOnomatopee(4)="XIIIMenuStart.Controle_PC.clapclap"
     hSoundMenu1=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMulti'
}
