//============================================================================
// The In Game menu.
//
//============================================================================
class XIIIMenuInGame extends XIIIWindow;

var XIIIButton       SaveBtn, ReturnBtn, ControlsBtn, CompetencesBtn, ItemBtn, RestartBtn, QuitBtn;
var localized string SaveTxt, ReturnTxt, ControlsTxt, CompetencesTxt, ItemTxt, RestartTxt, QuitTxt;
var localized string ConfirmQuitTxt, ConfirmRestartTxt; 

//var array<string> Objectives;
//var localized array<string> Objectives;
var int iObjDecalY, timer;

function Created()
{
	local XIIIBaseHUD Hud;
	local HudMessage HMsg;
	local int i, OffsetInit;


    Super.Created();

	OffsetInit = 155;
	i = 0;
    SaveBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, OffsetInit*fScaleTo, 200, 30*fScaleTo));
    SaveBtn.Text = SaveTxt;
    SaveBtn.bUseBorder = false;
	i++;

    ReturnBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, (OffsetInit + 30*i)*fScaleTo, 200, 30*fScaleTo));
    ReturnBtn.Text = ReturnTxt;
    ReturnBtn.bUseBorder = false;
	i++;

    ControlsBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, (OffsetInit + 30*i)*fScaleTo, 200, 30*fScaleTo));
    ControlsBtn.Text = ControlsTxt;
    ControlsBtn.bUseBorder = false;
	i++;

    CompetencesBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, (OffsetInit + 30*i)*fScaleTo, 200, 30*fScaleTo));
    CompetencesBtn.Text = CompetencesTxt;
    CompetencesBtn.bUseBorder = false;
	i++;
    
	//ItemBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, 265*fScaleTo, 200, 30*fScaleTo));
    //ItemBtn.Text = ItemTxt;
    //ItemBtn.bUseBorder = false;
	RestartBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, (OffsetInit + 30*i)*fScaleTo, 200, 30*fScaleTo));
	RestartBtn.Text = RestartTxt;
	RestartBtn.bUseBorder = false;
	i++;

    if ( GetPlayerOwner().Level.Title~="mapcredits" )
	{
		RestartBtn.bNeverFocus=true;
		RestartBtn.TextColor=class'Canvas'.Static.MakeColor(192,192,192);
	}

    QuitBtn = XIIIbutton(CreateControl(class'XIIIbutton', 230, (OffsetInit + 30*i)*fScaleTo, 200, 30*fScaleTo));
    QuitBtn.Text = QuitTxt;
    QuitBtn.bUseBorder = false;

    Controls[0] = SaveBtn;
    Controls[1] = ReturnBtn;
    Controls[2] = ControlsBtn;
    Controls[3] = CompetencesBtn;
	Controls[4] = RestartBtn;
    Controls[5] = QuitBtn;

	// erase important message display
	Hud = XIIIBaseHUD(GetPlayerOwner().myHUD);
	if ( Hud != none )
	{
		for ( HMsg = Hud.HudMsg; HMsg!=none; HMsg = HMsg.NextHudMsg)
		{
			HMsg.bIsSpecial = false;
			HMsg.MyMessage.EndOfLife = GetPlayerOwner().Level.TimeSeconds;
		}
	}
	myRoot.bPerformMemoryCardReDetection = true;

	iObjDecalY = 30;	// antibug for XBox => Now use for all plateforms
}


