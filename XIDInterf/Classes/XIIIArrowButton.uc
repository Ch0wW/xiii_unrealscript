//============================================================================
// A simple button with text
//============================================================================
class XIIIArrowButton extends XIIIGUIBaseButton;

VAR texture   tIconL, tIconR;
VAR bool      bLeftOrient;

function Paint(Canvas C,float X,float Y)
{
    Super.Paint(C,X,Y);
	if ( myRoot.CurrentPF==0 )
	{
		C.Style=5;
		if ( MenuState==MSAT_Focused )
			C.DrawColor = C.Static.MakeColor(255,255,255,255);
		else
			C.DrawColor = C.Static.MakeColor(255,255,255,128);
	}
	else
		C.DrawColor = C.Static.MakeColor(255,255,255);

    if (bLeftOrient)
    {
		DrawStretchedTexture(C, 0, 0, 16, 16, tIconL);
//        C.SetPos(0,0);
//        C.DrawTile( tIcon, 16, 16, tIcon.USize, 0, -tIcon.USize,  );
    }
    else 
    {
		DrawStretchedTexture(C, 0, 0, 16, 16, tIconR);
//        C.SetPos(0,0);
//        C.DrawTile( tIcon, 16, 16, 0, 0, tIcon.USize, tIcon.VSize );
    }
	C.Style=1;

}



defaultproperties
{
     tIconL=Texture'XIIIMenuStart.Control_Console.fleche_gauche'
     tIconR=Texture'XIIIMenuStart.Control_Console.fleche_droite'
}
