//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ExclaBarfight extends exclamation;

var int TimeStart;

function PostBeginPlay()
{
 TimeStart = Level.TimeSeconds;
}

auto state init
{
begin:
    if (Level.TimeSeconds - TimeStart > 0.9)
     destroy();
    sleep(0.5);
    goto('begin');
}


defaultproperties
{
}
