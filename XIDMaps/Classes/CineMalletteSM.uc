//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineMalletteSM extends SMAttached
	placeable;

var() Pawn PersoALaMallette;
var() CineMalletteSM PartieSuperieure;
var bool bFermeLaMallette;
var bool bMalletteEnMain;
var rotator rRot;
var int eRotRollMax;
var vector vPosInit;
var float fHauteur, fHauteurMax;


//-----------------------------------------------------------
event PostBeginPlay()
{
	if (PartieSuperieure == none)
	{
		// la partie superieure est independante, la partie inferieure traitera les deux cas
		Disable( 'Trigger' );
	}
}

//-----------------------------------------------------------
function Trigger( actor Other, pawn EventInstigator )
{
	if ( !bFermeLaMallette )
	{
		rRot = Rotation;
		GotoState( 'STA_FermetureMallette' );
	}
	else
	{
		if ( PersoALaMallette != none )
		{
			if ( !bMalletteEnMain )
			{
				bMalletteEnMain = true;
				// partie inferieure
				PersoALaMallette.AttachToBone(self,'X R Hand');
				SetRelativeLocation(Default.RelativeLocation);
				SetRelativeRotation(Default.RelativeRotation);
				bHidden = true;
				RefreshDisplaying();
				// partie superieure
				PersoALaMallette.AttachToBone(PartieSuperieure,'X R Hand');
				PartieSuperieure.SetRelativeLocation(Default.RelativeLocation);
				PartieSuperieure.SetRelativeRotation(Default.RelativeRotation + rot(0,0,1)*eRotRollMax);
				PartieSuperieure.bHidden = true;
				PartieSuperieure.RefreshDisplaying();
			}
			else
			{
				// partie inferieure
				PersoALaMallette.DetachFromBone(self);
				SetLocation( vect( -7839, -2760, 898) );
				SetRotation( rot( 0, 32768, 0 ) );
				bHidden = false;
				RefreshDisplaying();
				// partie superieure

				PersoALaMallette.DetachFromBone(PartieSuperieure);
				PartieSuperieure.SetLocation( vect( -7839, -2760, 898) );
				PartieSuperieure.SetRotation( rot( 0, 32768, -20390 ) );
//				PartieSuperieure.SetLocation(Location);
//				PartieSuperieure.SetRotation(Rotation + rot(0,0,1)*eRotRollMax);
				PartieSuperieure.bHidden = false;
				PartieSuperieure.RefreshDisplaying();
				bMalletteEnMain = false;
				GotoState('STA_PoseMallette');
			}
		}
	}
}

//-----------------------------------------------------------
State STA_FermetureMallette
{
	event Tick(float dt)
	{
		rRot.Roll -= 70000*dt;
		rRot.Roll = fMax( rRot.Roll,eRotRollMax );
		PartieSuperieure.SetRotation(rRot);
		if ( rRot.Roll == eRotRollMax )
		{
			bFermeLaMallette = true;
			GotoState('');
		}
	}
}


//-----------------------------------------------------------
State STA_PoseMallette
{
	event BeginState()
	{
		vPosInit = Location;
		fHauteur = 0;
		fHauteurMax = 10;
	}
	
	event Tick(float dt)
	{
		fHauteur += 50*dt;
		fHauteur = fMin(fHauteur,fHauteurMax);
		SetLocation( vPosInit - fHauteur*vect(0,0,1) );
		PartieSuperieure.SetLocation(Location);
		if ( fHauteur == fHauteurMax )
		{
			GotoState('');
		}
	}
}


//-----------------------------------------------------------


defaultproperties
{
     eRotRollMax=-20390
     RelativeLocation=(X=42.000000,Z=2.000000)
     RelativeRotation=(Pitch=16384,Roll=16384)
     StaticMesh=StaticMesh'Staticbanque.liasse_valise_bas'
}
