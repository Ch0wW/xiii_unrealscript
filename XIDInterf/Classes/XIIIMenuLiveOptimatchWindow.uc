class XIIIMenuLiveOptimatchWindow extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton GameTypeButton;
var XIIIGUIButton MapNameButton;
var XIIIGUIButton MinPlayersButton;
var XIIIGUIButton MaxPlayersButton;
//var XIIIGUIButton FragLimitButton;
//var XIIIGUIButton TimeLimitButton;
var XIIIGUIButton FriendlyFireButton;
//var XIIIGUIButton CycleLevelsButton;
var XIIIGUIButton LanguageButton;

var localized string LabelNames[7];
var GUILabel Labels[7];

var localized string EnglishString;
var localized string FrenchString;
var localized string GermanString;
var localized string SpanishString;
var localized string SwedishString;
var localized string DutchString;
var localized string ItalianString;

// Variables for GameType selection
var class<GameInfo> GameClass;
var string Games[64];
var int MaxGames;
var config string Map;
var config string GameType;
var localized string GameTypeList[64];
var int OnGame;
var int MinPlayers;
var int MaxPlayers;
//var int FragLimit;
//var int TimeLimit;
var int FriendlyFire; // 0 == false, 1 == true, -1 == Any
var int CycleLevels;  // 0 == false, 1 == true, -1 == Any
var localized string YesString,NoString,AnyString;
var string Maps[64];
var int MaxMaps, onMap;
var XboxLiveManager.eLanguage language;
var bool bAutoUpdate;

