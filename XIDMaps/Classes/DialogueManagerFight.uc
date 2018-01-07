//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DialogueManagerFight extends DialogueManager;

var() int MinimumAlive;
var int MaxAlive;
//##############################################################################

//event PostBeginPlay()
/*
function int HowManyLeft()
{
    local int i,j;
    local pawn p,q;
    local array<pawn> AlivePawn;

   // MaxAlive=0;

    for ( i = 0; i < Speakers.Length; ++i )
    {
        p = Pawn(Speakers[i].Pawn);
        //if (p!=none)
        if (( p==none ) ||  ( p.bDeleteMe ) ||  p.bIsDead)
        {
            for ( j = 0; j < Speakers.Length; ++j )
            {
                q = AlivePawn[j];
                if(p!=q)
                {
                    //if (q!=none)
                    //{
                        MaxAlive++;
                    //}
                    AlivePawn[i]=p;
                    //break;
                }
            }
        }
        else
        {
          MaxAlive--;
          AlivePawn[i]=none;
          //break;
        }
    }

    return MaxAlive;
}
*/

function bool MustBeStop( )
{
    LOCAL int i, j;
    local Pawn p,q;
    local bool bFoundNext;
    local int iCurrentAlive;

    for ( i = 0; i < Speakers.Length; ++i )
    {
        if  ( bool( bGivenSpeaker[ i ] ) )
        {
            p = Pawn(Speakers[i].Pawn);
           /* if  (
                    ( p==none ) ||  ( p.bDeleteMe ) ||  p.bIsDead   // Pawn only conditions
                ||
                    ( p.Controller==none )
                ||
                    ( p.Controller.IsA( 'IAController' ) && ( p.controller.Enemy!=none ) )
                )
            {
//              DebugLog("MUST BE STOPPED !!!");
                return true;
            } */
            if  (( p==none ) ||  ( p.bDeleteMe ) ||  p.bIsDead)
            {

                //iCurrentAlive=0;
                //current pawn is dead hence should try another one
                for ( j = 0; j < Speakers.Length; ++j)
                {
                    q = Pawn(Speakers[j].Pawn);
                    if (( q!=none ) &&  ( !q.bDeleteMe ) &&  !q.bIsDead)
                    {
                        if (!bFoundNext)
                        {
                          Speakers[i].pawn=q;
                          p=q;
                         // break;
                          bFoundNext=true;
                        }
                        iCurrentAlive++;
                        //log("current alive"@iCurrentAlive);
                        //log("desired alive"@MinimumAlive);
                       if (j==Speakers.Length-1)
                       {
                            //iCurrentAlive = HowManyLeft();
                            //log("current alive"@iCurrentAlive);
                            //if ((HowManyLeft()>=MinimumAlive) && bFoundNext)
                           if ((iCurrentAlive>=MinimumAlive) && bFoundNext)
                           {
                              break;
                            }
                            else
                            {
                                //if (j==Speakers.Length-1)
                                //{
                                    return true;
                                //}
                            }

                       //break;
                       }
                   }
                   // else
                   // {
                   //     return true;
                   // }
                    }
                //return true;
            }
        }
    }
    return false;
    super.mustbestop();
}




defaultproperties
{
}
