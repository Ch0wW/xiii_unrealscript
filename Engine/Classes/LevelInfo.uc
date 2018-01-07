//=============================================================================
// LevelInfo contains information about the current level. There should
// be one per level and it should be actor 0. UnrealEd creates each level's
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	nativereplication;

// Textures.
#exec Texture Import File=Textures\WhiteSquareTexture.pcx COMPRESS=DXT1
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex COMPRESS=DXT1

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.

//-----------------------------------------------------------------------------
// Text info about level.

var() localized string Title;
var()           string Author;		    // Who built it.
var() int IdealPlayerCount;	// Ideal number of players for this level.
var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;		    // List of the group names which were checked when the level was last saved
//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var	bool			 bPathsRebuilt;	  // True if path network is valid
var() bool bNoEnemyAlliance;
VAR bool			 bCineFrame;	  // ::iKi:: Draw cinematics frame 16/9°
var() bool           bAllowCheat;     // Allow cheat code in retail.

var int				 ShadowMode;      // Actor shadows display mode.

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var (Audio) sound	   InitMusic;
var (Audio) INT	 InitMusicParameters[5];
struct MusicVar	{
	var () string	Name;
	var () int		Value;
	var () enum EMusicVarType
{
	SNDVarType_Int,
	SNDVarType_Bool
}Type;

};
var (Audio) Array<MusicVar> MusicVars;
var config bool bReplaceHXScripts;	//to use audio 'engine' functions instead of HX scripts...


//-----------------------------------------------------------------------------
// Miscellaneous information.
var int iLoadEngineValue;
var() float Brightness;
var() texture Screenshot;
var texture DefaultTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

// Resolution information.
struct ResInfo
{
    var INT PixelWidth;
    var INT PixelHeight;
};

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
var Actor FlashManager;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var const Pawn PawnList;  // Multiplayer pawn list for handling autoaim on clients. (WARN, not initialized in offline)

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Initial Cartoon Effect.

var() int InitialCartoonEffect;

var(Bot) int BotLevel[8];
var(Bot) int BotTeam[8];
var(Bot) int BotNumber;
var(Bot) string configMenu;

var(Difficulty) float AdjustDifficulty ;

//-----------------------------------------------------------------------------
// For automatic dynamic load referencing
// Forces some pointers to load (JOB)
var(ForcedLoading) array<texture>				ForcedTextures;
var(ForcedLoading) array<mesh>					ForcedMeshes;
var(ForcedLoading) array<staticmesh>			ForcedStaticMeshes;
var(ForcedLoading) array<class>					ForcedClasses;

var array<string> MPClassNames;
var array<string> MPMeshNames;
var array<string> MPSMeshNames;
var array<string> MPTexNames;

//-----------------------------------------------------------------------------
// Functions.

event ParseDynamicLoading(LevelInfo MyLI)
{
    local int i;

    Log("PARSING "$self$" for DYAMICLOADING");
    if ( MyLI.bLonePlayer )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject("XIII.XIIISOloMutator", class'Class'));
      return;
    }

    // Multiplayer game, add all multiplayer classes to arrays

    // Load FlashBang & Bomb
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
      class(DynamicLoadObject("XIIIMP.FlashBang", class'Class'));
    class<inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length - 1]).Static.StaticParseDynamicLoading(MyLI);
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
      class(DynamicLoadObject("XIIIMP.MPBomb", class'Class'));
    class<inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length - 1]).Static.StaticParseDynamicLoading(MyLI);
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
      class(DynamicLoadObject("XIIIMP.BerettaMulti", class'Class'));
    class<inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length - 1]).Static.StaticParseDynamicLoading(MyLI);

    // Load all defaults
    for ( i=0; i<MPClassNames.Length; i++ )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.MPClassNames[i], class'Class'));
      if ( class<inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length - 1]) != none )
        class<inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length - 1]).Static.StaticParseDynamicLoading(MyLI);
    }
    for ( i=0; i<MPMeshNames.Length; i++ )
      MyLI.ForcedMeshes[MyLI.ForcedMeshes.Length] =
        Mesh(DynamicLoadObject(default.MPMeshNames[i], class'Mesh'));
    for ( i=0; i<MPSMeshNames.Length; i++ )
      MyLI.ForcedStaticMeshes[MyLI.ForcedStaticMeshes.Length] =
        StaticMesh(DynamicLoadObject(default.MPSMeshNames[i], class'StaticMesh'));
    for ( i=0; i<MPTexNames.Length; i++ )
      MyLI.ForcedTextures[MyLI.ForcedTextures.Length] =
        texture(DynamicLoadObject(default.MPTexNames[i], class'Texture'));
}

