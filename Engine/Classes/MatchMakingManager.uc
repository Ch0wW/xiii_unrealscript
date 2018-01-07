// This class is the front-end to access the match-making capabilities buried inside the engine.

class MatchMakingManager extends Object
	native
    transient;



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
	var string GameDesc;        // Description of the game
};


struct MMPlayer
{
    var string Alias;           // the name of the player
    var string IPAddress;       // Its IP address
    var string AltIPAddress;    // Its alternate IP address
    var int IsSpectator;        // is he a spectator ?
};


// For PSX2 more-specific interface (see below)
struct PSX2NetCnfCombination
{
    var int status;             // permet de repérer des configs qui existent mais ne sont pas utilisables  
    var int iftype;             // décrit le mode de connexion (ethernet, modem PPP, PPPoE ...)
    var string combinationName; // ce champ on peut s'en passer à votre niveau (nom système de la config)
    var string ifcName;         // le nom utilisateur, affichable de la config
    var string devName;         // le nom du hard associé à la config 
};

// For PSX2 more-specific interface (see below)
struct PSX2NetCnfStatus
{
    var string ifname;          // nom de l'interface physique (eth0 ...)
    var string ifname2;         // nom de l'interface virtuelle (pppoe0 dans le cas où la config utilise PPPoE)
    var int iftype;             // comme tout à l'heure ...
    var int error;              // un code d'erreur eventuel
    var int state;              // code décrivant l'état de l'interface (indépendant du protocole : stopped, starting, started, stopping ...)
    var int phase;              // code décrivant l'étape de connexion en cours, dépendant du protocole (numérotation, login ...)
    var int link;               // dans le cas ethernet, état du réseau : 1 si y a un signal , 0 sinon ... ça doit permettre de dire si le câble réseau est bien branché ...
    var string message;         // une ligne de texte décrivant l'état actuel
};

/*
// For PSX2 DNAS authentication progress
enum PSX2DNASAuthenticationStatus
{
	DNAS_DONOTUSE_0 , // 0
	DNAS_DORMANT , // 1
	DNAS_INIT , // 2
	DNAS_INST , // 3
	DNAS_DATA , // 4
	DNAS_END , // 5
	DNAS_NG , // 6
	DNAS_COM_ERROR , // 7
	DNAS_DATA_DONE , // 8
	DNAS_GETID , // 9 
	DNAS_DONOTUSE_10 , // 10
	DNAS_NETSTART , // 11
} ;

struct PSX2DNASAuthenticationStatus
{
	var int code ;
	var int subcode ;
	var int progress ;
	var int optional ;
}
*/
// This array translates in plain text the error codes (use the ResultCode as an index in this array)
var const localized string FailureMessages[106];



// create a user account on Game Service network (before login)
native(475) static final function CreatePlayerAccount(string _Alias, string _Password, string _FirstName, string _LastName, string _Email, string _Country);
native(474) static final function bool IsPlayerAccountCreated(out int _ResultCode);


native static final function CheckAccountValidity(string _Alias, string _Password);
native static final function bool IsAccountValidityChecked(out int _ResultCode);

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

//======================== connection reset by GS ? ========================
native static final function bool IsConnectionLostWithGS();


native(449) static final function RegisterMyGameServer(string _Name, int _MaxPlayers, int _MaxSpectators, string _Password, string _Info, string _AdditionalInfo, int _Port, bool _IsDedicated);
native(448) static final function bool IsMyGameServerRegistered(out int _ResultCode);

native(447) static final iterator function AllPlayerConnectedToMyGameServer(out MMPlayer _Player);

native(446) static final function UpdateMyGameServer(int _MaxPlayers, int _MaxSpectators, string _Password, string _Info, string _AdditionalInfo, int _Port);
native(445) static final function bool IsMyGameServerUpdated(out int _ResultCode);

native(444) static final function StartMatch();
native(443) static final function bool IsStartMatchAcknowledged(out int _ResultCode);

native(442) static final function MatchFinished();
native(441) static final function bool IsMatchFinishedAcknowledged(out int _ResultCode);

native static final function UnregisterMyGameServer();

native static final function bool IsMyGameServerStillRegistered();


//
//
// A more PS2-specific interface
//
//