const SETID_ONGAME      = 0;
const SETID_ONMAP       = 1;
const SETID_MINPLAYERS  = 2;
const SETID_MAXPLAYERS  = 3;
const SETID_FFIRE       = 4;
const SETID_LANGUAGE    = 5;

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

  OnGame = xboxlive.GetSetting(SETID_ONGAME);
  GameType = Games[OnGame];
  GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameType, class'Class'));

  if (string(GameClass) != "XIIIMP.XIIIMPGameInfo" && string(GameClass) != "XIIIMP.XIIIRocketArena")
  {
    FriendlyFireButton.bNeverFocus = false;
    FriendlyFireButton.MenuState = MSAT_Blurry;
    //MapCombo.bNeverFocus = false;
    FriendlyFire = int(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
    if (FriendlyFire==0)
      FriendlyFireButton.Caption  = NoString;
    else if (FriendlyFire==1)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = AnyString;
  }
  else
  {
    FriendlyFireButton.bNeverFocus = true;
    FriendlyFireButton.MenuState = MSAT_Disabled;
    FriendlyFire = 0;
    if (FriendlyFire==0)
      FriendlyFireButton.Caption  = NoString;
    else if (FriendlyFire==1)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = AnyString;
  }

  GameTypeButton.Caption = GameTypeList[OnGame];

     /*local int i, j, Selection;
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
        FriendlyFire = int(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
        if (FriendlyFire==0)
          FriendlyFireButton.Caption  = NoString;
        else if (FriendlyFire==1)
          FriendlyFireButton.Caption  = YesString;
        else
          FriendlyFireButton.Caption  = AnyString;
     }
     else
     {
        FriendlyFireButton.bNeverFocus = true;
        FriendlyFireButton.MenuState = MSAT_Disabled;
        FriendlyFire = 0;
        if (FriendlyFire==0)
          FriendlyFireButton.Caption  = NoString;
        else if (FriendlyFire==1)
          FriendlyFireButton.Caption  = YesString;
        else
          FriendlyFireButton.Caption  = AnyString;
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
  Maps[MaxMaps] = anystring;
  MaxMaps++;
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
  xboxlive.SetSetting(SETID_ONMAP, OnMap);
  MapNameButton.Caption = Maps[OnMap];
  /*
     local string FirstMap, NextMap, TestMap;
     local int Selected;
     local bool bFoundSavedMap;

     FirstMap = GetPlayerOwner().GetMapName(GameClass.Default.MapPrefix, "", 0);

     NextMap = FirstMap;
     MaxMaps = -1;

     MaxMaps++;
     Maps[MaxMaps] = AnyString;
     if (Map ~= AnyString || Map == "")
     {
        bFoundSavedMap = true;
        Selected = MaxMaps;
     }

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

function String GetLanguageString()
{
  switch (language)
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
  CycleLevels = -1;

  //language = LANG_All;
  language = GetLanguage(xboxlive.GetSetting(SETID_LANGUAGE));

  languageButton.Caption = GetLanguageString();

  IterateGames();
  IterateMaps(xboxlive.GetSetting(SETID_ONMAP));

  GameTypeButton.Caption  = GameTypeList[OnGame];
  if (OnMap==0)
    MapNameButton.Caption   = Maps[OnMap];
  else
    MapNameButton.Caption   = xboxlive.GetNiceName(Maps[OnMap]);

  MinPlayers = xboxlive.GetSetting(SETID_MINPLAYERS);
  MinPlayersButton.Caption = string(MinPlayers);

  MaxPlayers = xboxlive.GetSetting(SETID_MAXPLAYERS);
  if (MaxPlayers > 7) MaxPlayers = 7;
  if (MaxPlayers == 0) MaxPlayers = 7;
  MaxPlayersButton.Caption = string(MaxPlayers);

  //FriendlyFire = int(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
  FriendlyFire = xboxlive.GetSetting(SETID_FFIRE);
  if (FriendlyFire==0)
    FriendlyFireButton.Caption  = NoString;
  else if (FriendlyFire==1)
    FriendlyFireButton.Caption  = YesString;
  else
    FriendlyFireButton.Caption  = AnyString;

  /*
  FragLimit = class<XIIIMPGameInfo>(GameClass).Default.WinningScore;
  FragLimitButton.Caption = string(FragLimit);
  if (FragLimit == 0) FragLimitButton.Caption ="-";

  if (string(GameClass) == "XIIIMP.XIIIRocketArena")
  {
    TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime;
    TimeLimitButton.Caption = string(TimeLimit)@"sec";
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }
  else
  {
    TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime / 60;
    TimeLimitButton.Caption = string(TimeLimit);
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }
  */

  /*if (CycleLevels==0)
    CycleLevelsButton.Caption   = NoString;
  else if (CycleLevels==1)
    CycleLevelsButton.Caption  = YesString;
  else
    CycleLevelsButton.Caption  = AnyString;
  */
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
    if (OnMap==0)
      MapNameButton.Caption   = Maps[OnMap];
    else
      MapNameButton.Caption   = xboxlive.GetNiceName(Maps[OnMap]);
    MapChanged();
  }
  else if (c==MinPlayersButton)
  {
    if (MinPlayers>0)
      MinPlayers--;
    MinPlayersButton.Caption = string(MinPlayers);
    MinPlayersChanged();
  }
  else if (c==MaxPlayersButton)
  {
    if (MaxPlayers>MinPlayers && MaxPlayers>1)
      MaxPlayers--;
    MaxPlayersButton.Caption = string(MaxPlayers);
    MaxPlayersChanged();
  }
  /*else if (c==FragLimitButton)
  {
    FragLimit-=10;
    if (FragLimit<0)
      FragLimit = 0;
    class<XIIIMPGameInfo>(GameClass).Default.WinningScore = FragLimit;
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
      class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit;
      TimeLimitButton.Caption = string(TimeLimit)@"sec";
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    else
    {
      TimeLimit -= 5;
      if (TimeLimit<0)
        TimeLimit = 0;
      class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit*60;
      TimeLimitButton.Caption = string(TimeLimit);
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    TimeLimitChanged();
  }*/
  else if (c==FriendlyFireButton)
  {
    if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
    {
      FriendlyFire--;
      if (FriendlyFire<-1)
        FriendlyFire=1;
      if (FriendlyFire==0)
        FriendlyFireButton.Caption  = NoString;
      else if (FriendlyFire==1)
        FriendlyFireButton.Caption  = YesString;
      else
        FriendlyFireButton.Caption  = AnyString;
    }
    FriendlyFireChanged();
  }
  /*else if (c==CycleLevelsButton)
  {
    CycleLevels--;
    if (CycleLevels<-1)
      CycleLevels=1;
    if (CycleLevels==0)
      CycleLevelsButton.Caption  = NoString;
    else if (CycleLevels==1)
      CycleLevelsButton.Caption  = YesString;
    else
      CycleLevelsButton.Caption  = AnyString;
    CycleLevelsChanged();
  }*/
  else if (c==LanguageButton)
  {
    switch (language)
    {
      case LANG_All:
        language = LANG_ItalianOnly;
      break;
      case LANG_EnglishOnly:
        language = LANG_All;
      break;
      case LANG_FrenchOnly:
        language = LANG_EnglishOnly;
      break;
      case LANG_GermanOnly:
        language = LANG_FrenchOnly;
      break;
      case LANG_SpanishOnly:
        language = LANG_GermanOnly;
      break;
      case LANG_SwedishOnly:
        language = LANG_SpanishOnly;
      break;
      case LANG_DutchOnly:
        language = LANG_SwedishOnly;
      break;
      case LANG_ItalianOnly:
        language = LANG_DutchOnly;
      break;
    }
    LanguageButton.Caption = GetLanguageString();
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
    if (OnMap==0)
      MapNameButton.Caption   = Maps[OnMap];
    else
      MapNameButton.Caption   = xboxlive.GetNiceName(Maps[OnMap]);
    MapChanged();
  }
  else if (c==MinPlayersButton)
  {
    if (MinPlayers<MaxPlayers-1)
      MinPlayers++;
    MinPlayersButton.Caption = string(MinPlayers);
    MinPlayersChanged();
  }
  else if (c==MaxPlayersButton)
  {
    if (MaxPlayers<7)
      MaxPlayers++;
    MaxPlayersButton.Caption = string(MaxPlayers);
    MaxPlayersChanged();
  }
  /*
  else if (c==FragLimitButton)
  {
    FragLimit+=10;
    if (FragLimit>100)
      FragLimit = 100;
    class<XIIIMPGameInfo>(GameClass).Default.WinningScore = FragLimit;
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
      class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit;
      TimeLimitButton.Caption = string(TimeLimit)@"sec";
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    else
    {
      TimeLimit += 5;
      if (TimeLimit>60)
        TimeLimit = 60;
      class<XIIIMPGameInfo>(GameClass).Default.MaxTime = TimeLimit*60;
      TimeLimitButton.Caption = string(TimeLimit);
      if (TimeLimit == 0) TimeLimitButton.Caption ="-";
    }
    TimeLimitChanged();
  }
  */
  else if (c==FriendlyFireButton)
  {
    if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
    {
      FriendlyFire++;
      if (FriendlyFire>1)
        FriendlyFire = -1;
      if (FriendlyFire==0)
        FriendlyFireButton.Caption  = NoString;
      else if (FriendlyFire==1)
        FriendlyFireButton.Caption  = YesString;
      else
        FriendlyFireButton.Caption  = AnyString;
    }
    FriendlyFireChanged();
  }
  /*else if (c==CycleLevelsButton)
  {
    CycleLevels++;
    if (CycleLevels>1)
      CycleLevels = -1;
    if (CycleLevels==0)
      CycleLevelsButton.Caption  = NoString;
    else if (CycleLevels==1)
      CycleLevelsButton.Caption  = YesString;
    else
      CycleLevelsButton.Caption  = AnyString;
    CycleLevelsChanged();
  }*/
  else if (c==LanguageButton)
  {
    switch (language)
    {
      case LANG_All:
        language = LANG_EnglishOnly;
      break;
      case LANG_EnglishOnly:
        language = LANG_FrenchOnly;
      break;
      case LANG_FrenchOnly:
        language = LANG_GermanOnly;
      break;
      case LANG_GermanOnly:
        language = LANG_SpanishOnly;
      break;
      case LANG_SpanishOnly:
        language = LANG_SwedishOnly;
      break;
      case LANG_SwedishOnly:
        language = LANG_DutchOnly;
      break;
      case LANG_DutchOnly:
        language = LANG_ItalianOnly;
      break;
      case LANG_ItalianOnly:
        language = LANG_All;
      break;
    }
    LanguageButton.Caption = GetLanguageString();
    LanguageChanged();
  }
}

