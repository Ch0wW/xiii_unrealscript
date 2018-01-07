// This class is the front-end to access the xboxlive capabilities buried inside the engine.

class XboxLiveManager extends Object
	native
    transient;


struct FRIEND_PACKET
{
  //var string  name;
  var int     onlineStatusFlags;
  var BYTE    onlineStatus;
  var BYTE    voiceStatus;
  var bool    isOnline;
};

enum eVoiceMask
{
  //VOICE_Normal,
  VOICE_Anonymous,
  VOICE_WalkieTalkie,
  VOICE_RobotAngel,
  VOICE_Boogieman,
  VOICE_RobotLord1,
  VOICE_RobotLord2,
  VOICE_WhisperingDonald,
  VOICE_GenderBender,
  VOICE_RobotChild1,
  VOICE_RobotChild2,
  VOICE_WhisperChild,
  VOICE_NoHomers,
  VOICE_Android,
  VOICE_Robot,
  VOICE_Custom,
};

enum dashboardPage
{
  DASHBOARD_ACCOUNT_CREATION,
  DASHBOARD_ACCOUNT_MANAGEMENT,
  DASHBOARD_NETWORK_CONFIG,
  DASHBOARD_MESSAGES,
};

enum eGameType
{
  GT_DM,
  GT_TeamDM,
  GT_CTF,
  GT_Sabotage,
  GT_Duel,
  GT_Ladder,
  GT_Invalid,
};

enum eLanguage
{
  LANG_All,
  LANG_EnglishOnly,
  LANG_FrenchOnly,
  LANG_GermanOnly,
  LANG_SpanishOnly,
  LANG_SwedishOnly,
  LANG_DutchOnly,
  LANG_ItalianOnly,
  LANG_Invalid,
};

enum eSkill
{
  SKILL_All,
  SKILL_Beginner,
  SKILL_BelowAverage,
  SKILL_Average,
  SKILL_AboveAverage,
  SKILL_Skilled,
  SKILL_Pro,
  SKILL_Elite,
};

enum ePasscodeSymbol
{
  PS_DPAD_UP,
  PS_DPAD_DOWN,
  PS_DPAD_LEFT,
  PS_DPAD_RIGHT,
  PS_GAMEPAD_X,
  PS_GAMEPAD_Y,
  PS_GAMEPAD_LEFT_TRIGGER,
  PS_GAMEPAD_RIGHT_TRIGGER,
};

