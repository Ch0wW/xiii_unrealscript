class XIIIMenuLiveCreateWindow extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton GameTypeButton;
var XIIIGUIButton MapNameButton;
var XIIIGUIButton PublicSlotsButton;
var XIIIGUIButton PrivateSlotsButton;
var XIIIGUIButton FragLimitButton;
var XIIIGUIButton TimeLimitButton;
var XIIIGUIButton FriendlyFireButton;

//var XIIIGUIButton CycleLevelsButton;

//var XIIIGUIButton MinSkillButton;
//var XIIIGUIButton MaxSkillButton;
var XIIIGUIButton LanguageButton;

var localized string EnglishString;
var localized string FrenchString;
var localized string GermanString;
var localized string SpanishString;
var localized string SwedishString;
var localized string DutchString;
var localized string ItalianString;

var localized string Anystring;

var localized string AllString;
var localized string BeginnerString;
var localized string BelowAverageString;
var localized string AverageString;
var localized string AboveAverageString;
var localized string SkilledString;
var localized string ProString;
var localized string EliteString;

var localized string WarningString;
var localized string WarningTooManyPlayers;

var localized string LabelNames[10];
var GUILabel Labels[10];

// Variables for GameType selection
var class<GameInfo> GameClass;
var string Games[64];
var int MaxGames;
var config string Map;
var config string GameType;
var localized string GameTypeList[64];
var int OnGame;
var int PublicSlots;
var int PrivateSlots;
var int FragLimit;
var int TimeLimit;
var bool FriendlyFire;
var bool CycleLevels;
var localized string YesString,NoString;
var string Maps[64];
var int MaxMaps, onMap;

var XboxLiveManager.eSkill MinSkill;
var XboxLiveManager.eSkill MaxSkill;
var XboxLiveManager.eLanguage Language;

var float starttime;

var bool WaitForStart;

// temp lobby
/*
var GUIListBox listbox;
var bool processMe;
var bool gameCreated;
var bool waitForDelete;
*/

const SETID_C_ONGAME      = 6;
const SETID_C_ONMAP       = 7;
const SETID_C_PUBLIC      = 8;
const SETID_C_PRIVATE     = 9;
const SETID_C_FRAGS       = 10;
const SETID_C_TIME        = 11;
const SETID_C_FFIRE       = 12;
const SETID_C_LANGUAGE    = 13;

function IterateGames()
{
  local int i;
  local class<GameInfo> TempClass;

  MaxGames = 0;

  Games[MaxGames] = xboxlive.GetGameTypeString(GT_DM);
  MaxGames++;
  Games[MaxGames] = xboxlive.GetGameTypeString(GT_TeamDM);
  MaxGames++;
  Games[MaxGames] = xboxlive.GetGameTypeString(GT_CTF);
  MaxGames++;
  Games[MaxGames] = xboxlive.GetGameTypeString(GT_Sabotage);
  MaxGames++;
  //Games[MaxGames] = xboxlive.GetGameTypeString(GT_Duel);
  //MaxGames++;

  OnGame = xboxlive.GetSetting(SETID_C_ONGAME);
  GameType = Games[OnGame];
  GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameType, class'Class'));

  if (string(GameClass) != "XIIIMP.XIIIMPGameInfo" && string(GameClass) != "XIIIMP.XIIIRocketArena")
  {
    FriendlyFireButton.bNeverFocus = false;
    FriendlyFireButton.MenuState = MSAT_Blurry;
    //FriendlyFire = bool(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
    FriendlyFire = bool(xboxlive.GetSetting(SETID_C_FFIRE));
  }
  else
  {
    FriendlyFireButton.bNeverFocus = true;
    FriendlyFireButton.MenuState = MSAT_Disabled;
  }

  GameTypeButton.Caption = GameTypeList[OnGame];

  if (GetGameType() == GT_Sabotage)
  {
    FragLimitButton.bNeverFocus = true;
    FragLimitButton.MenuState = MSAT_Disabled;
    TimeLimitButton.bNeverFocus = true;
    TimeLimitButton.MenuState = MSAT_Disabled;
  }
  else
  {
    FragLimitButton.bNeverFocus = false;
    FragLimitButton.MenuState = MSAT_Blurry;
    TimeLimitButton.bNeverFocus = false;
    TimeLimitButton.MenuState = MSAT_Blurry;
  }


     /*
     local int i, j, Selection;
     local class<GameInfo> TempClass;
     local string TempGame;
     local string NextGame;
     local string TempGames[64];
     local bool bFoundSavedGameClass;

     // Compile a list of all gametypes.
     NextGame = GetPlayerOwner().GetNextInt("GameInfo", 0);
     while (NextGame != "")
     {
          TempGames[i++] = NextGame;
          NextGame = GetPlayerOwner().GetNextInt("GameInfo", i);
     }

      // Fill the control.
     for (i=0; i<64; i++)
     {
          if (TempGames[i] != "")
          {
               Games[MaxGames] = TempGames[i];
               if ( !bFoundSavedGameClass && (Games[MaxGames] ~= GameType) )
               {
                    bFoundSavedGameClass = true;
                    Selection = MaxGames;
               }
               log("Found gametype: "$Games[MaxGames]);
               TempClass = Class<GameInfo>(DynamicLoadObject(Games[MaxGames], class'Class'));
               //GameCombo.AddItem(TempClass.Default.GameName);
               GameTypeList[MaxGames] = (TempClass.Default.GameName);
               MaxGames++;
          }
     }

     //GameCombo.SetSelectedIndex(Selection);
     OnGame = Selection;
     GameType = Games[Selection];
     GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameType, class'Class'));

     if (string(GameClass) != "XIIIMP.XIIIMPGameInfo" && string(GameClass) != "XIIIMP.XIIIRocketArena")
     {
        FriendlyFireButton.bNeverFocus = false;
        FriendlyFireButton.MenuState = MSAT_Blurry;
        //MapCombo.bNeverFocus = false;
        FriendlyFire = bool(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
     }
     else
     {
        FriendlyFireButton.bNeverFocus = true;
        FriendlyFireButton.MenuState = MSAT_Disabled;
     }
     GameTypeButton.Caption = GameTypeList[Selection];
     */

}

