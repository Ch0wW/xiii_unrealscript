class XIIIMenuChooseMap extends XIIIWindow;

var string MapList[64];
var int MaxMaps, onMap;
var localized string MapText;
var color MapColor;

var XIIIbutton DndButton, GodButton, FlyButton, EquipButton, NeuButton, Ghostbutton, Gobutton;
var localized string DndText, GodText, FlyText, EquipText, NeuText, GhostText, GoText;


function Created()
{
     Super.Created();

     IterateMaps("");

/*
     Gobutton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 160, 200, 30));
     Gobutton.Text=GoText;
     Gobutton.bNoBg =true;
     FlyButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 220, 200, 30));
     FlyButton.Text = FlyText;
     FlyButton.bNoBg =true;
     EquipButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 250, 200, 30));
     EquipButton.Text=EquipText;
     EquipButton.bNoBg =true;
     DndButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 280, 200, 30));
     DndButton.Text=NeuText;
     DndButton.bNoBg =true;
     Ghostbutton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 310, 200, 30));
     Ghostbutton.Text=GhostText;
     Ghostbutton.bNoBg =true;
     GodButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 330, 200, 30));
     GodButton.Text=GodText;
     GodButton.bNoBg =true;

Controls[0] = Gobutton;
    Controls[5] = GodButton; Controls[1] = FlyButton;
    Controls[2] = EquipButton; Controls[3] = DndButton; Controls[4] = GhostButton;
*/
}


function IterateMaps(string DefaultMap)
{
     local string FirstMap, NextMap, TestMap;
     local int Selected;

     FirstMap = GetPlayerOwner().GetMapName("", "", 0);

     NextMap = FirstMap;
     MaxMaps = 0;
     while (!(FirstMap ~= TestMap))
     {
          if(!(Left(NextMap, 7) ~= "mapmenu") && !(Left(NextMap, 5) ~= "entry"))
          {
               if(!(Left(NextMap, 2) ~= "DM") && !(Left(NextMap, 2) ~= "CM") && !(Left(NextMap, 2) ~= "CT")) //Len(NextMap) -
               {
                    if (!(Left(NextMap, 4) ~= "auto") && !(Left(NextMap, 4) ~= "cine"))
                    {
                    log("NextMap: "$NextMap);
                    MapList[MaxMaps] = left(NextMap, Len(NextMap) - 4);
                    MaxMaps++;
                    }
               }
          }

          // Get the map.
          NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);
          // Text to see if this is the last.
          TestMap = NextMap;
     }
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = true;
}


function Paint(Canvas C, float X, float Y)
{
     local float fScale;

     Super.Paint(C, X, Y);

     C.Style = 1; 
     C.DrawColor = GoldColor;
     C.SetPos( 32, 50); C.DrawText(Caps("Load a map"), false);

     MapColor = HighlightColor;
     C.SetPos(32, 100);
     C.DrawColor = MapColor;
     C.DrawText(Caps(MapText)$"        "$Caps(MapList[OnMap]), false);
     C.DrawColor = WhiteColor;
}


function StartMap()
{
     local string URL, Checksum;

     URL = MapList[OnMap] $ "?Game=XIII.XIIIGameInfo";
     myRoot.bCloseAfterLoading = true;
     myRoot.CloseAll(true);
     myRoot.gotostate('');
     GetPlayerOwner().ConsoleCommand("SetViewPortNumberForNextMap 1");
     GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if ((State==1) || (state==2))// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
            StartMap();    
        /*switch(FindComponentIndex(FocusedControl))
            {
               case 0: StartMap();
               break;
               case 1: GetPlayerOwner().ConsoleCommand("TeleportNext");
               break;
               case 2: GetPlayerOwner().ConsoleCommand("EquipMe");
               break;
               case 3: GetPlayerOwner().ConsoleCommand("DAndD");
               break;
               case 4: GetPlayerOwner().ConsoleCommand("Ghost");
               break;
               case 5: GetPlayerOwner().ConsoleCommand("God");
               break;
               
            }
            */
            return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
	        OnMap--;
	        if (OnMap < 0) OnMap = 0;
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
            OnMap++;
	        if (OnMap > MaxMaps-1) OnMap = MaxMaps-1;
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     MapText="Map Name:"
     DndText="Deaf & Dumb"
     GodText="God"
     FlyText="Teleport"
     EquipText="EquipMe"
     NeuText="Neu neu"
     GhostText="Ghost"
     GoText="Go!"
}
