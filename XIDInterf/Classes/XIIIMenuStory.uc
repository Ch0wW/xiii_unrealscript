//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuStory extends XIIIWindow;


var XIIITextureButton Doc1Button, Doc2Button, Doc3Button, Doc4Button, Doc5Button, Doc6Button, Doc7Button, Doc8Button, Doc9Button, Doc10Button, Doc11Button, Doc12Button;
var XIIILabel Doc1Label, Doc2Label, Doc3Label, Doc4Label, Doc5Label, Doc6Label, Doc7Label, Doc8Label, Doc9Label, Doc10Label, Doc11Label, Doc12Label;
var  localized string TitleText, Doc1Text, Doc2Text, Doc3Text, Doc4Text, Doc5Text, Doc6Text, Doc7Text, Doc8Text, Doc9Text, Doc10Text, Doc11Text, Doc12Text;

var texture tBackGround[20], tHighlight[20], tBackPlane[8];
var string sBackGround[20], sHighlight[20], sBackPlane[8];

var  localized string Doc1LabText, Doc2LabText, Doc3LabText, Doc4LabText, Doc5LabText, Doc6LabText, Doc7LabText, Doc8LabText;



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
var int ImageNb;
var bool bPageShowNext;

event timer() //(float numb,bool bFlag)
{
  ImageNb++;

  if (NbMap < 3)
  {
	if (ImageNb > 2*NbMap+1)
		{
		ImageNb = NbMap*2+1;
		bPageShowNext=false;
		}	
  }
}


//============================================================================
function Created()
{
    local int i;

    Super.Created();

    settimer(3,true);

    for (i=0; i<8; i++)
    {
        tBackPlane[i] = texture(DynamicLoadObject(sBackPlane[i], class'Texture'));
    }

    for (i=0; i<20; i++)
    {
        tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
        //tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
    }

if (Doc1LabText != "")    
    InitLabel(Doc1Label, 20, 39*fScaleTo, 250, 30*fScaleTo, Doc1LabText);
if (Doc2LabText != "")
    InitLabel(Doc2Label, 225, 150*fScaleTo, 250, 30*fScaleTo, Doc2LabText);
if (Doc3LabText != "")
    InitLabel(Doc3Label, 365, 40*fScaleTo, 250, 30*fScaleTo, Doc3LabText);
if (Doc4LabText != "")
    InitLabel(Doc4Label, 220, 280*fScaleTo, 250, 30*fScaleTo, Doc4LabText);
if (Doc5LabText != "")
    InitLabel(Doc5Label, 355, 160*fScaleTo, 250, 30*fScaleTo, Doc5LabText);
if (Doc6LabText != "")
    InitLabel(Doc6Label, 370, 160*fScaleTo, 250, 30*fScaleTo, Doc6LabText);
if (Doc7LabText != "")
    InitLabel(Doc7Label, 20, 390*fScaleTo, 250, 30*fScaleTo, Doc7LabText);
if (Doc8LabText != "")
    InitLabel(Doc8Label, 295, 390*fScaleTo, 250, 30*fScaleTo, Doc8LabText);


    /*DrawStretchedTexture(C, 30*fRatioX, 30*fRatioY*fScaleTo, 180*fRatioX, 280*fRatioY*fScaleTo, tBackPlane[0]);
    DrawStretchedTexture(C, 220*fRatioX, 30*fRatioY*fScaleTo, 90*fRatioX, 140*fRatioY*fScaleTo, tBackPlane[1]);
    DrawStretchedTexture(C, 320*fRatioX, 30*fRatioY*fScaleTo, 290*fRatioX, 140*fRatioY*fScaleTo, tBackPlane[2]);
    DrawStretchedTexture(C, 220*fRatioX, 180*fRatioY*fScaleTo, 120*fRatioX, 130*fRatioY*fScaleTo, tBackPlane[3]);
    DrawStretchedTexture(C, 350*fRatioX, 180*fRatioY*fScaleTo, 120*fRatioX, 130*fRatioY*fScaleTo, tBackPlane[4]);
    DrawStretchedTexture(C, 480*fRatioX, 180*fRatioY*fScaleTo, 130*fRatioX, 230*fRatioY*fScaleTo, tBackPlane[5]);
    DrawStretchedTexture(C, 30*fRatioX, 320*fRatioY*fScaleTo, 250*fRatioX, 90*fRatioY*fScaleTo, tBackPlane[6]);
    DrawStretchedTexture(C, 290*fRatioX, 320*fRatioY*fScaleTo, 180*fRatioX, 90*fRatioY*fScaleTo, tBackPlane[7]);*/


}


//============================================================================
function ShowWindow()
{
    Super.ShowWindow();
    bShowBCK = true;
    bShowNXT=bPageShowNext;
}


