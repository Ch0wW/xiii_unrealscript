//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPDuckMessage extends XIIILocalMessage;

var localized string HasTheDuck,LoseTheDuck, KillTheKKK;
var localized string HasX,XPoints,XPoint;

//_____________________________________________________________________________

static function string GetString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    local string NbPoint;

    NbPoint = string(switch);

    if( switch == -1 )
    {
        return RelatedPRI_1.PlayerName@Default.LoseTheDuck;
    }
    else if( switch == 0 )
    {
        if( RelatedPRI_1.PlayerName == "" )
            return "";
        else
            return RelatedPRI_1.PlayerName@Default.HasTheDuck;
    }
    else if( switch == 1 )
        return RelatedPRI_1.PlayerName@Default.HasX@NbPoint@Default.XPoint;
    else if( switch == -2 )
    {
        if( RelatedPRI_1.PlayerName == "" )
            return "";
        else
            return RelatedPRI_1.PlayerName@Default.KillTheKKK;
    }
    else
        return RelatedPRI_1.PlayerName@Default.HasX@NbPoint@Default.XPoints;
}

//_____________________________________________________________________________



defaultproperties
{
     HasTheDuck="has the Bird !"
     LoseTheDuck="Lose The Bird !"
     KillTheKKK="Killed The Death ! Bonus + 30"
     HasX="has"
     XPoints="Points !"
     XPoint="Point !"
     DrawColor=(B=210,G=252,R=255,A=230)
}
