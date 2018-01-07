//============================================================================
// Competences light ingame menu.
//
//============================================================================
class XIIIMenuCompetencesIngame extends XIIIWindow;

var localized string TitleText, DualWeaponText, BreathText, FirstAidText, SixSenseText, SniperText, StunningText, PickLockText, SilentWalkText;
var XIIITextureButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button, Doc9Button, Doc10Button, Doc11Button, Doc12Button;
var texture ValidatedTex;
var  localized string Doc1LabText, Doc2LabText, Doc3LabText, Doc4LabText, Doc5LabText, Doc6LabText, Doc7LabText, Doc8LabText;

var texture tBackGround[20], tHighlight[20], tBackPlane[4], ArrowText;
var string sBackGround[20], sHighlight[20], sBackPlane[4], MessageText, NoSKill;


function Created()
{
    local int i;

    Super.Created();

    bShowBCK = true;
    bShowSEL = true;


    for (i=0; i<4; i++)
    {
        tBackPlane[i] = texture(DynamicLoadObject(sBackPlane[i], class'Texture'));
    }

    for (i=0; i<20; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        //tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }


    Doc1Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 65*fScaleTo, 20, 20*fScaleTo));
    Doc1Button.bUseBorder=false;

    Doc2Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 105*fScaleTo, 20, 20*fScaleTo));
    Doc2Button.bUseBorder=false;

    Doc3Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 145*fScaleTo, 20, 20*fScaleTo));
    Doc3Button.bUseBorder=false;

    Doc4Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 185*fScaleTo, 20, 20*fScaleTo));
    Doc4Button.bUseBorder=false;

    Doc5Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 225*fScaleTo, 20, 20*fScaleTo));
    Doc5Button.bUseBorder=false;

    Doc6Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 265*fScaleTo, 20, 20*fScaleTo));
    Doc6Button.bUseBorder=false;

    Doc7Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 305*fScaleTo, 20, 20*fScaleTo));
    Doc7Button.bUseBorder=false;

    Doc8Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 230, 345*fScaleTo, 20, 20*fScaleTo));
    Doc8Button.bUseBorder=false;



    Doc1Button.tFirstTex[0]=myRoot.FondMenu;
    Doc1Button.tFirstTex[1]=ArrowText;

    Doc2Button.tFirstTex[0]=myRoot.FondMenu;
    Doc2Button.tFirstTex[1]=ArrowText;

    Doc3Button.tFirstTex[0]=myRoot.FondMenu;
    Doc3Button.tFirstTex[1]=ArrowText;

    Doc4Button.tFirstTex[0]=myRoot.FondMenu;
    Doc4Button.tFirstTex[1]=ArrowText;
    Doc5Button.tFirstTex[0]=myRoot.FondMenu;
    Doc5Button.tFirstTex[1]=ArrowText;

    Doc6Button.tFirstTex[0]=myRoot.FondMenu;
    Doc6Button.tFirstTex[1]=ArrowText;
    Doc7Button.tFirstTex[0]=myRoot.FondMenu;
    Doc7Button.tFirstTex[1]=ArrowText;

    Doc8Button.tFirstTex[0]=myRoot.FondMenu;
    Doc8Button.tFirstTex[1]=ArrowText;

    Controls[0]=Doc1Button; 
    Controls[1]=Doc2Button; 
    Controls[2]=Doc3Button; 
    Controls[3]=Doc4Button; 
    Controls[4]=Doc5Button; 
    Controls[5]=Doc6Button; 
    Controls[6]=Doc7Button; 
    Controls[7]=Doc8Button; 


}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i, index;

   local mapinfo Currentmap;

   local string MessageText;
   local array<string> MsgArray;
   local int v;
   local int Length;
   local int TextWith;


    index = FindComponentIndex(FocusedControl);


    Super.Paint(C,X,Y);

    // background
    if (myRoot.GetLevel().bCineFrame)
	{
	    C.Style = 5;
		C.DrawColor = BlackColor;
		C.DrawColor.A = 192;
	    DrawStretchedTexture(C, 0, 0, WinWidth*C.ClipX, WinHeight*C.ClipY, myRoot.FondMenu);
		C.Style = 1;
	}

		C.DrawMsgboxBackground(false, 120*fRatioX, 50*fRatioY*fScaleTo, 10, 10, 420*fRatioX, 390*fRatioY*fScaleTo);



   /* // main design
    if (!myRoot.GetLevel().bCineFrame)
	{
		C.DrawMsgboxBackground(false, 120*fRatioX, 50*fRatioY*fScaleTo, 10, 10, 420*fRatioX, 350*fRatioY*fScaleTo);
	}
    else
    {
		C.DrawMsgboxBackground(false, 0.09*C.ClipX*fRatioX, 0.2*C.ClipY*fRatioY*fScaleTo, 10, 10, 0.82*C.ClipX*fRatioX, 0.6*C.ClipY*fRatioY*fScaleTo);
    }*/


    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(TitleText, W, H);
    DrawStretchedTexture(C, 80*fRatioX, 110*fRatioY*fScaleTo, W+40*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    //C.SetPos(100*fRatioX-W/40, (130*fScaleTo*fRatioY)-H/2);
    C.SetPos(80*fRatioX+(40*fRatioX)/2, (110*fRatioY+(40*fRatioY-H)/2)*fScaleTo);
    C.DrawText(TitleText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;



// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(SilentWalkText, W, H);
    //DrawStretchedTexture(C, 320, 80*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (75*fScaleTo*fRatioY)-H/2);
    C.DrawText(SilentWalkText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;


// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(DualWeaponText, W, H);
    //DrawStretchedTexture(C, 320, 120*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (115*fScaleTo*fRatioY)-H/2);
    C.DrawText(DualWeaponText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;


// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(BreathText, W, H);
    //DrawStretchedTexture(C, 320, 160*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (155*fScaleTo*fRatioY)-H/2);
    C.DrawText(BreathText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(FirstAidText, W, H);
    //DrawStretchedTexture(C, 320, 200*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (195*fScaleTo*fRatioY)-H/2);
    C.DrawText(FirstAidText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(SixSenseText, W, H);
    //DrawStretchedTexture(C, 320, 240*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (235*fScaleTo*fRatioY)-H/2);
    C.DrawText(SixSenseText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(SniperText, W, H);
    //DrawStretchedTexture(C, 320, 280*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (275*fScaleTo*fRatioY)-H/2);
    C.DrawText(SniperText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(StunningText, W, H);
    //DrawStretchedTexture(C, 320, 320*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (315*fScaleTo*fRatioY)-H/2);
    C.DrawText(StunningText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

// skill title
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
    C.TextSize(PickLockText, W, H);
    //DrawStretchedTexture(C, 320, 360*fScaleTo*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(300*fRatioX, (355*fScaleTo*fRatioY)-H/2);
    C.DrawText(PickLockText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

   CurrentMap = XIIIGameInfo(GetPlayerOwner().Player.Actor.Level.Game).MapInfo;

   if ( CurrentMap.XIIIPawn.FindInventoryKind('SilentWalkSkill') != none )
   {
    C.bUseBorder = true;
    if (index==0)
      MessageText=Doc1LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 65*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==0)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 65*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

   if ( CurrentMap.XIIIPawn.FindInventoryKind('DualWeaponSkill') != none )
   {
    C.bUseBorder = true;
    if (index==1)
    MessageText=Doc2LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 105*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==1)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 105*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

   if ( CurrentMap.XIIIPawn.FindInventoryKind('BreathSkill') != none )
   {
    C.bUseBorder = true;
    if (index==2)
     MessageText=Doc3LabText; 
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 145*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==2)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 145*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

   if ( CurrentMap.XIIIPawn.FindInventoryKind('FirstAidSkill') != none )
   {
    C.bUseBorder = true;
    if (index==3)
    MessageText=Doc4LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 185*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==3)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 185*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

   if ( CurrentMap.XIIIPawn.FindInventoryKind('SixSenseSkill') != none )
   {
    C.bUseBorder = true;
    if (index==4)
    MessageText=Doc5LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 225*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==4)
      MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 225*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

   if ( CurrentMap.XIIIPawn.FindInventoryKind('SniperSkill') != none )
   {
    C.bUseBorder = true;
    if (index==5)
    MessageText=Doc6LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 265*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==5)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 265*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }


   
   if ( CurrentMap.XIIIPawn.FindInventoryKind('StunningSkill') != none )
   {
    C.bUseBorder = true;
    if (index==6)
    MessageText=Doc7LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 305*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==6)
	MessageText=NoSkill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 305*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }


   if ( CurrentMap.XIIIPawn.FindInventoryKind('PickLockSkill') != none )
   {
    C.bUseBorder = true;
    if (index==7)
    MessageText=Doc8LabText;
    C.DrawColor = BlackColor;
    DrawStretchedTexture(C, 260*fRatioX, 345*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, ValidatedTex);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }
   else
   {
    C.bUseBorder = true;
    if (index==7)
      MessageText=NoSKill;
    C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 260*fRatioX, 345*fScaleTo*fRatioY, 20*fRatioX, 20*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
   }

	TextWith = 400*fRatioX;
        C.Font = font'XIIIFonts.XIIIConsoleFont';
	C.DrawColor = BlackColor;
	C.WrapStringToArray(MessageText, MsgArray, TextWith, "|");
	Length = MsgArray.Length;
 	if (Length > 1)
	{
		for(v=0;v<Length;v++)
		{
			C.TextSize(MsgArray[v], W, H);
			C.SetPos(130*fRatioX, 380*fRatioY*fScaleTo + (H*v*fRatioY)*fScaleTo);
			C.DrawText(MsgArray[v], false);
		}
	}
	else
	{
		if (MessageText!="?")
		{
		C.TextSize(MsgArray[v], W, H);
		C.SetPos(130*fRatioX, 390*fRatioY*fScaleTo + (H*fRatioY)*fScaleTo);
		C.DrawText(MsgArray[v], false);
		}
		else
		{
		C.TextSize(MsgArray[v], W, H);
		C.SetPos(320*fRatioX, 390*fRatioY*fScaleTo + (H*fRatioY)*fScaleTo);
		C.DrawText(MsgArray[v], false);
		}

	}          
	C.DrawColor = WhiteColor;


}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
   local int index;
   local bool bLeft, bRight, bUp, bDown;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
	        myRoot.CloseMenu(true);
            return true;
	    }
	    else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	bUp = (Key==0x26);
        bDown = (Key==0x28);
        bLeft = (Key==0x25);
        bRight = (Key==0x27);
	    if ( bUp || bDown || bLeft || bRight )
	    {
	        index = FindComponentIndex(FocusedControl);
            switch (index)
	        {
	            case 0 :
                    if ( bDown) Controls[1].FocusFirst(Self,false);
                    if ( bUp ) Controls[7].FocusFirst(Self,false);
                break;
	            case 1 : 
                    if ( bDown ) Controls[2].FocusFirst(Self,false);
                    if ( bUp ) Controls[0].FocusFirst(Self,false);
                break;
	            case 2 : 
                    if ( bDown) Controls[3].FocusFirst(Self,false);
                    if ( bUp ) Controls[1].FocusFirst(Self,false);
		break;
	            case 3 : 
                    if ( bDown) Controls[4].FocusFirst(Self,false);
                    if ( bUp ) Controls[2].FocusFirst(Self,false);
                break;
	            case 4 : 
                    if ( bUp ) Controls[3].FocusFirst(Self,false);
		    if ( bDown) Controls[5].FocusFirst(Self,false);
                break;
	            case 5 : 
                    if ( bUp ) Controls[4].FocusFirst(Self,false);
		    if ( bDown) Controls[6].FocusFirst(Self,false);
                break;
	            case 6 : 
                    if ( bUp ) Controls[5].FocusFirst(Self,false);
		    if ( bDown) Controls[7].FocusFirst(Self,false);
                break;
	            case 7 : 
                    if ( bUp ) Controls[6].FocusFirst(Self,false);
		    if ( bDown) Controls[0].FocusFirst(Self,false);
                break;
			}
			return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



defaultproperties
{
     TitleText="Skills"
     DualWeaponText="Dual Weapon Skill"
     BreathText="Breathing Skill"
     FirstAidText="First Aid SKill"
     SixSenseText="Sixth Sense Skill"
     SniperText="Sniper Skill"
     StunningText="Stunning SKill"
     PickLockText="Lockpicking SKill"
     SilentWalkText="Silent Walk Skill"
     ValidatedTex=Texture'XIIIMenu.HUD.Valid'
     Doc1LabText="You remember your gift for stealth. From now on, you'll make 50% less noise when you move around."
     Doc2LabText="Remember… You used to be able to shoot 2 handguns at once, using ALTERNATING fire."
     Doc3LabText="You just remembered your records for holding your breath. From now on, you can stay twice as long underwater."
     Doc4LabText="You recall your healing powers. All at once, MEDIKITs have double the effect on you."
     Doc5LabText="There should go the English description of the sixth sense skill"
     Doc6LabText="You got back your powers of concentration. From now on, you can stabilize your fire when sniping at an enemy."
     Doc7LabText="You remember how to deliver a forearm blow: Move discreetly towards an enemy, then press ACTION to knock him out."
     Doc8LabText="You remember your skill. Once again, you can open doors twice as fast."
     ArrowText=Texture'XIIIMenuStart.Control_Console.fleche_droite'
     NoSKill="?"
     bForceHelp=True
     Background=None
}
