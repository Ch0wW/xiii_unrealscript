//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPRFlag extends XIIIMPFlag;

//_____________________________________________________________________________

function GiveHarnaisCTFAndFlag( XIIIPawn P)
{
    local Inventory NewItem;

    if( P.FindInventoryType(Class'XIIIMP.HarnaisCTF')==None )
    {
        NewItem = Spawn(Class'XIIIMP.HarnaisCTF',,,P.Location);

        if( NewItem != None )
            NewItem.GiveTo(P);
    }
}

//_____________________________________________________________________________



defaultproperties
{
     TeamNum=0
     StaticMesh=StaticMesh'Meshes_communs.flagred'
     LightHue=0
}
