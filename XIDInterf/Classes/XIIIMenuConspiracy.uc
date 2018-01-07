//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuConspiracy extends XIIIWindow;


var XIIITextureButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button, Doc9Button, Doc10Button, Doc11Button, Doc12Button;
var XIIILabel Doc1Label, Doc2Label, Doc3Label, Doc4Label, Doc5Label, Doc6Label, Doc7Label, Doc8Label, Doc9Label, Doc10Label, Doc11Label, Doc12Label;
var  localized string TitleText, Doc1Text, Doc2Text, Doc3Text, Doc4Text, Doc5Text, Doc6Text, Doc7Text, Doc8Text, Doc9Text, Doc10Text, Doc11Text, Doc12Text;

var XIIITextureButton DocXButton[20];
var localized string ConspJobs[20];
var string tmpjobs[20];

var int dSize[20];

var texture tBackGround[20], tHighlight[20], tBackPlane[4];
var string sBackGround[20], sHighlight[20], sBackPlane[4];

var int MaxSlots;
var int ReturnCode;
var int IsEmpty;
//var int i;
var int Year;
var byte Month, Day, Hour, Min;

var string Description;

var int Time;
var int MyLastTime;
var int MyLastSlot;
var int NbMap;
var int bLocalBorder[20];

//============================================================================
function Created()
{
    local int i, j, k;

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


	for (j=0; j<4; j++)
        {
		for (i=0; i<5; i++)
    		{
	 		
				//if (tBackGround[k] != none)
				 DocXButton[k] = XIIITextureButton(CreateControl(class'XIIITextureButton', (i*77+178)*fRatioX, (j*100+44)*fRatioY, 63*fRatioX, 64*fRatioY));
			     DocXButton[k].Hint=tmpJobs[k];
			     DocXButton[k].tFirstTex[0]=tHighlight[k];
   			     DocXButton[k].tFirstTex[1]=tHighlight[k];
			     DocXButton[k].bUseBorder=true;
			     Controls[k]=DocXButton[k]; 
			k++;
						
		}
		i=0;
	}


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
	local int i, j, k, index;

	// big black border behind documents
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 170*fRatioX, 35*fRatioY, 396*fRatioX, 399*fRatioY*fScaleTo, myRoot.FondMenu);

	// image backrgound
	 C.bUseBorder = false;
	 DrawStretchedTexture(C, 170*fRatioX, 35*fRatioY*fScaleTo, 198*fRatioX, 200*fRatioY*fScaleTo, tBackPlane[0]);
	 DrawStretchedTexture(C, 368*fRatioX, 35*fRatioY*fScaleTo, 198*fRatioX, 200*fRatioY*fScaleTo, tBackPlane[1]);
	 DrawStretchedTexture(C, 170*fRatioX, 233*fRatioY*fScaleTo, 198*fRatioX, 200*fRatioY*fScaleTo, tBackPlane[2]);
	 DrawStretchedTexture(C, 368*fRatioX, 233*fRatioY*fScaleTo, 198*fRatioX, 200*fRatioY*fScaleTo, tBackPlane[3]);


	// image behind title
	//DrawStretchedTexture(C, 40*fRatioX, 36*fRatioY, 180*fRatioX, 100*fRatioY, tBackGround[0]);

	for (j=0; j<4; j++)
        {
		for (i=0; i<5; i++)
    		{
			index = FindComponentIndex(FocusedControl);
			//k=index;
			refreshConsp();
			if (bLocalBorder[k]!=0)
			 C.bUseBorder = true;
	 		if (tBackGround[k] != none)
				DrawStretchedTexture(C, (i*77+178)*fRatioX-dSize[k], (j*100+44)*fRatioY*fScaleTo-dSize[k], 63*fRatioX+2*dSize[k], 64*fRatioY*fScaleTo+2*dSize[k], tBackGround[k]);
			 C.bUseBorder = false;
			k++;			
		}
		i=0;
	}
	
	 // Title
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, -1, 140*fRatioY*fScaleTo, 140*fRatioX, 30*fRatioY*fScaleTo, myRoot.FondMenu);
	 C.TextSize(TitleText, W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((144*fRatioX-W)/2, (140*fRatioY+(24*fRatioY-H)/2)*fScaleTo); C.DrawText(TitleText, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;

        super.paint(C,X,Y);     


}

function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    Super.AfterPaint(C, X, Y);

    C.Style = 1;

}

