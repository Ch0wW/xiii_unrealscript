class XIIIMenuMultiGSFindServers extends XIIIWindowMainMenu;

defaultproperties
{
     CreateText="Create"
     FilterText="Filter"
     RefreshText="Refresh"
     BackText="Back"
     SearchingText="Searching..."
     ConfirmationText="Confirmation requested"
     ConfirmExitText="You will disconnect from UBI.com.|Please confirm"
     ErrorText="Unable to get servers"
     sGameType="Game Type"
     sAllGameTypes="All"
     sMapName="Map"
     sAllMaps="All"
     sPrivateGames="Show private games"
     sPrivateGameVisible="Yes"
     sPrivateGamesHidden="No"
     tPrivate=Texture'XIIIMenuStart.Multi_rules.Private'
     tConnection(0)=Texture'XIIIMenuStart.Multi_rules.connectgris'
     tConnection(1)=Texture'XIIIMenuStart.Multi_rules.connectvert'
     tConnection(2)=Texture'XIIIMenuStart.Multi_rules.connectorang'
     tHighlight=Texture'XIIIMenuStart.Control_Console_advanced.barreselectmenuoptadv'
     NbServersByPage=7
     Filter=(GameTypeIndex=-1,Private=True)
     sWorking(0)="GUIContent.Working01"
     sWorking(1)="GUIContent.Working02"
     sWorking(2)="GUIContent.Working03"
     sWorking(3)="GUIContent.Working02"
     hSoundMenu2=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMulti2'
}
