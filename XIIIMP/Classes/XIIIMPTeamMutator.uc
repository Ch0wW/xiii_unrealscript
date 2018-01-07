//
//-----------------------------------------------------------
class XIIIMPTeamMutator extends XIIIMPMutator;

var bool AddStorage;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local XIIIMPTeamStorage BTS;

    if( ! AddStorage )
    {
        AddStorage = true;
        BTS = Spawn(class'XIIIMPTeamStorage',,, Other.Location);
        BTS.TeamId=0;
        BTS = Spawn(class'XIIIMPTeamStorage',,, Other.Location);
        BTS.TeamId=1;
    }

    return true;
}




defaultproperties
{
}