enum XBL_MESSAGES
{
	XBLE_NONE,
	XBLE_UNEXPECTED,
	//general messages
	XBLE_OVERFLOW,
	XBLE_NO_SESSION,
	XBLE_USER_NOT_LOGGED_ON,
	XBLE_NO_GUEST_ACCESS,
	XBLE_NOT_INITIALIZED,
	XBLE_NO_USER,
	XBLE_INTERNAL_ERROR,
	XBLE_OUT_OF_MEMORY,
	XBLE_TASK_BUSY,
	XBLE_SERVER_ERROR,
	XBLE_IO_ERROR,
	XBLE_BAD_CONTENT_TYPE,
	XBLE_USER_NOT_PRESENT,
	XBLE_PROTOCOL_MISMATCH,
	XBLE_INVALID_SERVICE_ID,
	XBLE_INVALID_REQUEST,
	//logon messages
	XBLE_LOGON_NO_NETWORK_CONNECTION,
	XBLE_LOGON_CANNOT_ACCESS_SERVICE,
	XBLE_LOGON_UPDATE_REQUIRED,
	XBLE_LOGON_SERVERS_TOO_BUSY,
	XBLE_LOGON_CONNECTION_LOST,
	XBLE_LOGON_KICKED_BY_DUPLICATE_LOGON,
	XBLE_LOGON_INVALID_USER,
	XBLE_SILENT_LOGON_DISABLED,
	XBLE_SILENT_LOGON_NO_ACCOUNTS,
	XBLE_SILENT_LOGON_PASSCODE_REQUIRED,
	XBLE_LOGON_SERVICE_NOT_REQUESTED,
	XBLE_LOGON_SERVICE_NOT_AUTHORIZED,
	XBLE_LOGON_SERVICE_TEMPORARILY_UNAVAILABLE,
	XBLE_LOGON_USER_HAS_MESSAGE,
	XBLE_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT,
	XBLE_LOGON_MU_NOT_MOUNTED,
	XBLE_LOGON_MU_IO_ERROR,
  XBLE_LOGON_CHANGE_USER_FAILED,
	XBLE_LOGON_NOT_LOGGED_ON,
	//notification messages
	XBLE_NOTIFICATION_BAD_CONTENT_TYPE,
	XBLE_NOTIFICATION_INVALID_MESSAGE_TYPE,
	XBLE_NOTIFICATION_NO_ADDRESS,
	XBLE_NOTIFICATION_INVALID_PUID,
	XBLE_NOTIFICATION_NO_CONNECTION,
	XBLE_NOTIFICATION_SEND_FAILED,
	XBLE_NOTIFICATION_RECV_FAILED,
	XBLE_NOTIFICATION_MESSAGE_TRUNCATED,
	XBLE_NOTIFICATION_SERVER_BUSY,
	XBLE_NOTIFICATION_LIST_FULL,
	XBLE_NOTIFICATION_BLOCKED,
	XBLE_NOTIFICATION_FRIEND_PENDING,
	XBLE_NOTIFICATION_FLUSH_TICKETS,
	XBLE_NOTIFICATION_TOO_MANY_REQUESTS,
	XBLE_NOTIFICATION_USER_ALREADY_EXISTS,
	XBLE_NOTIFICATION_USER_NOT_FOUND,
	XBLE_NOTIFICATION_OTHER_LIST_FULL,
	XBLE_NOTIFICATION_SELF,
	XBLE_NOTIFICATION_SAME_TITLE,
	XBLE_NOTIFICATION_NO_TASK,
	//match messages
	XBLE_MATCH_INVALID_SESSION_ID,
	XBLE_MATCH_INVALID_TITLE_ID,
	XBLE_MATCH_INVALID_DATA_TYPE,
	XBLE_MATCH_REQUEST_TOO_SMALL,
	XBLE_MATCH_REQUEST_TRUNCATED,
	XBLE_MATCH_INVALID_SEARCH_REQ,
	XBLE_MATCH_INVALID_OFFSET,
	XBLE_MATCH_INVALID_ATTR_TYPE,
	XBLE_MATCH_INVALID_VERSION,
	XBLE_MATCH_OVERFLOW,
	XBLE_MATCH_INVALID_RESULT_COL,
	XBLE_MATCH_INVALID_STRING,
	XBLE_MATCH_STRING_TOO_LONG,
	XBLE_MATCH_BLOB_TOO_LONG,
	XBLE_MATCH_INVALID_ATTRIBUTE_ID,
	XBLE_MATCH_SESSION_ALREADY_EXISTS,
	XBLE_MATCH_CRITICAL_DB_ERR,
	XBLE_MATCH_NOT_ENOUGH_COLUMNS,
	XBLE_MATCH_PERMISSION_DENIED,
	XBLE_MATCH_INVALID_PART_SCHEME,
	XBLE_MATCH_INVALID_PARAM,
	XBLE_MATCH_DATA_TYPE_MISMATCH,
	XBLE_MATCH_SERVER_ERROR,
	XBLE_MATCH_NO_USERS,
	XBLE_MATCH_INVALID_BLOB,
	//offering messages
	XBLE_OFFERING_NEW_CONTENT,
	XBLE_OFFERING_NO_NEW_CONTENT,
	XBLE_OFFERING_BAD_REQUEST,
	XBLE_OFFERING_INVALID_USER,
	XBLE_OFFERING_INVALID_OFFER_ID,
	XBLE_OFFERING_INELIGIBLE_FOR_OFFER,
	XBLE_OFFERING_OFFER_EXPIRED,
	XBLE_OFFERING_SERVICE_UNREACHABLE,
	XBLE_OFFERING_PURCHASE_BLOCKED,
	XBLE_OFFERING_PURCHASE_DENIED,
	XBLE_OFFERING_BILLING_SERVER_ERROR,
	XBLE_OFFERING_OFFER_NOT_CANCELABLE,
	XBLE_OFFERING_NOTHING_TO_CANCEL,
	XBLE_OFFERING_ALREADY_OWN_MAX,
	XBLE_OFFERING_NO_CHARGE,
	XBLE_OFFERING_PERMISSION_DENIED,
	XBLE_OFFERING_NAME_TAKEN,
	//offering/billing messages
	XBLE_BILLING_AUTHORIZATION_FAILED,
	XBLE_BILLING_CREDIT_CARD_EXPIRED,
	XBLE_BILLING_NON_ACTIVE_ACCOUNT,
	XBLE_BILLING_INVALID_PAYMENT_INSTRUMENT_STATUS,
	//i have no idea messages
	XBLE_UODB_KEY_ALREADY_EXISTS,
	XBLE_MSGSVR_INVALID_REQUEST,
	XBLE_FEEDBACK_NULL_TARGET,
	XBLE_FEEDBACK_BAD_TYPE,
	XBLE_FEEDBACK_CANNOT_LOG,
	//stat messages
	XBLE_STAT_BAD_REQUEST,
	XBLE_STAT_INVALID_TITLE_OR_LEADERBOARD,
	XBLE_STAT_TOO_MANY_SPECS,
	XBLE_STAT_TOO_MANY_STATS,
	XBLE_STAT_USER_NOT_FOUND,
	XBLE_STAT_SET_FAILED_0,
	XBLE_STAT_PERMISSION_DENIED,
	XBLE_STAT_LEADERBOARD_WAS_RESET,
	XBLE_STAT_INVALID_ATTACHMENT,
	XBLE_STAT_CAN_UPLOAD_ATTACHMENT,
	//damned if I know
	XBLE_STORAGE_INVALID_REQUEST,
	XBLE_STORAGE_ACCESS_DENIED,
	XBLE_STORAGE_FILE_IS_TOO_BIG,
	XBLE_STORAGE_FILE_NOT_FOUND,
	XBLE_STORAGE_INVALID_ACCESS_TOKEN,
	XBLE_STORAGE_CANNOT_FIND_PATH,
	XBLE_STORAGE_FILE_IS_ELSEWHERE,
	XBLE_STORAGE_INVALID_STORAGE_PATH,
	XBLE_STORAGE_INVALID_FACILITY,
	XBLE_STORAGE_UNKNOWN_DOMAIN,
	XBLE_STORAGE_SYNC_TIME_SKEW,
	XBLE_STORAGE_SYNC_TIME_SKEW_LOCALTIME,
	XBLE_CUSTOM_YOU_HAVE_NO_FRIENDS,
	XBLE_RUNNING,
	XBLE_COUNT
};


