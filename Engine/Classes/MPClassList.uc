//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPClassList extends Info;

struct StructClassInfo
{
  var string ClassName;
  var string ReadableName;
};

var localized array<StructClassInfo> ClassListInfo;

/* // Ex usage
    NbClasses = class'MPClassList'.default.ClassListInfo.Length;
    Log("STATIC ClassList NbClass="$NbClasses);
    if ( NbClasses > 0 )
    {
      for (i=0; i<NbClasses; i++)
        Log("  "$i$" - "$class'MPClassList'.default.ClassListInfo[i].ReadableName@"("$class'MPClassList'.default.ClassListInfo[i].ClassName$")");
    }
*/

defaultproperties
{
     ClassListInfo(0)=(ClassName="XIIIMP.HunterPlayer",ReadableName="Hunter")
     ClassListInfo(1)=(ClassName="XIIIMP.HeavySoldierPlayer",ReadableName="Heavy Soldier")
     ClassListInfo(2)=(ClassName="XIIIMP.SniperPlayer",ReadableName="Sniper")
     ClassListInfo(3)=(ClassName="XIIIMP.SoldierPlayer",ReadableName="Soldier")
}
