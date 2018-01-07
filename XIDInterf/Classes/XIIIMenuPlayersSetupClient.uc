//============================================================================
// Select Profile menu.
//
//============================================================================
class XIIIMenuSelectProfile extends XIIIWindowMainMenu;

var localized string TitleText;
var localized string ProfileText;
var localized string CreateText;

var XIIIComboControl ProfileCombo;
var int MaxProfiles, ProfileIdx;

var array<string> ProfileNameList;

var XIIIButton CreateButton;
var XIIIEditCtrl NewProfileButton;

var XIIIMsgBox msgbox;
var localized string ProfileErrorTitle, ProfileErrorText, NoProfileText, ProfileDiskFull, ProfileMaxNumberCreated, ProfileAlreadyExistText,  ProfileCorrupted, ProfileInitText, NewProfileText, ConfirmCreateText;

var string sBackGround[4];
var texture tBackGround[4];

var int ReturnCode;       // to be used with profile device
var int ReturnFreeBlock;  // number of free block on DD
var int i;

//============================================================================
function Created()
{
    local int i;

    Super.Created();

	ReturnFreeBlock = -1;
    MaxProfiles = -1;
    ProfileIdx = 0;
    
    for (i=0; i<4; i++)
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

    ProfileCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 160, 228, 350, 32));
    ProfileCombo.Text = ProfileText;
    ProfileCombo.bArrows = true;
    ProfileCombo.bGlassLook = true;
    ProfileCombo.bVisible = false;
    ProfileCombo.bNeverFocus = true;
	
    CreateButton = XIIIbutton(CreateControl(class'XIIIbutton', 210, 296, 220, 32));
    CreateButton.Text = CreateText;
    CreateButton.bGlassLook = true;

	NewProfileButton = XIIIEditCtrl(CreateControl(class'XIIIEditCtrl',50, 296, 500, 32));
	NewProfileButton.TitleText = NewProfileText;
	NewProfileButton.bVisible = false;
	NewProfileButton.bNeverFocus = true;
	NewProfileButton.MaxWidth	 = 12;
	NewProfileButton.bCapsOnly = true;

    Controls[0] = ProfileCombo; 
    Controls[1] = CreateButton;
	Controls[2] = NewProfileButton;
    
    bShowSEL = true;

    GotoState('InitProfile');
}