//Audio
native(593) static final function IncAttente();
native(592) static final function DecAttente();
native(591) static final function IncAlerte();
native(590) static final function DecAlerte();
native(589) static final function IncAttaque();
native(588) static final function DecAttaque();


//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

// ***** Random cube sprite effect *****

// Initialise the random cube sprite effect. Erase all excluded region.
// MaxNbrSpr define the maximum number of sprite per cube.
// PropSprUsed define the proportion sprite initialy used. 1 = MaxNbrSpr sprites are used. 0 = no sprite are used.
// Distance define the distance up to the cubes are visible.
native simulated function InitRndCubeSpr( texture Texture, int MaxNbrSpr, float PropSprUsed, float Distance );

// Activate of deactivate the effect.
native simulated function SetRndCubeSprState( bool Activate );

// Set the sprite speed in unit per second.
// RandomSpeed set the intensity of the additionnal random speed. 0 = no random speed.
// RandomAcc set the random acceleration factor. 1 = normal.
native simulated function SetRndCubeSprSpeed( Vector Speed, float RandomSpeed, float RandomAcc );

// Set the proportion of used sprite.
// The proportion is changed smoothly. SpeedChg (0 to 1) define the fade speed.
// NbrSprFadePerLoop give the number of sprite that begin to fade each call. NbrSprFadePerLoop can be floating and lower than 1.
// The function return true is the wanted proportion is reached.
native simulated function bool ChangeRndCubeSprProp( float Proportion, float FadeSpeed, float NbrSprFadePerLoop );

// Add an excluded region. This function add a cubic region where is effect isn't visible.
// Notes : only one excluded region should be visible at a time.
//         excluded region are rounded to coordinates multiple of 512.
//         don't use too many excluded regions (less than 10 would be good).
native simulated function AddRndCubeSprExclude( Vector Min, Vector Max );

// Set the new sprite size. Default value = 5.0f.
native simulated function SetRndCubeSprSize( float NewSpriteSize, optional float NewSpriteSizeMax, optional bool IsMask );

// ***** End Random cube sprite effect *****

// Set the poison effect.
native simulated function SetPoisonEffect( bool NewState, float Delay, optional float MaxIntensity, optional color Hue );

// Set the blur effect.
native simulated function SetBlurEffect( bool NewState );

// Set the sharp effect.
native simulated function SetSharpEffect( bool NewState );

// Set the Injured effect.
native simulated function SetInjuredEffect( bool NewState, float Delay );

// Set the Viewport.
native(575) static final function SetViewport( int x, int y, int width, int height );

// Set if we should only postrender the main viewport
native(574) static final function SetOnlyPostRender( bool flag );

// Set the poison effect.
native simulated function GetAvailableRes( out array<ResInfo> ListRes );

// Move the viewport on the screen
native static final function DecalScreen(int _Axis, int _value); // axis 0 is X, axis 1 is Y

// Get the plate forme number. (0=PC, 1=PS2, 2=XBox, 3=Cube)
native simulated function int GetPlateForme();

//_____________________________________________________________________________
simulated event PreBeginPlay()
{
    local int i, NbSkins;

    Super.PreBeginPlay();

    if ( NetMode != NM_Standalone )
    {
      NbSkins = class'MeshSkinList'.default.MeshSkinListInfo.Length;
      Log("DYNAMICLOAD SkinList NbSkins="$NbSkins);
      if ( NbSkins > 0 )
      {
        for (i=0; i<NbSkins; i++)
        {
          Log("  "$i$" - "$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinReadableName@"("$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode$"|"$class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName$") CodeMesh="$class'MeshSkinList'.default.MeshSkinListInfo[i].CodeMesh);
          DynamicLoadObject(class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName, class'Mesh');
          DynamicLoadObject(class'MeshSkinList'.default.MeshSkinListInfo[i].SkinRed, class'Texture');
          DynamicLoadObject(class'MeshSkinList'.default.MeshSkinListInfo[i].SkinBlue, class'Texture');
        }
      }
    }
}

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if( NextURL=="" )
	{
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}


/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}


//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation;
}

//    MPClassNames(21)="XIIIMP.XIIIMPCoverMeGameInfo"
//    MPClassNames(47)="XIIIMP.XIIIRocketArena"
//    MPClassNames(36)="XIIIMP.RocketArenaBotController"
//    MPClassNames(48)="XIIIMP.GIPlayer"