const US_JOINABLE = 1;
const US_ONLINE   = 2;
const US_PLAYING  = 4;
const US_VOICE    = 8;




const XONLINE_FRIENDSTATE_FLAG_NONE             = 0x00000000;
const XONLINE_FRIENDSTATE_FLAG_ONLINE           = 0x00000001;
const XONLINE_FRIENDSTATE_FLAG_PLAYING          = 0x00000002;
const XONLINE_FRIENDSTATE_FLAG_VOICE            = 0x00000008;
const XONLINE_FRIENDSTATE_FLAG_JOINABLE         = 0x00000010;
const XONLINE_FRIENDSTATE_MASK_GUESTS           = 0x00000060;
const XONLINE_FRIENDSTATE_FLAG_RESERVED0        = 0x00000080;
const XONLINE_FRIENDSTATE_FLAG_SENTINVITE       = 0x04000000;
const XONLINE_FRIENDSTATE_FLAG_RECEIVEDINVITE   = 0x08000000;
const XONLINE_FRIENDSTATE_FLAG_INVITEACCEPTED   = 0x10000000;
const XONLINE_FRIENDSTATE_FLAG_INVITEREJECTED   = 0x20000000;
const XONLINE_FRIENDSTATE_FLAG_SENTREQUEST      = 0x40000000;
const XONLINE_FRIENDSTATE_FLAG_RECEIVEDREQUEST  = 0x80000000;







var const localized string errorMessages[132]; // XBLE_COUNT messages

/*
// a game server
struct MMGameServer
{
    var int GameServerId;	    // The Id of the game server
    var string Name;            // Its name
    var string IPAddress;       // Its IP address
    var string AltIPAddress;    // Its Alternate IP address
    var int MaxNbPlayers;       // The max number of players allowed in
    var int MaxNbSpectators;    // The max number of spectators allowed in
    var int CurrentNbPlayers;   // The current nb of players in the game
    var int CurrentNbSpectators;// The current nb of spectators in the game
};


struct MMPlayer
{
    var string Alias;           // the name of the player
    var string IPAddress;       // Its IP address
    var string AltIPAddress;    // Its alternate IP address
    var int IsSpectator;        // is he a spectator ?
};
*/

// Check if the actual hardware network cable is connected to the xbox
native static final function bool IsNetCableIn();

// Check if someone logged in using this account (should autologout)
native static final function bool IsLoggedInTwice();

// Get number of Xbox Live accounts on the system
native static final function int GetNumberOfAccounts();
// Get the name of a specified Xbox Live account
native static final function string GetAccountName(int index);
// Is the account list updated since last check? (sets the update flag to false also)
native static final function bool IsAccountListUpdated();

// Reboot the xbox into the specified page of the dashboard (account management etc)
native static final function string RebootToDashboard(int page);

// Returns true if the specified user has a passcode
native static final function bool HasPasscode(string user);
// Returns true if the passcode is the correct one for the specified user.
native static final function bool IsPasscodeCorrect(string user, ePasscodeSymbol passcode[4]);

// Start a login request
native static final function bool StartLogin(string user);
// Returns true if/when the login is successful
native static final function bool IsLoggedIn(string user);
// Returns true if there was an error logging in (resets it also)
native static final function bool ErrorLoggingIn(string user);

