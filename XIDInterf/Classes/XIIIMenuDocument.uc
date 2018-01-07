//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuDocument extends XIIIWindow;


var XIIITextureButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button, Doc9Button, Doc10Button, Doc11Button, Doc12Button;
var XIIILabel Doc1Label, Doc2Label, Doc3Label, Doc4Label, Doc5Label, Doc6Label, Doc7Label, Doc8Label, Doc9Label, Doc10Label, Doc11Label, Doc12Label;
var  localized string TitleText, Doc1Text, Doc2Text, Doc3Text, Doc4Text, Doc5Text, Doc6Text, Doc7Text, Doc8Text, Doc9Text, Doc10Text, Doc11Text, Doc12Text, NoDocText;
var  string Doc1bisText, Doc2bisText, Doc3bisText, Doc4bisText, Doc5bisText, Doc6bisText, Doc7bisText, Doc8bisText, Doc9bisText, Doc10bisText, Doc11bisText, Doc12bisText;

var texture tBackGround[12], tHighlight[12], tOnomatopee[12];
var string sBackGround[12], sHighlight[12], sOnomatopee[12];

var int MaxSlots;
var int ReturnCode;
var int IsEmpty;
var int i, Index;
var int Year;
var byte Month, Day, Hour, Min;

var string Description, Emission, Ind;

var int Time;
var int MyLastTime;
var int MyLastSlot;
var int NbMap;