native static final function int PSX2SwitchToOnlineMode();
native static final function PSX2SwitchToOfflineMode();

//--------------- Asynchronous operation management ---------------


// Wait for the end of an asynchronous operation
// return value: 
//              1 - still executing
//              0 - operation over. The result can be obtained with PS2NetCnfGetResult()
native static final function int PSX2NetCnfGetState();

// Get the result of an asynchronous operation (once over)
native static final function int PSX2NetCnfGetResult();



//--------------- list and choose a config ---------------

// init config choice        
native static final function PSX2NetCnfInit();

    // exit config choice
native static final function PSX2NetCnfExit();
	

// [Asynchronous operation] Get a list of config on a memory card
// netdb: media identifier (mc0 or mc1 for memory card)
// return value: <0 if error, else operation started successfully
// When the operation is over, PSX2NetCnfGetResult() will give:
//              - number of config on the media (6 max for a memory card, 0 if none)
//              - <0 if error
native static final function int PSX2NetCnfGetCombinationList(string netdb);

// Iterate config list	
// index: between 1 and the number of config obtained
// combination: a structure that contains info on the config
native static final function PSX2NetCnfGetCombination(int index, out PSX2NetCnfCombination Combination);
		
// Get default config		
native static final function int PSX2NetCnfGetDefault();
		
// [Asynchronous operation] Select a config			
// index: index of the config to use
// return value: <0 if error, else operation started successfully
// When the operation is over, PSX2NetCnfGetResult() will give:
//              - <0 if error
//              - >=0 if success
native static final function int PSX2NetCnfSelectCombination(int index);
		



//--------------- activate the selected config and start network ---------------

// init network activation
native static final function PSX2NetCtlInit();

// exit network activation
native static final function PSX2NetCtlExit();
		
// [Asynchronous operation] Attach config to the network interface
// When the operation is over, PSX2NetCnfGetResult() will give:
//              - <0 if error
//              - >=0 if success
native static final function int PSX2NetCtlBind();
		
// Start network connection		
// Return code:
//              - <0 if error
//              - >=0 if success
native static final function int PSX2NetCtlUp();

// End network connection	
// Return code:
//              - <0 if error
//              - >=0 if success
native static final function int PSX2NetCtlDown();

// Test the state of the connection
// return code: possible errors
native static final function int PSX2NetCtlGetStatus(out PSX2NetCnfStatus Status);


//--------------- activate and  check DNAS authentication ---------------

// init DNAS stuff (load the proper overlay)
native static final function int PSX2DNASInit(int ng);

// exit DNAS stuff (load the proper overlay)
native static final function PSX2DNASExit();

// start DNAS authentication (asynchronous function)
native static final function int PSX2DNASAuthenticate();

// check authentication progress
native static final function int PSX2DNASProgress(out int code, out int subcode, out int progress);



//--------------- Presence of memory card ---------------

// Check presence of memory card in each slot
// Return code:
//              - <0 if error
//              - >=0 if success
//                  Port0, Port1: contains 1 if a memory card is present in the corresponding slot, 0 otherwise
native static final function int PSX2McCheckPort(out int Port0, out int port1);
	

