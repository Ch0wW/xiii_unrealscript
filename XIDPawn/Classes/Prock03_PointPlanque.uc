//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Prock03_PointPlanque extends GrenadeTarget;
//des BM sont associes pour definir si la planque est encore bonne
var() array<XiiiMover> Breakable_Associe;

function postbeginplay()
{
   super.postbeginplay();
   settimer(1,true);
}

function timer()
{
   local int i;
   if (Breakable_Associe.length>0)
   {
      for (i=0;i<Breakable_Associe.length;i++)
      {
         if (Breakable_Associe[i]!=none && !Breakable_Associe[i].bdeleteme)
           return;
      }
   }
   bactive=false;
   gotostate('');
}




defaultproperties
{
}