// returns true if successfully joined / created a game
native static final function bool IsPlaying();

// returns true if we are inside of a game (maybe without network)
native static final function bool IsIngame();

// Set the current user (doesn't have to be logged in however)
native static final function SetCurrentUser(string user);
// Get the current user (doesn't have to be logged in however)
native static final function string GetCurrentUser();

// Shutdown all live services and clean up
native static final function ShutdownAndCleanup();

// Set user state on xbox live (US_JOINABLE | US_ONLINE | US_PLAYING | US_VOICE)
native static final function bool SetUserState(string user, int flags);

// Get the last error (XBL_MESSAGE)
native static final function int GetLastError();

// Functions to join a game after rebooting (joining from other xbox game)
native static final function bool IsJoiningAfterBoot();
native static final function ResetJoiningAfterBoot();
native static final function string GetFriendInviterAfterBoot();
native static final function string GetUserInvitedAfterBoot();

native static final function bool IsLadderGame();
native static final function SetLadderGame(bool ladder);

native static final function SetSearchParams(eGameType gt, string map, int ff, eLanguage lang);
native static final function eGameType GetSearchGameType();
native static final function string GetSearchMap();
native static final function int GetSearchFriendlyFire();
native static final function eLanguage GetSearchLanguage();



// Get a descriptive error string from specified error
final function string GetErrorString(int msg)
{
  return errorMessages[msg];
}

// Has specified user voice?
native static final function bool          HasUserVoice(string user);

// Verify that a specified IP number joined the VoiceNet
native static final function bool          VerifyIPLoggedIn(string gamertag, string IP);

// Get the username from the user with specified IP
native static final function string        GetGamerTag(string IP);

// Maphandling
native static final function string        GetFirstMap(eGameType gameType);
native static final function string        GetNextMap(eGameType gameType);
native static final function string        GetRandomMap(eGameType gameType);
native static final function string        GetNiceName(string Map);
native static final function int           GetRecommendedPlayers(string Map);

// Ingame player list (currently playing players)
native static final function bool          CachePlayerList();
native static final function bool          UpdatePlayersTalking();
native static final function int           GetNumberOfPlayers();
native static final function string        GetPlayerName(int index);
native static final function bool          IsPlayerTalking(int index);
native static final function bool          IsPlayerMuted(int index);
native static final function bool          HasPlayerVoice(int index);
native static final function bool          IsPlayerInGame(int index);

native static final function bool          AddPlayerToMuteList(int index);
native static final function bool          RemovePlayerFromMuteList(int index);
native static final function bool          IsPlayerOnMuteList(int index);
native static final function bool          AddPlayerToMuteListByName(string name);
native static final function bool          RemovePlayerFromMuteListByName(string name);
native static final function bool          IsPlayerOnMuteListByName(string name);


// Xbox Live Online Settings Options
native static final function               SetVoiceThroughSpeakers(bool enabled);
native static final function bool          GetVoiceThroughSpeakers();
native static final function               SetOnlineStatus(bool enabled);
native static final function bool          GetOnlineStatus();
native static final function               SetVoiceStatus(bool enabled);
native static final function bool          GetVoiceStatus();
native static final function               SetVoiceMask(eVoiceMask mask);
native static final function eVoiceMask    GetVoiceMask();

native static final function               SetVoiceMaskSpecEnergyWeight(float val);
native static final function               SetVoiceMaskPitchScale(float val);
native static final function               SetVoiceMaskWhisperValue(float val);
native static final function               SetVoiceMaskRoboticValue(float val);
native static final function float         GetVoiceMaskSpecEnergyWeight();
native static final function float         GetVoiceMaskPitchScale();
native static final function float         GetVoiceMaskWhisperValue();
native static final function float         GetVoiceMaskRoboticValue();

native static final function               SetVoiceMaskEnabled(bool enabled);
native static final function bool          GetVoiceMaskEnabled();

native static final function bool           IsServerDown();
native static final function bool           IsKicked();

// Statistics
native static final function                SetStatisticsType(eGameType gametype);
native static final function int            StatsGetLeaderboardSize();
native static final function bool           StatsIsRankReady(int rank);
native static final function int            StatsGetActiveUserRank();
native static final function bool           StatsSetRequestedRank(int rank);
native static final function bool           StatsStopCachingLeaderboard();

native static final function eGameType      GetStatisticsType();

native static final function bool           StatsReset();
native static final function bool           StatsPumpReset();
native static final function                StatsCancelReset();