function GameChanged()
{
  local int msg;
  
  xboxlive.SetSetting(SETID_ONGAME, OnGame);

  GameType = Games[OnGame];
  GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameType, class'Class'));

  IterateMaps(0);
  if (string(GameClass) != "XIIIMP.XIIIMPGameInfo" && string(GameClass) != "XIIIMP.XIIIRocketArena")
  {
    FriendlyFireButton.bNeverFocus = false;
    FriendlyFireButton.MenuState = MSAT_Blurry;
    //MapCombo.bNeverFocus = false;
    FriendlyFire = int(class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale);
    if (FriendlyFire==0)
      FriendlyFireButton.Caption  = NoString;
    else if (FriendlyFire==1)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = AnyString;
  }
  else
  {
    FriendlyFireButton.MenuState = MSAT_Disabled;
    FriendlyFireButton.bNeverFocus = true;
    FriendlyFire = 0;
    if (FriendlyFire==0)
      FriendlyFireButton.Caption  = NoString;
    else if (FriendlyFire==1)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = AnyString;
  }

  //PublicSlots = class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers;
  //PublicSlotsButton.Caption = string(PublicSlots);

  //PrivateSlots = 0;
  //PrivateSlotsButton.Caption = string(PrivateSlots);

/*
  if (string(GameClass) == "XIIIMP.XIIIRocketArena")
  {
    TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime;
    TimeLimitButton.Caption = string(TimeLimit)@"sec";
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }
  else
  {
    TimeLimit = class<XIIIMPGameInfo>(GameClass).Default.MaxTime / 60;
    TimeLimitButton.Caption = string(TimeLimit);
    if (TimeLimit == 0) TimeLimitButton.Caption ="-";
  }

  FragLimit = class<XIIIMPGameInfo>(GameClass).Default.WinningScore;
  FragLimitButton.Caption = string(FragLimit);
  if (FragLimit == 0) FragLimitButton.Caption ="-";
*/

  //xboxlive.SessionSetGameType(GetGameType());
  //if (OnMap==0)
  //  xboxlive.SessionSetMapName("");
  //else
  //  xboxlive.SessionSetMapName(Maps[OnMap]);
  //xboxlive.SessionSetTimeLimit(TimeLimit);
  //xboxlive.SessionSetFragLimit(FragLimit);
  //xboxlive.SessionSetPublicSlots(PublicSlots);
  //xboxlive.SessionSetPrivateSlots(PrivateSlots);
  //xboxlive.SessionSetFriendlyFire(FriendlyFire);
  //xboxlive.SessionSetCycleLevels(CycleLevels);
  //xboxlive.SessionSetLanguage(language);
}