function IterateMaps(int DefaultMap)
{
  local XboxLiveManager.eGameType gt;
  local string map;

  gt = GetGameType();
  map = xboxlive.GetFirstMap(gt);
  MaxMaps = 0;
  while (map != "")
  {
    // Add the map.
    Maps[MaxMaps] = map;//Left(map, Len(map) - 4);
    MaxMaps++;
    map = xboxlive.GetNextMap(gt);
  }
  if (DefaultMap>=MaxMaps)
    OnMap = 0;
  else
    OnMap = DefaultMap;
  xboxlive.SetSetting(SETID_C_ONMAP, OnMap);
  MapNameButton.Caption = "["$xboxlive.GetRecommendedPlayers(Maps[OnMap])$"] "$xboxlive.GetNiceName(Maps[OnMap]);

     /*
     local string FirstMap, NextMap, TestMap;
     local int Selected;
     local bool bFoundSavedMap;

     FirstMap = GetPlayerOwner().GetMapName(GameClass.Default.MapPrefix, "", 0);

     NextMap = FirstMap;
     MaxMaps = -1;

     while (!(FirstMap ~= TestMap))
     {
         MaxMaps++;

         if ( !bFoundSavedMap && (NextMap ~= Map) )
         {
            bFoundSavedMap = true;
            Selected = MaxMaps;
         }
         // Add the map.
         //MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4)); //, NextMap);
         Maps[MaxMaps] = Left(NextMap, Len(NextMap) - 4);
         NextMap = GetPlayerOwner().GetMapName(GameClass.Default.MapPrefix, NextMap, 1);

         // Test to see if this is the last.
         TestMap = NextMap;
     }

     if (bFoundSavedMap)
     {
        OnMap = Selected;
        //MapCombo.SetSelectedIndex(Selected);
     }
//     MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex(Map, True), 0));
  MapNameButton.Caption = Maps[Selected];
  */
}

function xboxlivemanager.eLanguage GetLanguage(int index)
{
  switch (index)
  {
    case 0:
      return LANG_All;
    case 1:
      return LANG_EnglishOnly;
    case 2:
      return LANG_FrenchOnly;
    case 3:
      return LANG_GermanOnly;
    case 4:
      return LANG_SpanishOnly;
    case 5:
      return LANG_SwedishOnly;
    case 6:
      return LANG_DutchOnly;
    case 7:
      return LANG_ItalianOnly;
  }
  return LANG_Invalid;
}

