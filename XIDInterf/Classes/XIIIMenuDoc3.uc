//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuDoc3 extends XIIIWindow;


var XIIIComboControl DocumentCombo;
var localized string ObjectName[8];

var XIIITextureButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button;
var XIIILabel Doc1Label, Doc2Label, Doc3Label, Doc4Label, Doc5Label, Doc6Label, Doc7Label, Doc8Label;
var  localized string TitleText, Doc1Text, Doc2Text, Doc3Text, Doc4Text, Doc5Text, Doc6Text, Doc7Text, Doc8Text;

var texture tBackGround[11], tHighlight[11], tOnomatopee[11];
var string sBackGround[11], sHighlight[11], sOnomatopee[11];

var int texturenb;
var int MaxSlots;
var int ReturnCode;
var int IsEmpty;
var int i;
var int Year;
var byte Month, Day, Hour, Min;

var string Description, Emission, Ind, Message;

var int Time, Index;
var int MyLastTime;
var int MyLastSlot;
var int NbMap, OnGame;



//============================================================================
function Created()
{
    local int i;

    Super.Created();

   for (i=0; i<10; i++)
    {
        //tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }

    // Document Type
        DocumentCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 260, 380*fScaleTo, 340,40*fScaleTo));
    //DocumentCombo.Text = Doc1Text;
    //DocumentCombo.bSmallFont = true;
    DocumentCombo.bArrows = true;
    //DocumentCombo.bAlwaysFocus = true;
    IterateDocuments();
    Controls[0] = DocumentCombo;


}

function IterateDocuments()
{
	local int i;
	
	for (i=0;i<4;i++)
	{
		
		
		DocumentCombo.AddItem(ObjectName[i]);
		
	}

	DocumentCombo.SetSelectedIndex(0);
}

//============================================================================
function ShowWindow()
{
    Super.ShowWindow();
    bShowBCK = true;
    ////bShowSEL = true;
}


