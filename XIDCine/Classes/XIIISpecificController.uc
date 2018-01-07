//=============================================================================
// XIIISpecificController.
// Created by iKi on Dec ??th 2001
// Last Modification Feb 04th 2002
//=============================================================================
class XIIISpecificController extends AIController;

VAR XIIIPlayerController PC;

FUNCTION Actor GetPositionInfo(int index)
{
	LOCAL PositionInfo pi;

	foreach DynamicActors( class'PositionInfo',pi )
	{
		if (pi.name==name("PositionInfo"$index))
		return pi;
	}
	DebugLog("###"@Name@": Can't find actor 'PositionInfo"$index$"'.");
	return none;
}

FUNCTION FindPlayerController()
{
	PC=XIIIPlayerController(Level.ControllerList);
/*	LOCAL Controller C;
	for( C=Level.ControllerList; C!=None; C=C.nextController )
		if( C.IsA('PlayerController') )
		{
			PC=XIIIPlayerController(C);
			break;
		}*/
}

FUNCTION int CountPawnByTag(name t)
{
	LOCAL Pawn P;
	LOCAL int n;
	n=0;
	foreach DynamicActors( class'Pawn',P ,t)
		n++;
	return n;
}

FUNCTION DisableEnnemyGroupByTag(name t)
{
	LOCAL Pawn P;

	foreach DynamicActors( class'Pawn',P ,t)
	{
		if (P.IsA('basesoldier'))
		{
			P.bstasis=true;
			P.Controller.bstasis=true;
		}
	}
}

FUNCTION EnableEnnemyGroupByTag(name t)
{
	LOCAL Pawn P;

	foreach DynamicActors( class'Pawn',P ,t)
	{
		if (P.IsA('basesoldier'))
		{
			P.bstasis=false;
			P.Controller.bstasis=false;
		}
	}
}

FUNCTION UseActorRotation(Actor A)
{
	FocalPoint=A.Location+1000*vector(A.Rotation);
	Focus=none;
}

// DebugLog
FUNCTION DebugLog(string str)
{
	PC.MyHud.LocalizedMessage(class'XIIIDialogMessage',0, none,none,none,"DEBUG : "@str);
}

// put the right pawn position and rotation after a developped animation
FUNCTION CorrectPosition()
{
	Pawn.SetLocation(Pawn.GetBoneCoords('X').Origin);
	Pawn.SetRotation(Pawn.GetBoneRotation('X'));
}



defaultproperties
{
}