function SetObjectives(canvas C)
{
	local MapInfo CurrentMap;
	local int i,j, ob, LineY;
    local float W, H, oldClipX;
	local array<string> MsgArray;

	CurrentMap = XIIIGameInfo(GetPlayerOwner().Player.Actor.Level.Game).MapInfo;
/*	ob = CurrentMap.Objectif.Length;
	Objectives.Length = 0;
	for (i=0; i<ob; i++)
	{
		if (( CurrentMap.Objectif[i].bPrimary ) && ( !CurrentMap.Objectif[i].bCompleted || CurrentMap.Objectif[i].bAntigoal ))
		{
			Objectives[j] = CurrentMap.Objectif[i].GoalText;
			j++;
		}
	}*/
	//log(self@"---> LISTE DES OBJECTIFS :"@Objectives[0]@Objectives[1]@Objectives[2]@Objectives[3]);

	C.bUseBorder = false;
	C.DrawColor = WhiteColor;
    C.Style = 5;
    if (myRoot.GetLevel().bCineFrame)
		C.DrawColor.A=192;
	else
		C.DrawColor.A=128;
	DrawStretchedTexture(C, 0, 0, C.ClipX, 118*fScaleTo*fRatioY, myRoot.FondMenu);
	C.DrawColor.A=255;
    C.Style = 1;

	LineY=0;
	for (j=0;j<CurrentMap.Objectif.Length;j++)
	{
		if (( CurrentMap.Objectif[j].bPrimary ) && ( !CurrentMap.Objectif[j].bCompleted || CurrentMap.Objectif[j].bAntigoal ))
		{
			MsgArray.Remove( 0, MsgArray.Length );
			C.WrapStringToArray( CurrentMap.Objectif[j].GoalText, MsgArray, 540*fRatioX, "|");
			C.bUseBorder = false;
			if ( CurrentMap.Objectif[j].bAntigoal )
				C.DrawColor = C.Static.MakeColor(144,0,0);
			else
				C.DrawColor = BlackColor;
			for ( i=0; i<MsgArray.Length; i++ )
			{
				C.TextSize( MsgArray[i], W, H);
//				LOG( H);
				C.SetPos( 50*fRatioX, (LineY+6)*fRatioY/*H/4*/+iObjDecalY);
				C.DrawText( MsgArray[i], false);
				LineY+=0.9*H;
			}
			LineY+=0.15*H;
		}
	}

}


function ShowWindow()
{
    Super.ShowWindow();

	bShowBCK = true;
    bShowSEL = true;
}


function BeforePaint(Canvas C, float X, float Y)
{
    super.BeforePaint(C, X, Y);

    if (bDoQuitGame)
       QuitGame();
    if (bDoRestartGame)
       RestartGame();

    if ( GetPlayerOwner().Level.Game.bGameEnded )// game over
    {
        //ReturnBtn.Text="Retry";
		ReturnBtn.bNeverFocus=true;
		ReturnBtn.TextColor=class'Canvas'.Static.MakeColor(192,192,192);
		SaveBtn.bNeverFocus=true;
		SaveBtn.TextColor=class'Canvas'.Static.MakeColor(192,192,192);

		if (FocusedControl==Controls[0])
			NextControl(FocusedControl);
		if (FocusedControl==Controls[1])
			NextControl(FocusedControl);
    }
	else
	{
		// FQ, if there's a memory card, we can save, even if we chose "Continue Without Saving"
		// if ((!myRoot.IsThereACheckpoint()) || (!myRoot.bSavingPossible) || (myRoot.bContinueWithoutSaving)) // nothing to save
		if ((!myRoot.IsThereACheckpoint()) || (!myRoot.bSavingPossible) || GetPlayerOwner().Level.Title~="mapcredits" ) // nothing to save
		{
			SaveBtn.TextColor=class'Canvas'.Static.MakeColor(192,192,192);
			SaveBtn.bNeverFocus=true;
			if (FocusedControl==Controls[0])
				NextControl(FocusedControl);
		}
		else
		{
			SaveBtn.TextColor=SaveBtn.Default.TextColor;
			SaveBtn.bNeverFocus=false;
		}
	}
}


