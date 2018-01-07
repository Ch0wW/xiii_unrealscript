//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuSkill extends XIIIWindow;


var XIIIButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button, Doc9Button, Doc10Button, Doc11Button, Doc12Button;
var XIIILabel Doc1Label, Doc2Label, Doc3Label, Doc4Label, Doc5Label, Doc6Label, Doc7Label, Doc8Label, Doc9Label, Doc10Label, Doc11Label, Doc12Label;
var  localized string TitleText, Doc1Text, Doc2Text, Doc3Text, Doc4Text, Doc5Text, Doc6Text, Doc7Text, Doc8Text, Doc9Text, Doc10Text, Doc11Text, Doc12Text,ServiceText;
var  localized string Doc1LabText, Doc2LabText, Doc3LabText, Doc4LabText, Doc5LabText, Doc6LabText, Doc7LabText, Doc8LabText;

var texture tBackGround[20], tHighlight[20], tBackPlane[4];
var string sBackGround[20], sHighlight[20], sBackPlane[4], MessageText;

var int MaxSlots;
var int ReturnCode;
var int IsEmpty;
var int i;
var int Year;
var byte Month, Day, Hour, Min;

var string Description;

var int Time;
var int MyLastTime;
var int MyLastSlot;
var int NbMap;


//============================================================================
function Created()
{
    local int i;

    Super.Created();

    for (i=0; i<4; i++)
    {
        tBackPlane[i] = texture(DynamicLoadObject(sBackPlane[i], class'Texture'));
    }

    for (i=0; i<20; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        //tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }


    Doc1Button = XIIIButton(CreateControl(class'XIIIButton', 35, 125*fScaleTo, 140, 22*fScaleTo));
    Doc1Button.Text = Doc1Text;
    Doc1Button.bUseBorder=false;

    Doc2Button = XIIIButton(CreateControl(class'XIIIButton', 35, 150*fScaleTo, 140, 22*fScaleTo));
    Doc2Button.Text = Doc2Text;
    Doc2Button.bUseBorder=false;

    Doc3Button = XIIIButton(CreateControl(class'XIIIButton', 35, 175*fScaleTo, 140, 22*fScaleTo));
    Doc3Button.Text = Doc3Text;
    Doc3Button.bUseBorder=false;

    Doc4Button = XIIIButton(CreateControl(class'XIIIButton', 35, 200*fScaleTo, 140, 22*fScaleTo));
    Doc4Button.Text = Doc4Text;
    Doc4Button.bUseBorder=false;

    Doc5Button = XIIIButton(CreateControl(class'XIIIButton', 35, 225*fScaleTo, 140, 22*fScaleTo));
    Doc5Button.Text = Doc5Text;
    Doc5Button.bUseBorder=false;

    Doc6Button = XIIIButton(CreateControl(class'XIIIButton', 35, 250*fScaleTo, 140, 22*fScaleTo));
    Doc6Button.Text = Doc6Text;
    Doc6Button.bUseBorder=false;

    Doc7Button = XIIIButton(CreateControl(class'XIIIButton', 35, 275*fScaleTo, 140, 22*fScaleTo));
    Doc7Button.Text = Doc7Text;
    Doc7Button.bUseBorder=false;

    Doc8Button = XIIIButton(CreateControl(class'XIIIButton', 35, 300*fScaleTo, 140, 22*fScaleTo));
    Doc8Button.Text = Doc8Text;
    Doc8Button.bUseBorder=false;


    Controls[0]=Doc1Button; 
    Controls[1]=Doc2Button; 
    Controls[2]=Doc3Button; 
    Controls[3]=Doc4Button; 
    Controls[4]=Doc5Button; 
    Controls[5]=Doc6Button; 
    Controls[6]=Doc7Button; 
    Controls[7]=Doc8Button; 

    InitLabel(Doc1Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc1LabText);
    InitLabel(Doc2Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc2LabText);
    InitLabel(Doc3Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc3LabText);
    InitLabel(Doc4Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc4LabText);
    InitLabel(Doc5Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc5LabText);
    InitLabel(Doc6Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc6LabText);
    InitLabel(Doc7Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc7LabText);
    InitLabel(Doc8Label, 30, 350*fScaleTo, 580, 80*fScaleTo, Doc8LabText);

sBackGround[0]=Doc1LabText;
sBackGround[1]=Doc2LabText;
sBackGround[2]=Doc3LabText;
sBackGround[3]=Doc4LabText;
sBackGround[4]=Doc5LabText;
sBackGround[5]=Doc6LabText;
sBackGround[6]=Doc7LabText;
sBackGround[7]=Doc8LabText;

}


//============================================================================
function ShowWindow()
{
    Super.ShowWindow();
    bShowBCK = true;
    //bShowSEL = true;
}


//============================================================================
function Paint(Canvas C, float X, float Y)
{
	local float fScale, fHeight, W, H;
	local int i, j, k;


	local array<string> MsgArray;
	local int v;
	local int Length;
	local int TextWith;


        super.paint(C,X,Y);     

	// big black border behind documents
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 30*fRatioX, 350*fRatioY*fscaleto, 580*fRatioX, 80*fRatioY*fscaleto, myRoot.FondMenu);

	 DrawStretchedTexture(C, 30*fRatioX, 120*fRatioY*fscaleto, 150*fRatioX, 220*fRatioY*fscaleto, myRoot.FondMenu);

	 //thin line under service record
	 DrawStretchedTexture(C, 200*fRatioX, 172*fRatioY, 410*fRatioX, 1*fRatioY, myRoot.FondMenu);


	// image backrgound
	 C.bUseBorder = false;
	 DrawStretchedTexture(C, 200*fRatioX, 35*fRatioY, 130*fRatioX, 130*fRatioY, tBackPlane[0]);
	 DrawStretchedTexture(C, 200*fRatioX, 180*fRatioY, 260*fRatioX, 140*fRatioY, tBackPlane[1]);
	 DrawStretchedTexture(C, 470*fRatioX, 180*fRatioY, 140*fRatioX, 140*fRatioY, tBackPlane[2]);

	 C.bUseBorder = false;
	 //DrawStretchedTexture(C, 400*fRatioX, 140*fRatioY, 140*fRatioX, 32*fRatioY, myRoot.FondMenu);
	 C.TextSize(Caps(ServiceText), W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((400 + (140-W)/2)*fRatioX, (140+(32-H)/2)*fRatioY); C.DrawText(Caps(ServiceText), false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;

	// image behind title
	//DrawStretchedTexture(C, 40*fRatioX, 36*fRatioY, 180*fRatioX, 100*fRatioY, tBackGround[0]);

	for (j=0; j<4; j++)
        {
		for (i=0; i<5; i++)
    		{
	 		if (tBackGround[k] != none)
				DrawStretchedTexture(C, (i*77+128)*fRatioX, (j*100+44)*fRatioY, 63*fRatioX, 64*fRatioY, tBackGround[k]);
			k++;			
		}
		i=0;
	}
	
	 // Title
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 30*fRatioX, 40*fRatioY*fScaleTo, 140*fRatioX, 32*fRatioY*fScaleTo, myRoot.FondMenu);
	 C.TextSize(TitleText, W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((30*fRatioX + (140*fRatioX-W)/2), (40*fRatioY+(32*fRatioY-H)/2)*fscaleto); C.DrawText(TitleText, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;






	// only selected control has a border
    for (i=0; i<8; i++)
        XIIIButton(Controls[i]).bUseBorder = false;    
    if (FindComponentIndex(FocusedControl)!= -1)
        XIIIButton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;

	TextWith = 540*fRatioX;
	C.DrawColor = BlackColor;
	MessageText=sBackGround[FindComponentIndex(FocusedControl)];
	C.WrapStringToArray(MessageText, MsgArray, TextWith, "|");
	//log("messagetext = "$messagetext);
	Length = MsgArray.Length;
 	if (Length > 1)
	{
		for(v=0;v<Length;v++)
		{
			C.TextSize(MsgArray[v], W, H);
			C.SetPos(50*fRatioX, 360*fRatioY*fscaleto + (H*v*fRatioY)*fscaleto);
			C.DrawText(MsgArray[v], false);
		}
	}
	else
	{
		C.TextSize(MsgArray[v], W, H);
		C.SetPos(50*fRatioX, 350*fRatioY*fscaleto + (H*fRatioY)*fscaleto);
		C.DrawText(MsgArray[v], false);

	}

	 C.DrawColor = WhiteColor;


}
/*
//============================================================================
function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;
    local int index;

    Super.AfterPaint(C, X, Y);

    C.Style = 5;

    index = FindComponentIndex(FocusedControl);
    switch (index)
	{
	case 0 :
        	DrawLabel(C, Doc1Label);		
	break;
	case 1 :
        	DrawLabel(C, Doc2Label);		
	break;
	case 2 :
        	DrawLabel(C, Doc3Label);		
	break;
	case 3 :
        	DrawLabel(C, Doc4Label);		
	break;
	case 4 :
        	DrawLabel(C, Doc5Label);		
	break;
	case 5 :
        	DrawLabel(C, Doc6Label);		
	break;
	case 6 :
        	DrawLabel(C, Doc7Label);		
	break;
	case 7 :
        	DrawLabel(C, Doc8Label);		
	break;
	}

    C.Style = 1;
}*/
//============================================================================
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
   local int index;
   local bool bLeft, bRight, bUp, bDown;
	
    if (State==1)// IST_Press // to avoid auto-repeat
    {
	    if ((Key==0x08/*IK_Escape*/) || (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	    	return true;
		log("conspiracy closed");
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
	


event HandleParameters(string Param1, string Param2)
{
    // interpret info at page load
    // how many maps have we been through
    Description = Param1;
    log("Param1="$Description);
    if (Description=="Brighton Beach 1")
		NbMap=0;
    if (Description=="Brighton Beach 2")
		NbMap=1;
    if (Description=="Winslow Bank")
		NbMap=2;
    if (Description=="FBI")
		NbMap=3;
    if (Description=="Major Jones")
		NbMap=4;
    if (Description=="Emerald Base bridge")
		NbMap=5;
    if (Description=="Emerald Base roof")
		NbMap=6;
    if (Description=="Carrington's cell")
		NbMap=7;
    if (Description=="Cable car station")
		NbMap=8;
    if (Description=="Cable car")
		NbMap=9;
    if (Description=="Kellownee Lake")
		NbMap=10;
    if (Description=="Kellownee hideout")
		NbMap=11;
    if (Description=="Plain Rock 1")
		NbMap=12;
    if (Description=="Doc Johansson")
		NbMap=13;
    if (Description=="Canyon 1")
		NbMap=14;
    if (Description=="Canyon 2")
		NbMap=15;
    if (Description=="Sewage")
		NbMap=16;
    if (Description=="SPADS camp 1")
		NbMap=17;
    if (Description=="McCall")
		NbMap=18;
    if (Description=="Submarine base")
		NbMap=19;
    if (Description=="Submarine 1")
		NbMap=20;
    if (Description=="Submarine 2")
		NbMap=21;
    if (Description=="Sabotage")
		NbMap=22;
    if (Description=="Quay 33")
		NbMap=23;
    if (Description=="Bristol Suites Hotel")
		NbMap=24;
    if (Description=="Sanctuary Garden")
		NbMap=25;
    if (Description=="Sanctuary hall")
		NbMap=26;
    if (Description=="Sanctuary crypt")
		NbMap=27;
    if (Description=="Sanctuary cliff")
		NbMap=28;
    if (Description=="SSH101a")
		NbMap=29;
    if (Description=="SSH101b")
		NbMap=30;
    if (Description=="SSH101c")
		NbMap=31;
    if (Description=="SSH102b")
		NbMap=32;
    if (Description=="Bateau01")
		NbMap=33;
    if (Description=="Bove President")
		NbMap=0;
    else
	NbMap=0;
    log("NbMap = "$NbMap);


}



//============================================================================


defaultproperties
{
     TitleText="Skills"
     Doc1Text="Stunning skill"
     Doc2Text="Sixth sense"
     Doc3Text="Silent walk"
     Doc4Text="Breathing skill"
     Doc5Text="First aid"
     Doc6Text="Dual weapon"
     Doc7Text="Lock pick"
     Doc8Text="Sniper skill"
     ServiceText="Service Record"
     Doc1LabText="I can use any object as a weapon to stun my enemies"
     Doc2LabText="I can see the danger surrounding me"
     Doc3LabText="I do not make any noise when I move slowly"
     Doc4LabText="I can hold my breath for a longer period of time"
     Doc5LabText="I get back more life when I cure myself"
     Doc6LabText="I can hold two handguns guns at once, either Beretta or Uzi"
     Doc7LabText="I can lock pick closed door, Sam Fisher style"
     Doc8LabText="My sniping hability is improved, my moves are more assured"
     sBackPlane(0)="XIIIMenuStart.conspi.skill.spadslogo"
     sBackPlane(1)="XIIIMenuStart.conspi.skill.Info"
     sBackPlane(2)="XIIIMenuStart.conspi.skill.xiiiphoto"
     sBackPlane(3)="XIIIMenuStart.conspi.galerieportraits4"
}
