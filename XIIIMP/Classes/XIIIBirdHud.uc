//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIBirdHud extends XIIIMPHud;

//____________________________________________________________________

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
    if( ( Level.NetMode == NM_StandAlone) && ( ( Level.Game == none ) || ( Level.Game.NumPlayers > 1 ) ) )
    {
        if( Message == class'XIIIDeathMessage' )
            return;
    }

    if ( Message == class'XIIIEndGameMessage' )
    {
      AddHudEndMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      bHideHud = true;
    }
    else if ( ( Message == class'XIIIDeathMessage' ) && ( PawnOwner.bIsDead )  )
    {
      AddHudEndMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      bHideHud = true;
    }
    else if( ( ( ( Message == class'XIIIDeathMessage' ) || ( Message == class'XIIIMPCTFMessage') ) || ( Message == class'XIIIMultiMessage' ) ) || ( Message == class'XIIIMPDuckMessage' ) )
    {
      if( OptionalObject == class'DT_KKK' )
        AddHudMPMessage( Message, 3, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      else if( switch == 1 )
        AddHudMPMessage( Message, 2, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      else
        AddHudMPMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
    }
    else
      AddHudMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
}



defaultproperties
{
}
