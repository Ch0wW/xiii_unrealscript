class XIIILiveWindow extends XIIIWindow;

var XIIILiveMsgBox msgbox;
var XboxLiveManager xboxlive;
var texture tBackGround[6];
var string sBackground[6];

var bool bCheckNetworkCable;
var bool bPopupHasBeenUp;

var localized string pleaseWaitString, networkcableDisconnectedString, networkTroubleShoot, doubleLoginString;

var color LightGrey;

var texture inviteReceivedIcon, friendRequestReceivedIcon;
var bool showLiveIcons;

function InternalOnOpen()
{
  Log("Live Timer set");
  SetTimer(0.1, true);
}

function Created()
{
  local int i;
  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';
  Super.Created();
  OnReOpen = InternalOnOpen;
  InternalOnOpen();
  for (i=0; i<6; i++)
    tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

  bCheckNetworkCable=true;
  bForceHelp=true;
  bPopupHasBeenUp = false;
}


function Paint(Canvas C, float X, float Y)
{
  local float alphavalue, yPosInviteIcon;

  Super.Paint(C, X, Y);

  if (!showLiveIcons)
    return;


  alphavalue      = abs(sin(GetPlayerOwner().Level.TimeSeconds*4.0))*255.0;
  yPosInviteIcon = 55.0;


  if (xboxlive.HasInvite())
  {
    // render an invite icon
    if (XIIIPlayerController(GetPlayerOwner()) != none && XIIIPlayerController(GetPlayerOwner()).Player.Actor.Level.Game.IsA('XIIIMPTeamGameInfo') == false)
      C.SetPos( 50.0*fRatioX + 5, yPosInviteIcon);
    else
      C.SetPos(50.0*fRatioX + 5, /*(245.0 - 35.0)*/ yPosInviteIcon);

    C.DrawColor = WhiteColor;
    C.DrawColor.A = alphavalue;

    C.Style = 5; // ERenderStyle.STY_Alpha;
    C.DrawTile(inviteReceivedIcon, inviteReceivedIcon.USize, inviteReceivedIcon.VSize, 0, 0, inviteReceivedIcon.USize, inviteReceivedIcon.VSize);
    C.Style = 1; // ERenderStyle.STY_Normal;
  }
  else if (xboxlive.HasFriendRequest())
  {
    // render a friend request icon
    if (XIIIPlayerController(GetPlayerOwner()).Player.Actor.Level.Game.IsA('XIIIMPTeamGameInfo') == false)
      C.SetPos( 50.0*fRatioX + 5, yPosInviteIcon);
    else
      C.SetPos(50.0*fRatioX + 5, yPosInviteIcon);

    C.DrawColor = WhiteColor;
    C.DrawColor.A = alphavalue;
    C.Style = 5; // ERenderStyle.STY_Alpha;
    C.DrawTile(friendRequestReceivedIcon, friendRequestReceivedIcon.USize, friendRequestReceivedIcon.VSize, 0, 0, friendRequestReceivedIcon.USize, friendRequestReceivedIcon.VSize);
    C.Style = 1; // ERenderStyle.STY_Normal;
  }

}