function Paint(Canvas C, float X, float Y)
{
    local string sVersion;
    local int i;

	if ( SaveBtn.bNeverFocus )
		bShowBCK = false;	

    Super.Paint(C,X,Y);

    timer=31;
    //if ( timer < 16 )
    //    timer++;
	C.SpaceX = 0;
    // background
    if (myRoot.GetLevel().bCineFrame)
	{
	    C.Style = 5;
		C.DrawColor = BlackColor;
		C.DrawColor.A = 192;
	    DrawStretchedTexture(C, 0, 0, WinWidth*C.ClipX, WinHeight*C.ClipY, myRoot.FondMenu);
		C.Style = 1;
	}
	C.DrawMsgboxBackground(false, 220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);

	// only selected control has a border
    for (i=0; i<6; i++)
        XIIIbutton(Controls[i]).bUseBorder = false;    
    if (FindComponentIndex(FocusedControl)!= -1)
        XIIIbutton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;

    // page title
    C.SetPos(220*fRatioX,340*fRatioY*fScaleTo);
	C.DrawColor = BlackColor;
	C.DrawColor.A = 255;
//	sVersion ="no version";
//	sVersion = myRoot.GetXIIIEngineVersion();
//	C.DrawText(sVersion, false);

	// objectives
	SetObjectives(C);
	
	// restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local XIIIMsgBoxInGame MsgBox;

	if (Sender == SaveBtn)
	{
        myRoot.OpenMenu("XIDInterf.XIIIMenuSave");
	}
    else if (Sender == ReturnBtn) 
	{
	    /*// if game finished, disable return to game and name the button Retry, not return to game
		GetPlayerOwner().ResetInputs();
        if (GetPlayerOwner().Level.Game.bGameEnded)// game over
        {   // the game is over, start at last saved checkpoint
            if (myRoot.IsThereACheckpoint()) // there is a checkpoint, 
            {
                myRoot.CloseAll(true);
                myRoot.GotoState('');
                myRoot.LoadAtCheckpoint();
            }
            else
            {   // otherwise start at the beginning of the map
                myRoot.CloseAll(true);
                myRoot.GotoState('');
            }
        }
        else
        {*/
		    // return to game
			GetPlayerOwner().ResetInputs();
            myRoot.CloseAll(true);
            myRoot.GotoState('');
        //}

    }
    else if (Sender == ControlsBtn)
    {
        if (myRoot.CurrentPF > 0)
			myRoot.OpenMenu("XIDInterf.XIIIMenuInGameControlsWindow"); // consoles
        else 
			myRoot.OpenMenu("XIDInterf.XIIIMenuInputPC"); // PC
    }
    else if (Sender == CompetencesBtn) 
	{
        myRoot.OpenMenu("XIDInterf.XIIIMenuCompetencesIngame");
    }
    else if (Sender == ItemBtn) 
	{
        myRoot.OpenMenu("XIDInterf.XIIIMenuItemsIngame");
    }
    else if (Sender == RestartBtn) 
	{
		bShowBCK = false;
		myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
		MsgBox = XIIIMsgBoxInGame(myRoot.ActivePage);
		MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
		MsgBox.SetupQuestion(ConfirmRestartTxt, QBTN_Yes | QBTN_No, QBTN_No,"");
		MsgBox.OnButtonClick = RestartMsgBoxReturn;
    }
    else if (Sender == QuitBtn) 
	{
		bShowBCK = false;
		myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
		MsgBox = XIIIMsgBoxInGame(myRoot.ActivePage);
		MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
		MsgBox.SetupQuestion(ConfirmQuitTxt, QBTN_Yes | QBTN_No, QBTN_No,"");
		MsgBox.OnButtonClick = QuitMsgBoxReturn;
    }
    return true;
}


function QuitMsgBoxReturn(byte bButton)
{
	bShowBCK = true;
	if ((bButton & QBTN_Yes) != 0)
	{
		QuitGame();
	}
}

function RestartMsgBoxReturn(byte bButton)
{
	bShowBCK = true;
	if ((bButton & QBTN_Yes) != 0)
	{
		RestartGame();
	}
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
 timer=31;
 if (timer > 15)
 {
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
            return InternalOnClick(FocusedControl);

	    if (Key==0x08 || Key ==0x1B/*IK_Backspace*/)
	    {
			if (!GetPlayerOwner().Level.Game.bGameEnded)
			{
				GetPlayerOwner().ResetInputs();
				myRoot.CloseAll(true);
				myRoot.GotoState('');
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
    }
    return super.InternalOnKeyEvent(Key, state, delta);
  }
 else
	 return true;
}


function RestartGame()
{
/*    bDoRestartGame = false;
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    //GetPlayerOwner().ConsoleCommand("RestartLevel");
    myRoot.LoadAtCheckpoint(true);     // force load the checkpoint at map start
*/
    bDoRestartGame = false;
	GetPlayerOwner().ResetInputs();
	if (myRoot.IsThereACheckpoint()) // there is a checkpoint, 
	{
		myRoot.CloseAll(true);
		myRoot.GotoState('');
		myRoot.LoadAtCheckpoint();
	}
	else
	{   
		// otherwise start at the beginning of the map
		myRoot.CloseAll(true);
		myRoot.GotoState('');
	}
}


function QuitGame()
{
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    GetPlayerOwner().ClientTravel("MapMenu", TRAVEL_Absolute, false);
}




defaultproperties
{
     SaveTxt="Save game"
     ReturnTxt="Return to game"
     ControlsTxt="Controls"
     CompetencesTxt="Skills"
     ItemTxt="Items found"
     RestartTxt="Retry"
     QuitTxt="Main menu"
     ConfirmQuitTxt="All unsaved progress will be lost.|Quit game ?"
     ConfirmRestartTxt="Are you sure ?"
     bForceHelp=True
     Background=None
     bAllowedAsLast=True
}
