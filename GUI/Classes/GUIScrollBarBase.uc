// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIScrollBarBase extends GUIMultiComponent
        Native;

var GUIListBase MyList;         // The list this Scrollbar is attached to

function UpdateGripPosition(float NewPos);
function MoveGripBy(int items);
event AlignThumb();



defaultproperties
{
}