function ResetButtons()
{
  language = GetLanguage(xboxlive.GetSetting(SETID_C_LANGUAGE));

  //FriendlyFire = bool(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
  FriendlyFire = bool(xboxlive.GetSetting(SETID_C_FFIRE));
  CycleLevels = false;

  MinSkill = SKILL_Beginner;
  MaxSkill = SKILL_Elite;
  //Language = LANG_All;

  IterateGames();
  IterateMaps(xboxlive.GetSetting(SETID_C_ONMAP));

  GameTypeButton.Caption  = GameTypeList[OnGame];
  MapNameButton.Caption = "["$xboxlive.GetRecommendedPlayers(Maps[OnMap])$"] "$xboxlive.GetNiceName(Maps[OnMap]);

  PrivateSlots = 0;
  PrivateSlotsButton.Caption = string(PrivateSlots);

  //PublicSlots = class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers;
  //PublicSlots = xboxlive.GetSetting(SETID_C_PUBLIC);
  PublicSlots = xboxlive.GetRecommendedPlayers(Maps[OnMap])-1;
  if (PublicSlots > xboxlive.GetRecommendedPlayers(Maps[OnMap])-1) PublicSlots = xboxlive.GetRecommendedPlayers(Maps[OnMap])-1;
  if (PublicSlots <= 0) PublicSlots = 1;
  PublicSlotsButton.Caption = string(PublicSlots);
  xboxlive.SetSetting(SETID_C_PUBLIC, PublicSlots);

  FragLimit = xboxlive.GetSetting(SETID_C_FRAGS);
  //FragLimit = class<XIIIMPGameInfo>(GameClass).Default.WinningScore;
  FragLimitButton.Caption = string(FragLimit);
  if (FragLimit == 0) FragLimitButton.Caption ="-";

  if (string(GameClass) == "XIIIMP.XIIIRocketArena")
  {
    //TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime;
    TimeLimit = xboxlive.GetSetting(SETID_C_TIME);
    TimeLimitButton.Caption = string(TimeLimit)@"sec";
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }
  else
  {
    //TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime / 60;
    TimeLimit = xboxlive.GetSetting(SETID_C_TIME);
    TimeLimitButton.Caption = string(TimeLimit);
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }

  if (FriendlyFire)
    FriendlyFireButton.Caption  = YesString;
  else
    FriendlyFireButton.Caption  = NoString;
  //if (CycleLevels)
  //  CycleLevelsButton.Caption   = YesString;
  //else
  //  CycleLevelsButton.Caption  = NoString;

  //MinSkillButton.Caption = GetSkillString(MinSkill);
  //MaxSkillButton.Caption = GetSkillString(MaxSkill);
  LanguageButton.Caption = GetLanguageString();
}

function string GetSkillString(XboxLiveManager.eSkill skill)
{
  switch (skill)
  {
    case SKILL_All:
    return AllString;
    case SKILL_Beginner:
    return BeginnerString;
    case SKILL_BelowAverage:
    return BelowAverageString;
    case SKILL_Average:
    return AverageString;
    case SKILL_AboveAverage:
    return AboveAverageString;
    case SKILL_Skilled:
    return SkilledString;
    case SKILL_Pro:
    return ProString;
    case SKILL_Elite:
    return EliteString;
  }
}

function String GetLanguageString()
{
  switch (Language)
  {
    case LANG_All:
    return AnyString;
    case LANG_EnglishOnly:
    return EnglishString;
    case LANG_FrenchOnly:
    return FrenchString;
    case LANG_GermanOnly:
    return GermanString;
    case LANG_SpanishOnly:
    return SpanishString;
    case LANG_SwedishOnly:
    return SwedishString;
    case LANG_DutchOnly:
    return DutchString;
    case LANG_ItalianOnly:
    return ItalianString;
  }
  return AnyString;
}

