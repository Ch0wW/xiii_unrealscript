//=============================================================================
// AttackPoint.
//=============================================================================
class AttackPoint extends NavigationPoint placeable native;


var vector lookdir; //direction to look while stopped
var AttackPoint NextAttackP;

var() name NextAttackPoint; //next point to go to
var() int NumReseau; // num du reseau propre
// ----------------------------------------------
//             PROPRIETES
//----------------------------------------------
enum ProprietesPossibles
{
     Rester,
     Sauter,
};
struct Propr
{
     var() ProprietesPossibles Propriete;
     var() Array<string> Arguments; //Proprietes de l'AttackPoint
};
var() Propr Proprietes;

var bool bDejaPasse;
var() bool bBoucleSurDernier; // Dernier AttackPoint: repete la derniere propriete a l'infini
var() bool bAccroupi; //s'accroupi ou pas
var() bool bTriggerEvent; //declenche un trigger ou non
var() bool bTirEntreLes2; //Tir ou pas a la sortie de cet ATTACKPOINT jusqu'au prochain
var() bool bTirSurPlace; //Tir quand est sur AP
var() bool bForceDeplacement; //force deplacement vers attackpoint meme si XIII plus pres

var(AttackPointAdvanced) bool bTenteGrenadage; //tente grenade sur XIII si a une grenade
var(AttackPointAdvanced) bool bReprenable; // reutilisable
var(AttackPointAdvanced) bool bAlerteAmisEnCriant; //alerte perso en criant en fonction de "probaalerteamiencriant" du basesoldier

var(Son) bool bMusiqueAttaque;

var(AttackPointAdvanced) int NbPointsSkipables; //nb de points suivant concernes par le choix
var(AttackPointAdvanced) NavigationPoint PointSortieEnRoulade; //point de sortie en roulade
var(AttackPointAdvanced) GrenadeTarget Ciblegrenade; //cible eventuelle pour une grenade
var(AttackPointAdvanced) AttackPoint PointDuSecondChemin; // donne autre point et permet de desactiver la branche
var(AttackPointAdvanced) CrashPoint PointArriveeCrash; //point d'arrive lors de la chute





function PreBeginPlay()
{
     local AttackPoint CurPoint;

     lookdir =10000 * vector(Rotation);

     //find the patrol point with the tag specified by Nextpatrol
     NextAttackP = None;
     if (NextAttackPoint != '')
     {
          foreach AllActors(class 'AttackPoint', CurPoint, NextAttackPoint)
          {
               if (CurPoint != self)
               {
                    NextAttackP = CurPoint;
                    break;
               }
          }
     }
     Super.PreBeginPlay();
}



defaultproperties
{
     Proprietes=(Arguments=("0"))
     bMusiqueAttaque=True
     Texture=Texture'Engine.SubActionGameSpeed'
     CollisionRadius=0.000000
     bDirectional=True
}
