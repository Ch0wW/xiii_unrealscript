//============================================================================
// UbiSoft's Game Service menu.
//
//============================================================================
class XIIIMenuMultiBase extends XIIIWindowMainMenu;

VAR texture tBackground01, tBackground02, tBackground03, tBackground04;
CONST NbGameType=6;
VAR BOOL bUseDefaultBackground;
VAR localized string GameTypeText[NbGameType];
VAR string GameInfoText[NbGameType], PrefixText[NbGameType], MutatorText[NbGameType];
VAR int DefaultGameTypeValue[NbGameType], PointsLimitFactor[NbGameType];
VAR ARRAY<int> AllowedGameTypeIndex, GameMapsIndex, NbPlayers;
VAR int MaxAllMaps, MaxMaps;
VAR Array<string> MapsList, DescList;
VAR ARRAY<byte> DMOnly;

CONST DeathmatchIndex = 0;
CONST TeamDeathmatchIndex = 1;
CONST CaptureTheFlagIndex = 2;
CONST TheHuntIndex = 3;
CONST SabotageIndex = 4;
CONST PowerUpIndex = 5;

//============================================================================

FUNCTION Paint(Canvas C, float X, float Y)
{
	Super.Paint(C,X,Y);

	if ( bUseDefaultBackground )
	{
		DrawStretchedTexture(C, 28*fRatioX, 28*fScaleTo*fRatioY, 584*fRatioX, 406*fRatioY*fScaleTo, myRoot.tFondNoir);

		DrawStretchedTexture(C,  30*fRatioX,  30*fScaleTo*fRatioY, 290*fRatioX, 201*fScaleTo*fRatioY, tBackGround01);
		DrawStretchedTexture(C, 320*fRatioX,  30*fScaleTo*fRatioY, 290*fRatioX, 201*fScaleTo*fRatioY, tBackGround02);
		DrawStretchedTexture(C,  30*fRatioX, 231*fScaleTo*fRatioY, 290*fRatioX, 201*fScaleTo*fRatioY, tBackGround03);
		DrawStretchedTexture(C, 320*fRatioX, 231*fScaleTo*fRatioY, 290*fRatioX, 201*fScaleTo*fRatioY, tBackGround04);
	}
}