function PrevValue(GUIComponent c)
{
  if (c == GameTypeButton)
  {
    OnGame--;
    if (OnGame<0)
      OnGame = MaxGames-1;
    GameTypeButton.Caption = GameTypeList[OnGame];
    GameChanged();
  }
  else if (c==MapNameButton)
  {
    OnMap--;
    if (OnMap<0)
      OnMap = MaxMaps-1;
    MapNameButton.Caption = "["$xboxlive.GetRecommendedPlayers(Maps[OnMap])$"] "$xboxlive.GetNiceName(Maps[OnMap]);
    MapChanged();
  }
  else if (c==PublicSlotsButton)
  {
    if (PublicSlots>0 && PublicSlots+PrivateSlots>1)
      PublicSlots--;
    class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = PublicSlots+PrivateSlots+1;
    PublicSlotsButton.Caption = string(PublicSlots);
    PublicSlotsChanged();
  }
  else if (c==PrivateSlotsButton)
  {
    if ((PublicSlots>=1 && PrivateSlots>0) || (PublicSlots==0 && PrivateSlots>=2))
      PrivateSlots--;
    class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = PublicSlots+PrivateSlots+1;
    PrivateSlotsButton.Caption = string(PrivateSlots);
    PrivateSlotsChanged();
  }
  else if (c==FragLimitButton)
  {
    FragLimit-=5;
    if (FragLimit<0)
      FragLimit = 0;
    //class<XIIIMPGameInfo>(GameClass).Default.WinningScore = FragLimit;
    FragLimitButton.Caption = string(FragLimit);
    if (FragLimit==0)
      FragLimitButton.Caption = "-";
    FragLimitChanged();
  }
  else if (c==TimeLimitButton)
  {
    if (string(GameClass) == "XIIIMP.XIIIRocketArena")
    {
      TimeLimit -= 30;
      if (TimeLimit<0)
        TimeLimit = 0;
      //class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit;
      TimeLimitButton.Caption = string(TimeLimit)@"sec";
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    else
    {
      TimeLimit -= 5;
      if (TimeLimit<0)
        TimeLimit = 0;
      //class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit*60;
      TimeLimitButton.Caption = string(TimeLimit);
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    TimeLimitChanged();
  }
  else if (c==FriendlyFireButton)
  {
    if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
    {
      FriendlyFire = !FriendlyFire;
      //class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);
      if (FriendlyFire)
        FriendlyFireButton.Caption  = YesString;
      else
        FriendlyFireButton.Caption  = NoString;
    }
    FriendlyFireChanged();
  }
  /*else if (c==CycleLevelsButton)
  {
    CycleLevels = !CycleLevels;
    if (CycleLevels)
      CycleLevelsButton.Caption   = YesString;
    else
      CycleLevelsButton.Caption  = NoString;
    CycleLevelsChanged();
  }*/
  else if (c==LanguageButton)
  {
    switch (Language)
    {
      case LANG_All:
        Language = LANG_ItalianOnly;
      break;
      case LANG_EnglishOnly:
        Language = LANG_All;
      break;
      case LANG_FrenchOnly:
        Language = LANG_EnglishOnly;
      break;
      case LANG_GermanOnly:
        Language = LANG_FrenchOnly;
      break;
      case LANG_SpanishOnly:
        Language = LANG_GermanOnly;
      break;
      case LANG_SwedishOnly:
        Language = LANG_SpanishOnly;
      break;
      case LANG_DutchOnly:
        Language = LANG_SwedishOnly;
      break;
      case LANG_ItalianOnly:
        Language = LANG_DutchOnly;
      break;
    }
    LanguageButton.Caption   = GetLanguageString();
    LanguageChanged();
  }
}

function NextValue(GUIComponent c)
{
  if (c == GameTypeButton)
  {
    OnGame++;
    if (OnGame>=MaxGames)
      OnGame = 0;
    GameTypeButton.Caption = GameTypeList[OnGame];
    GameChanged();
  }
  else if (c==MapNameButton)
  {
    OnMap++;
    if (OnMap>=MaxMaps)
      OnMap = 0;
    MapNameButton.Caption = "["$xboxlive.GetRecommendedPlayers(Maps[OnMap])$"] "$xboxlive.GetNiceName(Maps[OnMap]);
    MapChanged();
  }
  else if (c==PublicSlotsButton)
  {
    if (PublicSlots<xboxlive.GetRecommendedPlayers(Maps[OnMap])-1-PrivateSlots)
      PublicSlots++;
    class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = PublicSlots+PrivateSlots+1;
    PublicSlotsButton.Caption = string(PublicSlots);
    PublicSlotsChanged();
  }
  else if (c==PrivateSlotsButton)
  {
    if (PrivateSlots<xboxlive.GetRecommendedPlayers(Maps[OnMap])-1-PublicSlots)
      PrivateSlots++;
    class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = PublicSlots+PrivateSlots+1;
    PrivateSlotsButton.Caption = string(PrivateSlots);
    PrivateSlotsChanged();
  }
  else if (c==FragLimitButton)
  {
    FragLimit+=5;
    if (FragLimit>100)
      FragLimit = 100;
    //class<XIIIMPGameInfo>(GameClass).Default.WinningScore = FragLimit;
    FragLimitButton.Caption = string(FragLimit);
    if (FragLimit==0)
      FragLimitButton.Caption = "-";
    FragLimitChanged();
  }
  else if (c==TimeLimitButton)
  {
    if (string(GameClass) == "XIIIMP.XIIIRocketArena")
    {
      TimeLimit += 30;
      if (TimeLimit>300)
        TimeLimit = 300;
      //class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit;
      TimeLimitButton.Caption = string(TimeLimit)@"sec";
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    else
    {
      TimeLimit += 5;
      if (TimeLimit>60)
        TimeLimit = 60;
      //class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit*60;
      TimeLimitButton.Caption = string(TimeLimit);
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    TimeLimitChanged();
  }
  else if (c==FriendlyFireButton)
  {
    if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
    {
      FriendlyFire = !FriendlyFire;
      //class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);
      if (FriendlyFire)
        FriendlyFireButton.Caption  = YesString;
      else
        FriendlyFireButton.Caption  = NoString;
    }
    FriendlyFireChanged();
  }
  /*else if (c==CycleLevelsButton)
  {
    CycleLevels = !CycleLevels;
    if (CycleLevels)
      CycleLevelsButton.Caption   = YesString;
    else
      CycleLevelsButton.Caption  = NoString;
    CycleLevelsChanged();
  }*/
  else if (c==LanguageButton)
  {
    switch (Language)
    {
      case LANG_All:
        Language = LANG_EnglishOnly;
      break;
      case LANG_EnglishOnly:
        Language = LANG_FrenchOnly;
      break;
      case LANG_FrenchOnly:
        Language = LANG_GermanOnly;
      break;
      case LANG_GermanOnly:
        Language = LANG_SpanishOnly;
      break;
      case LANG_SpanishOnly:
        Language = LANG_SwedishOnly;
      break;
      case LANG_SwedishOnly:
        Language = LANG_DutchOnly;
      break;
      case LANG_DutchOnly:
        Language = LANG_ItalianOnly;
      break;
      case LANG_ItalianOnly:
        Language = LANG_All;
      break;
    }
    LanguageButton.Caption   = GetLanguageString();
    LanguageChanged();
  }
}

function GameChanged()
{
  local int msg;
  
  xboxlive.SetSetting(SETID_C_ONGAME, OnGame);

  GameType = Games[OnGame];
  GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameType, class'Class'));

  IterateMaps(0);
  MapChanged();
  
  if (string(GameClass) != "XIIIMP.XIIIMPGameInfo" && string(GameClass) != "XIIIMP.XIIIRocketArena")
  {
    FriendlyFireButton.bNeverFocus = false;
    FriendlyFireButton.MenuState = MSAT_Blurry;
    //MapCombo.bNeverFocus = false;
    FriendlyFire = bool(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
    if (FriendlyFire)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = NoString;
  }
  else
  {
    FriendlyFireButton.bNeverFocus = true;
    FriendlyFireButton.MenuState = MSAT_Disabled;
  }

  //PublicSlots = class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers;
  //PublicSlotsButton.Caption = string(PublicSlots);

  //PrivateSlots = 0;
  //PrivateSlotsButton.Caption = string(PrivateSlots);

  //FragLimit = class<XIIIMPGameInfo>(GameClass).Default.WinningScore;
  FragLimitButton.Caption = string(FragLimit);
  if (FragLimit == 0) FragLimitButton.Caption ="-";

  if (string(GameClass) == "XIIIMP.XIIIRocketArena")
  {
    //TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime;
    TimeLimitButton.Caption = string(TimeLimit)@"sec";
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    FragLimitButton.bNeverFocus = false;
    FragLimitButton.MenuState = MSAT_Blurry;
    TimeLimitButton.bNeverFocus = false;
    TimeLimitButton.MenuState = MSAT_Blurry;
  }
  else if (GetGameType() == GT_Sabotage)
  {
    TimeLimit = 0;
    FragLimit = 0;
    FragLimitChanged();
    TimeLimitChanged();
    FragLimitButton.bNeverFocus = true;
    FragLimitButton.MenuState = MSAT_Disabled;
    TimeLimitButton.bNeverFocus = true;
    TimeLimitButton.MenuState = MSAT_Disabled;
    TimeLimitButton.Caption ="-";
    FragLimitButton.Caption ="-";
  }
  else
  {
    //TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime / 60;
    TimeLimitButton.Caption = string(TimeLimit);
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    FragLimitButton.bNeverFocus = false;
    FragLimitButton.MenuState = MSAT_Blurry;
    TimeLimitButton.bNeverFocus = false;
    TimeLimitButton.MenuState = MSAT_Blurry;
  }

  xboxlive.SessionSetGameType(GetGameType());
  xboxlive.SessionSetMapName(Maps[OnMap]);
  xboxlive.SessionSetTimeLimit(TimeLimit);
  xboxlive.SessionSetFragLimit(FragLimit);
  xboxlive.SessionSetPublicSlots(PublicSlots+1);
  xboxlive.SessionSetPrivateSlots(PrivateSlots);
  xboxlive.SessionSetFriendlyFire(FriendlyFire);
  xboxlive.SessionSetCycleLevels(CycleLevels);
  xboxlive.SessionSetMinSkill(MinSkill);
  xboxlive.SessionSetMaxSkill(MaxSkill);
  xboxlive.SessionSetLanguage(Language);

  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function MapChanged()
{
  local int msg;
  
  PublicSlots = xboxlive.GetRecommendedPlayers(Maps[OnMap])-1-PrivateSlots;
  if (PublicSlots<0)                 PublicSlots = 0;
  if (PublicSlots+PrivateSlots > xboxlive.GetRecommendedPlayers(Maps[OnMap])-1)
  {
    PrivateSlots = 0;
    PrivateSlotsButton.Caption = string(PrivateSlots);
    PublicSlots = xboxlive.GetRecommendedPlayers(Maps[OnMap])-PrivateSlots-1;
    PrivateSlotsChanged();
  }
  if (PrivateSlots+PublicSlots+1 <= 1) PublicSlots = 1;
  PublicSlotsButton.Caption = string(PublicSlots);
  PublicSlotsChanged();
  
  //Map = MapNameButton.Caption$".unr";
  Map = Maps[onMap]$".unr";
  xboxlive.SessionSetMapName(Maps[OnMap]);
  xboxlive.SetSetting(SETID_C_ONMAP, OnMap);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function PublicSlotsChanged()
{
  local int msg;
  xboxlive.SessionSetPublicSlots(PublicSlots+1);
  xboxlive.SetSetting(SETID_C_PUBLIC, PublicSlots);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function PrivateSlotsChanged()
{
  local int msg;
  xboxlive.SessionSetPrivateSlots(PrivateSlots);
  xboxlive.SetSetting(SETID_C_PRIVATE, PrivateSlots);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function FragLimitChanged()
{
  local int msg;
  xboxlive.SessionSetFragLimit(FragLimit);
  xboxlive.SetSetting(SETID_C_FRAGS, FragLimit);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function TimeLimitChanged()
{
  local int msg;
  xboxlive.SessionSetTimeLimit(TimeLimit);
  xboxlive.SetSetting(SETID_C_TIME, TimeLimit);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function FriendlyFireChanged()
{
  local int msg;
  xboxlive.SessionSetFriendlyFire(FriendlyFire);
  xboxlive.SetSetting(SETID_C_FFIRE, int(FriendlyFire));

  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function LanguageChanged()
{
  xboxlive.SessionSetLanguage(Language);
  xboxlive.SetSetting(SETID_C_LANGUAGE, Language);
}

function MinSkillChanged()
{
  xboxlive.SessionSetMinSkill(MinSkill);
}

function MaxSkillChanged()
{
  xboxlive.SessionSetMaxSkill(MaxSkill);
}

function CycleLevelsChanged()
{
  local int msg;
  xboxlive.SessionSetCycleLevels(CycleLevels);
  // temp lobby
  /*
  if (!xboxlive.SessionUpdate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
  }
  */
}

function Created()
{
  local int i;
  local int msg;

  Super.Created();

  GameTypeButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15-30,    100,      180, 30));
  MapNameButton         = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15,    100+35,   150, 30));
  PublicSlotsButton     = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15,    100+35*2, 50,  30));
  PrivateSlotsButton    = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15,    100+35*3, 50,  30));
  FragLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 525-37-15, 100+35*4, 75,  30));
  TimeLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 525-37-15, 100+35*5, 75,  30));
  FriendlyFireButton    = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15,    100+35*6, 50,  30));
  //CycleLevelsButton     = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500, 345, 50, 30));
  LanguageButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15,    100+35*7, 150, 30));
  //MinSkillButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-10,    100-11+31*8, 150, 30));
  //MaxSkillButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-10,    100-11+31*9, 150, 30));

  Controls[0]=GameTypeButton;
  Controls[1]=MapNameButton;
  Controls[2]=PublicSlotsButton;
  Controls[3]=PrivateSlotsButton;
  Controls[4]=FragLimitButton;
  Controls[5]=TimeLimitButton;
  Controls[6]=FriendlyFireButton;
  //Controls[7]=CycleLevelsButton;
  Controls[7]=LanguageButton;
  //Controls[8]=MinSkillButton;
  //Controls[9]=MaxSkillButton;

  XIIIGuiButton(Controls[0]).bDrawArrows = true;
  XIIIGuiButton(Controls[1]).bDrawArrows = true;
  XIIIGuiButton(Controls[2]).bDrawArrows = true;
  XIIIGuiButton(Controls[3]).bDrawArrows = true;
  XIIIGuiButton(Controls[4]).bDrawArrows = true;
  XIIIGuiButton(Controls[5]).bDrawArrows = true;
  XIIIGuiButton(Controls[6]).bDrawArrows = true;
  XIIIGuiButton(Controls[7]).bDrawArrows = true;

  for (i=0; i<8; i++)
    Controls[i].StyleName = "SquareButton";

  Labels[0] = GUILabel(CreateControl(class'GUILabel', 300-35, 100,      150, 26));
  Labels[1] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35,   150, 26));
  Labels[2] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*2, 150, 26));
  Labels[3] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*3, 150, 26));
  Labels[4] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*4, 150, 26));
  Labels[5] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*5, 150, 26));
  Labels[6] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*6, 150, 26));
  Labels[7] = GUILabel(CreateControl(class'GUILabel', 300-35, 100+35*7, 150, 26));
  //Labels[8] = GUILabel(CreateControl(class'GUILabel', 300-35, 100-11+31*8, 150, 26));
  //Labels[9] = GUILabel(CreateControl(class'GUILabel', 300-35, 100-11+31*9, 150, 26));

  for (i=0; i<8; i++)
  {
    Labels[i].caption = LabelNames[i];
    Labels[i].StyleName="LabelWhite";
    Labels[i].TextColor.R=255;
    Labels[i].TextColor.G=255;
    Labels[i].TextColor.B=255;
    controls[8+i] = Labels[i];
  }

  ResetButtons();

  // temp lobby
  //processMe = true;

  // temp lobby
  /*
  listbox = GUIListbox(controls[16]);
  listbox.FocusInstead = controls[0];
  */

  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';

  xboxlive.SessionSetGameType(GetGameType());
  xboxlive.SessionSetMapName(Maps[OnMap]);
  xboxlive.SessionSetLanguage(Language);
  xboxlive.SessionSetFragLimit(FragLimit);
  xboxlive.SessionSetTimeLimit(TimeLimit);
  xboxlive.SessionSetPublicSlots(PublicSlots+1);
  xboxlive.SessionSetPrivateSlots(PrivateSlots);
  //xboxlive.SessionSetReserved(1);
  xboxlive.SessionSetFriendlyFire(FriendlyFire);
  xboxlive.SessionSetCycleLevels(CycleLevels);
  xboxlive.SessionSetMinSkill(MinSkill);
  xboxlive.SessionSetMaxSkill(MaxSkill);

  // temp lobby
  /*
  if (!xboxlive.SessionCreate())
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    processMe = false;
  }
  */
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      StartPressed();
      //log("[XIIILiveMsgBox] Ok pressed");
      //xboxlive.ShutdownAndCleanup();
      //xboxlive.SessionReset();
      //Controller.ReplaceMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function XboxLiveManager.eGameType GetGameType()
{
  switch (OnGame)
  {
    case 0:
      return GT_DM;
    case 1:
      return GT_TeamDM;
    case 2:
      return GT_CTF;
    case 3:
      return GT_Sabotage;
    case 4:
      return GT_Duel;
  }
  return GT_Invalid;
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);

	OnClick = InternalOnClick;
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = true;
     //bShowSEL = true;
}