native static final function bool           StatsRequestOverall(int page, int playersPerPage);
native static final function bool           StatsPumpRequestOverall();
native static final function                StatsCancelRequestOverall();
native static final function bool           StatsRequestFriends(int page, int playersPerPage);
native static final function bool           StatsPumpRequestFriends();
native static final function                StatsCancelRequestFriends();
native static final function bool           StatsRequestUser(int page, int playersPerPage);
native static final function bool           StatsPumpRequestUser();
native static final function                StatsCancelRequestUser();

native static final function int            StatsUpdateMyStats(int kills, int deaths, int suicides, int minutes, int games, int gameswon, int flagscapt, int flagsret);
native static final function bool	    IsMyStatsUpdateDone();
native static final function bool	    WasMyStatsUpdateSuccessful();

native static final function int            StatsGetResultCount();
native static final function int            StatsGetResultPosition(int index);
native static final function string         StatsGetResultName(int index);
native static final function int            StatsGetResultKills(int index);
native static final function int            StatsGetResultDeaths(int index);
native static final function int            StatsGetResultMinutes(int index);
native static final function int            StatsGetResultGames(int index);
native static final function int            StatsGetResultGamesWon(int index);
native static final function int            StatsGetResultSuicides(int index);
native static final function int            StatsGetResultFlagsRet(int index);
native static final function int            StatsGetResultFlagsCap(int index);

//same as above, except it's for friends
native static final function int            StatsGetFriendsResultCount();
native static final function int            StatsGetFriendsResultPosition(int index);
native static final function string         StatsGetFriendsResultName(int index);
native static final function int            StatsGetFriendsResultKills(int index);
native static final function int            StatsGetFriendsResultDeaths(int index);
native static final function int            StatsGetFriendsResultMinutes(int index);
native static final function int            StatsGetFriendsResultGames(int index);
native static final function int            StatsGetFriendsResultGamesWon(int index);
native static final function int            StatsGetFriendsResultSuicides(int index);
native static final function int            StatsGetFriendsResultFlagsRet(int index);
native static final function int            StatsGetFriendsResultFlagsCap(int index);

//ladder things
native static final function bool	    GetMyLadderStats();
native static final function bool	    IsGetMyLadderStatsDone();
native static final function int            GetLadderSize();
native static final function int            GetMyLadderRank();
native static final function                SetShouldUpdateStats(bool set);


// Matchmaking
native static final function bool           QuickmatchStartQuery(eGameType gametype);
native static final function XBL_MESSAGES   QuickmatchProcessQuery();
native static final function bool           QuickmatchCancelQuery();
native static final function int            QuickmatchGetResultCount();
native static final function eGameType      QuickmatchGetGameType(int index);
native static final function string         QuickmatchGetMapName(int index);
native static final function string         QuickmatchGetOwner(int index);
native static final function int            QuickmatchGetFragLimit(int index);
native static final function int            QuickmatchGetTimeLimit(int index);
native static final function eLanguage      QuickmatchGetLanguage(int index);
native static final function eSkill         QuickmatchGetMinSkill(int index);
native static final function eSkill         QuickmatchGetMaxSkill(int index);
native static final function int            QuickmatchGetPlayerCount(int index);
native static final function bool           QuickmatchGetFriendlyFire(int index);
native static final function bool           QuickmatchGetCycleLevels(int index);
native static final function int            QuickmatchGetTotalPublicSlots(int index);
native static final function int            QuickmatchGetOpenPublicSlots(int index);
native static final function int            QuickmatchGetTotalPrivateSlots(int index);
native static final function int            QuickmatchGetOpenPrivateSlots(int index);
native static final function bool           QuickmatchJoinSession(int index);
native static final function bool           QuickmatchJoinIsFinished();
native static final function string         QuickmatchGetURL();
native static final function int            QuickmatchGetQoS(int index);
native static final function bool           QuickmatchProbe();
native static final function bool           QuickmatchIsProbing();


native static final function bool           OptimatchStartQuery(eGameType gametype, string mapname, eLanguage language, int minplayers, int maxplayers, int friendlyFire, int cycleLevels, eSkill minskill, eSkill maxskill);
native static final function XBL_MESSAGES   OptimatchProcessQuery();
native static final function bool           OptimatchCancelQuery();
native static final function int            OptimatchGetResultCount();
native static final function eGameType      OptimatchGetGameType(int index);
native static final function string         OptimatchGetMapName(int index);
native static final function string         OptimatchGetOwner(int index);
native static final function int            OptimatchGetFragLimit(int index);
native static final function int            OptimatchGetTimeLimit(int index);
native static final function eLanguage      OptimatchGetLanguage(int index);
native static final function eSkill         OptimatchGetMinSkill(int index);
native static final function eSkill         OptimatchGetMaxSkill(int index);
native static final function int            OptimatchGetPlayerCount(int index);
native static final function bool           OptimatchGetFriendlyFire(int index);
native static final function bool           OptimatchGetCycleLevels(int index);
native static final function int            OptimatchGetTotalPublicSlots(int index);
native static final function int            OptimatchGetOpenPublicSlots(int index);
native static final function int            OptimatchGetTotalPrivateSlots(int index);
native static final function int            OptimatchGetOpenPrivateSlots(int index);
native static final function bool           OptimatchJoinSession(int index);
native static final function bool           OptimatchJoinIsFinished();
native static final function string         OptimatchGetURL();
native static final function int            OptimatchGetQoS(int index);
native static final function bool           OptimatchProbe();
native static final function bool           OptimatchIsProbing();

