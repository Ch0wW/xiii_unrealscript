class XIIIMenuLiveDownload extends XIIILiveWindow;

var localized string TitleText;

function Created()
{
  local int i;
  Super.Created();
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
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
  /*
    local int i;
    if (Sender == Controls[0])
    {
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinStartWindow");
    }
    return true;
    */
    return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (state==1/* || state==2*/)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