//============================================================================
function Created()
{
    local int i;

    Super.Created();

    for (i=0; i<12; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }
    for (i=0; i<5; i++)
        tOnomatopee[i] = texture(DynamicLoadObject(sOnomatopee[i], class'Texture'));

    Doc1Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 138-40, 80*fScaleTo, 98, 98*fScaleTo));
    Doc1Button.tFirstTex[0]=tHighlight[0];
    Doc1Button.tFirstTex[1]=tHighlight[0];
    Doc1Button.bUseBorder=false;
    if (NbMap < 3)
    {
     Doc1Button.Hint=NoDocText;
     Doc1Button.tFirstTex[0]=tBackGround[0];
     Doc1Button.tFirstTex[1]=tBackGround[0];
    }
    else
	Doc1bisText=Doc1Text;

    Doc2Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 255-40, 80*fScaleTo, 98, 98*fScaleTo));
    Doc2Button.tFirstTex[0]=tHighlight[1];
    Doc2Button.tFirstTex[1]=tHighlight[1];
    Doc2Button.bUseBorder=false;
    if (NbMap < 4)
    {
     Doc2Button.Hint=NoDocText;
     Doc2Button.tFirstTex[0]=tBackGround[1];
     Doc2Button.tFirstTex[1]=tBackGround[1];
    }
    else
	Doc2bisText=Doc2Text;


    Doc3Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 372-40, 80*fScaleTo, 98, 98*fScaleTo));
    Doc3Button.tFirstTex[0]=tHighlight[2];
    Doc3Button.tFirstTex[1]=tHighlight[2];
    Doc3Button.bUseBorder=false;
    if (NbMap < 8)
    {
     Doc3Button.Hint=NoDocText;
     Doc3Button.tFirstTex[0]=tBackGround[2];
     Doc3Button.tFirstTex[1]=tBackGround[2];
    }
    else
	Doc3bisText=Doc3Text;



    Doc4Button = XIIITexturebutton(CreateControl(class'XIIITextureButton', 489-40, 80*fScaleTo, 98, 98*fScaleTo));
    Doc4Button.tFirstTex[0]=tHighlight[3];
    Doc4Button.tFirstTex[1]=tHighlight[3];
    Doc4Button.bUseBorder=false;
    if (NbMap < 12)
    {
     Doc4Button.Hint=NoDocText;
     Doc4Button.tFirstTex[0]=tBackGround[3];
     Doc4Button.tFirstTex[1]=tBackGround[3];
    }
    else
	Doc4bisText=Doc4Text;



    Doc5Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 138-40, 192*fScaleTo, 98, 98*fScaleTo));
    Doc5Button.tFirstTex[0]=tHighlight[4];
    Doc5Button.tFirstTex[1]=tHighlight[4];
    Doc5Button.bUseBorder=false;
    if (NbMap < 14)
    {
     Doc5Button.Hint=NoDocText;
     Doc5Button.tFirstTex[0]=tBackGround[4];
     Doc5Button.tFirstTex[1]=tBackGround[4];
    }
    else
	Doc5bisText=Doc5Text;




    Doc6Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 255-40, 192*fScaleTo, 98, 98*fScaleTo));
    Doc6Button.tFirstTex[0]=tHighlight[5];
    Doc6Button.tFirstTex[1]=tHighlight[5];
    Doc6Button.bUseBorder=false;
    if (NbMap < 18)
    {
     Doc6Button.Hint=NoDocText;
     Doc6Button.tFirstTex[0]=tBackGround[5];
     Doc6Button.tFirstTex[1]=tBackGround[5];
    }
    else
	Doc6bisText=Doc6Text;



    Doc7Button = XIIITexturebutton(CreateControl(class'XIIITextureButton', 372-40, 192*fScaleTo, 98, 98*fScaleTo));
    Doc7Button.tFirstTex[0]=tHighlight[6];
    Doc7Button.tFirstTex[1]=tHighlight[6];
    Doc7Button.bUseBorder=false;
    if (NbMap < 22)
    {
     Doc7Button.Hint=NoDocText;
     Doc7Button.tFirstTex[0]=tBackGround[6];
     Doc7Button.tFirstTex[1]=tBackGround[6];
    }
    else
	Doc7bisText=Doc7Text;



    Doc8Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 489-40, 192*fScaleTo, 98, 98*fScaleTo));
    Doc8Button.tFirstTex[0]=tHighlight[7];
    Doc8Button.tFirstTex[1]=tHighlight[7];
    Doc8Button.bUseBorder=false;
    if (NbMap < 25)
    {
     Doc8Button.Hint=NoDocText;
     Doc8Button.tFirstTex[0]=tBackGround[7];
     Doc8Button.tFirstTex[1]=tBackGround[7];
    }
    else
	Doc8bisText=Doc8Text;



    Doc9Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 138-40, 302*fScaleTo, 98, 98*fScaleTo));
    Doc9Button.tFirstTex[0]=tHighlight[8];
    Doc9Button.tFirstTex[1]=tHighlight[8];
    Doc9Button.bUseBorder=false;
    if (NbMap < 25)
    {
     Doc9Button.Hint=NoDocText;
     Doc9Button.tFirstTex[0]=tBackGround[8];
     Doc9Button.tFirstTex[1]=tBackGround[8];
    }
    else
	Doc9bisText=Doc9Text;




    Doc10Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 255-40, 302*fScaleTo, 98, 98*fScaleTo));
    Doc10Button.tFirstTex[0]=tHighlight[9];
    Doc10Button.tFirstTex[1]=tHighlight[9];
    Doc10Button.bUseBorder=false;
    if (NbMap < 30)
    {
     Doc10Button.Hint=NoDocText;
     Doc10Button.tFirstTex[0]=tBackGround[9];
     Doc10Button.tFirstTex[1]=tBackGround[9];
    }
    else
	Doc10bisText=Doc10Text;



    Doc11Button = XIIITexturebutton(CreateControl(class'XIIITextureButton', 372-40, 302*fScaleTo, 98, 98*fScaleTo));
    Doc11Button.tFirstTex[0]=tHighlight[10];
    Doc11Button.tFirstTex[1]=tHighlight[10];
    Doc11Button.bUseBorder=false;
    if (NbMap < 31)
    {
     Doc11Button.Hint=NoDocText;
     Doc11Button.tFirstTex[0]=tBackGround[10];
     Doc11Button.tFirstTex[1]=tBackGround[10];
    }
    else
	Doc11bisText=Doc11Text;


    Doc12Button = XIIITextureButton(CreateControl(class'XIIITextureButton', 489-40, 302*fScaleTo, 98, 93*fScaleTo));
    Doc12Button.tFirstTex[0]=tHighlight[11];
    Doc12Button.tFirstTex[1]=tHighlight[11];
    Doc12Button.bUseBorder=false;
    if (NbMap < 33)
    {
     Doc12Button.Hint=NoDocText;
     Doc12Button.tFirstTex[0]=tBackGround[11];
     Doc12Button.tFirstTex[1]=tBackGround[11];
    }
    else
	Doc12bisText=Doc12Text;


    Controls[0]=Doc1Button; 
    Controls[1]=Doc2Button; 
    Controls[2]=Doc3Button; 
    Controls[3]=Doc4Button; 
    Controls[4]=Doc5Button;
    Controls[5]=Doc6Button; 
    Controls[6]=Doc7Button; 
    Controls[7]=Doc8Button;
    Controls[8]=Doc9Button;
    Controls[9]=Doc10Button; 
    Controls[10]=Doc11Button; 
    Controls[11]=Doc12Button;