native static final function string         ConvertString(string org);
native static final function string         UnconvertString(string con);

native static final function bool           JoinSession();
native static final function bool           JoinIsFinished();
native static final function string         JoinGetURL();

native static final function bool           FriendIsInSameGame(string friendName);
native static final function bool           FriendIsInSameSession(string friendName);
native static final function bool           FriendFindSession(string friendName);
native static final function bool           FriendFindIsFinished();
native static final function bool           FriendJoinSession();
native static final function bool           FriendJoinIsFinished();
native static final function string         FriendJoinGetURL();

native static final function bool           SessionCreate();
native static final function bool           SessionIsCreateFinished();
native static final function bool           SessionStartSubnet();
native static final function bool           SessionIsSubnetStarted();
native static final function bool           SessionUpdate();
native static final function XBL_MESSAGES   SessionProcess();
native static final function bool           SessionDelete();
native static final function                SessionReset();
native static final function                SessionListen(bool listen);
native static final function                SessionSetGameType(eGameType gametype);
native static final function                SessionSetMapName(string mapname);
native static final function                SessionSetLanguage(eLanguage language);
native static final function                SessionSetFragLimit(int fraglimit);
native static final function                SessionSetTimeLimit(int timelimit);
native static final function                SessionSetPublicSlots(int count);
native static final function                SessionSetPrivateSlots(int count);
native static final function                SessionSetReserved(int reserved);
native static final function                SessionSetFriendlyFire(bool friendlyfire);
native static final function                SessionSetCycleLevels(bool cyclelevels);
native static final function                SessionSetMinSkill(eSkill skill);
native static final function                SessionSetMaxSkill(eSkill skill);


static final function string GetGameTypeString(eGameType gameType)
{
  switch(gameType)
  {
    case GT_DM:
      return "XIIIMP.XIIIMPGameInfo";
    case GT_TeamDM:
      return "XIIIMP.XIIIMPTeamGameInfo";
    case GT_CTF:
      return "XIIIMP.XIIIMPCTFGameInfo";
    case GT_Sabotage:
      return "XIIIMP.XIIIMPBombGame";
    case GT_Duel:
      return "XIIIMP.XIIIRocketArena";
    case GT_Ladder:
      return "XIIIMP.XIIIMPGameInfo";
    case GT_Invalid:
      return "";
  }
}

// FRIENDS SYSTEM

native static final function FRIEND_PACKET GetFriendAtIndex(int index);
native static final function string        GetFriendNameAtIndex(int index);
native static final function string        GetFriendTitleAtIndex(int index);
native static final function FRIEND_PACKET GetFriend(string friendName);
native static final function int           GetNumberOfFriends();

native static final function bool          UpdateFriends();
native static final function bool          IsFriendsListChanged();


native static final function bool          SetActiveFriend(string friendName);
native static final function FRIEND_PACKET GetActiveFriend();
native static final function string        GetActiveFriendName();
native static final function string        GetActiveFriendTitle();

native static final function bool          RemoveFriend(string friendName);
native static final function string        GetFriendGameName(string friendName);
native static final function bool          AcceptFriendRequest(string friendName);
native static final function bool          DeclineFriendRequest(string friendName);
native static final function bool          CancelFriendRequest(string friendName);
native static final function bool          BlockFriendRequest(string friendName);
native static final function bool          SendFriendRequest(string friendName);
native static final function bool          SendGameInvite(string friendName);
native static final function bool          AcceptGameInvite(string friendName);
native static final function bool          DeclineGameInvite(string friendName);
native static final function bool          RevokeGameInvite(string friendName);
native static final function bool          IsUpdatingFriends();
native static final function bool          IsInSameSession(string friendName);


native static final function bool          SendFeedback(string friendName, BYTE feedback);

native static final function bool          SetActivePlayer(string playerName);
native static final function string        GetActivePlayer();
native static final function bool          IsFriend(string playerName);
native static final function bool          IsPlayerListUpdated();

native static final function bool          IsHost();
native static final function bool          InternalKick(string playerName);
native static final function bool          SetPlayerVoiceStatus(string playerName, bool mute);

