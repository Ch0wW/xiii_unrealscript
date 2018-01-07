//=============================================================================
// PatrolPoint.
//=============================================================================
class PatrolPoint extends NavigationPoint
placeable native;


var() name Nextpatrol; //next point to go to
var() float pausetime; //how long to pause here
var() float deltatime; // fluctuation du temps de pause
var      vector lookdir; //direction to look while stopped
var() array<name> PatrolAnim;
var() bool bBoucleSurAnim; //joue l'anim en boucle
var() int NumReseau; // num du reseau propre
var PatrolPoint NextPatrolPoint;
var() bool bEnCourant;
var() bool bResteSurDernier;
var(son) enum SoundType
{
   rien,
   Sifflements,
   Eternuments,
   Toux,
   OnoAleatoire
}  TypeSon;
var(son) float ProbaJouerOno;


function PreBeginPlay()
{
     local PatrolPoint CurPoint;

     lookdir = 200 * vector(Rotation);

     //find the patrol point with the tag specified by Nextpatrol
     NextPatrolPoint = None;
     if (NextPatrol != '')
     {
          foreach AllActors(class 'PatrolPoint', CurPoint, Nextpatrol)
          {
               if (CurPoint != self)
               {
                    NextPatrolPoint = CurPoint;
                    break;
               }
          }
     }
     Super.PreBeginPlay();
}



defaultproperties
{
     ProbaJouerOno=33.000000
     CollisionRadius=0.000000
     bDirectional=True
}
