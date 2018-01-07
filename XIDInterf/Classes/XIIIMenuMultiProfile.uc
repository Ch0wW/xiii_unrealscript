//============================================================================
// Multiplayer Profile menu.
//
//============================================================================
class XIIIMenuMultiProfile extends XIIIMenuMultiBase;

var localized string TitleText, TitleXBoxText, NameText, SkinText, TeamText, BlueText, RedText, ValidText;

var XIIIButton ValidButton;
var XIIIEditCtrl NameButton;
var XIIIComboControl SkinButton;
var XIIICheckboxControl TeamButton;

var int NumSkin, NbSkins;
var string MyClass, MyName, MyTeam;
var string MemoClass, MemoName, MemoTeam;

//var Array< class<XIIIMPPlayerPawn> > PlayerClass;
var Array<string> PlayerSkin, PlayerClass, PlayerSkinCode;


//============================================================================
function Created()
{
    local int i;
//	local string URL, MyClassTemp, MyNameTemp, MyTeamTemp;

	Super.Created();

/*	URL = "?Map="$GetPlayerOwner().Level.GetLocalURL();
	log("URL="$URL);

	MyClass = LocalParseOption( URL, "Class", "");
	MyName = LocalParseOption( URL, "Name", "");
	MyTeam = LocalParseOption( URL, "Team", "");

	log(self@"---> DONNEES PAR GET LOCAL URL : Class="$MyClass$" Name="$MyName$" Team="$MyTeam);

	MyClassTemp = GetPlayerOwner().GetDefaultURL("Class");
	MyNameTemp = GetPlayerOwner().GetDefaultURL("Name");
	MyTeamTemp = GetPlayerOwner().GetDefaultURL("Team");

	log(self@"---> DONNEES PAR GET DEFAULT URL: Class="$MyClassTemp$" Name="$MyNameTemp$" Team="$MyTeamTemp);

	MyClass = string (GetPlayerOwner().PawnClass);
	MyName = GetPlayerOwner().PlayerReplicationInfo.PlayerName;
	MyTeam = string (GetPlayerOwner().PlayerReplicationInfo.Team.TeamIndex);

	log(self@"---> DONNEES UN PEU PARTOUT: Class="$MyClass$" Name="$MyName$" Team="$MyTeam);

    MyClass = XIIIGameInfo(GetPlayerOwner().Level.Game).PlayerClass;
	MyName = XIIIGameInfo(GetPlayerOwner().Level.Game).PlayerName;
	MyTeam = string (XIIIGameInfo(GetPlayerOwner().Level.Game).PlayerTeam);

	log(self@"---> DONNEES PAR GAMEINFO: Class="$MyClass$" Name="$MyName$" Team="$MyTeam);
*/
	// version par GetDefaultUrl()
	MyName = GetPlayerOwner().GetDefaultURL("MyName");
	if (MyName == "")
		MyName = GetPlayerOwner().GetDefaultURL("Name");
	MyClass = GetPlayerOwner().GetDefaultURL("MySkin");
	MyTeam = GetPlayerOwner().GetDefaultURL("MyTeam");

	MemoName = MyName;
	MemoClass = MyClass;
	MemoTeam = MyTeam;

    NameButton = XIIIEditCtrl(CreateControl(class'XIIIEditCtrl', 160, 200*fScaleTo, 300, 32*fScaleTo));
    NameButton.TitleText = NameText;
	NameButton.Text = MyName;

	SkinButton = XIIIComboControl(CreateControl(class'XIIIComboControl', 160, 260*fScaleTo, 300, 32*fScaleTo));
    SkinButton.Text = SkinText;
	SkinButton.bArrows = true;
	NbSkins = class'MeshSkinList'.default.MeshSkinListInfo.Length;
	NumSkin = 0;
	for (i=0;i<NbSkins;i++)
	{
		PlayerSkin[i] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinReadableName;
		PlayerClass[i] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName;
		PlayerSkinCode[i] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode;
		SkinButton.AddItem(PlayerSkin[i]);
		if ( MyClass == PlayerClass[i] )
			NumSkin = i;
	}
	SkinButton.SetSelectedIndex(NumSkin);

	TeamButton = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 160, 320*fScaleTo, 300, 32*fScaleTo));
	TeamButton.Text = TeamText;
	TeamButton.sYes = BlueText;
	TeamButton.sNo = RedText;
	if ( MyTeam == "0" )
		TeamButton.bChecked = false;
	else
		TeamButton.bChecked = true;
	TeamButton.bWhiteColorOnlyWhenFocused = true;

	ValidButton = XIIIButton( CreateControl( class'XIIIButton', 210, 380*fScaleTo, 200, 32*fScaleTo ) );
	ValidButton.Text = ValidText;

	Controls[0] = NameButton;
	Controls[1] = SkinButton;
	Controls[2] = TeamButton;
	Controls[3] = ValidButton;
}


