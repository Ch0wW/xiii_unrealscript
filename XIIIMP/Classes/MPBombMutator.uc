//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPBombMutator extends XIIIMPMutator;

var bool AddStorage;
/*
// Classes should be : + Additional equipment (9mm infinite ammo is basis)
Sniper :
· sniper rifle · mini gun · 2 flasbangs

Soldier :
· AssaultRifle · 1 AssaultRifke grenad · FGrenad · Flasbang

Mercenary :
· Kalash · MiniGun · 2 FGrenad

Heavy soldier :
· M60 · Grenad

Hunter
· ShotGun · 3 Grenads · 1 FlashBang
*/

//_____________________________________________________________________________
// Handle classes here ?
function ModifyPlayer(Pawn Other)
{
    local XIIIMPPlayerPawn MPPlayer;
    Local Weapon Inv;
    local Armor A;
    local Ammunition Amm;

    MPPlayer = XIIIMPPlayerPawn(Other);
    switch(MPPlayer.SubClass)
    {
        Case SC_Sniper:
            Inv = Weapon(GiveSomething(class'FusilSnipe', MPPlayer));
            Inv.AmmoType.AmmoAmount = 30;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FlashBangBot', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FlashBang', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            A = Armor(GiveSomething(class'GiletMK1', MPPlayer));
            A.Charge=50;
            break;

        case SC_Soldier:
            Inv = Weapon(GiveSomething(class'M16', MPPlayer));
            Inv.AmmoType.AmmoAmount = 150;
            Amm = Ammunition(GiveSomething(class'M16GrenadAmmo', MPPlayer));
            Amm.AmmoAmount = 2;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FlashBangBot', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FlashBang', MPPlayer));
            A = Armor(GiveSomething(class'GiletMK1', MPPlayer));
            A.Charge=50;
            A = Armor(GiveSomething(class'Casque', MPPlayer));
            A.Charge=40;
            break;

        Case SC_HeavySoldier:
            Inv = Weapon(GiveSomething(class'M60', MPPlayer));
            Inv.AmmoType.AmmoAmount = 200;
            A = Armor(GiveSomething(class'GiletMK1', MPPlayer));
            A.Charge=75;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FGrenad', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FGrenadB', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            break;

        Case SC_Hunter:
            Inv = Weapon(GiveSomething(class'FusilPompe', MPPlayer));
            Inv.AmmoType.AmmoAmount = 30;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FGrenad', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FGrenadB', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FlashBangBot', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FlashBang', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            A = Armor(GiveSomething(class'GiletMK1', MPPlayer));
            A.Charge = 100;
            A = Armor(GiveSomething(class'Casque', MPPlayer));
            A.Charge = 60;
            break;

        Case SC_Mercenary:
        default:
            Inv = Weapon(GiveSomething(class'FusilPompe', MPPlayer));
            Inv.AmmoType.AmmoAmount = 30;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FGrenad', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FGrenadB', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            if ( MPPlayer.controller.bIsBot )
              Inv = Weapon(GiveSomething(class'FlashBangBot', MPPlayer));
            else
              Inv = Weapon(GiveSomething(class'FlashBang', MPPlayer));
            Inv.AmmoType.AmmoAmount = 2;
            A = Armor(GiveSomething(class'GiletMK1', MPPlayer));
            A.Charge = 100;
            A = Armor(GiveSomething(class'Casque', MPPlayer));
            A.Charge = 100;
    }

    if ( NextMutator != None )
      NextMutator.ModifyPlayer(Other);
}

//_____________________________________________________________________________
function Inventory GiveSomething(class<Inventory> ItemClass, XIIIPawn P)
{
  local Inventory NewItem;
  local XIIIMPSabotageStorage BTS;

  if( ! AddStorage )
  {
      AddStorage = true;
      BTS = Spawn(class'XIIIMPSabotageStorage',,, P.Location);
      BTS.TeamId=0;
      BTS = Spawn(class'XIIIMPSabotageStorage',,, P.Location);
      BTS.TeamId=1;
  }

  if( P.FindInventoryType(ItemClass)==None )
  {
    NewItem = Spawn(ItemClass,,,P.Location);
    if( NewItem != None )
      NewItem.GiveTo(P);
  }
  else
  {
    NewItem = P.FindInventoryType(ItemClass);
    if ( Ammunition(NewItem) != none )
      Ammunition(NewItem).AmmoAmount += Class<Ammunition>(ItemClass).default.AmmoAmount;
  }
  return NewItem;
}

//______________________________________________________________________________
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( DBMutator ) Log("MUTATOR CheckReplacement for"@Other);

    if ( (Level.Game != none) && Level.Game.bWaitingToStartMatch )
    { // when game starts
      if ( (PickUp(Other) != none) && (XIIIMPBombPick(Other) == none) )
      {
        Other.Destroy();
      }
    }
    else if (XIIIMPBombPick(Other) != none)
    { // when playing
      Other.Destroy();
    }

    return true;
}

//______________________________________________________________________________


defaultproperties
{
}