native static final function LevelInfo     GetLevelInfo();
native static final function bool          IsPlayerNameInGame(string playerName);


native static final function bool          ShouldRenderInvite();
native static final function bool          HasInvite();
native static final function bool          HasFriendRequest();

native static final function bool          BootToUpdateXBE();

native static final function bool          BootToDownloadManager();

native static final function bool          ResetVoiceNet();

//native static final function bool          AddListener(string user);
//native static final function bool          RemoveListener(string user);
native static final function bool          IsUserMuted(string user);
//native static final function bool          ClearListeners();

native static final function bool          SetListeners(string user, string hear1, string hear2, string hear3);

native static final function bool          EnumerateFriends(bool start);

native static final function               SetSetting(int id, int val);
native static final function int           GetSetting(int id);

static final function bool                 Kick(string playerName)
{
  //local LevelInfo info;
  //info = GetLevelInfo();
  //if (info == none)
  //  return false;
  //if (InternalKick(playerName))
  //  info.Game.KickBan(playerName);
  return InternalKick(playerName);
}

native static final function                      UpdateServerListeners();

/*
// create a user account on Game Service network (before login)
native(475) static final function CreatePlayerAccount(string _Alias, string _Password, string _FirstName, string _LastName, string _Email, string _Country);
native(474) static final function bool IsPlayerAccountCreated(out int _ResultCode);

//======================== Login ========================
// Send a request to log a player in the match making system. The name (_Alias) and password (_Password) are required.

native(473) static final function Login(string _Alias, string _Password);
native(472) static final function Logout();



//========================  ========================
native(471) static final function RequestGameServerList();
native(463) static final function bool IsGameServerListComplete(out int _ResultCode);


// Modify user account
native(462) static final function ModifyPlayerAccount(string _Password, string _FirstName, string _LastName, string _Email, string _Country);
native(461) static final function bool IsPlayerAccountModified(out int _ResultCode);



//========================  ========================
native(460) static final iterator function AllGameServer(out MMGameServer _GameServer);


native(459) static final function RefreshGameServer(int _GameServerID);
native(458) static final function bool IsGameServerRefreshed(out int _ResultCode);


//========================  ========================
native(457) static final function RequestGameServerAdditionalInfo(int _GameServerID);
native(456) static final function bool IsGameServerAdditionalInfoArrived(out int _ResultCode, out string _AdditionalInfo);


//========================  ========================
native(455) static final function JoinGameServer(int _GameServerID, string _Password);
native(454) static final function bool IsJoinGameServerAcknowledged(out int _ResultCode, out string _GameServerIP, out string _GameServerAltIp, out int _GameServerPort);

//========================  ========================
native(453) static final function bool IsMatchStartedByGameServer();

//========================  ========================
native(452) static final function IStartMatch();
native(451) static final function IFinishMatch();


//========================  ========================
native(450) static final function LeaveGameServer();




native(449) static final function RegisterMyGameServer(string _Name, int _MaxPlayers, int _MaxSpectators, string _Password, string _Info, string _AdditionalInfo, int _Port, bool _IsDedicated);
native(448) static final function bool IsMyGameServerRegistered(out int _ResultCode);

native(447) static final iterator function AllPlayerConnectedToMyGameServer(out MMPlayer _Player);

native(446) static final function UpdateMyGameServer(int _MaxPlayers, int _MaxSpectators, string _Password, string _Info, string _AdditionalInfo, int _Port);
native(445) static final function bool IsMyGameServerUpdated(out int _ResultCode);

native(444) static final function StartMatch();
native(443) static final function bool IsStartMatchAcknowledged(out int _ResultCode);

native(442) static final function MatchFinished();
native(441) static final function bool IsMatchFinishedAcknowledged(out int _ResultCode);
*/