defaultproperties
{
     TimeDilation=1.000000
     Title="Untitled"
     VisibleGroups="None"
     bHighDetailMode=True
     bNoEnemyAlliance=True
     MusicVars(0)=(Name="NbAttente")
     MusicVars(1)=(Name="NbAlerte")
     MusicVars(2)=(Name="NbAttaque")
     Brightness=1.000000
     DefaultTexture=Texture'Engine.DefaultTexture'
     WhiteSquareTexture=Texture'Engine.WhiteSquareTexture'
     //LargeVertex=Texture'Engine.LargeVertex'
     InitialCartoonEffect=-1
     MPClassNames(0)="XIIIMP.XIIIMPPlayerPawn"
     MPClassNames(1)="XIIIMP.BotPlayer"
     MPClassNames(2)="XIIIMP.HeavySoldierPlayer"
     MPClassNames(3)="XIIIMP.HunterPlayer"
     MPClassNames(4)="XIIIMP.MercenaryPlayer"
     MPClassNames(5)="XIIIMP.SniperPlayer"
     MPClassNames(6)="XIIIMP.SoldierPlayer"
     MPClassNames(9)="XIIIMP.XIIIAccessControl"
     MPClassNames(10)="XIIIMP.XIIIAdmin"
     MPClassNames(11)="XIIIMP.Bot_GI"
     MPClassNames(12)="XIIIMP.Bot_Killer1"
     MPClassNames(13)="XIIIMP.Bot_Killer2"
     MPClassNames(14)="XIIIMP.Bot_XIII"
     MPClassNames(15)="XIIIMP.XIIIMPHud"
     MPClassNames(16)="XIIIMP.XIIITeamHud"
     MPClassNames(17)="XIIIMP.XIIIBombHud"
     MPClassNames(18)="XIIIMP.XIIIMPGameInfo"
     MPClassNames(19)="XIIIMP.XIIIMPTeamGameInfo"
     MPClassNames(20)="XIIIMP.XIIIMPBombGame"
     MPClassNames(22)="XIIIMP.XIIIMPCTFGameInfo"
     MPClassNames(23)="XIIIMP.XIIIMPGameRules"
     MPClassNames(24)="XIIIMP.XIIIMPMutator"
     MPClassNames(25)="XIIIMP.MarioMutator"
     MPClassNames(26)="XIIIMP.MPBombMutator"
     MPClassNames(27)="XIIIMP.XIIIMPSniperArena"
     MPClassNames(28)="XIIIMP.XIIIMPBazookArena"
     MPClassNames(29)="XIIIMP.XIIIMPScoreBoard"
     MPClassNames(30)="XIIIMP.XIIIMPTeamScoreBoard"
     MPClassNames(31)="XIIIMP.BotController"
     MPClassNames(32)="XIIIMP.TeamBotController"
     MPClassNames(33)="XIIIMP.CTFBotController"
     MPClassNames(34)="XIIIMP.CatchableDuckBotController"
     MPClassNames(35)="XIIIMP.DuckBotController"
     MPClassNames(37)="XIIIMP.XIIIMPDuckController"
     MPClassNames(38)="XIIIMP.TheDuck"
     MPClassNames(39)="XIIIMP.TheCatchableDuck"
     MPClassNames(40)="XIIIMP.XIIIMPDuckGameInfo"
     MPClassNames(41)="XIIIMP.XIIIMPCatchableDuckGameInfo"
     MPClassNames(42)="XIIIMP.SabotageBotController"
     MPClassNames(43)="XIIIMP.XIIIMPCTFGameInfo"
     MPClassNames(44)="XIIIMP.XIIIMPCTFMutator"
     MPClassNames(45)="XIIIMP.XIIIMPCTFStorage"
     MPClassNames(46)="XIIIMP.XIIIMPSabotageStorage"
     MPClassNames(49)="XIIIMP.XIIIMPSpecialMatos"
     MPClassNames(50)="XIIIMP.HarnaisCTF"
     MPClassNames(51)="XIIIMP.BlueHarnaisCTF"
     MPClassNames(52)="XIIIMP.HarnaisCTFAttachment"
     MPClassNames(53)="XIIIMP.BlueHarnaisCTFAttachment"
     MPClassNames(54)="XIIIMP.XIIIMPTeamStorage"
     MPClassNames(55)="XIIIMP.XIIIMPTeamMutator"
     MPClassNames(56)="XIIIMP.XIIIMPDuckMutator"
     MPClassNames(57)="XIIIMP.XIIIMPCatchableDuckMutator"
     MPClassNames(58)="XIIIMP.HarnaisBomb"
     MPClassNames(59)="XIIIMP.HarnaisBombAttachment"
     MPClassNames(60)="XIIIMP.XIIIMPCTFScoreBoard"
     MPClassNames(61)="XIIIMP.XIIIMPSabotageScoreBoard"
     MPClassNames(62)="XIIIMP.XIIICTFHud"
     MPClassNames(63)="XIIIMP.XIIIBirdHud"
     MPClassNames(64)="XIIIMP.MarioArmorAndMedKitPickUp"
     MPClassNames(65)="XIIIMP.MarioHeavyWeaponPickUp"
     MPClassNames(66)="XIIIMP.MarioSmallWeaponPickUp"
     MPClassNames(67)="XIIIMP.MarioSuperBonusPickUp"
     MPClassNames(68)="XIIIMP.MarioSuperBonus"
     MPClassNames(69)="XIIIMP.Invisibility"
     MPClassNames(70)="XIIIMP.Invulnerability"
     MPClassNames(71)="XIIIMP.LoseArmor"
     MPClassNames(72)="XIIIMP.LoseLife"
     MPClassNames(73)="XIIIMP.Regeneration"
     MPClassNames(74)="XIIIMP.SuperArmor"
     MPClassNames(75)="XIIIMP.SuperBoost"
     MPClassNames(76)="XIIIMP.SuperDamage"
     MPClassNames(77)="XIIIMP.Teleport"
     MPClassNames(78)="XIIIMP.SuperDuck"
     MPClassNames(79)="XIII.FusilChasse"
     MPClassNames(80)="XIII.FGrenadB"
     MPClassNames(81)="XIII.FGrenad"
     MPMeshNames(0)="XIIIPersos.MouetSolM"
     MPMeshNames(1)="XIIIPersos.MouetteM"
     MPMeshNames(2)="XIIIPersos.DeathM"
     MPMeshNames(3)="XIIIPersos.XIIIMilitM"
     MPMeshNames(4)="XIIIPersos.CarringtonM"
     MPMeshNames(5)="XIIIPersos.DanhsuM"
     MPMeshNames(6)="XIIIPersos.GaminM"
     MPMeshNames(7)="XIIIPersos.ScandiM"
     MPMeshNames(8)="XIIIPersos.NiheiM"
     MPMeshNames(9)="XIIIPersos.FrenchyM"
     MPMeshNames(10)="XIIIPersos.Frenchy2M"
     MPMeshNames(11)="XIIIPersos.RastaM"
     MPMeshNames(12)="XIIIPersos.MangousteM"
     MPSMeshNames(0)="Meshes_communs.FlagredHarnais"
     MPSMeshNames(1)="Meshes_communs.FlagblueHarnais"
     MPSMeshNames(2)="Meshes_communs.BombHarnais"
     MPTexNames(0)="XIIIPersos.Mul_XIIIMilit_RougeTex"
     MPTexNames(1)="XIIIPersos.Mul_XIIIMilit_bleuTex"
     MPTexNames(2)="XIIIPersos.Mul_danhsu_RougeTEX"
     MPTexNames(3)="XIIIPersos.Mul_danhsu_BleuTEX"
     MPTexNames(4)="XIIIPersos.Mul_gamin_RougeTEX"
     MPTexNames(5)="XIIIPersos.Mul_gamin_BleuTEX"
     MPTexNames(6)="XIIIPersos.Mul_scandi_RougeTEX"
     MPTexNames(7)="XIIIPersos.Mul_scandi_BleuTEX"
     MPTexNames(8)="XIIIPersos.Mul_rasta_RougeTEX"
     MPTexNames(9)="XIIIPersos.Mul_rasta_BleuTEX"
     MPTexNames(10)="XIIIPersos.Mul_Carrington_rougeTEX"
     MPTexNames(11)="XIIIPersos.Mul_Carrington_bleuTEX"
     MPTexNames(12)="XIIIPersos.Mul_Frenchy_rougeTEX"
     MPTexNames(13)="XIIIPersos.Mul_Frenchy_bleuTEX"
     MPTexNames(14)="XIIIPersos.Mul_Frenchy2_rougeTEX"
     MPTexNames(15)="XIIIPersos.Mul_Frenchy2_bleuTEX"
     MPTexNames(16)="XIIIPersos.Mul_Mangouste_rougeTEX"
     MPTexNames(17)="XIIIPersos.Mul_Mangouste_bleuTEX"
     MPTexNames(18)="XIIIPersos.Mul_nihei_rougeTEX"
     MPTexNames(19)="XIIIPersos.Mul_nihei_bleuTEX"
     bWorldGeometry=True
     bAlwaysRelevant=True
     bHiddenEd=True
}