// temp lobby
/*
function Process()
{
  local XboxLiveManager.XBL_MESSAGES msg;
  local int i;

  if (!gameCreated)
  {
    msg = xboxlive.SessionProcess();

    if (msg != XBLE_NONE)
    {
      if (msg == XBLE_RUNNING)
      { // WHOOO
        gameCreated = true;
      }
      else
      {
        ProcessMe = false;
        //msg = xboxlive.GetLastError();
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
      }
    }
  }
  else
  {
    msg = xboxlive.SessionProcess();

    if (msg != XBLE_NONE && msg != XBLE_RUNNING)
    {
      if (msg == XBLE_RUNNING)
      {
        ProcessMe = false;
        //msg = xboxlive.GetLastError();
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
      }
    }
  }
}
*/

// temp lobby
/*
function UpdateDelete()
{
  local XboxLiveManager.XBL_MESSAGES msg;
  local int i;

  msg = xboxlive.SessionProcess();

  if (msg != XBLE_NONE)
  {
    if (msg == XBLE_RUNNING)
    { // WHOOO
      waitForDelete = false;
      Controller.CloseMenu(true);
      Controller.CloseMenu(true);
      xboxlive.SessionReset();
    }
    else
    {
      waitForDelete = false;
      //msg = xboxlive.GetLastError();
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
    }
  }
}
*/