function ShowWindow()
{
    super.ShowWindow();
    bShowCCL = true;
//    bShowSEL = true;
}


function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;

	bShowACC = ( FocusedControl==ValidButton );
	bShowEDT = ( FocusedControl==NameButton );

    Super.Paint(C,X,Y);

    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
	if ( myRoot.CurrentPF == 2 )
		TitleText = TitleXBoxText;
	C.TextSize(TitleText, W, H);
    DrawStretchedTexture(C, -1, 80*fRatioY, (W+80)*fRatioX, (H+10)*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(40*fRatioX, 80*fRatioY+H/4);
    C.DrawText( TitleText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
	C.Style = 1;
	C.bUseBorder = false;

}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local string URL;
	local XIIIMsgBox MsgBox;

	if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
			if (FocusedControl==ValidButton)
			{
				MyName = NameButton.Text;
				MyClass = PlayerClass[NumSkin];
				MyTeam = string ( int( TeamButton.bChecked ) );

				if ( myRoot.CurrentPF == 2 )
				{
					if (MayISave())
					{
						myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
						MsgBox = XIIIMsgBox(myRoot.ActivePage);
						MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
						MsgBox.SetupQuestion(class'XIIIMenuOptions'.default.SaveQuestionText, QBTN_Yes | QBTN_No, QBTN_Yes, "");
						MsgBox.OnButtonClick = SaveMsgBoxReturn;
					}
					else
					{
						myRoot.CloseMenu(true);
					}
				}
				else
				{
					ProcessSave();
				}
				return true;
			}
	    }

		if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }

	    if (Key==0x26/*IK_Up*/)
	    {
  	        PrevControl(FocusedControl);
    	    return true;
	    }

	    if (Key==0x28/*IK_Down*/)
	    {
            NextControl(FocusedControl);
    	    return true;
	    }

		if ((Key==0x25) || (Key==0x27))
		{
			if (FocusedControl == Controls[1])
			{
				if (Key == 0x25)
					NumSkin --;
				if (Key == 0x27)
					NumSkin ++;
				NumSkin = Clamp(NumSkin,0,NbSkins - 1);
				SkinButton.SetSelectedIndex(NumSkin);
			}

			if (FocusedControl == Controls[2])
			{
				if (Key==0x25)
					TeamButton.bChecked = true;
				if (Key==0x27)
					TeamButton.bChecked = false;
			}

		}
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}


function bool MayISave()
{
	return (
		( MemoName != MyName )
	||	( MemoClass != MyClass )
	||	( MemoTeam != MyTeam )
	);
}
function SaveMsgBoxReturn(byte bButton)
{
	if ( (bButton & QBTN_Yes) != 0)
	{
		ProcessSave();
	}
	else
	{
		myRoot.CloseMenu(true);
	}
}


function ProcessSave()
{
	GetPlayerOwner().ChangeName(MyName);
	GetPlayerOwner().UpdateURL("MyName",MyName,true);
	GetPlayerOwner().UpdateURL("MySkin",MyClass,true);
	GetPlayerOwner().UpdateURL("MyTeam",MyTeam,true);

	SaveConfigs();
}




defaultproperties
{
     TitleText="Online multiplayer profile"
     TitleXBoxText="System link profile"
     NameText="Name"
     SkinText="Skin"
     TeamText="Team"
     BlueText="Blue"
     RedText="Red"
     ValidText="Accept"
     bForceHelp=True
}