function Tick(float DeltaTime)
{
}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;

    Super.Paint(C,X,Y);

    // background
    // 293 is (640-27*2)/2
    DrawStretchedTexture(C, 32*fRatioX, 24*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[0]);
    DrawStretchedTexture(C, 320*fRatioX, 24*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[1]);
    DrawStretchedTexture(C, 32*fRatioX, 240*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[2]);
    DrawStretchedTexture(C, 320*fRatioX, 240*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[3]);

    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(Caps(TitleText), W, H);
    DrawStretchedTexture(C, 400, 80*fRatioY, 400*fRatioX, (H+10)*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(440*fRatioX, 80*fRatioY+H/4);
    C.DrawText(TitleText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local XIIIMenuVirtualKeyboard msgbox;

	if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
			if (FocusedControl == Controls[0])
			{
				myRoot.SelectedProfileName = ProfileCombo.GetValue();
				GotoState('UseProfile');				
			}

			if (FocusedControl == Controls[1])
			{
				NewProfileButton.SetText("");
				myRoot.OpenMenu("XIDInterf.XIIIMenuVirtualKeyboardProfile");
				msgbox = XIIIMenuVirtualKeyboardProfile(myRoot.ActivePage);
				msgbox.InitVK( NewProfileButton );
			}

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
	    if ((Key==0x25/*IK_Left*/) || (Key==0x27/*IK_Right*/))
	    {
            if (FocusedControl == Controls[0])
	        {
                if (Key==0x25) ProfileIdx--;
                if (Key==0x27) ProfileIdx++;
                if (ProfileIdx < 0) ProfileIdx = 0;
                if (ProfileIdx > MaxProfiles-1) ProfileIdx = MaxProfiles - 1;
                ProfileCombo.SetSelectedIndex(ProfileIdx);
            }
            return true;
        }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}


function VirtualKeyboardReturn(byte bButton)
{
	log("VirtualKeyboardReturn - Texte="$NewProfileButton.Text);
	if (NewProfileButton.Text != "" )
	{
		myRoot.SelectedProfileName = NewProfileButton.Text;
		GotoState('CreateProfile');
	}
	else
	{
		ProfileList();
	}
}


function ReturnMsgBoxNotEnoughSpaceOnDD(byte bButton)
{
	ProfileList();    
}

function ReturnMsgBoxMaxNumberOfProfileReach(byte bButton)
{
	ProfileList();    
}

function ReturnMsgBoxProfileCorrupted(byte bButton)
{
    if ((bButton & QBTN_Yes) != 0)       // ok to overwrite
    {
        GotoState('OverwriteProfile');
    }
    else
    {
        ProfileList();    
    }
}

function ReturnMsgBoxUseExitingProfile(byte bButton)
{
    if ((bButton & QBTN_Yes) != 0)       // ok to overwrite
    {
        GotoState('OverwriteProfile');
    }
    else
    {
        ProfileList();    
    }
}

function ProfileList()
{
    ProfileCombo.Clear();
	MaxProfiles = ProfileNameList.Length; 
    for( i=0;i < MaxProfiles ; i++ )
    {
        ProfileCombo.AddItem(ProfileNameList[i]);
    }
    // never go there if MaxProfile=0 and no space on DD
    if (MaxProfiles>0)
    {
        ProfileCombo.bVisible = true;
        ProfileCombo.bNeverFocus = false;
        Controls[0].FocusFirst(self,true);
        ProfileCombo.SetSelectedIndex(0);
    }
    else
    {
        Controls[1].FocusFirst(self,true);
    }
	GotoState('');
}

State InitProfile
{
Begin:
	if (myRoot.bMusicPlay) 
    {   
		// start the music
		MusicValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MusicSliderPos") );
		if ( MusicValue != 0 )
			MusicValue = 2;
		GetPlayerOwner().StopMusic();
		GetPlayerOwner().SetMusicSliderPos(MusicValue);
		GetPlayerOwner().PlayMusic(menuzik);
        myRoot.bMusicPlay = false;
    }

    if (!myRoot.RequestGetProfileList())
    {
        log("Unable to read profile list -");
    }
    else
    {
      while (!myRoot.IsGetProfileListFinished(ReturnFreeBlock, ProfileNameList))
      {
          Sleep(0.01);
      }
	  // ReturnCode code represente le nombre de block restant sur le DD
      if ((ReturnFreeBlock < 4)&&(ProfileNameList.Length==0))
      {
		  myRoot.bSavingPossible=false;
		  myRoot.OpenMenu("XIDInterf.XIIIMenuFreeBlock",false,string(4-ReturnFreeBlock));
	  }
      else
      {
		ProfileList();
      }
    }
  GotoState('');
}

State CreateProfile
{
Begin:
	for( i=0;i < MaxProfiles ; i++ )
	{
		if (ProfileNameList[i]==myRoot.SelectedProfileName)
		{
			log("profile already define");
			myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
			msgbox = XIIIMsgBox(myRoot.ActivePage);
			msgbox.InitBox(220, 130*fScaleTo, 10, 10, 220, 230*fScaleTo);
			msgbox.SetupQuestion(ProfileAlreadyExistText, QBTN_YesNo, QBTN_No, ProfileErrorTitle);
			msgbox.OnButtonClick=ReturnMsgBoxUseExitingProfile;
			GotoState('');
		}
	}

	if (ReturnFreeBlock < 4) // can't create new profile not enough space on DD
	{
		myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
		msgbox = XIIIMsgBox(myRoot.ActivePage);
		msgbox.InitBox(220, 130*fScaleTo, 10, 10, 220, 230*fScaleTo);
	    ProfileDiskFull = msgbox.Replace(ProfileDiskFull, "nbblocks", string(4-ReturnFreeBlock));
		msgbox.SetupQuestion(ProfileDiskFull, QBTN_Ok, QBTN_Ok, ProfileErrorTitle);
		msgbox.OnButtonClick=ReturnMsgBoxNotEnoughSpaceOnDD;
        GotoState('');
	}
	else
	if (MaxProfiles==20)
	{
		myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
		msgbox = XIIIMsgBox(myRoot.ActivePage);
		msgbox.InitBox(220, 130*fScaleTo, 10, 10, 220, 230*fScaleTo);
		msgbox.SetupQuestion(ProfileMaxNumberCreated, QBTN_Ok, QBTN_Ok, ProfileErrorTitle);
		msgbox.OnButtonClick=ReturnMsgBoxMaxNumberOfProfileReach;
		GotoState('');
	}

	if (!myRoot.RequestCreateProfile(myRoot.SelectedProfileName))
	{
		log("Unable to create profile"@myRoot.SelectedProfileName);
		GotoState('');
	}
	else
	{
		while (!myRoot.IsCreateProfileFinished(ReturnCode))
		{
			Sleep(0.01);
		}
		if (ReturnCode<0) 
		{
			// Unable to create the profile
			log("Failed to create the profile");
			GotoState('');
		}
		else
		{
			ReturnFreeBlock = ReturnFreeBlock - 4;
			ProfileCombo.AddItem(myRoot.SelectedProfileName);
			ProfileNameList[MaxProfiles] = myRoot.SelectedProfileName;
			MaxProfiles ++;
			ProfileIdx = MaxProfiles - 1;
			ProfileCombo.bVisible = true;
			ProfileCombo.bNeverFocus = false;
			Controls[0].FocusFirst(self,true);
			ProfileCombo.SetSelectedIndex(ProfileIdx);
			NewProfileButton.SetText("");
			GotoState('');
		}
	}
}


State OverwriteProfile
{
Begin:
	log("overwrite the profile");
	if (!myRoot.RequestCreateProfile(myRoot.SelectedProfileName))
	{
		log("Unable to create profile"@myRoot.SelectedProfileName);
		GotoState('');
	}
	else
	{
		while (!myRoot.IsCreateProfileFinished(ReturnCode))
		{
			Sleep(0.01);
		}
		if (ReturnCode<0) 
		{
			// Unable to create the profile
			log("Failed to overwrite the profile");
			GotoState('');
		}
		else
		{
			for( i=0;i < MaxProfiles ; i++ )
				if (ProfileNameList[i]==myRoot.SelectedProfileName)
				{
					ProfileIdx = i;
					break;				
				}
			Controls[0].FocusFirst(self,true);
			ProfileCombo.SetSelectedIndex(ProfileIdx);
			NewProfileButton.SetText("");
			GotoState('');
		}
	}
}



State UseProfile        // slot to use is in SlotNumberToSaveIn
{
Begin:
    if (!myRoot.RequestUseProfile(myRoot.SelectedProfileName))
    {
        log("Unable to use profile "@myRoot.SelectedProfileName);
        GotoState('');
    }
    else
    {
        while (!myRoot.IsUseProfileFinished(ReturnCode))
        {
            Sleep(0.01);
        }
        if (ReturnCode < 0)
        {
            myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
            msgbox = XIIIMsgBox(myRoot.ActivePage);
            msgbox.InitBox(220, 130*fScaleTo, 10, 10, 220, 230*fScaleTo);
	        ProfileCorrupted = msgbox.Replace(ProfileCorrupted, "name", myRoot.SelectedProfileName);
            msgbox.SetupQuestion(ProfileCorrupted, QBTN_YesNo, QBTN_Yes, "");
            msgbox.OnButtonClick=ReturnMsgBoxProfileCorrupted;

            GotoState('');
        }
        else
        {
            myRoot.bProfileSelected=true;
            myRoot.OpenMenu("XIDInterf.XIIIMenu");
        }
    }
    GotoState('');
}



defaultproperties
{
     ClassText="Sabotage class"
     TeamText="Team"
     BlueTeam="Blue"
     RedTeam="Red"
     PlayerText="Player"
     sBackground="XIIIMenuStart.vignette_fond"
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     bUseDefaultBackground=False
}
