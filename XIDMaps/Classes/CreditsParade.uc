class CreditsParade extends Info
	hidecategories(Advanced,Collision,Display,LightColor,Lighting,MOvement,Object,RollOff,Sound)
	placeable;

VAR()			Array<string>	Lines;
VAR()			Sound			BeginSound;
VAR()			Sound			BeginMusic;
VAR()			Sound			EndSound;
VAR()			Sound			EndMusic;

VAR				Array<float>	LineHeights, LineWidths;
VAR				Array<int>		LineCodes;
VAR				bool			bSentEndMessage;
VAR				CreditsManager	CM;
VAR TRANSIENT	XIIIBaseHUD		HUD;
VAR TRANSIENT	Canvas			Canvas;
VAR TRANSIENT	float			YStart;
VAR TRANSIENT	M16Pick			pi;
//VAR TRANSIENT	float			LargeFontHeight, BigFontHeight, MedFontHeight, SmallFontHeight;			
//VAR TRANSIENT	float			MyYL, Highest;

// 0 -  Default text ( BigFont - Blanc )
// 1 - Titre ( LargeFont - Jaune )

FUNCTION Init(Canvas MyCanvas, XIIIBaseHUD MyHUD)
{
	LOCAL int i, code;
	LOCAL float f, DefaultHeight;
	Canvas=MyCanvas;
	HUD=MyHUD;

	LineHeights.Insert( 0, Lines.Length );
	LineWidths.Insert( 0, Lines.Length );
	LineCodes.Insert( 0, Lines.Length );
	
	Canvas.Font = HUD.BigFont;
	Canvas.TextSize("W", f, DefaultHeight);

	for (i=0; i<Lines.Length; i++)
	{
		//log ( "ASC( Lines["@i@"] ) ="@ASC( Lines[i] ) );
		if ( Lines[i]!="" )
		{
			if ( ASC( Lines[i] )==35 )
			{
				code = ASC( Mid(Lines[i], 1,1) )-48;
				Lines[i] = Mid( Lines[i], 2);
				SelectFont( code );
				LineCodes[i] = code;
			}
			else
			{
				Canvas.Font = HUD.BigFont;
			}
			if ( InStr(caps(Lines[i]),"UTEZ")!=-1 )
			{
				SelectFont(5);
				LineCodes[i]=5;
			}
			Canvas.TextSize( Lines[i], LineWidths[i], LineHeights[i]);
		}
		else
		{
			LineHeights[i] = DefaultHeight;
		}

	}
	YStart = Canvas.ClipY ;
	GotoState('');
}

FUNCTION Start()
{
	SetTimer( 0.03, true );
	if ( BeginSound!=none )
		CM.PlaySound( BeginSound );
	if ( BeginMusic!=none )
		CM.PlayMusic( BeginMusic );
}

EVENT Timer( )
{
	YStart-=1.5;
}

FUNCTION SelectFont( int code )
{
	switch ( code )
	{
//	case 9: // 1 - Title ( Huge Yellow )
//		Canvas.Font = HUD.BigFont;
//		break;
	case 3: // 1 - Title ( Huge Yellow )
		Canvas.Font = HUD.MedFont;
		break;
	case 1: // 1 - Title ( Huge Yellow )
		Canvas.Font = HUD.LargeFont;
		break;
	case 0: // 0 - Normal ( Big White )
	default:
		Canvas.Font = HUD.BigFont;
	}
}