//============================================================================
function Paint(Canvas C, float X, float Y)
{
	local float fScale, fHeight, W, H;

        super.paint(C,X,Y);     

	// big black border behind documents
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 180*fRatioX, 36*fRatioY*fScaleTo, 430*fRatioX, 368*fRatioY*fScaleTo, myRoot.FondMenu);

	// document itself
	 //C.bUseBorder = true;
	// DrawStretchedTexture(C, 190*fRatioX, 46*fRatioY, 410*fRatioX, 348*fRatioY, tBackGround[texturenb]);


	// image behind title
	//DrawStretchedTexture(C, 40*fRatioX, 36*fRatioY, 130*fRatioX, 80*fRatioY, tBackGround[0]);
	C.bUseBorder = false;
	switch(texturenb)
	{
	case 0 :
	   DrawStretchedTexture(C, 190*fRatioX, 121*fRatioY*fScaleTo, 410*fRatioX, 151*fRatioY*fScaleTo, tBackGround[0]);
	break;
	case 1 :
           DrawStretchedTexture(C, 220*fRatioX, 151*fRatioY*fScaleTo, 350*fRatioX, 212*fRatioY*fScaleTo, tBackGround[1]);
	break;
	case 2 :
           DrawStretchedTexture(C, 230*fRatioX, 86*fRatioY*fScaleTo, 330*fRatioX, 268*fRatioY*fScaleTo, tBackGround[2]);
	break;
	case 3 :
	   DrawStretchedTexture(C, 190*fRatioX, 46*fRatioY*fScaleTo, 410*fRatioX, 348*fRatioY*fScaleTo, tBackGround[3]);
	   //DrawStretchedTexture(C, 395*fRatioX, 46*fRatioY*fScaleTo, 205*fRatioX, 348*fRatioY*fScaleTo, tBackGround[4]);
	break;
	case 4 :
           DrawStretchedTexture(C, 190*fRatioX, 46*fRatioY*fScaleTo, 410*fRatioX, 348*fRatioY*fScaleTo, tBackGround[4]);
	break;

	}
	
	 // Title
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 30*fRatioX, 70*fRatioY*fScaleTo, 140*fRatioX, 32*fRatioY*fScaleTo, myRoot.FondMenu);
	 C.TextSize(TitleText, W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((30*fRatioX + (140*fRatioX-W)/2), (70*fRatioY+(32*fRatioY-H)/2)*fScaleTo); C.DrawText(TitleText, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;


	// image behind object name
	C.bUseBorder = false;
	DrawStretchedTexture(C, 50*fRatioX, 196*fRatioY, 98*fRatioX, 98*fRatioY, tBackGround[9]);
	
	 // object name
	 C.bUseBorder = true;
	 C.TextSize(Doc2Text, W, H);
	 DrawStretchedTexture(C, 30*fRatioX, 280*fRatioY*fScaleTo, (W+20)*fRatioX, 32*fRatioY*fScaleTo, myRoot.FondMenu);
	 C.DrawColor = BlackColor;
	 C.SetPos((30*fRatioX + ((w+20)*fRatioX-W)/2), (280*fRatioY+(32*fRatioY-H)/2)*fScaleTo); C.DrawText(Doc2Text, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;



}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ((State==1) || (state==2))// IST_Press // to avoid auto-repeat
	{
        if ((Key==0x08/*IK_Escape*/) || (Key==0x1B))
        {
            Index = 2;
            Message = 
                "?Transmitted="$Emission$
                "?Ind="$Index;
            log("Message = "$Message);
            myRoot.CloseMenu(true,Message);
            //myRoot.OpenMenu("XIDInterf.XIIIMenuDocument",,Emission);
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
		if ((Key==0x25) || (Key==0x27))
		{
			OnMenu = FindComponentIndex(FocusedControl);
			if (OnMenu == 0)
			{
				if (Key==0x25) OnGame--;
				if (Key==0x27) OnGame++;
				if (OnGame < 0) OnGame = 0;
				else if (OnGame > 4-1) OnGame = 4-1;
				DocumentCombo.SetSelectedIndex(OnGame);
				texturenb = OnGame;
				//paint();
				//DocumentChanged(OnGame);
			}
			return true;
		}
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}


event HandleParameters(string Param1, string Param2)
{
    Description = localParseOption(Param1,"Emission","");
    log("Emission = "$Description);
    Index = int(localParseOption(Param1,"Ind",""));
    Emission=Description;

}

//============================================================================


defaultproperties
{
     ObjectName(0)="Letter"
     ObjectName(1)="Photo"
     ObjectName(2)="Photo"
     ObjectName(3)="account info"
     ObjectName(4)="tableau de chasse"
     ObjectName(5)="book"
     ObjectName(6)="fork"
     ObjectName(7)="glass"
     TitleText="Documents"
     Doc1Text="Passport"
     Doc2Text="W.H. File"
     Doc3Text="Document3"
     Doc4Text="Document4"
     Doc5Text="Document5"
     Doc6Text="Document6"
     Doc7Text="Document7"
     Doc8Text="Document8"
     sBackground(0)="XIIIMenuStart.doc.doc.lettrealerte"
     sBackground(1)="XIIIMenuStart.doc.photokkk"
     sBackground(2)="XIIIMenuStart.doc.photovideo"
     sBackground(3)="XIIIMenuStart.doc.03_lettrewhitehouse"
     sBackground(4)="XIIIMenuStart.doc.Acount3_Standwell02"
     sBackground(5)="XIIIMenuStart.doc.dollars"
     sBackground(6)="XIIIMenuStart.doc.Acount3_Standwell01"
     sBackground(7)="XIIIMenuStart.doc.Acount3_Standwell02"
     sBackground(8)="XIIIMenuStart.storygris"
     sBackground(9)="XIIIMenuStart.doc.dossierWhiteHouse"
     sHighlight(0)="XIIIMenuStart.conspiracy"
     sHighlight(1)="XIIIMenuStart.competence"
     sHighlight(2)="XIIIMenuStart.dossier"
     sHighlight(3)="XIIIMenuStart.story"
     sHighlight(4)="XIIIMenuStart.play"
     sOnomatopee(0)="XIIIMenuStart.newgameWoowoo"
     sOnomatopee(1)="XIIIMenuStart.multiplayerBam"
     sOnomatopee(2)="XIIIMenuStart.optionBrrrr"
     sOnomatopee(3)="XIIIMenuStart.loadgameSlam"
     sOnomatopee(4)="XIIIMenuStart.bang"
}
