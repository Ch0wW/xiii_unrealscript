//============================================================================
// Display the briefing
//============================================================================
class XIIIMenuBriefingWindow extends XIIIWindow;

var bool       bInitialized;
var string     OldSettings, BackText;
var float      ControlOffset;

var XIIIbutton          NextButton;
var localized string    NextGameText;

var bool      bInGame;
//var int        GoalArraySize;
//var array<UWindowCheckbox> GoalCheck;

var MapInfo    CurrentMap;
//var  XIIIRootWindow myRoot;


function Created()
{
     Super.Created();

//     myRoot = XIIIRootWindow(Root);

     NextButton = XIIIbutton(CreateControl(class'XIIIbutton', 510, 420*fScaleTo, 100, 30*fScaleTo));
     NextButton.Text = NextGameText;
     NextButton.bUseBorder = true;
}

function InitBriefingAndGoals()
{
     local int ControlOffset, ControlPos, ControlWidth, t, newGoal;
     local string temp;

     CurrentMap = XIIIGameInfo(GetPlayerOwner().Player.Actor.Level.Game).MapInfo;
/*     GoalArraySize = CurrentMap.Objectif.Length;
     log("Map: "$CurrentMap$"    nb obj: "$CurrentMap.Objectif.Length$" GoalSize: "$GoalArraySize);
//     if (GoalArraySize > 0) CtrlOffset = (100 / (GoalArraySize/2));
     ControlWidth = (WinWidth/4)*3;
     ControlPos = (WinWidth - ControlWidth)/2;
     ControlOffset = WinHeight/2 + 50;

     for (t = 0; t < GoalArraySize; t++)
     {
          if (!CurrentMap.Objectif[t].bAntiGoal)
          {
               GoalCheck[t] = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlPos, ControlOffset, ControlWidth, 1));
               GoalCheck[t].SetText(CurrentMap.Objectif[t].GoalText);

               GoalCheck[t].SetFont(F_Normal);
               GoalCheck[t].SetTextColor(BlackColor);
               GoalCheck[t].Align = TA_Left;
               ControlOffset += 40;
               newGoal++;
               log("Obj "$t$": "$GoalCheck[t].Text);//$" Primary: "$CurrentMap.Objectif[t].bPrimary);
          }
     }
     GoalArraySize = newGoal;*/
}


function ShowWindow()
{
     InitBriefingAndGoals();
//     SetGoalPosition();
     if (!bInGame){
          NextButton.Text = NextGameText;
     }
     else NextButton.Text = BackText;
     Super.ShowWindow();
     bShowRUN = true;
}

/*
function SetGoalPosition()
{
     local int ControlWidth, ControlLeft, ControlRight;
     local int CenterWidth, CenterPos, t;

     ControlWidth = WinWidth/2.5;
     ControlLeft = (WinWidth/2 - ControlWidth)/2;
     ControlRight = WinWidth/2 + ControlLeft;
     CenterWidth = (WinWidth/4)*3;
//     CenterPos = (WinWidth - CenterWidth)/2;

     for (t = 0; t < GoalArraySize; t++)
     {
          GoalCheck[t].bChecked = CurrentMap.Objectif[t].bCompleted;
          if (!CurrentMap.Objectif[t].bPrimary)
          {
               GoalCheck[t].WinLeft=96;
               GoalCheck[t].SetSize(CenterWidth-32, 1);
               GoalCheck[t].bDisabled = true;
          }
          else {
          GoalCheck[t].SetSize(CenterWidth, 1);
          GoalCheck[t].WinLeft = 64;//CenterPos;
          }
//          if (!CurrentMap.Objectif[t].bPrimary) GoalCheck[t].HideWindow();
//          else GoalCheck[t].ShowWindow();
          //else GoalCheck[t].ShowWindow();
     }
}*/


/*function BeforePaint(Canvas C, float X, float Y)
{
     local int t;

     for (t = 0; t < GoalArraySize-1; t++)
          GoalCheck[t].bChecked = CurrentMap.Objectif[t].bCompleted;

//     SetGoalPosition();
}*/


function Paint(Canvas C, float X, float Y)
{
     local string text;

     super.Paint(C, X, Y);

     DrawStretchedTexture(C, 0, 0, C.ClipX, C.ClipY, myRoot.FondMenu);

//     C.Font = myRoot.Fonts[F_Large];
     C.DrawColor = GoldColor;
     C.SetPos( 30, 50); C.DrawText(Caps("Briefing"), false);
//     C.Font = myRoot.Fonts[F_Normal];

     // MLK Printing the briefing text
    log(CurrentMap);
     if (CurrentMap != none) {
     if (CurrentMap.bBriefing)
     {
          text = CurrentMap.TexteduBriefing;
          log(Text);
     //MOD     myRoot.Printf(C, 50, 240, text);
//          C.DrawColor = BlackColor;
//          myRoot.Printf(C, text, 65, 101, WinWidth - 124);
          //if (bInGame)
          C.DrawColor = BlackColor;
          //else C.DrawColor = WhiteColor;
          if (text!="")
          myRoot.Printf(C, text, 64*fRatioX, 100*fRatioY, C.ClipX - 100);// - 128);
    }
    }

    C.DrawColor = WhiteColor;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/)|| (Key==0x1B))
	    {
//            Controller.FocusedControl.OnClick(FocusedControl);
            if (bInGame)
                myRoot.CloseMenu(true);
            else {
                myRoot.gotostate('');
                myRoot.CloseAll(true);
            }
            myRoot.bBriefingDone = true;
            myRoot.bBriefing= false;
//            return InternalOnClick(FocusedControl);
	    }
        //return false;
    }
    return super.InternalOnKeyEvent(Key, state, delta);
//    return false;
}

/*function HideWindow()
{
     local int t;

     Super.HideWindow();
     for (t=0; t<GoalCheck.Length; t++)
          GoalCheck[t].Close();
     GoalCheck.Length = 0;
} */


/*
//_____________________________________________________________
// When the briefing has been read, the player shall choose his weapons
function GotoNextWindow()
{
     if (NextWindow == none)
          NextWindow = XIIIWindow(Root.CreateWindow(class'XIIIMenuWeaponWindow',0, 0, 640, 480));
     if (NextWindow != none)
          NextWindow.ShowWindow();
     XIIIMenuWeaponWindow(NextWindow).PrevWindow = self;
     HideWindow();
}*/




defaultproperties
{
     BackText="Back"
     NextGameText="Continue"
     bForceHelp=True
}