function MapChanged()
{
  local int msg;
  xboxlive.SetSetting(SETID_ONMAP, OnMap);
  if (OnMap == 0)
  {
    Map = "";
    //xboxlive.SessionSetMapName("");
  }
  else
  {
    Map = Maps[OnMap]$".unr";//MapNameButton.Caption$".unr";
    //xboxlive.SessionSetMapName(Maps[OnMap]);
  }
}

function MinPlayersChanged()
{
  //local int msg;
  //xboxlive.SessionSetPublicSlots(PublicSlots);
  xboxlive.SetSetting(SETID_MINPLAYERS, MinPlayers );
}

function MaxPlayersChanged()
{
  //local int msg;
  //xboxlive.SessionSetPrivateSlots(PrivateSlots);
  xboxlive.SetSetting(SETID_MAXPLAYERS, MaxPlayers );
}

function FragLimitChanged()
{
  //local int msg;
  //xboxlive.SessionSetFragLimit(FragLimit);
}

function TimeLimitChanged()
{
  //local int msg;
  //xboxlive.SessionSetTimeLimit(TimeLimit);
}

function FriendlyFireChanged()
{
  //local int msg;
  //xboxlive.SessionSetFriendlyFire(FriendlyFire);
  xboxlive.SetSetting(SETID_FFIRE, FriendlyFire );
}