//============================================================================
// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  return true;
}


//============================================================================
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
   local int index, i;
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
                //log("Focused Control nb"$index);
                for (i=0; i<20; i++)
                {
			if (i==index)
			     dSize[i]=10;
			else
			  dSize[i]=0;
		}
            switch (index)
	        {
	            case 0 :
                    if ( bRight ) Controls[1].FocusFirst(Self,false);
                    if ( bDown) Controls[5].FocusFirst(Self,false);
		    if ( bLeft ) Controls[4].FocusFirst(Self,false);
                    if ( bUp ) Controls[15].FocusFirst(Self,false);
                break;
	            case 1 : 
                    if ( bDown ) Controls[6].FocusFirst(Self,false);
		    if ( bLeft ) Controls[0].FocusFirst(Self,false);
                    if ( bRight ) Controls[2].FocusFirst(Self,false);
                    if ( bUp ) Controls[16].FocusFirst(Self,false);
                break;
	            case 2 : 
                    if ( bDown) Controls[7].FocusFirst(Self,false);
                    if ( bLeft ) Controls[1].FocusFirst(Self,false);
		    if ( bRight ) Controls[3].FocusFirst(Self,false);
                    if ( bUp ) Controls[17].FocusFirst(Self,false);
		break;
	            case 3 : 
                    if ( bDown) Controls[8].FocusFirst(Self,false);
                    if ( bLeft ) Controls[2].FocusFirst(Self,false);
		    if ( bRight ) Controls[4].FocusFirst(Self,false);
                    if ( bUp ) Controls[18].FocusFirst(Self,false);
                break;
	            case 4 : 
                    if ( bUp ) Controls[19].FocusFirst(Self,false);
                    if ( bLeft ) Controls[3].FocusFirst(Self,false);
		    if ( bRight ) Controls[0].FocusFirst(Self,false);
		    if ( bDown) Controls[9].FocusFirst(Self,false);
                break;
	            case 5 : 
                    if ( bUp ) Controls[0].FocusFirst(Self,false);
                    if ( bLeft ) Controls[9].FocusFirst(Self,false);
		    if ( bRight ) Controls[6].FocusFirst(Self,false);
		    if ( bDown) Controls[10].FocusFirst(Self,false);
                break;
	            case 6 : 
                    if ( bUp ) Controls[1].FocusFirst(Self,false);
                    if ( bLeft ) Controls[5].FocusFirst(Self,false);
		    if ( bRight ) Controls[7].FocusFirst(Self,false);
		    if ( bDown) Controls[11].FocusFirst(Self,false);
                break;
	            case 7 : 
                    if ( bUp ) Controls[2].FocusFirst(Self,false);
                    if ( bLeft ) Controls[6].FocusFirst(Self,false);
		    if ( bRight ) Controls[8].FocusFirst(Self,false);
		    if ( bDown) Controls[12].FocusFirst(Self,false);
                break;
	            case 8 : 
                    if ( bUp ) Controls[3].FocusFirst(Self,false);
                    if ( bLeft ) Controls[7].FocusFirst(Self,false);
		    if ( bRight ) Controls[9].FocusFirst(Self,false);
		    if ( bDown) Controls[13].FocusFirst(Self,false);
                break;
	            case 9 : 
                    if ( bUp ) Controls[4].FocusFirst(Self,false);
                    if ( bLeft ) Controls[8].FocusFirst(Self,false);
		    if ( bRight ) Controls[5].FocusFirst(Self,false);
		    if ( bDown) Controls[14].FocusFirst(Self,false);
                break;
	            case 10 : 
                    if ( bUp ) Controls[5].FocusFirst(Self,false);
                    if ( bLeft ) Controls[14].FocusFirst(Self,false);
		    if ( bRight ) Controls[11].FocusFirst(Self,false);
		    if ( bDown) Controls[15].FocusFirst(Self,false);
                break;
	            case 11 : 
                    if ( bUp ) Controls[6].FocusFirst(Self,false);
                    if ( bLeft ) Controls[10].FocusFirst(Self,false);
		    if ( bRight ) Controls[12].FocusFirst(Self,false);
		    if ( bDown) Controls[16].FocusFirst(Self,false);
                break;
	            case 12 : 
                    if ( bUp ) Controls[7].FocusFirst(Self,false);
                    if ( bLeft ) Controls[11].FocusFirst(Self,false);
		    if ( bRight ) Controls[13].FocusFirst(Self,false);
		    if ( bDown) Controls[17].FocusFirst(Self,false);
                break;
	            case 13 : 
                    if ( bUp ) Controls[8].FocusFirst(Self,false);
                    if ( bLeft ) Controls[12].FocusFirst(Self,false);
		    if ( bRight ) Controls[14].FocusFirst(Self,false);
		    if ( bDown) Controls[18].FocusFirst(Self,false);
                break;
	            case 14 : 
                    if ( bUp ) Controls[9].FocusFirst(Self,false);
                    if ( bLeft ) Controls[13].FocusFirst(Self,false);
		    if ( bRight ) Controls[10].FocusFirst(Self,false);
		    if ( bDown) Controls[19].FocusFirst(Self,false);
                break;
	            case 15 : 
                    if ( bUp ) Controls[10].FocusFirst(Self,false);
                    if ( bLeft ) Controls[19].FocusFirst(Self,false);
		    if ( bRight ) Controls[16].FocusFirst(Self,false);
		    if ( bDown) Controls[0].FocusFirst(Self,false);
                break;
	            case 16 : 
                    if ( bUp ) Controls[11].FocusFirst(Self,false);
                    if ( bLeft ) Controls[15].FocusFirst(Self,false);
		    if ( bRight ) Controls[17].FocusFirst(Self,false);
		    if ( bDown) Controls[1].FocusFirst(Self,false);
                break;
	            case 17 : 
                    if ( bUp ) Controls[12].FocusFirst(Self,false);
                    if ( bLeft ) Controls[16].FocusFirst(Self,false);
		    if ( bRight ) Controls[18].FocusFirst(Self,false);
		    if ( bDown) Controls[2].FocusFirst(Self,false);
                break;
	            case 18 : 
                    if ( bUp ) Controls[13].FocusFirst(Self,false);
                    if ( bLeft ) Controls[17].FocusFirst(Self,false);
		    if ( bRight ) Controls[19].FocusFirst(Self,false);
		    if ( bDown) Controls[3].FocusFirst(Self,false);
                break;
	            case 19 : 
                    if ( bUp ) Controls[14].FocusFirst(Self,false);
                    if ( bLeft ) Controls[18].FocusFirst(Self,false);
		    if ( bRight ) Controls[15].FocusFirst(Self,false);
		    if ( bDown) Controls[4].FocusFirst(Self,false);
                break;
			}
			return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

