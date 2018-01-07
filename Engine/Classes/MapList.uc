//=============================================================================
// MapList.
// contains a list of maps to check names in .ini (to allow download new maps)
// Used as STATIC
//=============================================================================
class MapList extends Info
  config(MapList) native;

struct StructMapInfo
{
  var string MapReadableName;
  var string MapUnrName;
  var int NbPlayers;
  var bool bDeathMatchOnly;  // map only available for deathmatch mode
  var bool bOnXBox;			// map available on XBox platform
  var bool bOnPC;			// map available on PC platform
  var bool bOnCube;			// map available on Cube platform
  var bool bOnPS2;			// map available on PS2 platform
};

var config array<StructMapInfo> MapStructInfo;

defaultproperties
{
     MapStructInfo(0)=(MapReadableName="Winslow Bank",MapUnrName="DM_Banque.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(1)=(MapReadableName="Platform 02",MapUnrName="DM_Base.unr",NbPlayers=4,bOnCube=True,bOnPS2=True)
     MapStructInfo(2)=(MapReadableName="Platform 02",MapUnrName="DM_Base_XBox.unr",NbPlayers=4,bOnXBox=True,bOnPC=True)
     MapStructInfo(3)=(MapReadableName="AFM-10",MapUnrName="DM_Base2.unr",NbPlayers=4,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(4)=(MapReadableName="Emerald",MapUnrName="DM_Hual1.unr",NbPlayers=4,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(5)=(MapReadableName="FBI",MapUnrName="DM_Amos.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(6)=(MapReadableName="Bristol Suites",MapUnrName="DM_Pal.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(7)=(MapReadableName="SPADS",MapUnrName="DM_Spads.unr",NbPlayers=4,bOnCube=True,bOnPS2=True)
     MapStructInfo(8)=(MapReadableName="SPADS",MapUnrName="DM_Spads_XBox.unr",NbPlayers=6,bOnXBox=True,bOnPC=True)
     MapStructInfo(9)=(MapReadableName="Plain Rock",MapUnrName="DM_PRock.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(10)=(MapReadableName="Warehouse 33",MapUnrName="DM_Warehouse.unr",NbPlayers=4,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(11)=(MapReadableName="USS-Patriot",MapUnrName="CTF_Base.unr",NbPlayers=8,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(12)=(MapReadableName="XX",MapUnrName="CTF_Sanc.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(13)=(MapReadableName="Kellownee",MapUnrName="CTF_Snow.unr",NbPlayers=6,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(14)=(MapReadableName="New York",MapUnrName="CTF_Toits.unr",NbPlayers=8,bOnXBox=True,bOnPC=True,bOnCube=True,bOnPS2=True)
     MapStructInfo(15)=(MapReadableName="Temple",MapUnrName="CTF_Temple.unr",NbPlayers=8,bOnXBox=True,bOnPC=True,bOnCube=True)
     MapStructInfo(16)=(MapReadableName="Docks",MapUnrName="SB_USA2.unr",NbPlayers=8,bOnXBox=True,bOnPC=True)
     MapStructInfo(17)=(MapReadableName="Choland",MapUnrName="SB_Hual1a.unr",NbPlayers=8,bOnXBox=True,bOnPC=True)
     MapStructInfo(18)=(MapReadableName="Camp",MapUnrName="SB_Camp.unr",NbPlayers=8,bOnXBox=True,bOnPC=True)
     MapStructInfo(19)=(MapReadableName="Hualpar",MapUnrName="DM_Hual04a.unr",NbPlayers=4,bDeathMatchOnly=True,bOnXBox=True,bOnPC=True)
     MapStructInfo(20)=(MapReadableName="Asylum",MapUnrName="DM_PRock01a.unr",NbPlayers=4,bDeathMatchOnly=True,bOnXBox=True,bOnPC=True)
     MapStructInfo(21)=(MapReadableName="USA",MapUnrName="DM_USA01.unr",NbPlayers=4,bDeathMatchOnly=True,bOnXBox=True,bOnPC=True)
     MapStructInfo(22)=(MapReadableName="SS-419",MapUnrName="DM_SM01.unr",NbPlayers=4,bDeathMatchOnly=True,bOnXBox=True,bOnPC=True)
}
