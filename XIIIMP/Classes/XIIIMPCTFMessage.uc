//
// CTF Messages
//
// 0: Capture Message. RelatedPRI_1 is the scorer. OptionalObject is the flag.
// 1: Return Message. RelatedPRI_1 is the scorer. OptionalObject is the flag.
// 2: Dropped Message. RelatedPRI_1 is the holder. OptionalObject is the flag's team teaminfo.
// 3: Was Returned Message. OptionalObject is the flag's team teaminfo.
// 4: Has the flag. RelatedPRI_1 is the holder. OptionalObject is the flag's team teaminfo.
// 5: Auto Send Home. OptionalObject is the flag's team teaminfo.
// 6: Pickup stray. RelatedPRI_1 is the holder. OptionalObject is the flag's team teaminfo.

class XIIIMPCTFMessage extends XIIILocalMessage;

var localized string ReturnBlue, ReturnRed;
var localized string ReturnedBlue, ReturnedRed;
var localized string CaptureBlue, CaptureRed;
var localized string DroppedBlue, DroppedRed;
var localized string HasBlue,HasRed;

static function string GetString(
     optional int Switch,
     optional PlayerReplicationInfo RelatedPRI_1,
     optional PlayerReplicationInfo RelatedPRI_2,
     optional Object OptionalObject
     )
{
     switch (Switch)
     {
          case 0:
               if (RelatedPRI_1 == None)
                    return "";
               if ( XIIIMPFlag(OptionalObject) == None )
                    return "";

               if ( XIIIMPFlag(OptionalObject).Team.TeamIndex == 0 )
                    return Default.CaptureRed;
               else
                    return Default.CaptureBlue;
               break;

          // Returned the flag.
          case 1:
               if ( XIIIMPFlag(OptionalObject) == None )
                    return "";
               if (RelatedPRI_1 == None)
               {
                    if ( XIIIMPFlag(OptionalObject).Team.TeamIndex == 1 )
                         return Default.ReturnedRed;
                    else
                         return Default.ReturnedBlue;
               }
               if ( XIIIMPFlag(OptionalObject).Team.TeamIndex == 0 )
                    return RelatedPRI_1.PlayerName@Default.ReturnRed;
               else
                    return RelatedPRI_1.playername@Default.ReturnBlue;
               break;

          // Dropped the flag.
          case 2:
               if (RelatedPRI_1 == None)
                    return "";
               if ( TeamInfo(OptionalObject) == None )
                    return "";

               if ( TeamInfo(OptionalObject).TeamIndex == 0 )
                    return RelatedPRI_1.playername@Default.DroppedRed;
               else
                    return RelatedPRI_1.playername@Default.DroppedBlue;
               break;

          // Was returned.
          case 3:
               if ( TeamInfo(OptionalObject) == None )
                    return "";

               if ( TeamInfo(OptionalObject).TeamIndex == 0 )
                    return Default.ReturnedRed;
               else
                    return Default.ReturnedBlue;
               break;

          // Has the flag.
          case 4:
               if (RelatedPRI_1 == None)
                    return "";
               if ( TeamInfo(OptionalObject) == None )
                    return "";

               if ( TeamInfo(OptionalObject).TeamIndex == 0 )
                    return RelatedPRI_1.playername@Default.HasRed;
               else
                    return RelatedPRI_1.playername@Default.HasBlue;
               break;

          // Auto send home.
          case 5:
               if ( TeamInfo(OptionalObject) == None )
                    return "";

               if ( TeamInfo(OptionalObject).TeamIndex == 0 )
                    return Default.ReturnedRed;
               else
                    return Default.ReturnedBlue;
               break;

          // Pickup
          case 6:
               if (RelatedPRI_1 == None)
                    return "";
               if ( TeamInfo(OptionalObject) == None )
                    return "";

               if ( TeamInfo(OptionalObject).TeamIndex == 0 )
                    return RelatedPRI_1.playername@Default.HasRed;
               else
                    return RelatedPRI_1.playername@Default.HasBlue;
               break;
     }
     return "";
}


/*static function float GetOffset(int Switch, float YL, float ClipY )
{
     return (Default.YPos/768.0) * ClipY;
}

static function int GetFontSize(int Switch)
{
     return Default.FontSize;
}*/




defaultproperties
{
     ReturnBlue="returns the blue flag"
     ReturnRed="returns the red flag"
     ReturnedBlue="The blue flag was returned"
     ReturnedRed="The red flag was returned"
     CaptureBlue="The red team scores"
     CaptureRed="The blue team scores"
     DroppedBlue="dropped the blue flag"
     DroppedRed="dropped the red flag"
     HasBlue="has the blue flag"
     HasRed="has the red flag"
     DrawColor=(B=168,R=255,A=230)
}
