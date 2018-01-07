
class XIIISaveMenuStack extends Object;


var array<string> Menu;


function AddMenu(coerce string MenuParameters)
{
    local int index;

    index = Menu.Length;
    Menu.Length = Menu.Length + 1;
    Menu[index] = MenuParameters;

    //log("AddMenu - Menu["$index$"] = "$Menu[index]);
}


function Dump()
{
    local int i;

    log("XIIISaveMenuStack dumping its content:");
    for (i=0; i<Menu.Length; i++)
    {
        log("Saved menu ["$i$"] = "$Menu[i]);
    }
}




defaultproperties
{
}