FUNCTION string GetGameTypeText( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return GameTypeText[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return "Invalid GameType" ;
}

FUNCTION string GetGameInfoText( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return GameInfoText[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return "" ;
}

FUNCTION string GetPrefixText( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return PrefixText[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return "" ;
}

FUNCTION string GetMutatorText( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return MutatorText[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return "" ;
}

FUNCTION bool IsDeathMatch( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return ( AllowedGameTypeIndex[ AllowedIndex ] == DeathmatchIndex ) ;
	else
		return false ;
}

FUNCTION bool IsTeamDeathMatch( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return ( AllowedGameTypeIndex[ AllowedIndex ] == TeamDeathmatchIndex ) ;
	else
		return false ;
}

FUNCTION bool HasFriendlyFire( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return ( AllowedGameTypeIndex[ AllowedIndex ] == TeamDeathmatchIndex )
			|| ( AllowedGameTypeIndex[ AllowedIndex ] == CaptureTheFlagIndex )
			|| ( AllowedGameTypeIndex[ AllowedIndex ] == SabotageIndex );
	else
		return false ;
}

FUNCTION bool HasTimeAndFragLimits( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return ( AllowedGameTypeIndex[ AllowedIndex ] != SabotageIndex );
	else
		return false ;
}

FUNCTION string Underscores2Spaces( string strVar )
{
	LOCAL string strResult, strCar;
	LOCAL int i;

	for ( i = 0; i < len( strVar ); i++ )
	{
		strCar = Mid( strVar, i, 1 );
		if ( strCar=="_" )
			strResult = strResult $ " ";
		else
			strResult = strResult $ strCar;
			
	}
	return strResult;
}

FUNCTION string Spaces2Underscores( string strVar )
{
	LOCAL string strResult, strCar;
	LOCAL int i;

	for ( i = 0; i < len( strVar ); i++ )
	{
		strCar = Mid( strVar, i, 1 );
		if ( strCar==" " )
			strResult = strResult $ "_";
		else
			strResult = strResult $ strCar;
			
	}
	return strResult;
}
/*
FUNCTION string SkipSquareBrackets( string strVar )
{
	LOCAL int LBracketIndex, RBracketIndex;
	LBracketIndex = InStr( strVar, "[" );
	RBracketIndex = InStr( strVar, "[" );
	if ( LBracketIndex==0 && RBracketIndex!=-1 )
		return Mid( strVar, RBracketIndex+1 );
	else
		return strVar;
}
*/
FUNCTION Created()
{
	LOCAL int i;

	SUPER.Created();

	// real names of maps
	MaxAllMaps = class'MapList'.default.MapListInfo.Length;

	if ( MaxAllMaps > 0 )
	{
		for (i=0; i<MaxAllMaps; i++)
		{
			if	( CanBePlayedOnThisPlateform(i) )
			{
				if ( myRoot.CurrentPF == 0 )
				{
					DescList[DescList.Length] = class'MapList'.default.MapListInfo[i].MapReadableName;
				}
				else
				{
					if (( myRoot.CurrentPF == 1 ) && ( class'MapList'.default.MapListInfo[i].NbPlayers > 6 ))
						DescList[DescList.Length] = "[6] "$class'MapList'.default.MapListInfo[i].MapReadableName;
					else
						DescList[DescList.Length] = "["$class'MapList'.default.MapListInfo[i].NbPlayers$"] "$class'MapList'.default.MapListInfo[i].MapReadableName;
				}
				MapsList[MapsList.Length] = class'MapList'.default.MapListInfo[i].MapUnrName;
				NbPlayers[NbPlayers.Length] = class'MapList'.default.MapListInfo[i].NbPlayers;
				if ( class'MapList'.default.MapListInfo[i].bDeathMatchOnly )
					DMOnly[DMOnly.Length]=1;
				else
					DMOnly[DMOnly.Length]=0;
			}
		}
	}

	MaxAllMaps = MapsList.Length;
}

FUNCTION bool CanBePlayedOnThisPlateform( int AbsoluteMapIndex )
{
	return 
		( myRoot.CurrentPF == 0 && class'MapList'.default.MapListInfo[AbsoluteMapIndex].bOnPC ) 
	||	( myRoot.CurrentPF == 1 && class'MapList'.default.MapListInfo[AbsoluteMapIndex].bOnPS2 )
	||	( myRoot.CurrentPF == 2 && class'MapList'.default.MapListInfo[AbsoluteMapIndex].bOnXBOX )
	||	( myRoot.CurrentPF == 3 && class'MapList'.default.MapListInfo[AbsoluteMapIndex].bOnCube );
}

FUNCTION bool MapPrefixMatch( int AbsoluteMapIndex, string Prefix )
{
	return Left(MapsList[AbsoluteMapIndex],2) ~= Prefix;
}


FUNCTION GetMapArray( int AllowedIndex, out ARRAY<STRING> MapDescArray, out ARRAY<STRING> MapUNRArray )
{
	LOCAL int i;

	MapDescArray.Length = 0;
	MapUNRArray.Length = 0;
	GameMapsIndex.Length = 0;

	for ( i=0; i<MaxAllMaps; i++ )
	{
		// if we are in deathmatch mode, deathmatch specific maps can be used
		// if we are in team deathmatch mode, CTF maps can be used
		if	(	AllowedIndex==-1 
				||	( IsDeathMatch( AllowedIndex ) && MapPrefixMatch( i,GetPrefixText(DeathMatchIndex) ) )
				||	( MapPrefixMatch(i,GetPrefixText(AllowedIndex) ) && ( DMOnly[i]==0 ) )
				||	( IsTeamDeathMatch( AllowedIndex ) && MapPrefixMatch( i,PrefixText[CaptureTheFlagIndex] ) )
			)
		{
			// Add the map.
			MapDescArray[MapDescArray.Length] = DescList[i];
			MapUNRArray[MapUNRArray.Length] = MapsList[i];
			GameMapsIndex[GameMapsIndex.Length] = i;
		}
	}
	MaxMaps=MapDescArray.Length;
}


FUNCTION int GetDefaultGameTypeValue( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return DefaultGameTypeValue[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return 0 ;
}


FUNCTION int GetPointsLimitFactor( int AllowedIndex )
{
	if ( AllowedIndex>=0 && AllowedIndex<AllowedGameTypeIndex.Length )
		return PointsLimitFactor[ AllowedGameTypeIndex[ AllowedIndex ] ] ;
	else
		return 0 ;
}



defaultproperties
{
     tBackground01=Texture'XIIIMenuStart.Multi_rules.multilive01'
     tBackground02=Texture'XIIIMenuStart.Multi_rules.multilive02'
     tBackground03=Texture'XIIIMenuStart.Multi_rules.multilive03'
     tBackground04=Texture'XIIIMenuStart.Multi_rules.multilive04'
     bUseDefaultBackground=True
     GameTypeText(0)="Deathmatch"
     GameTypeText(1)="Team Deathmatch"
     GameTypeText(2)="Capture The Flag"
     GameTypeText(3)="The Hunt"
     GameTypeText(4)="Sabotage"
     GameTypeText(5)="Power Up"
     GameInfoText(0)="XIIIMP.XIIIMPGameInfo"
     GameInfoText(1)="XIIIMP.XIIIMPTeamGameInfo"
     GameInfoText(2)="XIIIMP.XIIIMPCTFGameInfo"
     GameInfoText(3)="XIIIMP.XIIIMPDuckGameInfo"
     GameInfoText(4)="XIIIMP.XIIIMPBombGame"
     GameInfoText(5)="XIIIMP.XIIIMPGameInfo"
     PrefixText(0)="DM"
     PrefixText(1)="DM"
     PrefixText(2)="CT"
     PrefixText(3)="DM"
     PrefixText(4)="SB"
     PrefixText(5)="DM"
     MutatorText(5)="XIIIMP.MarioMutator"
     DefaultGameTypeValue(0)=10
     DefaultGameTypeValue(1)=10
     DefaultGameTypeValue(2)=5
     DefaultGameTypeValue(3)=100
     DefaultGameTypeValue(5)=10
     PointsLimitFactor(0)=10
     PointsLimitFactor(1)=10
     PointsLimitFactor(2)=1
     PointsLimitFactor(3)=50
     PointsLimitFactor(5)=10
}