function ProcessWait()
{
  local string URL, Checksum;
  local int N;
	local int i;
	local string MyClass, SkinCode;
	local int FriendlyFireInt;
  
  if (true/*xboxlive.SessionIsSubnetStarted() && (GetPlayerOwner().Level.TimeSeconds - starttime)>2.0*/)
  {
    WaitForStart = false;
     //if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
     //   class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);

     N = PublicSlots+PrivateSlots+1;//PlayerCombo.GetValue();
     class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = N;
     //MapChanged(); GameChanged();

    xboxlive.SessionSetGameType(GetGameType());
    xboxlive.SessionSetMapName(Maps[OnMap]);
    xboxlive.SessionSetTimeLimit(TimeLimit);
    xboxlive.SessionSetFragLimit(FragLimit);
    xboxlive.SessionSetPublicSlots(PublicSlots+1);
    xboxlive.SessionSetPrivateSlots(PrivateSlots);
    xboxlive.SessionSetFriendlyFire(FriendlyFire);
    xboxlive.SessionSetCycleLevels(CycleLevels);
    xboxlive.SessionSetLanguage(Language);
    xboxlive.SessionSetMinSkill(MinSkill);
    xboxlive.SessionSetMaxSkill(MaxSkill);

    Map = Maps[OnMap];
    GameType = Games[OnGame];

     //URL = Map$"?Game="$GameType$"?Listen";
    //SaveConfigs();
    myRoot.bXboxStartup = true;
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    XIIIMenuLiveAccountWindow(myRoot.ActivePage).AutoLoginUser = xboxlive.GetCurrentUser();
    myRoot.CloseAll(true);
    myRoot.GotoState('');
     GetPlayerOwner().AttribPadToViewport();
     GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(xboxlive.GetCurrentUser());
     //log("TRAVELING w/URL: "$URL);
     //GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
    //GetPlayerOwner().ConsoleCommand("start "$Map$"?Game="$GameType$"?listen");

	// skin
	MyClass = GetPlayerOwner().GetDefaultURL("MySkin");
	SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[0].SkinCode;
	for (i=0;i<class'MeshSkinList'.default.MeshSkinListInfo.Length;i++)
	{
		if ( MyClass == class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName )
		{
			SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode;
			break;
		}
	}
	
	FriendlyFireInt = int(FriendlyFire);
	
      URL = Map$
            "?listen"$
            "?Game="$GameType$
            "?NP="$N$
            "?FF="$FriendlyFireInt$
            "?FR="$FragLimit$
            "?TI="$TimeLimit$
		        "?SK="$SkinCode$
            "?GAMERTAG="$xboxlive.ConvertString(xboxlive.GetCurrentUser());
    log("TRAVELING w/URL: "$URL);
    GetPlayerOwner().ConsoleCommand("start "$URL);
  }
  else
  {
  }
}