if (Doc1BisText != "")        
    InitLabel(Doc1Label, 116-40, 160*fScaleTo, 128, 32*fScaleTo, Doc1bisText);
if (Doc2BisText != "")
    InitLabel(Doc2Label, 233-40, 160*fScaleTo, 128, 32*fScaleTo, Doc2bisText);
if (Doc3BisText != "")
    InitLabel(Doc3Label, 350-40, 160*fScaleTo, 128, 32*fScaleTo, Doc3bisText);
if (Doc4BisText != "")
    InitLabel(Doc4Label, 467-40, 160*fScaleTo, 128, 32*fScaleTo, Doc4bisText);
if (Doc5BisText != "")
    InitLabel(Doc5Label, 116-40, 266*fScaleTo, 128, 32*fScaleTo, Doc5bisText);
if (Doc6BisText != "")
    InitLabel(Doc6Label, 233-40, 266*fScaleTo, 128, 32*fScaleTo, Doc6bisText);
if (Doc7BisText != "")
    InitLabel(Doc7Label, 350-40, 266*fScaleTo, 128, 32*fScaleTo, Doc7bisText);
if (Doc8BisText != "")
    InitLabel(Doc8Label, 467-40, 266*fScaleTo, 128, 32*fScaleTo, Doc8bisText);
if (Doc9BisText != "")
    InitLabel(Doc9Label, 116-40, 372*fScaleTo, 128, 32*fScaleTo, Doc9bisText);
if (Doc10BisText != "")
    InitLabel(Doc10Label, 233-40, 372*fScaleTo, 128, 32*fScaleTo, Doc10bisText);
if (Doc11BisText != "")
    InitLabel(Doc11Label, 350-40, 372*fScaleTo, 128, 32*fScaleTo, Doc11bisText);
if (Doc12BisText != "")
    InitLabel(Doc12Label, 467-40, 372*fScaleTo, 128, 32*fScaleTo, Doc12bisText);
}


//============================================================================
function ShowWindow()
{
    Super.ShowWindow();
    bShowBCK = true;
    bShowSEL = true;
}


