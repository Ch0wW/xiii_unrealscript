//-----------------------------------------------
//	XIIIWindowMainMenu used for menu music
//-----------------------------------------------
class XIIIWindowMainMenu extends XIIIWindow;


var sound hSoundOptionsMenu;
var sound hSoundNewGame;
var sound hSoundQuitGame;
var sound hSoundLoadMenu;
var sound menuzik;
var sound hSoundMenu1;
var sound hSoundMenu2;

var int MusicValue;


//============================================================================
function InternalOnOpen()
{
	GetPlayerOwner().PlayMenu(hSoundMenu1);
}


//============================================================================
State ReinitMusic
{
Begin:
	if ( myRoot.bMusicPlay ) 
	{
		// start the music
		MusicValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MusicSliderPos") );
		if ( MusicValue != 0 )
			MusicValue = 2;
		GetPlayerOwner().StopMusic();
		GetPlayerOwner().SetMusicSliderPos(MusicValue);
		GetPlayerOwner().PlayMusic(menuzik);
		GetPlayerOwner().PlayMenu(hSoundMenu2);
	}
	else
	{
		GetPlayerOwner().PlayMenu(hSoundMenu1);
	}

	myRoot.bMusicPlay = false;
	GotoState('');
}


//--------------------------------------------------


defaultproperties
{
     hSoundOptionsMenu=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hOption'
     hSoundNewGame=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hNewGame'
     hSoundQuitGame=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hQuiting'
     hSoundLoadMenu=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hLoad'
     menuzik=Sound'XIIIsound.Music__MapMenu.MapMenu__hMusicInit'
}