defaultproperties
{
     errorMessages(0)="No error"
     errorMessages(1)="Unexpected error"
     errorMessages(2)="Overflow error"
     errorMessages(3)="No session found"
     errorMessages(4)="User is not logged on"
     errorMessages(5)="No guest access"
     errorMessages(6)="Not initialized"
     errorMessages(7)="No user"
     errorMessages(8)="Internal error"
     errorMessages(9)="Out of memory"
     errorMessages(10)="Task busy"
     errorMessages(11)="Server error"
     errorMessages(12)="IO error"
     errorMessages(13)="Bad content"
     errorMessages(14)="User not present"
     errorMessages(15)="Protocol mismatch"
     errorMessages(16)="Invalid service ID"
     errorMessages(17)="Invalid request"
     errorMessages(18)="No network connection"
     errorMessages(19)="Cannot access service"
     errorMessages(20)="Update required"
     errorMessages(21)="Server is too busy"
     errorMessages(22)="Connection lost"
     errorMessages(23)="Already logged in"
     errorMessages(24)="Invalid user"
     errorMessages(25)="Logon disabled"
     errorMessages(26)="No accounts"
     errorMessages(27)="Passcode required"
     errorMessages(28)="Service not requested"
     errorMessages(29)="Service not authorized"
     errorMessages(30)="Service temporarily unavailable"
     errorMessages(31)="User has message"
     errorMessages(32)="Account requires management"
     errorMessages(33)="Memory unit not mounted"
     errorMessages(34)="Failed to read from Memory unit"
     errorMessages(35)="Failed to change user"
     errorMessages(36)="Not logged on"
     errorMessages(37)="Bad content type"
     errorMessages(38)="Invalid message type"
     errorMessages(39)="No address"
     errorMessages(40)="Invalid PUID"
     errorMessages(41)="No connection"
     errorMessages(42)="Send failed"
     errorMessages(43)="Receive failed"
     errorMessages(44)="Message truncated"
     errorMessages(45)="Server is busy"
     errorMessages(46)="List is full"
     errorMessages(47)="Blocked notification"
     errorMessages(48)="Friend pending"
     errorMessages(49)="Flush tickets"
     errorMessages(50)="Too many requests"
     errorMessages(51)="User already exists"
     errorMessages(52)="User not found"
     errorMessages(53)="List is full"
     errorMessages(54)="Self notification"
     errorMessages(55)="Same title"
     errorMessages(56)="No task"
     errorMessages(57)="Invalid session ID"
     errorMessages(58)="Invalid title ID"
     errorMessages(59)="Invalid data type"
     errorMessages(60)="Request is too small"
     errorMessages(61)="Request is truncated"
     errorMessages(62)="Invalid search request"
     errorMessages(63)="Invalid offset"
     errorMessages(64)="Invalid attribute type"
     errorMessages(65)="Invalid version"
     errorMessages(66)="Overflow"
     errorMessages(67)="Invalid result"
     errorMessages(68)="Invalid string"
     errorMessages(69)="String is too long"
     errorMessages(70)="Data is too big"
     errorMessages(71)="Invalid attribute ID"
     errorMessages(72)="Session already exists"
     errorMessages(73)="Critical database error"
     errorMessages(74)="Not enough columns"
     errorMessages(75)="Permission denied"
     errorMessages(76)="Invalid part scheme"
     errorMessages(77)="Invalid parameters"
     errorMessages(78)="Data type mismatch"
     errorMessages(79)="Server error"
     errorMessages(80)="No users"
     errorMessages(81)="Invalid data"
     errorMessages(82)="New content"
     errorMessages(83)="No new content"
     errorMessages(84)="Bad request"
     errorMessages(85)="Invalid user"
     errorMessages(86)="Invalid offer ID"
     errorMessages(87)="Ineligible for offer"
     errorMessages(88)="Offer expired"
     errorMessages(89)="Service unreachable"
     errorMessages(90)="Purchase blocked"
     errorMessages(91)="Purchase denied"
     errorMessages(92)="Billing server error"
     errorMessages(93)="Offer not cancelable"
     errorMessages(94)="Nothing to cancel"
     errorMessages(95)="Already own max"
     errorMessages(96)="No charge"
     errorMessages(97)="Permission denied"
     errorMessages(98)="Name is already taken"
     errorMessages(99)="Authorization failed"
     errorMessages(100)="Credit card expired"
     errorMessages(101)="Non active account"
     errorMessages(102)="Invalid payment instrument status"
     errorMessages(103)="Database key already exists"
     errorMessages(104)="Invalid request"
     errorMessages(105)="NULL Target"
     errorMessages(106)="Bad type"
     errorMessages(107)="Cannot log"
     errorMessages(108)="Bad request"
     errorMessages(109)="Invalid title or leaderboard"
     errorMessages(110)="Too many specs"
     errorMessages(111)="Too many stats"
     errorMessages(112)="User not found"
     errorMessages(113)="Set failed"
     errorMessages(114)="Permission denied"
     errorMessages(115)="Leaderboard was reset"
     errorMessages(116)="Invalid attachment"
     errorMessages(117)="Can upload attachment"
     errorMessages(118)="Invalid request"
     errorMessages(119)="Access denied"
     errorMessages(120)="File is too big"
     errorMessages(121)="File not found"
     errorMessages(122)="Invalid access token"
     errorMessages(123)="Cannot find path"
     errorMessages(124)="File is elsewhere"
     errorMessages(125)="Invalid storage path"
     errorMessages(126)="Invalid facility"
     errorMessages(127)="Unknown domain"
     errorMessages(128)="Sync time skew"
     errorMessages(129)="Sync time skew localtime"
     errorMessages(130)="You have no friends yet"
     errorMessages(131)="Processing..."
}