function PaintStandardBackground(Canvas C, float X, float Y, string TitleText)
{
     local float W, H, W2;
     local float fScale,fHeight;
     C.DrawColor = WhiteColor;
     C.Style = 5;
     fHeight = (373 / 320) * 5 * 64 * fScaleTo / 2; // (sum_back.height/sum_tex.height) * tex_height
     DrawStretchedTexture(C, 255*fRatioX, 56*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[2]);
     DrawStretchedTexture(C, 255*fRatioX, (56+fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[3]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+2*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[4]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+3*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[5]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+4*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[6]);
     DrawStretchedTexture(C, 41*fRatioX, 68*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[0]);
     DrawStretchedTexture(C, 41*fRatioX, (68+180*fScaleTo)*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[1]);
     C.Style = 1;
     if (TitleText != "")
     {
       C.bUseBorder = true;
       C.TextSize(TitleText, W, H);
       W2 = W+20;
       if (W2<80)
         W2 = 80;
       DrawStretchedTexture(C, 310*fRatioX- ((W2)*fRatioX*0.5) /*250*fRatioX*/, 40*fRatioY, (W2)*fRatioX, 40*fRatioY, myRoot.FondMenu);
       C.DrawColor = BlackColor;
       C.SetPos( 310*fRatioX- ((W+5)*fRatioX*0.5) /*(250 + 5)*fRatioX*/, (60-H/2)*fRatioY); C.DrawText(TitleText, false);
       C.bUseBorder = false;
       C.DrawColor = WhiteColor;
     }
}

// The super hack routine of doom just to get SOME kind of working header...
function PaintStandardBackground3(Canvas C, float X, float Y, string TitleText1, string TitleText2, string TitleText3, int focus)
{
     local float W, H, w1, h1, w2, h2, w3, h3;
     local float fScale,fHeight;
     local string str, s1, s2, s3;

     if (TitleText1 == "")
       str = TitleText1 $ "   " $ TitleText2 $ " - " $ TitleText3;
     else
       str = TitleText1 $ " - " $ TitleText2 $ " - " $ TitleText3;

     C.DrawColor = WhiteColor;
     C.Style = 5;
     fHeight = (373 / 320) * 5 * 64 * fScaleTo / 2; // (sum_back.height/sum_tex.height) * tex_height
     DrawStretchedTexture(C, 255*fRatioX, 56*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[2]);
     DrawStretchedTexture(C, 255*fRatioX, (56+fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[3]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+2*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[4]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+3*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[5]);
     //DrawStretchedTexture(C, 255*fRatioX, (56+4*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[6]);
     DrawStretchedTexture(C, 41*fRatioX, 68*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[0]);
     DrawStretchedTexture(C, 41*fRatioX, (68+180*fScaleTo)*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[1]);
     C.Style = 1;
    C.bUseBorder = true;

    //C.TextSize(TitleText, W, H);
    C.TextSize(str, W, H);
    DrawStretchedTexture(C, 320*fRatioX- ((W+20)*fRatioX*0.5), 40*fRatioY, (W+20)*fRatioX, 40*fRatioY, myRoot.FondMenu);

    if (focus == 1)
    {
      C.DrawColor = BlackColor;
      if (TitleText1 == "")
        s1 = TitleText1 $ "   ";
      else
        s1 = TitleText1 $ " - ";
    }
    else
    {
      C.DrawColor = LightGrey;
      s1 = TitleText1;
    }

    C.TextSize(s1, w1, h1);
    C.SetPos((320 + 5)*fRatioX - ((W+20)*fRatioX*0.5), (60-H/2)*fRatioY); C.DrawText(s1, false);

    if (focus == 2)
    {
      C.DrawColor = BlackColor;
      if (TitleText1 == "")
        s2 = "   " $ TitleText2 $ " - ";
      else
        s2 = " - " $ TitleText2 $ " - ";
    }
    else if (focus == 1)
    {
      C.DrawColor = LightGrey;
      s2 = TitleText2 $ " - ";
    }
    else if (focus == 3)
    {
      C.DrawColor = LightGrey;
      if (TitleText1 == "")
        s2 = "   " $ TitleText2;
      else
        s2 = " - " $ TitleText2;
    }

    C.TextSize(s2, w2, h2);
    C.SetPos((320 + 5)*fRatioX - ((W+20)*fRatioX*0.5)+w1, (60-H/2)*fRatioY); C.DrawText(s2, false);

    if (focus == 3)
    {
      C.DrawColor = BlackColor;
      s3 = " - " $ TitleText3;
    }
    else
    {
      C.DrawColor = LightGrey;
      s3 = TitleText3;
    }
    C.TextSize(s3, w3, h3);
    C.SetPos((320 + 5)*fRatioX - ((W+20)*fRatioX*0.5)+w1+w2, (60-H/2)*fRatioY); C.DrawText(s3, false);



    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
}

function ShowErrorBox(string errorText, optional string captionText)
{
  Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
  msgbox = XIIILiveMsgBox(myRoot.ActivePage);
  msgbox.SetupQuestion(errorText, QBTN_Ok, QBTN_Ok, captionText);
  //msgbox.OnButtonClick=MsgBoxClicked;
  msgbox.InitBox(160, 130, 16, 16, 320, 230);
}

function MsgBoxClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      // Test here if we are ingame
      if (xboxlive.IsIngame())
      { // ingame
  	    while (XIIIMenuInGameXboxLive(myRoot.ActivePage)==none && myRoot.ActivePage!=none)
  	      myRoot.CloseMenu(true);
  	    if (myRoot.ActivePage != none)
          XIIIMenuInGameXboxLive(myRoot.ActivePage).bDoQuitGame = true;
        xboxlive.ResetVoiceNet();
        xboxlive.ShutdownAndCleanup();
      }
      else
      { // menusystem
        xboxlive.ShutdownAndCleanup();
  	    while (XIIIMenuLiveAccountWindow(myRoot.ActivePage)==none && myRoot.ActivePage!=none)
  	      myRoot.CloseMenu(true);
        myRoot.CloseMenu(true);
      }
    break;
  }
}

function MsgBoxClickedTroubleshooting(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
        xboxlive.RebootToDashboard(xboxlive.dashboardPage.DASHBOARD_NETWORK_CONFIG);
        myRoot.CloseMenu(true);
/*
        xboxlive.ShutdownAndCleanup();
  	    while (XIIIMenuLiveAccountWindow(myRoot.ActivePage)==none)
  	      myRoot.CloseMenu(true);
        myRoot.CloseMenu(true);
        */
    break;

    case QBTN_Cancel:
      //myRoot.CloseMenu(true);
    break;
  }
}

function Timer()
{
  if (XIIILiveMsgBox(myRoot.ActivePage)==none && myRoot.ActivePage == self)
  {
     if (xboxlive != none && !xboxlive.IsNetCableIn() && !bPopupHasBeenUp)
     {
       bPopupHasBeenUp = true;
       if (bCheckNetworkCable)
       {
         KillTimer();
         Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
         msgbox = XIIILiveMsgBox(myRoot.ActivePage);
         msgbox.SetupQuestion(networkcableDisconnectedString, QBTN_Ok, QBTN_Ok);
         msgbox.OnButtonClick=MsgBoxClicked;
         msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
       }
       else
       {
         KillTimer();
         Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
         msgbox = XIIILiveMsgBox(myRoot.ActivePage);
         msgbox.SetupQuestion(networkTroubleShoot, QBTN_Ok | QBTN_Cancel, QBTN_Cancel);
         msgbox.OnButtonClick=MsgBoxClickedTroubleshooting;
         msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
       }
     }

     if (xboxlive != none && xboxlive.IsLoggedInTwice() && !bPopupHasBeenUp)
     {
       bPopupHasBeenUp = true;
       KillTimer();
       Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
       msgbox = XIIILiveMsgBox(myRoot.ActivePage);
       msgbox.SetupQuestion(doubleLoginString, QBTN_Ok, QBTN_Ok);
       msgbox.OnButtonClick=MsgBoxClicked;
       msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
     }
  }
}


