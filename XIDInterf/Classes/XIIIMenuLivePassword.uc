class XIIIMenuLivePassword extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton Buttons[4];
var int id;
var sound hMenuCurseur;

var XboxLiveManager.ePasscodeSymbol passcode[4];
var localized string wrongPasscodeString;

function Created()
{
  local int i;
     Super.Created();
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  /*
  local GUILabel label;
  label = GUILabel(CreateControl(class'GUILabel', 150, 100, 250, 20));
  label.caption = "Test";
  label.StyleName="SquareButton";
  controls[4] = label;
  focusedControl = controls[4];
  label = GUILabel(CreateControl(class'GUILabel', 150, 130, 250, 20));
  label.caption = "Test2";
  label.StyleName="SquareButton";
  controls[5] = label;
  */

  Super.InitComponent(MyController, MyOwner);

	Buttons[0] = XIIIGUIButton(Controls[0]);
	Buttons[0].Caption = "_";
	Buttons[0].bNeverFocus=true;
	Buttons[1] = XIIIGUIButton(Controls[1]);
	Buttons[1].Caption = "_";
	Buttons[1].bNeverFocus=true;
	Buttons[2] = XIIIGUIButton(Controls[2]);
	Buttons[2].Caption = "_";
	Buttons[2].bNeverFocus=true;
	Buttons[3] = XIIIGUIButton(Controls[3]);
	Buttons[3].Caption = "_";
	Buttons[3].bNeverFocus=true;

	//btn = new class'GUILabel';
	//btn.StyleName="SquareButton";
	//btn.InitComponent(Controller, MenuOwner);
	//btn.InitComponent(MyController, MyOwner);
	//Controls[Controls.Length] = btn;
	//Buttons[Buttons.Length] = btn;
	//btn.Caption = "Test";//ButtonNames[Clamp(idesc,0,7)];
	//btn.OnClick = ButtonClick;
	//btn.Tag = 1 << idesc;

  //listbox.StyleName = "Listbox";
  //listbox.List.Add("Hello");
  //listbox.List.Add("World");
  //listbox.List.ItemsPerPage = 5;
  //Controls[0]=listbox;






	OnClick = InternalOnClick;
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
}


function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    /*local int i;
    if (Sender == Controls[0])
    {
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinStartWindow");
    }
    */
    return true;
}

function PasscodeComplete()
{
  if (xboxlive.IsPasscodeCorrect(xboxlive.GetCurrentUser(), passcode))
  {
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveLoginWait",true);
  }
  else
  {
    //myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",true);
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(wrongPasscodeString, QBTN_Ok, QBTN_Ok);
    msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
    //Controller.OpenMenu("XIDInterf.XIIIMenuLiveLoginWait",true);

    //Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    //msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    //msgbox.SetupQuestion("Wrong Passcode!", QBTN_Retry | QBTN_Cancel, QBTN_Retry);
    //Controller.OpenMenu("XIDInterf.XIIIMenuLiveLoginWait",true);
  }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    //GUILabel(controls[4]).caption = "InternalOnKeyEvent: "@string(int(Key));
    //GUILabel(controls[5]).caption = "InternalOnKeyEvent: "@string(int(State));
    if (state==3)// Unpress // to avoid auto-repeat (Can't have it on press since the GUI thing overrides it for some reason)
    {
      Log("InternalOnKeyEvent: "@Key);
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	
	    // X = 202
	    // Y = 203
	    // LT = 206
	    // RT = 207
	    // WH = 205
	    // BL = 204
	    // DL = 37
	    // DR = 39
	    // DU = 38
	    // DD = 40
	
	
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	
	    if (Key==202) // X-Button
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_GAMEPAD_X;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==203) // Y-Button
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_GAMEPAD_Y;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==206) // Left Trigger
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_GAMEPAD_LEFT_TRIGGER;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==207) // Right Trigger
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_GAMEPAD_RIGHT_TRIGGER;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	
	    if (Key==0x25/*IK_Left*/)
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_DPAD_LEFT;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_DPAD_RIGHT;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==0x26/*IK_Up*/)
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_DPAD_UP;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
	    if (Key==0x28/*IK_Down*/)
	    {
	      if (id<4)
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        Buttons[id].Caption = "X";
	        Buttons[id].MenuState = MSAT_Blurry;
	        passcode[id] = PS_DPAD_DOWN;
	      }
	      id++;
	      if (id<4)
	      {
	        Buttons[id].Caption = "_";
	        Buttons[id].MenuState = MSAT_Focused;
	      }
	      else
	      {
          myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	        PasscodeComplete();
	      }
    	  return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