FUNCTION DisplayCredits(Canvas MyCanvas)
{
	LOCAL float X, X0, Y, W, H, a;
	LOCAL int i, j;
	LOCAL string C;
	LOCAL VECTOR v;


	Y = YStart;
	for ( i=0;i<Lines.Length && Y<Canvas.ClipY;i++)
	{
		if ( Y> -LineHeights[i] )
		{
			X = Canvas.ClipX*0.67-0.5*LineWidths[i];
			SelectFont( LineCodes[i] );
			a=clamp( 255*(2-(abs(Y-(Canvas.ClipY*0.5))/Canvas.ClipY*4))  ,0,255);
			switch ( LineCodes[i] )
			{
			case 7: // Water
				Canvas.Style = ERenderStyle.STY_Alpha;
				Canvas.SetDrawColor(224,224,255,64);
				Canvas.SetPos( X+1.5*cos(10*Level.TimeSeconds), Y+9 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(224,224,255,96);
				Canvas.SetPos( X+1.0*cos(10*Level.TimeSeconds+1.5), Y+6 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(224,224,255,128);
				Canvas.SetPos( X+0.5*cos(10*Level.TimeSeconds+3.0), Y+3 );
				Canvas.DrawText( Lines[i], false);
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;

			case 8:
				Canvas.Style = ERenderStyle.STY_Alpha;
				Canvas.SetDrawColor(255,255,255,128);
				Canvas.SetPos( X+3*cos(3*Level.TimeSeconds), Y+2*sin(5*Level.TimeSeconds) );
//				Canvas.DrawColor.A = 128;
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,255,255,128);
				Canvas.SetPos( X-2.5*cos(1+Level.TimeSeconds), Y-1.5*sin(7-7*Level.TimeSeconds) );
				Canvas.DrawText( Lines[i], false);
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;

			case 9: // Fire
				Canvas.Style = ERenderStyle.STY_Alpha;
				Canvas.SetDrawColor(255,64,0,0.45*a);
				Canvas.SetPos( X+1.5*cos(10*Level.TimeSeconds), Y-6 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,192,0,0.5*a);
				Canvas.SetPos( X+1.0*cos(10*Level.TimeSeconds+1.5), Y-4 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,255,0,0.63*a);
				Canvas.SetPos( X+0.5*cos(10*Level.TimeSeconds+3.0), Y-2 );
				Canvas.DrawText( Lines[i], false);
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255,a);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;
			case 0: // Outline noir
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(0,0,0,a);
				Canvas.SetPos( X+1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X-1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y+1 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y-1 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,255,255,a);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;
			case 10 :
				v = X*vect(1,0,0)+Y*vect(0,1,0)+vect(0,0,1);
//				Log ( HUD.XIIIPlayerOwner.MyInteraction.WorldToScreen( v ) );
				v = -HUD.XIIIPlayerOwner.MyInteraction.ScreenToWorld( v );
				v-=Location;
				v*=40;
				Log ( v );
				v = Location + v.Y*vector(Rotation)+vect( 0,0,-1 )*v.Z;
				if ( pi==none )
				{
					pi = Spawn( class'M16Pick',,,v);
					if ( pi!=none)
					{
						pi.SetDrawScale(0.0004);
						pi.SetCollision( false, false, false );
						pi.bCollideWorld=false;
					}

				}
				else
					pi.SetLocation( v );
				break;
			case 6: // Shadow rouge
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,0,0);
				Canvas.SetPos( X+2, Y+2 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,255,255);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;

			case 11: // Pong 
				X+=0.5*(Canvas.ClipX*0.4-LineWidths[i])*sin(Level.TimeSeconds);
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;
			case 5: // Sinus
				X0 = X;
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255,a);
				for ( j=0; j<len(Lines[i]); j++ )
				{
					C = Mid(Lines[i],j,1);
					Canvas.TextSize( C, W, H );
					Canvas.SetPos( X, Y+2*sin(X-X0+7*Level.TimeSeconds) );
					Canvas.DrawText( C, false);
					X+=W;
				}
//				X+=0.5*(Canvas.ClipX*0.5-LineWidths[i])*sin(Level.TimeSeconds);
				break;
			case 1: // 1 - Title ( Huge Yellow )
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(64,40,16,a);
				Canvas.SetPos( X+1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X-1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y+1 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y-1 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetDrawColor(255,160,64, a);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;
			case 2: // 1 - SubTitle ( Big Blue )
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(24,16,64,a);
				Canvas.SetPos( X+1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X-1, Y );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y+1 );
				Canvas.DrawText( Lines[i], false);
				Canvas.SetPos( X, Y-1 );
				Canvas.DrawText( Lines[i], false);
//				Canvas.SetDrawColor(112,112,240,a);
				Canvas.SetDrawColor(152,152,216,a);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
				break;
			case 3: // 3 - Medium Font white
			case 0: // 0 - Normal ( Big White )
			default:
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255,255,255, a);
				Canvas.SetPos( X, Y );
				Canvas.DrawText( Lines[i], false);
			}
		}
		Y += LineHeights[i];
	}
	if ( !bSentEndMessage && i==Lines.Length && Y<0.80*Canvas.ClipY )
	{
		bSentEndMessage =true;
		CM.ShowNextParade();
	}
	if ( i==Lines.Length && Y<0 )
	{
		CM.StopParade( );
		if ( EndSound!=none )
			CM.PlaySound( EndSound );
		if ( EndMusic!=none )
			CM.PlayMusic( EndMusic );
		Destroy();
	}
}



defaultproperties
{
     Texture=Texture'Engine.Proj_Icon'
     bDirectional=True
}