function refreshConsp()
{
		local int index, i;
	        index = FindComponentIndex(FocusedControl);
                //log("Focused Control nb"$index);
                for (i=0; i<20; i++)
                {
			if (i==index)
			{
			     dSize[i]=10;
			     bLocalBorder[i]=1;
			     //return i;
			}
			else
			{
			  dSize[i]=0;
			  bLocalBorder[i]=0;
			}
		}
		
}


event HandleParameters(string Param1, string Param2)
{
local int i;
    // interpret info at page load
    // how many maps have we been through
    Description = Param1;
    log("Param1="$Description);
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
	//NbMap=0;
    log("NbMap = "$NbMap);

    for (i=0; i<20; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }


    // depending on how many maps finished
    // replaced cards with mugshots

    // we have xiii at the begining	
    if (NbMap >= 0)
	{
	tmpJobs[12]=ConspJobs[12]; 
        tBackGround[12] = texture(DynamicLoadObject(sHighlight[12], class'Texture'));
	}
    // met nb 17 in map 11	
    if (NbMap >= 12) 
	{
	tmpJobs[16]=ConspJobs[16];
        tBackGround[16] = texture(DynamicLoadObject(sHighlight[16], class'Texture'));
	}
    // met nb 20 in map 13	
    if (NbMap >= 14)
	{
	tmpJobs[19]=ConspJobs[19]; 
        tBackGround[19] = texture(DynamicLoadObject(sHighlight[19], class'Texture'));
	}
    // met nb 11 in map 18	
    if (NbMap >= 19) 
	{
	tmpJobs[10]=ConspJobs[10];
        tBackGround[10] = texture(DynamicLoadObject(sHighlight[10], class'Texture'));
	}
    // met nb 7 in map 21	
    if (NbMap >= 22)
	{
	tmpJobs[6]=ConspJobs[6]; 
        tBackGround[6] = texture(DynamicLoadObject(sHighlight[6], class'Texture'));
	}

    // met nb 5 and 9 in map 24	
    if (NbMap >= 25){
	tmpJobs[4]=ConspJobs[4]; 
	tmpJobs[8]=ConspJobs[8];
        tBackGround[4] = texture(DynamicLoadObject(sHighlight[4], class'Texture'));
        tBackGround[8] = texture(DynamicLoadObject(sHighlight[8], class'Texture'));
	}

    // met nb 12 14 15 16 18 19 in map 27	
    if (NbMap >= 28){ 
	tmpJobs[11]=ConspJobs[11];
	tmpJobs[13]=ConspJobs[13];
	tmpJobs[14]=ConspJobs[14];
	tmpJobs[15]=ConspJobs[15];
	tmpJobs[17]=ConspJobs[17];
	tmpJobs[18]=ConspJobs[18];
        tBackGround[11] = texture(DynamicLoadObject(sHighlight[11], class'Texture'));
        tBackGround[13] = texture(DynamicLoadObject(sHighlight[13], class'Texture'));
        tBackGround[14] = texture(DynamicLoadObject(sHighlight[14], class'Texture'));
        tBackGround[15] = texture(DynamicLoadObject(sHighlight[15], class'Texture'));
        tBackGround[17] = texture(DynamicLoadObject(sHighlight[17], class'Texture'));
        tBackGround[18] = texture(DynamicLoadObject(sHighlight[18], class'Texture'));
	}

    // met nb 4 6 8 10 in map 28	
    if (NbMap >= 29){
	tmpJobs[3]=ConspJobs[3];
	tmpJobs[5]=ConspJobs[5];
	tmpJobs[7]=ConspJobs[7];
	tmpJobs[9]=ConspJobs[9]; 
        tBackGround[3] = texture(DynamicLoadObject(sHighlight[3], class'Texture'));
        tBackGround[5] = texture(DynamicLoadObject(sHighlight[5], class'Texture'));
        tBackGround[7] = texture(DynamicLoadObject(sHighlight[7], class'Texture'));
        tBackGround[9] = texture(DynamicLoadObject(sHighlight[9], class'Texture'));
	}



    // met nb 3 in map 30	
    if (NbMap >= 31) 
	{
	tmpJobs[2]=ConspJobs[2];
        tBackGround[2] = texture(DynamicLoadObject(sHighlight[2], class'Texture'));
	}

    // met nb 2 in map 31	
    if (NbMap >= 32) 
	{
	tmpJobs[1]=ConspJobs[1];        
	tBackGround[1] = texture(DynamicLoadObject(sHighlight[1], class'Texture'));
	}
    // met nb 1 in map 33
    // exceptionnaly we give nb 1 as soon as we open the map	
    if (NbMap >= 33)
	{
	tmpJobs[0]=tmpJobs[0];//ConspJobs[0]; 
        tBackGround[0] = texture(DynamicLoadObject(sHighlight[0], class'Texture'));
	}

    Controller.FocusedControl.LoseFocus(None);
    Controller.FocusedControl = Controls[0];    

                for (i=0; i<20; i++)
                {
			if (i==0)
			     dSize[i]=10;
			else
			  dSize[i]=0;
		}

}