//============================================================================
function Paint(Canvas C, float X, float Y)
{
	local float fScale, fHeight, W, H;
	local int i, j, k;

        super.paint(C,X,Y);     
	// image backrgound
	 C.bUseBorder = false;
	
	if (ImageNb <= NbMap*2+1)
	{

	switch(ImageNb)
	{
	case 0 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, myRoot.FondMenu);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, myRoot.FondMenu);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc4Label);		
	break;
	case 1 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, myRoot.FondMenu);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc4Label);		
	break;
	case 2 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, myRoot.FondMenu);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc4Label);		
	break;
	case 3 :	 
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
	break;
	case 4 :
		C.bUseBorder = true;
		ShowWindow();	 
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo, tBackPlane[4]);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo,myRoot.FondMenu);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
        	DrawLabel(C, Doc5Label);		
	break;
	case 5 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo, tBackPlane[4]);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo, tBackPlane[5]);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,myRoot.FondMenu);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
        	DrawLabel(C, Doc5Label);		
        	DrawLabel(C, Doc6Label);		
	break;
	case 6 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo, tBackPlane[4]);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo, tBackPlane[5]);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, myRoot.FondMenu);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,tBackPlane[7]);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
        	DrawLabel(C, Doc5Label);		
        	DrawLabel(C, Doc6Label);		
        	DrawLabel(C, Doc8Label);		
	break;
	case 7 :
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo, tBackPlane[4]);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo, tBackPlane[5]);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, tBackPlane[6]);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,tBackPlane[7]);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
        	DrawLabel(C, Doc5Label);		
        	DrawLabel(C, Doc6Label);		
        	DrawLabel(C, Doc7Label);		
        	DrawLabel(C, Doc8Label);		
	break;
	}
	}
	if ((ImageNb > 7) && (NbMap > 3))
		Controller.OpenMenu("XIDInterf.XIIIMenuStory2",,Description);
	if ((ImageNb > 7) && (NbMap == 3))
	{
		C.bUseBorder = true;
		ShowWindow();
	 	DrawStretchedTexture(C, 55*fRatioX, 33*fRatioY*fScaleTo, 141*fRatioX, 268*fRatioY*fScaleTo, tBackPlane[0]);
	 	DrawStretchedTexture(C, 207*fRatioX, 33*fRatioY*fScaleTo, 82*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[1]);
		DrawStretchedTexture(C, 300*fRatioX, 33*fRatioY*fScaleTo, 285*fRatioX, 145*fRatioY*fScaleTo, tBackPlane[2]);
	        DrawStretchedTexture(C, 207*fRatioX, 188*fRatioY*fScaleTo, 123*fRatioX, 113*fRatioY*fScaleTo,tBackPlane[3]);
 		DrawStretchedTexture(C, 346*fRatioX, 188*fRatioY*fScaleTo, 117*fRatioX, 113*fRatioY*fScaleTo, tBackPlane[4]);
		DrawStretchedTexture(C, 475*fRatioX, 188*fRatioY*fScaleTo, 110*fRatioX, 243*fRatioY*fScaleTo, tBackPlane[5]);
		DrawStretchedTexture(C, 55*fRatioX, 312*fRatioY*fScaleTo, 236*fRatioX, 119*fRatioY*fScaleTo, tBackPlane[6]);
		DrawStretchedTexture(C, 300*fRatioX, 312*fRatioY*fScaleTo, 163*fRatioX, 119*fRatioY*fScaleTo,tBackPlane[7]);
        	DrawLabel(C, Doc1Label);		
        	DrawLabel(C, Doc2Label);		
        	DrawLabel(C, Doc3Label);		
        	DrawLabel(C, Doc4Label);		
        	DrawLabel(C, Doc5Label);		
        	DrawLabel(C, Doc6Label);		
        	DrawLabel(C, Doc7Label);		
        	DrawLabel(C, Doc8Label);		
	}

	
	 /* Title
	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 240*fRatioX, 20*fRatioY, 160*fRatioX, 32*fRatioY, myRoot.FondMenu);
	 C.TextSize(Caps(TitleText), W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((240 + (160-W)/2)*fRatioX, (20+(32-H)/2)*fRatioY); C.DrawText(Caps(TitleText), false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;*/

}


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
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
		  ImageNb++;

		  if (NbMap < 3)
  		  {
			if (ImageNb > 2*NbMap+1)
			{
			ImageNb = NbMap*2+1;
			bPageShowNext=false;
			}	
  		  }
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
    ImageNb = 0;
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
     sHighlight(0)="XIIIMenuStart.conspi.xteteI"
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
     sHighlight(12)="XIIIMenuStart.conspi.xteteXII"
     sHighlight(13)="XIIIMenuStart.conspi.xteteXIV"
     sHighlight(14)="XIIIMenuStart.conspi.xteteXV"
     sHighlight(15)="XIIIMenuStart.conspi.xteteXVI"
     sHighlight(16)="XIIIMenuStart.conspi.teteXVII"
     sHighlight(17)="XIIIMenuStart.conspi.xteteXVIII"
     sHighlight(18)="XIIIMenuStart.conspi.xteteXIX"
     sHighlight(19)="XIIIMenuStart.conspi.xteteXX"
     sBackPlane(0)="XIIIMenuStart.storyline.storyline1image1"
     sBackPlane(1)="XIIIMenuStart.storyline.storyline1image2"
     sBackPlane(2)="XIIIMenuStart.storyline.storyline1image3"
     sBackPlane(3)="XIIIMenuStart.storyline.storyline1image4"
     sBackPlane(4)="XIIIMenuStart.storyline.storyline1image5"
     sBackPlane(5)="XIIIMenuStart.storyline.storyline1image6"
     sBackPlane(6)="XIIIMenuStart.storyline.storyline1image7"
     sBackPlane(7)="XIIIMenuStart.storyline.storyline1image8"
     bPageShowNext=True
}
