//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class Console extends Interaction;

//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=ConsoleFont FontName="Verdana" Height=12 AntiAlias=1 CharactersPerPage=256
#exec TEXTURE IMPORT NAME=ConsoleBK FILE=..\UWindow\TEXTURES\Black.PCX COMPRESS=DXT1
#exec TEXTURE IMPORT NAME=ConsoleBdr FILE=..\UWindow\TEXTURES\White.PCX	COMPRESS=DXT1

// Constants.
const MaxHistory=16;		// # of command histroy to remember.

// Variables

var globalconfig byte ConsoleKey;			// Key used to bring up the console

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[MaxHistory]; 	// Holds the current command, and the history
var bool bTyping;							// Turn when someone is typing on the console
var bool bSkipNextKey;

//-----------------------------------------------------------------------------
// Exec functions accessible from the console and key bindings.

// Begin typing a command on the console.
exec function Type()
{
	TypedStr="";
	GotoState( 'Typing' );
}

exec function Talk()
{
	bSkipNextKey = true;
	TypedStr="Say ";
	GotoState( 'Typing' );
}

exec function TeamTalk()
{
	bSkipNextKey = true;
	TypedStr="TeamSay ";
	GotoState( 'Typing' );
}

//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

event Message( coerce string Msg, float MsgLife);

//-----------------------------------------------------------------------------
// Check for the console key.

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if( Action!=IST_Press )
		return false;
	else if( Key==ConsoleKey )
	{
		GotoState('Typing');
		return true;
	}
	else
		return false;

}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

state Typing
{
	exec function Type()
	{
		TypedStr="";
		gotoState( '' );
	}
	function bool KeyType( EInputKey Key )
	{
		if ( bSkipNextKey )
		{
			bSkipNextKey = false;
			return true;
		}
		if( Key>=0x20 && Key<0x100 && Key!=Asc("~") && Key!=Asc("`") && (Len(TypedStr) < 240) )
		{
			TypedStr = TypedStr $ Chr(Key);
			return true;
		}
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
		local int i;

		if( Key==IK_Escape )
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				HistoryCur = HistoryTop;
				return true;
			}
			else
			{
				GotoState( '' );
			}
		}
		else if( global.KeyEvent( Key, Action, Delta ) )
		{
			return true;
		}
		else if( Action != IST_Press )
		{
			return false;
		}
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
				// Print to console.
				Message( TypedStr, 6.0 );

				History[HistoryTop] = TypedStr;
				HistoryTop = (HistoryTop+1) % MaxHistory;

				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
					HistoryBot = (HistoryBot+1) % MaxHistory;

				HistoryCur = HistoryTop;

				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";

				if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","Core"), 6.0 );

				Message( "", 6.0 );
				GotoState('');
			}
			else
				GotoState('');

			return true;
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
						HistoryCur = MaxHistory-1;
				}

				TypedStr = History[HistoryCur];
			}
			return True;
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
					HistoryCur = (HistoryCur+1) % MaxHistory;

				TypedStr = History[HistoryCur];
			}

		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			return true;
		}
		return true;
	}

	function PostRender(Canvas Canvas)
	{
			local float xl,yl;
			local string OutStr;

			// Blank out a space

//			Canvas.Font	 = font'ConsoleFont';
			OutStr = "(>"@TypedStr$"_";
			Canvas.Strlen(OutStr,xl,yl);

			Canvas.SetPos(0,Canvas.ClipY-6-yl);
//			Canvas.DrawTile( texture 'ConsoleBk', Canvas.ClipX, yl+6,0,0,32,32);

			Canvas.SetPos(0,Canvas.ClipY-8-yl);
			Canvas.SetDrawColor(0,255,0);
//			Canvas.DrawTile( texture 'ConsoleBdr', Canvas.ClipX, 2,0,0,32,32);

			Canvas.SetPos(0,Canvas.ClipY-3-yl);
		    Canvas.bCenter = False;
			Canvas.DrawText( OutStr, false );
	}

	function BeginState()
	{
		bTyping = true;
		bVisible= true;
		HistoryCur = HistoryTop;
	}
	function EndState()
	{
		bTyping = false;
		bVisible = false;
	}
}

defaultproperties
{
     ConsoleKey=113
     HistoryBot=-1
     bRequiresTick=True
}