//============================================================================


defaultproperties
{
     TitleText="Conspiracy"
     Doc1Text="Document1"
     Doc2Text="Document2"
     Doc3Text="Document3"
     Doc4Text="Document4"
     Doc5Text="Document5"
     Doc6Text="Document6"
     Doc7Text="Document7"
     Doc8Text="Document8"
     ConspJobs(0)="Walter Sheridan - Sénateur"
     ConspJobs(1)="Calvin Wax - conseiller spécial du président"
     ConspJobs(2)="William Standwell - Général"
     ConspJobs(3)="Philip Gillepsie - Juge"
     ConspJobs(4)="Clayton Willard  - Sénateur"
     ConspJobs(5)="Irving Allenby - Juge"
     ConspJobs(6)="Franklin Edelbright - Général"
     ConspJobs(7)="Dean Harrison - Député"
     ConspJobs(8)="Jasper Winslow - Banquier"
     ConspJobs(9)="Orville Midsummer - Press"
     ConspJobs(10)="Seymour Mac Call - Colonel"
     ConspJobs(11)="Lloyd Jennings - Conseiller à la Maison Blanche"
     ConspJobs(12)="Steve Rowland - Capitaine"
     ConspJobs(13)="Harriet Traymore - Federal Steel Corporation - PDG"
     ConspJobs(14)="Jack Dickinson - American Legion - PDG"
     ConspJobs(15)="Norman Ryder - Garde Nationale"
     ConspJobs(16)="Kim Rowland - Veuve de Steve Rowland"
     ConspJobs(17)="Edwin Rauschenberg - chaîne CBN - PDG"
     ConspJobs(18)="Elly Sheperd - Ministère de la Défense - DG"
     ConspJobs(19)="Edward W.Johansson - Plain Rock Asylum - Director"
     tmpjobs(0)="?"
     tmpjobs(1)="?"
     tmpjobs(2)="?"
     tmpjobs(3)="?"
     tmpjobs(4)="?"
     tmpjobs(5)="?"
     tmpjobs(6)="?"
     tmpjobs(7)="?"
     tmpjobs(8)="?"
     tmpjobs(9)="?"
     tmpjobs(10)="?"
     tmpjobs(11)="?"
     tmpjobs(12)="?"
     tmpjobs(13)="?"
     tmpjobs(14)="?"
     tmpjobs(15)="?"
     tmpjobs(16)="?"
     tmpjobs(17)="?"
     tmpjobs(18)="?"
     tmpjobs(19)="?"
     sBackground(0)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(1)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(2)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(3)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(4)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(5)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(6)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(7)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(8)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(9)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(10)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(11)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(12)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(13)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(14)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(15)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(16)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(17)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(18)="XIIIMenuStart.conspi.xtetegrise"
     sBackground(19)="XIIIMenuStart.conspi.xtetegrise"
     sHighlight(0)="XIIIMenuStart.conspi.xteteIfloue"
     sHighlight(1)="XIIIMenuStart.conspi.xteteII"
     sHighlight(2)="XIIIMenuStart.conspi.xteteIII"
     sHighlight(3)="XIIIMenuStart.conspi.xteteIV"
     sHighlight(4)="XIIIMenuStart.conspi.xteteV"
     sHighlight(5)="XIIIMenuStart.conspi.xteteVI"
     sHighlight(6)="XIIIMenuStart.conspi.xteteVII"
     sHighlight(7)="XIIIMenuStart.conspi.xteteVIII"
     sHighlight(8)="XIIIMenuStart.conspi.xteteIX"
     sHighlight(9)="XIIIMenuStart.conspi.xteteX"
     sHighlight(10)="XIIIMenuStart.conspi.xteteXI"
     sHighlight(11)="XIIIMenuStart.conspi.xteteXII"
     sHighlight(12)="XIIIMenuStart.conspi.xteteXIII"
     sHighlight(13)="XIIIMenuStart.conspi.xteteXIV"
     sHighlight(14)="XIIIMenuStart.conspi.xteteXV"
     sHighlight(15)="XIIIMenuStart.conspi.xteteXVI"
     sHighlight(16)="XIIIMenuStart.conspi.teteXVII"
     sHighlight(17)="XIIIMenuStart.conspi.xteteXVIII"
     sHighlight(18)="XIIIMenuStart.conspi.xteteXIX"
     sHighlight(19)="XIIIMenuStart.conspi.xteteXX"
     sBackPlane(0)="XIIIMenuStart.conspi.galerieportraits1"
     sBackPlane(1)="XIIIMenuStart.conspi.galerieportraits2"
     sBackPlane(2)="XIIIMenuStart.conspi.galerieportraits3"
     sBackPlane(3)="XIIIMenuStart.conspi.galerieportraits4"
}