//============================================================================
function Paint(Canvas C, float X, float Y)
{
	local float fScale, fHeight, W, H;

        super.paint(C,X,Y);     

	// big black border behind documents
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 80*fRatioX, 45*fRatioY, 490*fRatioX, 378*fRatioY*fScaleTo, myRoot.FondMenu);

	// image behind title
	//DrawStretchedTexture(C, 40*fRatioX, 36*fRatioY, 180*fRatioX, 100*fRatioY, tBackGround[0]);
	
	 // Title
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 40*fRatioX, 40*fRatioY*fScaleTo, 160*fRatioX, 32*fRatioY*fScaleTo, myRoot.FondMenu);
	 C.TextSize(TitleText, W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((40*fRatioX + (160*fRatioX-W)/2), (40*fRatioY+(32*fRatioY-H)/2)*fScaleTo); C.DrawText(TitleText, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;

}


//============================================================================
function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    Super.AfterPaint(C, X, Y);

    C.Style = 5;
    if (Doc1Button.bDisplayTex) {
        zoom = Doc1Button.zoom;
        DrawLabel(C, Doc1Label);
    }
    if (Doc2Button.bDisplayTex) {
        zoom = Doc2Button.zoom;
        DrawLabel(C, Doc2Label);
    }
    if (Doc3Button.bDisplayTex) {
        zoom = Doc3Button.zoom;
        DrawLabel(C, Doc3Label);
    }
    if (Doc4Button.bDisplayTex) {
        zoom = Doc4Button.zoom;
        DrawLabel(C, Doc4Label);
    }
    if (Doc5Button.bDisplayTex){
        zoom = Doc5Button.zoom;
        DrawLabel(C, Doc5Label);
    }
    if (Doc6Button.bDisplayTex) {
        zoom = Doc6Button.zoom;
        DrawLabel(C, Doc6Label);
    }
    if (Doc7Button.bDisplayTex) {
        zoom = Doc7Button.zoom;
        DrawLabel(C, Doc7Label);
    }
    if (Doc8Button.bDisplayTex){
        zoom = Doc8Button.zoom;
        DrawLabel(C, Doc8Label);
    }
    if (Doc9Button.bDisplayTex){
        zoom = Doc9Button.zoom;
        DrawLabel(C, Doc9Label);
    }
    if (Doc10Button.bDisplayTex) {
        zoom = Doc10Button.zoom;
        DrawLabel(C, Doc10Label);
    }
    if (Doc11Button.bDisplayTex) {
        zoom = Doc11Button.zoom;
        DrawLabel(C, Doc11Label);
    }
    if (Doc12Button.bDisplayTex){
        zoom = Doc12Button.zoom;
        DrawLabel(C, Doc12Label);
    }
    C.Style = 1;
}


//============================================================================
// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    
	
    if (Sender == Doc1Button)
	{
		if (NbMap>2)
		{
		Index = 0;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc1",,Description); 	
		}
	}
    if (Sender == Doc2Button)
	{
		if (NbMap>3)
		{
		Index = 1;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;

		Controller.OpenMenu("XIDInterf.XIIIMenuDoc2",,Description);
		} 	
	}
    if (Sender == Doc3Button)
	{
		if (NbMap>7)
		{
		Index = 2;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc3",,Description);
		} 	
	}
    if (Sender == Doc4Button)
	{
		if (NbMap>=12)
		{
		Index = 3;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc4",,Description); 	
		}
	}
    if (Sender == Doc5Button)
	{
		if (NbMap>=14)
		{
		Index = 4;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc5",,Description); 	
		}
	}
    if (Sender == Doc6Button)
	{
		if (NbMap>=18)
		{
		Index = 5;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc6",,Description);
		} 	
	}
    if (Sender == Doc7Button)
	{
		if (NbMap>=22)
		{
		Index = 6;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc7",,Description);
		} 	
	}
    if (Sender == Doc8Button)
	{
		if (NbMap>=25)
		{
		Index = 7;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc8",,Description); 	
		}
	}
    if (Sender == Doc9Button)
	{
		if (NbMap>=25)
		{
		Index = 8;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc9",,Description);
		} 	
	}
    if (Sender == Doc10Button)
	{
		if (NbMap>=30)
		{
		Index = 9;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc10",,Description); 	
		}
	}
    if (Sender == Doc11Button)
	{
		if (NbMap>=31)
		{
		Index = 10;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc11",,Description); 	
		}
	}
    if (Sender == Doc12Button)
	{
		if (NbMap>=33)
		{
		Index = 11;
		Description = 
				"?Emission="$Emission$
				"?Ind="$Index;
		Controller.OpenMenu("XIDInterf.XIIIMenuDoc12",,Description);
		} 	
	}
      
     return true;
}



