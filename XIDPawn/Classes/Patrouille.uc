//=============================================================================
// Patrouille.
//=============================================================================
class Patrouille extends GenFRD;

var basesoldier perso1,perso2,perso;
var() name PersoName1,PersoName2;
var int NbRecul;
var float DistEntreChemins;
var IAController Cont1,Cont2;  //2 controllers
var float AncienDelai;
var actor LastWP;
var int i;
var Xiiigameinfo GI;




//=============================================================================
// Patrouille ||.
//=============================================================================
Auto state patrouille
{
     function Timer()
     {
          local vector direct;
          local vector distance;
          local float delai;


          if ((perso1==none)||(perso2==none)||(Cont1.DestNavPoint==none)||(Cont2.DestNavPoint==none)||(perso1.health<=0)||(perso2.health<=0))
          {
               gotostate('fin');
               return;
          }
          Cont1=IAController(perso1.controller);
          Cont2=IAController(perso2.controller);
          //si repassse devant alors annule delais
          if ((perso==perso1)&&((vector(perso1.rotation) dot (perso2.location-perso1.location))>0))
          {
               log("retabli ancien delai 1");
               patrolpoint(Cont1.DestNavPoint).pausetime=Anciendelai;
               NbRecul=0;
               LAstWP=none;
               perso=none;
               if (Cont1.sleeptime!=0)
                    Cont1.gotostate('patrouille','patrol');
          }
          else if ((perso==perso2)&&((vector(perso2.rotation) dot (perso1.location-perso2.location))>0))
          {
               log("retabli ancien delai 2");
               patrolpoint(Cont2.DestNavPoint).pausetime=Anciendelai;
               NbRecul=0;
               LAstWP=none;
               perso=none;
               if (Cont2.sleeptime!=0)
                    Cont2.gotostate('patrouille','patrol');
          }
          if ((LastWP==none) || ((perso!=none)&&(LastWP!=IACOntroller                    (perso.controller).DestNavPoint)))
          {
               distance=perso1.location-perso2.location;
               if (sqrt(square(Vsize(distance))-DistEntreChemins)>396)
               {
                    log(" ****************   trop loin ***************");
                    // Qui est devant?
                    if (Cont1.Isinstate('patrouille')&&(Cont1.LastPatrolPoint!=none)&&(Cont1.DestNavPoint!=none))
                    {
                         direct=(Cont1.DestNavPoint.location - Cont1.LastPatrolPoint.location);
                    }
                    else if (Cont2.Isinstate('patrouille')&&(Cont2.LastPatrolPoint!=none)&&(Cont2.DestNavPoint!=none))
                         {
                              direct=(Cont2.DestNavPoint.location - Cont2.LastPatrolPoint.location);
                         }
                    if (direct dot (distance)>0)
                    {
                         log("perso1 devant");
                         if (perso==perso2)
                              NbRecul=0;
                         perso=perso1;
                    }
                    else
                    {
                         if (direct dot (distance)==0)
                         {
                              log("pas de delai");
                              return;
                         }
                         else
                         {
                              log("perso2 devant");
                              if (perso==perso2)
                                   NbRecul=0;
                              perso=perso2;
                         }
                    }


                    if (perso==perso1)
                    {
                         delai=Vsize(distance)/(perso2.groundSpeed*perso2.walkingspeed);
                         if ((Cont2.Isinstate('chasse')) || (Cont2.Isinstate('temporise'))||                               (Cont2.Isinstate('Vavers')))
                         {
                              log("1 rallonge le delai");
                              delai+=12+4*Frand();
                         }
                         else if (!Cont2.Isinstate('patrouille'))
                              delai+=6+4*Frand();
                    }
                    else
                    {
                         delai=Vsize(distance)/(perso1.groundSpeed*perso1.walkingspeed);
                         if ((Cont1.Isinstate('chasse')) || (Cont1.Isinstate('temporise'))||                               (Cont1.Isinstate('Vavers')))
                         {
                              log("2 rallonge le delai");
                              delai+=12+4*Frand();
                         }
                         else if (!Cont1.Isinstate('patrouille'))
                              delai+=6+4*Frand();
                    }
                    log("effectue delai"$delai);
                    Cont1=IAcontroller(perso.controller); //reutil de cont1
                    Anciendelai=patrolpoint(Cont1.DestNavPoint).pausetime;
                    patrolpoint(Cont1.DestNavPoint).pausetime += delai;
                    LastWP=Cont1.DestNavPoint;
                    NbRecul++;
                    if (NbRecul>1)
                         gotostate('fin');
               }
               else
                    NbRecul=0;
          }
     }

begin:

init:
     sleep(2);
    GI=XIIIGameInfo(level.game);
     For(i=0;i<GI.BaseSoldierList.Length;i++)
     {
          perso=basesoldier(GI.BaseSoldierList[i]);
          if (!perso.bisdead && !perso.controller.isinstate('faction'))
          {
               if (perso.name==PersoName1)
                    perso1=perso;
               else if (perso.name==PersoName2)
                    perso2=perso;
          }
     }
     if ((perso1==none) || (perso2==none))
     {
          log(" ***    pas trouve persos de patrouille   **** ");
          gotostate('fin');
     }
     Cont1=IAController(perso1.controller);
     Cont2=IAController(perso2.controller);
     if ((Cont1.DestNavPoint!=none) && (Cont2.DestNavPoint!=none))
          DistEntreChemins= square(VSize(Cont1.DestNavPoint.location-Cont2.DestNavPoint.location));
     else
          DistEntreChemins=square(236);
     NbRecul=0;
     perso=none;
     LAstWP=none;
     setTimer(2,true);
retard:

}


//=============================================================================
// FIN
//=============================================================================
state Fin
{

begin:
     log(self$"fin");
}



defaultproperties
{
     bDirectional=True
}
