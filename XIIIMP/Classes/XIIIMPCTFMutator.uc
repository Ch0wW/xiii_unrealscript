//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPCTFMutator extends XIIIMPMutator;

var bool AddStorage;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local XIIIMPCTFStorage BTS;

    if( ! AddStorage )
    {
        AddStorage = true;
        BTS = Spawn(class'XIIIMPCTFStorage',,, Other.Location);
        BTS.TeamId=0;
        BTS = Spawn(class'XIIIMPCTFStorage',,, Other.Location);
        BTS.TeamId=1;
    }

    return true;
}




defaultproperties
{
}