//============================================================================
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
   local int index;
   local bool bLeft, bRight, bUp, bDown;
	
	if (State==1)// IST_Press // to avoid auto-repeat
    {

        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
//            Controller.FocusedControl.OnClick(Self);
            return InternalOnClick(FocusedControl);//true;
	    }

	    if ((Key==0x08/*IK_Escape*/) || (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	      return true;
	    }


	    bUp = (Key==0x26);
        bDown = (Key==0x28);
        bLeft = (Key==0x25);
        bRight = (Key==0x27);

        // controls are
        //   0   1
        //	   4
		//   2   3
	    if ( bUp || bDown || bLeft || bRight )
	    {
	        index = FindComponentIndex(FocusedControl);
            switch (index)
	        {
	            case 0 :
                    if ( bRight ) Controls[1].FocusFirst(Self,false);
                    if ( bDown) Controls[4].FocusFirst(Self,false);
		    if ( bLeft ) Controls[3].FocusFirst(Self,false);
                    if ( bUp ) Controls[8].FocusFirst(Self,false);
                break;
	            case 1 : 
                    if ( bDown ) Controls[5].FocusFirst(Self,false);
		    if ( bLeft ) Controls[0].FocusFirst(Self,false);
                    if ( bRight ) Controls[2].FocusFirst(Self,false);
                    if ( bUp ) Controls[9].FocusFirst(Self,false);
                break;
	            case 2 : 
                    if ( bDown) Controls[6].FocusFirst(Self,false);
                    if ( bLeft ) Controls[1].FocusFirst(Self,false);
		    if ( bRight ) Controls[3].FocusFirst(Self,false);
                    if ( bUp ) Controls[10].FocusFirst(Self,false);
		break;
	            case 3 : 
                    if ( bDown) Controls[7].FocusFirst(Self,false);
                    if ( bLeft ) Controls[2].FocusFirst(Self,false);
		    if ( bRight ) Controls[0].FocusFirst(Self,false);
                    if ( bUp ) Controls[11].FocusFirst(Self,false);
                break;
	            case 4 : 
                    if ( bUp ) Controls[0].FocusFirst(Self,false);
                    if ( bLeft ) Controls[7].FocusFirst(Self,false);
		    if ( bRight ) Controls[5].FocusFirst(Self,false);
		    if ( bDown) Controls[8].FocusFirst(Self,false);
                break;
	            case 5 : 
                    if ( bUp ) Controls[1].FocusFirst(Self,false);
                    if ( bLeft ) Controls[4].FocusFirst(Self,false);
		    if ( bRight ) Controls[6].FocusFirst(Self,false);
		    if ( bDown) Controls[9].FocusFirst(Self,false);
                break;
	            case 6 : 
                    if ( bUp ) Controls[2].FocusFirst(Self,false);
                    if ( bLeft ) Controls[5].FocusFirst(Self,false);
		    if ( bRight ) Controls[7].FocusFirst(Self,false);
		    if ( bDown) Controls[10].FocusFirst(Self,false);
                break;
	            case 7 : 
                    if ( bUp ) Controls[3].FocusFirst(Self,false);
                    if ( bLeft ) Controls[6].FocusFirst(Self,false);
		    if ( bRight ) Controls[4].FocusFirst(Self,false);
		    if ( bDown) Controls[11].FocusFirst(Self,false);
                break;
	            case 8 : 
                    if ( bUp ) Controls[4].FocusFirst(Self,false);
                    if ( bLeft ) Controls[11].FocusFirst(Self,false);
		    if ( bRight ) Controls[9].FocusFirst(Self,false);
		    if ( bDown) Controls[0].FocusFirst(Self,false);
                break;
	            case 9 : 
                    if ( bUp ) Controls[5].FocusFirst(Self,false);
                    if ( bLeft ) Controls[8].FocusFirst(Self,false);
		    if ( bRight ) Controls[10].FocusFirst(Self,false);
		    if ( bDown) Controls[1].FocusFirst(Self,false);
                break;
	            case 10 : 
                    if ( bUp ) Controls[6].FocusFirst(Self,false);
                    if ( bLeft ) Controls[9].FocusFirst(Self,false);
		    if ( bRight ) Controls[11].FocusFirst(Self,false);
		    if ( bDown) Controls[2].FocusFirst(Self,false);
                break;
	            case 11 : 
                    if ( bUp ) Controls[7].FocusFirst(Self,false);
                    if ( bLeft ) Controls[10].FocusFirst(Self,false);
		    if ( bRight ) Controls[8].FocusFirst(Self,false);
		    if ( bDown) Controls[3].FocusFirst(Self,false);
                break;
			}
			return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

event HandleParameters(string Param1, string Param2)
{
    //Description = Param1;
    Description = localParseOption(Param1,"Transmitted","");
    log("Param1="$Description);
    Index = int(localParseOption(Param1,"Ind",""));
    log("button index ="$Index);
    if (Description=="Brighton Beach 1")
		NbMap=0;
    if ((Description=="Brighton Beach 2") || (Description=="Brighton Beach 3"))
		NbMap=1;
    if ((Description=="Winslow Bank") || (Description=="Winslow Bank 2") || (Description=="Winslow Bank 3"))
		NbMap=2;
    if ((Description=="FBI") || (Description=="FBI 2") || (Description=="FBI 3"))
		NbMap=3;
    if ((Description=="Major Jones") || (Description=="Major Jones 1") || (Description=="Major Jones 2") || (Description=="Major Jones 3"))
		NbMap=4;
    if (Description=="Emerald Base bridge")
		NbMap=5;
    if (Description=="Emerald Base roof")
		NbMap=6;
    if ((Description=="Carrington's cell") || (Description=="Carrington's cell 1") || (Description=="Carrington's cell 2") || (Description=="Carrington's cell 3"))
		NbMap=7;
    if (Description=="Cable car station")
		NbMap=8;
    if ((Description=="Cable car") || (Description=="Cable car 1"))
		NbMap=9;
    if ((Description=="Kellownee Lake") || (Description=="Kellownee Lake 1"))
		NbMap=10;
    if ((Description=="Kellownee hideout") || (Description=="Kellownee hideout 1"))
		NbMap=11;
    if ((Description=="Plain Rock 1") || (Description=="Plain Rock 2") || (Description=="Plain Rock 3") || (Description=="Plain Rock 4"))
		NbMap=12;
    if ((Description=="Doc Johansson") || (Description=="Doc Johansson 1"))
		NbMap=13;
    if ((Description=="Canyon 1") || (Description=="Canyon 2") || (Description=="Canyon 3"))
		NbMap=14;
    if ((Description=="Canyon 4") || (Description=="Canyon 5") || (Description=="Canyon 6"))
		NbMap=15;
    if (Description=="Sewage")
		NbMap=16;
    if ((Description=="SPADS camp 1") || (Description=="SPADS camp 2") || (Description=="SPADS camp 3"))
		NbMap=17;
    if ((Description=="McCall") || (Description=="McCall 1"))
		NbMap=18;
    if ((Description=="Submarine base") || (Description=="Submarine base 1"))
		NbMap=19;
    if ((Description=="Submarine 1") || (Description=="Submarine 2"))
		NbMap=20;
    if ((Description=="Submarine 3") || (Description=="Submarine 4"))
		NbMap=21;
    if ((Description=="Sabotage") || (Description=="Sabotage 1"))
		NbMap=22;
    if ((Description=="Quay 33") || (Description=="Quay 33-1"))
		NbMap=23;
    if ((Description=="Bristol Suites Hotel") || (Description=="Bristol Suites Hotel 1"))
		NbMap=24;
    if ((Description=="Sanctuary garden") || (Description=="Sanctuary garden 1"))
		NbMap=25;
    if ((Description=="Sanctuary hall") || (Description=="Sanctuary hall 1"))
		NbMap=26;
    if ((Description=="Sanctuary crypt") || (Description=="Sanctuary crypt 1"))
		NbMap=27;
    if ((Description=="Sanctuary cliff") || (Description=="Sanctuary cliff 1"))
		NbMap=28;
    if ((Description=="SSH1 base admission") || (Description=="SSH1 base admission 1") || (Description=="SSH1 base admission 2"))
		NbMap=29;
    if ((Description=="SSH1 trap") || (Description=="SSH1 trap 1"))
		NbMap=30;
    if (Description=="Total Red")
		NbMap=31;
    if ((Description=="SSH1 final") || (Description=="SSH1 final 1"))
		NbMap=32;
    if (Description=="Lady Bee")
		NbMap=33;
    if (Description=="Bove President")
		NbMap=0;
    //else
    //	NbMap=0;
    log("NbMap = "$NbMap);
    Emission=Description;
    //Controls[Index].FocusFirst(Self,false);
    Controller.FocusedControl.LoseFocus(None);
    Controller.FocusedControl = Controls[Index];    
    //SetFocus(Controls[Index]);
    log("Index Focus ="$Index);


}


//============================================================================


defaultproperties
{
     TitleText="Documents"
     Doc1Text="Document1"
     Doc2Text="Document2"
     Doc3Text="Document3"
     Doc4Text="Document4"
     Doc5Text="Document5"
     Doc6Text="Document6"
     Doc7Text="Document7"
     Doc8Text="Document8"
     Doc9Text="Document9"
     Doc10Text="Document10"
     Doc11Text="Document11"
     Doc12Text="Document12"
     NoDocText="Not available yet"
     Doc1bisText="?"
     Doc2bisText="?"
     Doc3bisText="?"
     Doc4bisText="?"
     Doc5bisText="?"
     Doc6bisText="?"
     Doc7bisText="?"
     Doc8bisText="?"
     Doc9bisText="?"
     Doc10bisText="?"
     Doc11bisText="?"
     Doc12bisText="?"
     sBackground(0)="XIIIMenuStart.doc.malettegris"
     sBackground(1)="XIIIMenuStart.doc.dossierFBI1gris"
     sBackground(2)="XIIIMenuStart.doc.dossierWhiteHouseGRIS"
     sBackground(3)="XIIIMenuStart.doc.dossierXVIIGRIS"
     sBackground(4)="XIIIMenuStart.doc.dossierXXGRIS"
     sBackground(5)="XIIIMenuStart.doc.dossierPentagonGRIS"
     sBackground(6)="XIIIMenuStart.doc.dossierVIIGRIS"
     sBackground(7)="XIIIMenuStart.doc.dossierIXGRIS"
     sBackground(8)="XIIIMenuStart.doc.dossierVGRIS"
     sBackground(9)="XIIIMenuStart.doc.dossierIIIGRIS"
     sBackground(10)="XIIIMenuStart.doc.dossierIIGRIS"
     sBackground(11)="XIIIMenuStart.doc.dossierIGRIS"
     sHighlight(0)="XIIIMenuStart.doc.malette"
     sHighlight(1)="XIIIMenuStart.doc.dossierFBI1"
     sHighlight(2)="XIIIMenuStart.doc.dossierWhiteHouse"
     sHighlight(3)="XIIIMenuStart.doc.dossierXVII"
     sHighlight(4)="XIIIMenuStart.doc.dossierXX"
     sHighlight(5)="XIIIMenuStart.doc.dossierPentagon"
     sHighlight(6)="XIIIMenuStart.doc.dossierVII"
     sHighlight(7)="XIIIMenuStart.doc.dossierIX"
     sHighlight(8)="XIIIMenuStart.doc.dossierV"
     sHighlight(9)="XIIIMenuStart.doc.dossierIII"
     sHighlight(10)="XIIIMenuStart.doc.dossierII"
     sHighlight(11)="XIIIMenuStart.doc.dossierI"
     sOnomatopee(0)="XIIIMenuStart.newgameWoowoo"
     sOnomatopee(1)="XIIIMenuStart.multiplayerBam"
     sOnomatopee(2)="XIIIMenuStart.optionBrrrr"
     sOnomatopee(3)="XIIIMenuStart.loadgameSlam"
     sOnomatopee(4)="XIIIMenuStart.bang"
}