function Paint(Canvas C, float X, float Y)
{
    if (WaitForStart)
    {
      ProcessWait();
    }

     // temp lobby
     /*
     if (ProcessMe)
     {
      Process();
     }
     */

     // temp lobby
     /*
     if (waitForDelete)
     {
       UpdateDelete();
     }
     */

     Super.Paint(C, X, Y);
     PaintStandardBackground(C, X, Y, TitleText);
}

function StartPressed()
{
  local int msg;
  WaitForStart = true;
  /*if (xboxlive.SessionStartSubnet())
  {
    starttime = GetPlayerOwner().Level.TimeSeconds;
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(pleaseWaitString, 0, 0, "Creating Session");
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
    WaitForStart = true;
  }
  else
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
  }*/
  /*
     local string URL, Checksum;
     local int N;
     if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
        class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);

     N = PublicSlots+PrivateSlots+1;//PlayerCombo.GetValue();
     class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = N;
     MapChanged(); GameChanged();
     URL = Map$"?Game="$GameType$"?Listen";
    //SaveConfigs();
    myRoot.bXboxStartup = true;
    myRoot.GotoState('');
    myRoot.CloseAll(true);
     GetPlayerOwner().AttribPadToViewport();
     GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(xboxlive.GetCurrentUser());
     log("TRAVELING w/URL: "$URL);
     //GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
    GetPlayerOwner().ConsoleCommand("start "$Map$"?Game="$GameType$"?listen");
    */
}


