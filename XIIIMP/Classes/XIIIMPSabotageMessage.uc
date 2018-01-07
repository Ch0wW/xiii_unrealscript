//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPSabotageMessage extends XIIILocalMessage;

var localized string BombIsActive,BombIsDesactivated, ObjectifDestroyed;

static function string GetString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    switch (Switch)
    {
      case 2: // Destroyed
        return Default.ObjectifDestroyed;//@"("$MPBombingBase(OptionalObject).sBaseName$")"; break;
      case 1: // Activated
        return Default.BombIsActive;//@"("$MPBombingBase(OptionalObject).sBaseName$")"; break;
      case 0: // Desactivated
        return Default.BombIsDesactivated;//@"("$MPBombingBase(OptionalObject).sBaseName$")"; break;
    }
    return default.class$" ERR::RECEIVED GetString with wrong or undefined Params";
}







defaultproperties
{
     BombIsActive="Bomb is ACTIVATED"
     BombIsDesactivated="Bomb is DISABLED"
     ObjectifDestroyed="Objectif is DESTROYED"
     DrawColor=(B=168,R=255,A=230)
}
