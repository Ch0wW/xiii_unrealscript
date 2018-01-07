// ====================================================================
//  (c) 2003 Ubi Soft.  All Rights Reserved
// ====================================================================

class XIIIMsgBoxQuitGame extends XIIIMsgBox;

var int T;
var sound hSoundConfirmQuitGame;
var GUIComponent mySender;
var bool bQuitGame;



function ReturnMsgBoxQuitGame()
{
	T = XIIIGUIButton(mySender).Tag;
	ParentPage.InactiveFadeColor=ParentPage.Default.InactiveFadeColor;
	Controller.CloseMenu(true);
	OnButtonClick(T);
}

function bool ButtonClick(GUIComponent Sender)
{
	if ( XIIIGUIButton(Sender).Tag == QBTN_Yes )
	{
		GetPlayerOwner().PlayMenu(hSoundConfirmQuitGame);
		mySender = Sender;
		GotoState('STA_QuitGame');
		return true;
	}
	else
	{
		ReturnMsgBoxQuitGame();
	}
}


// little time to play end sound
State STA_QuitGame
{	
	event BeginState()
	{
		SetTimer(0.5,false);
	}

	function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
	{
		if ( bQuitGame )
		{
			return true;
		}
		else
		{
			bQuitGame = true;
			return Super.InternalOnKeyEvent(Key,State,delta);
		}
	}

	event Timer()
	{
		ReturnMsgBoxQuitGame();
	}
}




defaultproperties
{
     hSoundConfirmQuitGame=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hQuited'
     Controls(0)=GUILabel'XIDInterf.XIIIMsgBox.TitleText'
     Controls(1)=GUILabel'XIDInterf.XIIIMsgBox.lblQuestion'
}
