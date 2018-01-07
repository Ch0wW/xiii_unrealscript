//=============================================================================
// CineKiller
// Created by iKi
// Last Modification by iKi
//=============================================================================
class CineKiller extends Trigger
	HideCategories(force,lightcolor,lighting,rollof,sound);

VAR() Pawn InnocentVictim;
//#exec Texture Import File=Textures\Cine_ico.pcx Name=Cine_ico Mips=Off
EVENT Trigger(actor Other, pawn EventInstigator )
{
	InnocentVictim.TakeDamage( 2000, InnocentVictim, InnocentVictim.Location, vect(0,0,0), Class'XIII.DTSureStunned' );
	Destroy();
}



defaultproperties
{
     Texture=Texture'XIDCine.Cine_ico'
}