defaultproperties
{
     FailureMessages(0)="No error"
     FailureMessages(1)="Unknown error"
     FailureMessages(2)="You are not registered, create a new account first"
     FailureMessages(3)="Your password is incorrect"
     FailureMessages(4)="This login is already in use, or your disconnection has not been detected yet"
     FailureMessages(5)="This login doesn't exist"
     FailureMessages(6)="The operation failed"
     FailureMessages(7)="A player with the same name as yours is already connected"
     FailureMessages(8)="The operation failed"
     FailureMessages(9)="The operation failed"
     FailureMessages(10)="The name you chose is already used by another player"
     FailureMessages(11)="You are already registered"
     FailureMessages(12)="The operation failed"
     FailureMessages(13)="Database problem. Some functions are disabled"
     FailureMessages(14)="UBI.com has a database problem. Please wait while it is beeing fixed. Sorry for the inconvenience"
     FailureMessages(15)="The operation failed"
     FailureMessages(16)="The password is invalid"
     FailureMessages(17)="The operation failed"
     FailureMessages(18)="The operation failed"
     FailureMessages(19)="The operation failed"
     FailureMessages(20)="The operation failed"
     FailureMessages(21)="The operation failed"
     FailureMessages(22)="A session already exist with this name"
     FailureMessages(23)="The operation failed"
     FailureMessages(24)="Maximum number of players reached"
     FailureMessages(25)="Maximum number of spectators reached"
     FailureMessages(26)="Visitors are not allowed in this session"
     FailureMessages(27)="The operation failed"
     FailureMessages(28)="No more player are allowed in this session"
     FailureMessages(29)="No more spectator are allowed in this session"
     FailureMessages(30)="The player is not registered"
     FailureMessages(31)="The session is not available"
     FailureMessages(32)="Session currently running"
     FailureMessages(33)="Invalid game version"
     FailureMessages(34)="Invalid password, you must specify the correct password to join this session"
     FailureMessages(35)="You are already in the session"
     FailureMessages(36)="Error: you are not the master of this session"
     FailureMessages(37)="Error: not currently in session"
     FailureMessages(38)="Not enough players in session to start game (min players)"
     FailureMessages(39)="This game does not exists"
     FailureMessages(40)="This session does not exist"
     FailureMessages(41)="The operation failed"
     FailureMessages(42)="The operation failed"
     FailureMessages(43)="Cannot login (bad login/password)"
     FailureMessages(44)="The operation failed"
     FailureMessages(45)="The operation failed"
     FailureMessages(46)="The operation failed"
     FailureMessages(47)="The operation failed"
     FailureMessages(48)="The operation failed"
     FailureMessages(49)="The operation failed"
     FailureMessages(50)="The operation failed"
     FailureMessages(51)="The operation failed"
     FailureMessages(52)="Unknown error"
     FailureMessages(53)="Unknown error"
     FailureMessages(54)="Unknown error"
     FailureMessages(55)="Unknown error"
     FailureMessages(56)="Unknown error"
     FailureMessages(57)="Unknown error"
     FailureMessages(58)="Unknown error"
     FailureMessages(59)="Unknown error"
     FailureMessages(60)="Unknown error"
     FailureMessages(61)="The operation failed"
     FailureMessages(62)="The operation failed"
     FailureMessages(63)="Unknown error"
     FailureMessages(64)="No spectator are allowed in this group"
     FailureMessages(65)="This room is full"
     FailureMessages(66)="The maximum number of spectator has been reached"
     FailureMessages(67)="This lobby is full"
     FailureMessages(68)="You are not registered"
     FailureMessages(69)="Match currently in progress"
     FailureMessages(70)="Wrong game version"
     FailureMessages(71)="Wrong password"
     FailureMessages(72)="You are already in that group"
     FailureMessages(73)="The operation failed"
     FailureMessages(74)="The operation failed"
     FailureMessages(75)="The minimum number of player has not been reached"
     FailureMessages(76)="Login error"
     FailureMessages(77)="Login error"
     FailureMessages(78)="Login error"
     FailureMessages(79)="No host lobby server"
     FailureMessages(80)="Disconnection from lobby server"
     FailureMessages(81)="The operation failed"
     FailureMessages(82)="The operation failed"
     FailureMessages(83)="The operation failed"
     FailureMessages(84)="The operation failed"
     FailureMessages(85)="The operation failed"
     FailureMessages(86)="The operation failed"
     FailureMessages(87)="The operation failed"
     FailureMessages(88)="Unknown error"
     FailureMessages(89)="Unknown error"
     FailureMessages(90)="The operation failed"
     FailureMessages(91)="The operation failed"
     FailureMessages(92)="The operation failed"
     FailureMessages(93)="The operation failed"
     FailureMessages(94)="The operation failed"
     FailureMessages(95)="The operation failed"
     FailureMessages(96)="The operation failed"
     FailureMessages(97)="The operation failed"
     FailureMessages(98)="Member is banned"
     FailureMessages(99)="The operation failed"
     FailureMessages(100)="The operation failed"
     FailureMessages(101)="The operation failed"
     FailureMessages(102)="The operation failed"
     FailureMessages(103)="The operation failed"
     FailureMessages(104)="The operation failed"
     FailureMessages(105)="The operation could not be completed"
}
