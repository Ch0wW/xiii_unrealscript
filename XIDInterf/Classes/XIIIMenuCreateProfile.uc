//============================================================================
// Create Profile menu.
//
//============================================================================
class XIIIMenuCreateProfile extends XIIIWindow;

var localized string TitleText;
var localized string ProfileText;
var localized string CreateText;

var XIIIComboControl ProfileCombo;
var int MaxProfiles, ProfileIdx;

var array<string> ProfileNameList;

// FQ : Moved the SelectedProfileName into myRoot
//var string SelectedProfileName;

var XIIIButton CreateButton;

var XIIIMsgBox msgbox;
var localized string DisplayedText, ProfileErrorTitle;

var string sBackGround[4];
var texture tBackGround[4];

var int ReturnCode;       // to be used with profile device
var int i;

function Created()
{
    Super.Created();

    CreateButton = XIIIbutton(CreateControl(class'XIIIButton', 292, 228, 120, 32));
    CreateButton.Text = CreateText;
    CreateButton.bGlassLook = true;

    Controls[0] = CreateButton;
    
    bShowBCK = true;
    bShowSEL = true;

    GotoState('InitProfile');
}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;

    Super.Paint(C,X,Y);

    // background
    DrawStretchedTexture(C, 0, 0, 320*fRatioX, 240*fRatioY*fScaleTo, tBackGround[0]);
    DrawStretchedTexture(C, 320*fRatioX, 0, 320*fRatioX, 240*fRatioY*fScaleTo, tBackGround[1]);
    DrawStretchedTexture(C, 0, 240*fRatioY*fScaleTo, 320*fRatioX, 240*fRatioY*fScaleTo, tBackGround[2]);
    DrawStretchedTexture(C, 320*fRatioX, 240*fRatioY*fScaleTo, 320*fRatioX, 240*fRatioY*fScaleTo, tBackGround[3]);

    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(Caps(TitleText), W, H);
    DrawStretchedTexture(C, 40, 80*fRatioY, (W+40)*fRatioX, (H+10)*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(60, 80*fRatioY+H/4);
    C.DrawText(Caps(TitleText), false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
            if (FocusedControl == Controls[1])
            {
                myRoot.OpenMenu("XIDInterf.XIIIMenuCreateProfile");
            }
            else
            {
                myRoot.SelectedProfileName = ProfileCombo.GetValue();
                GotoState('UseProfile');
            }
            return true;
	    }
	    else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
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

State InitProfile
{
Begin:
    for (i=0; i<MaxProfiles; i++)
    {
      if (!myRoot.RequestGetProfileList())
      {
          log("Unable to read profile list");
      }
      else
      {
          while (!myRoot.IsGetProfileListFinished(ReturnCode, ProfileNameList))
          {
              Sleep(0.01);
          }
          if (ReturnCode < 0)
          {
              log("Get profile list failed");
          }
          else
          {
            MaxProfiles = ProfileNameList.Length; 
            for( i=0;i < MaxProfiles ; i++ )
            {
                ProfileCombo.AddItem(ProfileNameList[i]);
            }
            if (MaxProfiles>0)
            {
                Controls[0].FocusFirst(self,true);
                ProfileCombo.SetSelectedIndex(0);
            }
            else
            {
                ProfileCombo.bVisible = false;
                ProfileCombo.bNeverFocus = true;
                Controls[1].FocusFirst(self,true);;
            }
          }
      }
  }
  GotoState('');
}

State UseProfile        // slot to use is in SlotNumberToSaveIn
{
Begin:
    if (!myRoot.RequestUseProfile(myRoot.SelectedProfileName))
    {
        log("Unable to use profile "$myRoot.SelectedProfileName);
    }
    else
    {
        while (!myRoot.IsUseProfileFinished(ReturnCode))
        {
            Sleep(0.01);
        }
        if (ReturnCode < 0)
        {
            myRoot.OpenMenu("XIDInterf.XIIIMsgBox",true);
            msgbox = XIIIMsgBox(myRoot.ActivePage);
            msgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
            DisplayedText = msgbox.Replace(DisplayedText, "name", myRoot.SelectedProfileName);
            msgbox.SetupQuestion(DisplayedText, QBTN_Ok, QBTN_Ok, ProfileErrorTitle);
        }
        else
        {
            myRoot.OpenMenu("XIDInterf.XIIIMenu");
        }
    }
    GotoState('');
}



defaultproperties
{
     TitleText="Select your profile"
     ProfileText="Profile"
     CreateText="new profile"
     DisplayedText="FAILED to use profile %name%"
     ProfileErrorTitle="Error in profile"
     sBackground(0)="GuiContent.BckGround.MN_fond00_1"
     sBackground(1)="GuiContent.BckGround.MN_fond00_2"
     sBackground(2)="GuiContent.BckGround.MN_fond00_3"
     sBackground(3)="GuiContent.BckGround.MN_fond00_4"
     bForceHelp=True
     Background=None
     bAllowedAsLast=True
}