function CycleLevelsChanged()
{
  //local int msg;
  //xboxlive.SessionSetCycleLevels(CycleLevels);
}

function LanguageChanged()
{
  //local int msg;
  //xboxlive.SessionSetLanguage(language);
  xboxlive.SetSetting(SETID_LANGUAGE, language );
}

function Created()
{
  local int i;
  local int msg;

  Super.Created();

  GameTypeButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15-30, 100, 150+30, 30));
  MapNameButton         = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15, 135, 150, 30));
  MinPlayersButton      = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15-20, 170, 90, 30));
  MaxPlayersButton      = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15-20, 205, 90, 30));
  //FragLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 525-37, 240, 75, 30));
  //TimeLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 525-37, 275, 75, 30));
  FriendlyFireButton    = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-15-20, 240, 90, 30));
  //CycleLevelsButton     = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10, 275, 50, 30));
  LanguageButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-15, 275, 150, 30));

  Controls[0]=GameTypeButton;
  Controls[1]=MapNameButton;
  Controls[2]=MinPlayersButton;
  Controls[3]=MaxPlayersButton;
  //Controls[4]=FragLimitButton;
  //Controls[5]=TimeLimitButton;
  Controls[4]=FriendlyFireButton;
  //Controls[5]=CycleLevelsButton;
  Controls[5]=LanguageButton;
  for (i=0; i<6; i++)
  {
    Controls[i].StyleName = "SquareButton";
    XIIIGuiButton(Controls[i]).bDrawArrows = true;
  }

  Labels[0] = GUILabel(CreateControl(class'GUILabel', 270, 100, 170, 26));
  Labels[0].caption = LabelNames[0];
  Labels[0].StyleName="LabelWhite";
  Labels[0].TextColor.R=255;
  Labels[0].TextColor.G=255;
  Labels[0].TextColor.B=255;
  controls[6] = Labels[0];
  Labels[1] = GUILabel(CreateControl(class'GUILabel', 270, 135, 170, 26));
  Labels[1].caption = LabelNames[1];
  Labels[1].StyleName="LabelWhite";
  Labels[1].TextColor.R=255;
  Labels[1].TextColor.G=255;
  Labels[1].TextColor.B=255;
  controls[7] = Labels[1];
  Labels[2] = GUILabel(CreateControl(class'GUILabel', 270, 170, 170, 26));
  Labels[2].caption = LabelNames[2];
  Labels[2].StyleName="LabelWhite";
  Labels[2].TextColor.R=255;
  Labels[2].TextColor.G=255;
  Labels[2].TextColor.B=255;
  controls[8] = Labels[2];
  Labels[3] = GUILabel(CreateControl(class'GUILabel', 270, 205, 170, 26));
  Labels[3].caption = LabelNames[3];
  Labels[3].StyleName="LabelWhite";
  Labels[3].TextColor.R=255;
  Labels[3].TextColor.G=255;
  Labels[3].TextColor.B=255;
  controls[9] = Labels[3];
  Labels[4] = GUILabel(CreateControl(class'GUILabel', 270, 240, 170, 26));
  Labels[4].caption = LabelNames[4];
  Labels[4].StyleName="LabelWhite";
  Labels[4].TextColor.R=255;
  Labels[4].TextColor.G=255;
  Labels[4].TextColor.B=255;
  controls[10] = Labels[4];
  Labels[5] = GUILabel(CreateControl(class'GUILabel', 270, 275, 150, 26));
  Labels[5].caption = LabelNames[5];
  Labels[5].StyleName="LabelWhite";
  Labels[5].TextColor.R=255;
  Labels[5].TextColor.G=255;
  Labels[5].TextColor.B=255;
  controls[11] = Labels[5];
  /*Labels[6] = GUILabel(CreateControl(class'GUILabel', 270, 310, 150, 26));
  Labels[6].caption = LabelNames[6];
  Labels[6].StyleName="LabelWhite";
  Labels[6].TextColor.R=255;
  Labels[6].TextColor.G=255;
  Labels[6].TextColor.B=255;
  controls[13] = Labels[6];
  */

  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';

  ResetButtons();

  //xboxlive.SessionSetGameType(GetGameType());
  //if (OnMap==0)
  //  xboxlive.SessionSetMapName("");
  //else
  //  xboxlive.SessionSetMapName(Maps[OnMap]);
  //xboxlive.SessionSetLanguage(LANG_EnglishOnly);
  //xboxlive.SessionSetFragLimit(FragLimit);
  //xboxlive.SessionSetTimeLimit(TimeLimit);
  //xboxlive.SessionSetPublicSlots(PublicSlots);
  //xboxlive.SessionSetPrivateSlots(PrivateSlots);
  //xboxlive.SessionSetReserved(1);
  //xboxlive.SessionSetFriendlyFire(FriendlyFire);
  //xboxlive.SessionSetCycleLevels(CycleLevels);
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      //log("[XIIILiveMsgBox] Ok pressed");
      //xboxlive.ShutdownAndCleanup();
      //xboxlive.SessionReset();
	    //myRoot.CloseMenu(true);
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
     bShowSCH = true;
     //bShowSEL = true;
}