function SaveConfigs()
{
     GameClass.static.StaticSaveConfig();
     SaveConfig();
     GetPlayerOwner().SaveConfig();
     GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  if (waitForStart)
    return true;
  if (publicSlots+privateSlots<=xboxlive.GetRecommendedPlayers(Maps[OnMap])-1)
  {
    StartPressed();
  }
  else
  {
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(WarningTooManyPlayers, QBTN_Ok | QBTN_Cancel, QBTN_Ok, WarningString);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
  }
  return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  local int msg;
    if (state==1 || state==2)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
          // temp lobby
          /*
	        if (gameCreated)
	        {
	          if (!xboxlive.SessionDelete())
	          {
              msg = xboxlive.GetLastError();
              Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
              msgbox = XIIILiveMsgBox(myRoot.ActivePage);
              msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
              msgbox.OnButtonClick=MsgBoxBtnClicked;
	          }
	          else
	          {
              Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
              msgbox = XIIILiveMsgBox(myRoot.ActivePage);
              msgbox.SetupQuestion("Please wait...", 0, 0, "Removing Game");
              msgbox.OnButtonClick=MsgBoxBtnClicked;
	            waitForDelete = true;
	          }
	        }
	        */
	        // anti temp lobby
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
	      PrevValue(FocusedControl);
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	      NextValue(FocusedControl);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

/*

  ButtonNames(0)="Start / Join a game"
  ButtonNames(1)="Friends"
  ButtonNames(2)="Xbox Live Options"
  ButtonNames(3)="View Scoreboard"
  ButtonNames(4)="Download New Content"

  //Begin Object Class=GUIListbox Name=cTestButton1
  //   StyleName="Listbox"
  //   WinLeft=350
  //   WinTop=100
 // 	 WinWidth = 200
 // 	 WinHeight = 275
  //   bVisibleWhenEmpty=true
  //End Object
  //controls(0)=cTestButton1

	Begin Object class=XIIIGUIButton name="StartJoin"
		StyleName="SquareButton"
		WinLeft=300
		WinTop=130
		WinWidth=250
		WinHeight=30
		bFocusOnWatch=true
    OnClick=InternalOnClick
	End Object
	controls(0)="StartJoin"
	Begin Object class=XIIIGUIButton name="Friends"
		StyleName="SquareButton"
		WinLeft=300
		WinTop=170
		WinWidth=250
		WinHeight=30
		bFocusOnWatch=true
	End Object
	controls(1)="Friends"
	Begin Object class=XIIIGUIButton name="OnlineSettings"
		StyleName="SquareButton"
		WinLeft=300
		WinTop=210
		WinWidth=250
		WinHeight=30
		bFocusOnWatch=true
	End Object
	controls(2)="OnlineSettings"
	Begin Object class=XIIIGUIButton name="Scoreboard"
		StyleName="SquareButton"
		WinLeft=300
		WinTop=250
		WinWidth=250
		WinHeight=30
		bFocusOnWatch=true
	End Object
	controls(3)="Scoreboard"
	Begin Object class=XIIIGUIButton name="Download"
		StyleName="SquareButton"
		WinLeft=300
		WinTop=290
		WinWidth=250
		WinHeight=30
		bFocusOnWatch=true
	End Object
	controls(4)="Download"
*/


