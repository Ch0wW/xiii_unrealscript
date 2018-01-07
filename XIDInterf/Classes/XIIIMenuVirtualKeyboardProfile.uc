class XIIIMenuVirtualKeyboardProfile extends XIIIMenuVirtualKeyboard;


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{

	if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ( Key==0x0D/*IK_Enter*/) 
	    {
			if ( FocusedControl==OkButton )
			{
				log("OK - Texte="$TextStr);
				myEditCtrl.SetText( TextStr );
				XIIIMenuSelectProfile(ParentPage).VirtualKeyboardReturn(0);
				myRoot.CloseMenu(true);
				return true;
			}
			else if ( FocusedControl==CancelButton )
			{
				log("CANCEL");
				myEditCtrl.SetText("");
				XIIIMenuSelectProfile(ParentPage).VirtualKeyboardReturn(0);
				myRoot.CloseMenu(true);
			    return true;
			}
		}
	}

	return Super.InternalOnKeyEvent(Key, State, delta);
}

