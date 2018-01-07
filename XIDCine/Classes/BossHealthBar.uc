//=============================================================================
// BossHealthBar
// Created by iKi on Jul 29th 2003
//=============================================================================
class BossHealthBar extends Info
	hidecategories(advanced,Collision,display,movement,rolloff,sound)
	placeable;

#exec Texture Import File=Textures\seen_ico.pcx Name=HealthBar_ico Mips=Off Masked=1

VAR() Pawn BossPawn;
VAR XIIIPlayerController PC;

EVENT Trigger( actor Other, pawn EventInstigator )
{
	PC = XIIIGameInfo(Level.Game).MapInfo.XIIIController;
	XIIIBaseHud(PC.MyHud).AddBossBar( BossPawn );
//	BossPawn.bBoss=false;
	SetTimer( 0.2, true );
}

EVENT Timer( )
{
	if ( BossPawn==none || BossPawn.bIsDead )
	{
		XIIIBaseHud(PC.MyHud).AddBossBar( none );
		Destroy();
	}
}




defaultproperties
{
     Texture=Texture'XIDCine.HealthBar_ico'
}