function Paint(Canvas C, float X, float Y)
{
  super.Paint(C,X,Y);
  PaintStandardBackground(C, X, Y, TitleText);

  if (bAutoUpdate)
  {
    bAutoUpdate = false;
    StartPressed();
  }

}

function StartPressed()
{
  local bool result;
  local int msg;
  local XboxLiveManager.eGameType gt;
  local XIIIMenuLiveOptimatchResultWindow reswin;
  local string map;
  
  gt = GetGameType();

  if (OnMap==0)
    result = xboxlive.OptimatchStartQuery(gt, "", language, minplayers, maxplayers, friendlyFire, cycleLevels, SKILL_Beginner, SKILL_Elite);
  else
    result = xboxlive.OptimatchStartQuery(gt, Maps[OnMap], language, minplayers, maxplayers, friendlyFire, cycleLevels, SKILL_Beginner, SKILL_Elite);

  if (!result)
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
  }
  else
  {
      if (OnMap == 0)
        map 	= xboxlive.GetRandomMap(gt);
      else
        map 	= Maps[OnMap];
	xboxlive.SetSearchParams(gt,map,friendlyFire,language);
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveOptimatchResultWindow");
  }


  //updateMe = true;

  /*
     local string URL, Checksum;
     local int N;

     if (GameType != "XIIIMP.XIIIMPGameInfo" && GameType != "XIIIMP.XIIIRocketArena")
        class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);

     N = PublicSlots+PrivateSlots;//PlayerCombo.GetValue();
     class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = N;
     //GetPlayerOwner().ConsoleCommand("SetViewPortNumberForNextMap "$N);
     MapChanged(); GameChanged();
     //TimeChanged(); FragChanged();
     URL = Map$"?Game="$GameType$"?Listen";
    SaveConfigs();
    myRoot.bXboxStartup = true;
    myRoot.CloseAll(true);
    myRoot.GotoState('');
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
    StartPressed();
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


