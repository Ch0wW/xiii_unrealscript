//=============================================================================
// GrenadeTarget.
//=============================================================================
class GrenadeTarget extends GenFRD;

var bool   bActive;

auto state() XIIITouchActivable
{
   event Touch (actor Other)
   {
      if (XIIIPlayerPawn(Other)!=none)
		  bactive=true;
   }
   event unTouch (actor Other)
   {
       if (bactive && XIIIPlayerPawn(Other)!=none)
		   bactive=false;
   }
begin:
}

state() TriggerActivable
{
     function Trigger( actor Other, pawn EventInstigator )
     {
         bactive=true;
         disable('trigger');
         enable('UnTrigger');
     }
     function UnTrigger( actor Other, pawn EventInstigator )
     {
         bactive=false;
         disable('Untrigger');
         enable('Trigger');
     }
begin:
}



defaultproperties
{
     bAlwaysRelevant=True
     bCollideActors=True
     Texture=Texture'Engine.S_LookTarget'
     CollisionRadius=100.000000
     CollisionHeight=100.000000
}
