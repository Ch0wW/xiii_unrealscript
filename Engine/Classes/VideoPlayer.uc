//-----------------------------------------------------------
//
//-----------------------------------------------------------
class VideoPlayer extends Object
      native;

//***********************************
// Open
//-----------------------------------
// Description : Open a video file and prepare the engine to play
//               the video
//-----------------------------------
// In
//   Filename : the name of the video file to open
//              ( without extension, and without path )
//-----------------------------------
// Out
//   Return true if the file is successfully open
//-----------------------------------
native(484) static final function bool Open(string FileName);


//***********************************
// Play
//-----------------------------------
// Description : Begin to play the video
native(483) static final function Play();


//***********************************
// Stop
//-----------------------------------
// Description : Stop to play the video, and close the video player
native(482) static final function Stop();

//***********************************
// Pause
//-----------------------------------
// Description : Pause the playback of the current video
native(481) static final function Pause();

//***********************************
// Resume
//-----------------------------------
// Description : Resume the playback of the current video
native(479) static final function Resume();

//***********************************
// SetSoundVolume
//-----------------------------------
// Description : Set the volume of the video
//-----------------------------------
// In
//   SoundVolume : Specifies the new volume level from 0 (silent) to 32768
//
native(478) static final function SetSoundVolume(int SoundVolume);

//***********************************
// SetSoundTrack
//-----------------------------------
// Description : Specifies the sound track number to play
//-----------------------------------
// In
//   SoundTrack : the sound track number
//
native(477) static final function SetSoundTrack(int SoundTrack);


//***********************************
// GetStatus
//-----------------------------------
// Description : Get the status of the video player
//-----------------------------------
// Out
//   return :
//           0 : no playback, or the playback is end
//           1 : playback of the video in progress
//           2 : an error occurs during playback of the video
//
native(476) static final function int GetStatus();

defaultproperties
{
}
