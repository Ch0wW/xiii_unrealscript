//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CableStart extends Keypoint;

var() CableEnd EndCable;
var CableLink MyLink;
var transient int Count;
var transient float Delay;

//_____________________________________________________________________________
event PostBeginPlay()
{
    if ( EndCable == none )
    {
      Log("### "$self$" destroying because CableEnd not initialized");
      destroy();
    }
    Super.PostBeginplay();
    MyLink = spawn(class'CableLink',self,,Location + (class'CableLink'.Default.LinkLength/2.0) * Normal(EndCable.Location - Location), rotator(EndCable.Location - Location));
    if ( MyLink != none )
    {
      MyLink.StartPoint = self;
      MyLink.EndPoint = EndCable;
      MyLink.CreateNextLink();
    }
    else
    {
      Log("### "$self$" destroying because MyLink could not be spawned");
      destroy();
    }
}

//_____________________________________________________________________________
event Trigger(Actor Other, Pawn EventInstigator)
{
    Log("### "$self$" Trigger");
    Tag='ShoudNotBeTriggeredAgain';
    GotoState('FreeCable');
}

//_____________________________________________________________________________
State FreeCable
{
    event BeginState()
    {
      Count = 0;
      Delay = 0.0;
    }
    event Tick(float dT)
    {
      Count ++;
      if ( Count%4 == 0)
        MyLink.FreeMove(dT*4);
      Delay += dT;
      if ( Delay > 10.0 )
        GotoState('');
    }
}

//_____________________________________________________________________________
event Destroyed()
{
    MyLink.Destroy();
}



defaultproperties
{
     bStatic=False
}
