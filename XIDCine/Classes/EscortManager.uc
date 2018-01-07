//---------------------------------------------------------------------------
// Specific class for XIII 'Prock01a' map, do not use somewhere else !!!
//---------------------------------------------------------------------------
class EscortManager extends Info
	placeable;

//--- variables designer ---
var() Cine2 PawnMaton1, PawnMaton2;			// les deux matons
var() Array<Actor> Chemin;					// le chemin des deux matons a parcourir
var() Array<Actor> CheminDoorPoints;		// le chemin spécifique des portes a ouvrir
var() Array<Actor> ObjetsSansInteraction;	// les objets avec interaction a retirer
var() float DistanceMatons;					// distance minimale entre les deux matons
var() float VitesseMaton1, VitesseMaton2;	// vitesse de déplacement des deux matons
var() Porte PorteInit;						// porte de la cellule
var() Actor CheminStop;						// point du chemin juste avant le couloir d intersection
var() Actor ColCouloirEscorte;				// mesh de col pour le couloir pendant l escorte
var() Actor ColEscalierEscorte;				// mesh de col pour l escalier pendant l escorte
var() float fDegatCoupDeMatraque;			// nombre de points de vie perdus par un coup de matraque

//--- variables internes ---
var transient CineController2 ControllerMaton1, ControllerMaton2;
var transient int Maton1Index, Maton2Index;
var transient float TimeStamp, EndTimePause;
var transient Pawn PlayerPawn;
var int i;
var int IndexCheminReprise;
var vector vPosPlayer;
var vector vPosChemin1;
var vector vPosChemin2;
var vector vPosMaton2;
var vector vPosCentralPlayer;
var vector vPosCentralMaton2;
var vector vOrthogonalChemin;
var vector vDirChemin1_Chemin2;
var vector vDirChemin1_Player;
var vector vDirChemin1_Maton2;
var vector vDirCentralMaton2_Chemin2;
var vector vDirMaton1_Chemin2;
var vector vDirMaton2_Chemin2;
var vector vDirPlayer_Chemin2;
var vector vDirChemin2_Player;
var vector vDirMaton1_Maton2;
var vector vDirMaton1_Player;
var vector vDirMatraquage;
var float fDistChemin1CentrePlayer;
var float fDistChemin1CentreMaton2;
var float fDecalageCentrePlayer;
var float fDecalageCentreMaton2;
var float fDecalageMax;
var float fTempsMatraquage;
var float fCollisionRadiusInitMaton1;
var float fCollisionRadiusInitMaton2;
var float DefaultWalkAnimVelocity;
var bool bPauseMaton1, bPauseMaton2;
var bool bPauseEscalierMaton2;
var bool bTapeSurLaGueuleDeXIIIMaton1;
var bool bTapeSurLaGueuleDeXIIIMaton2;
var bool bOuvrePorte;
var bool bPasseUnePorte;
var bool bAttendSonPote;
var bool bFinCheminMaton1;
var bool bEscortingEscalierMaton2;
var bool bXIIIDansEscalier;
var Actor ObjetATraiter;
var Actor PointAAtteindre;
var Actor CheminRepriseEscalier;


//_____________________________________________________________________________
event Trigger(actor Other,Pawn EventInstigator)
{

	foreach RadiusActors( class'Porte',PorteInit,256,PawnMaton2.Location)
	{
		Log( "PorteInit"@PorteInit );
		break;
	}
	// WakeUp
	ControllerMaton1=PawnMaton1.CineController;
	ControllerMaton2=PawnMaton2.CineController;
	ControllerMaton1.CineMoveTo(Chemin[Maton1Index]);
	ControllerMaton1.MoveSequence="";
	ControllerMaton2.MoveSequence="";
	PawnMaton1.WalkAnim='matrak3';
	PawnMaton2.WalkAnim='marchematrakhand';
	PawnMaton1.WaitAnim='waitmatrak';
	PawnMaton2.WaitAnim='waitmatrak';
	PlayerPawn=PawnMaton1.PC.Pawn;
	PawnMaton1.bPauseMovementIfBumped=false;
	PawnMaton2.bPauseMovementIfBumped=false;
	PawnMaton1.ImposedEndMovePosition=false;
	PawnMaton2.ImposedEndMovePosition=false;
	PawnMaton1.bInteractive = false;
	PawnMaton2.bInteractive = false;
	// on agrandit legerement la zone de collision des matons
	fCollisionRadiusInitMaton1 = PawnMaton1.CollisionRadius;
	fCollisionRadiusInitMaton2 = PawnMaton2.CollisionRadius;
	// on supprime l interaction avec tous les objets du tableau
	for (i=0;i<ObjetsSansInteraction.Length;i++)
	{
		ObjetATraiter = ObjetsSansInteraction[i];
		if ( ObjetATraiter.IsA('Porte') )
			Porte(ObjetATraiter).bNoInteractionIcon = true;
		else
			log(self@" ---> OBJET NON TRAITABLE !!");
	}
	// init donnees diverses
	Maton1Index = 0;
	Maton2Index = 0;



	vPosChemin1 = PawnMaton2.Location;
	vPosChemin2 = Chemin[0].Location;
	PointAAtteindre = Chemin[0];
	for (i=0;i<Chemin.Length;i++)
	{
		if (CheminStop == Chemin[i])
		{
			IndexCheminReprise = i + 3;
			CheminRepriseEscalier = Chemin[IndexCheminReprise];
		}
	}
	GotoState('STA_DebutEscorte');
}


//_____________________________________________________________________________
function FirstKeeperBehavior(float dt)
{
	if (bPauseMaton1)
	{
		// le premier maton s arrete
		// 1 -> pour attendre son pote
		// 2 -> pour ouvrir une porte
		// 3 -> pour frapper le joueur

		if ( bAttendSonPote )
		{
			//log(PawnMaton1@"---> ATTEND SON POTE");
			vDirMaton1_Maton2 = PawnMaton1.Location - PawnMaton2.Location;
			vDirMaton1_Maton2.z = 0;
			if ( vSize(vDirMaton1_Maton2) < 1.05*DistanceMatons )
			{
				bAttendSonPote = false;
				bPauseMaton1 = false;
				ControllerMaton1.Focus = PointAAtteindre;
				ControllerMaton1.CineMoveTo(PointAAtteindre);
			}
		}
		else
		{
			if ( bOuvrePorte )
			{
				//log(PawnMaton1@"---> OUVRE PORTE");
				if ( TimeStamp > EndTimePause )
				{
					//log(PawnMaton1@"---> FIN PAUSE : OUVERTURE PORTE"@Maton1Index@Chemin[Maton1Index - 1]@Porte(Chemin[Maton1Index - 1]));
					PawnMaton1.OpenDoor(Porte(Chemin[Maton1Index - 1]));
					bPauseMaton1 = false;
					bOuvrePorte = false;
					ControllerMaton1.Focus = PointAAtteindre;
					ControllerMaton1.CineMoveTo(PointAAtteindre);
				}
			}
			else
			{
				//log(PawnMaton1@"---> FRAPPE LE JOUEUR");
				fTempsMatraquage += dt;
				if ( bTapeSurLaGueuleDeXIIIMaton1 )
				{
					if ( fTempsMatraquage > 0.7 )
					{
						//log(self@"--> FIN COUP DE MATRAQUE");
						PlayerPawn.SpeedFactorLimit = 1.0;
						bPauseMaton1 = false;
						bTapeSurLaGueuleDeXIIIMaton1 = false;
						ControllerMaton1.Focus = PointAAtteindre;
						ControllerMaton1.CineMoveTo(PointAAtteindre);
					}
				}
				else
				{
					if ( fTempsMatraquage > 0.35 )
					{
						bTapeSurLaGueuleDeXIIIMaton1 = true;
						// on calcule le vecteur d ejection
						if ( !bXIIIDansEscalier )
						{
							// la direction de matraquage est perpendiculaire au chemin
							vDirMatraquage.x = - vDirMaton1_Chemin2.y;
							vDirMatraquage.y = vDirMaton1_Chemin2.x;
							vDirMatraquage.z = 0;
						}
						else
						{
							// la direction de matraquage se fait dans le sens du chemin
							vDirMatraquage = - vDirMaton1_Chemin2;
							vDirMatraquage.z = 0;
						}

						// dommages constants quelque soit la difficulte choisie = x pts par coup de matraque
						PlayerPawn.TakeDamage(fDegatCoupDeMatraque*1.5/((1+Level.Game.Difficulty)*0.15+Level.AdjustDifficulty/100), PawnMaton2, Location, vect(0,0,0), Class'XIII.DTFisted');
						PlayerPawn.AddVelocity(Normal(vDirMatraquage)*1500);
						PlayerPawn.SpeedFactorLimit = 0.0;
					}
				}
			}
		}
	}
	else
	{
		// dans un premier temps, on teste la distance entre les deux matons
		vDirMaton1_Maton2 = PawnMaton1.Location - PawnMaton2.Location;
		vDirMaton1_Maton2.z = 0;
		if ( vSize(vDirMaton1_Maton2) > 1.25*DistanceMatons )
		{
			// la distance est trop grande, le premier maton attend
			bPauseMaton1 = true;
			bAttendSonPote = true;
			ControllerMaton1.StopMove();
			ControllerMaton1.PlayAni(PawnMaton1.WaitAnim);
			PawnMaton1.PlayAnim(ControllerMaton1.CurrentAnim,2.0,0.1);
		}
		else
		{
			// le premier maton continue son chemin
			if ( !bFinCheminMaton1 )
			{
				// le joueur gene-t-il la progression du premier gardien ?
				vDirMaton1_Chemin2 = PawnMaton1.Location - PointAAtteindre.Location;
				vDirMaton1_Player = PawnMaton1.Location - PlayerPawn.Location;
				vDirMaton1_Chemin2.z = 0;
				vDirMaton1_Player.z = 0;
				if (/*( !bXIIIDansEscalier ) &&*/ ( PawnMaton1.Collide(PlayerPawn) ) && ( (vDirMaton1_Chemin2 dot vDirMaton1_Player) > 0 ))
				{
					// on tape sur le joueur
					bPauseMaton1 = true;
					//bTapeSurLaGueuleDeXIIIMaton1 = true;
					ControllerMaton1.StopMove();
					ControllerMaton1.Focus = PlayerPawn;
					ControllerMaton1.PlayAni('matrak4',3.0,0.1);
					PawnMaton1.PlayAnim(ControllerMaton1.CurrentAnim,3.0,0.1);
					PawnMaton1.BumpedActor=none;
					fTempsMatraquage = 0;
				}
				else
				{
					//vDirMaton1_Chemin2 = PawnMaton1.Location - PointAAtteindre.Location;
					//vDirMaton1_Chemin2.z = 0;
					// on regarde si il a atteint le prochain point de son chemin
					if ( vSize(vDirMaton1_Chemin2) < 5)
					{
						/*// pour eviter que le joueur passe devant dans l escalier, on agrandit sa zone de collision
						if ( Maton1Index == IndexCheminReprise )
						{
							PawnMaton1.SetCollisionSize( PawnMaton1.CollisionRadius*1.50, PawnMaton1.CollisionHeight );
						}
						else
						{
							if ( Maton1Index == (IndexCheminReprise + 1) )
							{
								PawnMaton1.SetCollisionSize( fCollisionRadiusInitMaton1, PawnMaton1.CollisionHeight );
							}
						}*/

						Maton1Index ++;
						if (Maton1Index < Chemin.Length)
						{
							if (Chemin[Maton1Index].IsA('Porte'))
							{
								//EndTimePause = TimeStamp + 0.7;
								// on ouvre la porte avant la fin de l anim
								EndTimePause = TimeStamp + 0.4;
								//*** si la porte est deja ouverte, pas besoin de l ouvrir a nouveau
								if ( Porte(Chemin[Maton1Index]).KeyNum == 0 )
								{
									log(PawnMaton1@"---> PORTE A OUVRIR"@Maton1Index@Chemin[Maton1Index]);
									bPauseMaton1 = true;
									bOuvrePorte = true;
									ControllerMaton1.StopMove();
									ControllerMaton1.PlayAni('opendoor');
									PawnMaton1.PlayAnim(ControllerMaton1.CurrentAnim,2.0,0.1);
									Maton1Index ++;
									PointAAtteindre = Chemin[Maton1Index];
									ControllerMaton1.Focus=PointAAtteindre;
								}
								else
								{
									Maton1Index ++;
									PointAAtteindre = Chemin[Maton1Index];
									ControllerMaton1.Focus=PointAAtteindre;
									ControllerMaton1.CineMoveTo(PointAAtteindre);
								}
							}
							else
							{
								// je regarde si un doorpoint peut remplacer le point a atteindre
								if ( CheminDoorPoints[Maton1Index] != none )
									PointAAtteindre = CheminDoorPoints[Maton1Index];
								else
									PointAAtteindre = Chemin[Maton1Index];
								ControllerMaton1.Focus = PointAAtteindre;
								ControllerMaton1.CineMoveTo(PointAAtteindre);
							}
						}
						else
						{
							// le maton est au bout de son chemin
							ControllerMaton1.StopMove();
							bFinCheminMaton1 = true;
						}
					}
				}
			}
		}
	}
}


//_____________________________________________________________________________
function TestMatraquageMaton2()
{
	// en cas de collision avec le joueur, on file un coup de matraque
	//if (PawnMaton2.Collide(PlayerPawn))
	//	GotoState('STA_Matraquage');

	// autre methode
	//vPosPlayer = PlayerPawn.Location;
	//vPosMaton2 = PawnMaton2.Location;
	//vDirChemin1_Chemin2 = vPosChemin2 - vPosChemin1;
	//vDirChemin1_Player = vPosPlayer - vPosChemin1;
	//vDirChemin1_Maton2 = vPosMaton2 - vPosChemin1;
	//vDirChemin1_Chemin2.z = 0;
	//vDirChemin1_Player.z = 0;
	//vDirChemin1_Maton2.z = 0;
	// calcul des distances par rapport a l axe Chemin1-Chemin2
	//fDistChemin1CentrePlayer = (vDirChemin1_Chemin2 dot vDirChemin1_Player)/vSize(vDirChemin1_Chemin2);
	//vPosCentralPlayer = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentrePlayer;
	//vPosCentralPlayer.z = 0;
	//fDistChemin1CentreMaton2 = (vDirChemin1_Chemin2 dot vDirChemin1_Maton2)/vSize(vDirChemin1_Chemin2);
	//vPosCentralMaton2 = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentreMaton2;
	//vPosCentralMaton2.z = 0;
	//if ( vSize(vPosCentralPlayer - vPosCentralMaton2) < 80)
	//{
	//	GotoState('STA_Matraquage');
	//}

	// troisieme methode
	vPosPlayer = PlayerPawn.Location;
	vPosMaton2 = PawnMaton2.Location;
	vPosPlayer.z = 0;
	vPosMaton2.z = 0;
	if ( vSize(vPosPlayer - vPosMaton2) < 130)
		GotoState('STA_Matraquage');
}


//_____________________________________________________________________________
function AjusteVitesseMaton2( float dt )
{
	vDirMaton1_Maton2 = PawnMaton1.Location - PawnMaton2.Location;
	vDirMaton1_Maton2.z = 0;
	// si l ecart est vraiment petit, on stoppe le second maton
	// attention : dans l escalier et le couloir etroit, l ecart est consideree tres petit
	if ( (( !bXIIIDansEscalier ) && ( vSize(vDirMaton1_Maton2) < 0.75*DistanceMatons ))
		|| (( bXIIIDansEscalier ) && ( vSize(vDirMaton1_Maton2) < 0.25*DistanceMatons )) )
	{
		GotoState('STA_AttenteCouloir');
	}
	else
	{
		// si le second maton est proche du premier, on diminue sa vitesse de deplacement
		if ( vSize(vDirMaton1_Maton2) < 0.95*DistanceMatons )
		{
			VitesseMaton2 = fClamp(VitesseMaton2 - 0.01*dt,0.3,0.33);
			ControllerMaton2.WantedSpeed = VitesseMaton2;
			//log(PawnMaton2@"---> AJUSTE VITESSE RALENTIE V="$VitesseMaton2@"dt="$dt);
		}
		else
		{
			// a distance normale, on retablit la vitesse du maton 2 à sa valeur initiale
			if ( vSize(vDirMaton1_Maton2) > DistanceMatons )
			{
				VitesseMaton2 = fClamp(VitesseMaton2 + 0.01*dt,0.3,0.33);
				ControllerMaton2.WantedSpeed = VitesseMaton2;
				//log(PawnMaton2@"---> AJUSTE VITESSE VERS NORMALE V="$VitesseMaton2@"dt="$dt);
			}
		}
	}
}


//_____________________________________________________________________________
function TestXIIIDansEscalier()
{
	// on regarde si XIII est dans l escalier
	// cela permet d adapter le comportement du maton1
	// differemment selon les lieux (couloir large et escalier etroit)
	if ( !bXIIIDansEscalier )
	{
		vDirChemin1_Chemin2 = CheminRepriseEscalier.Location - CheminStop.Location;
		vDirChemin2_Player = PlayerPawn.Location - CheminRepriseEscalier.Location;
		vDirChemin1_Chemin2.z = 0;
		vDirChemin2_Player.z = 0;
		if ( (vDirChemin1_Chemin2 dot vDirChemin2_Player) > 0 && Vsize(vDirChemin2_Player)>400)
		{
			bXIIIDansEscalier = true;
		}
	}
}

//_____________________________________________________________________________
STATE STA_DebutEscorte
{
	EVENT BeginState()
	{
		ControllerMaton2.RotationSpeed = 90;
		ControllerMaton2.LockedActor = self;
		PawnMaton2.PeeredActor = PlayerPawn;
		SetLocation( PawnMaton1.Location - 50*NORMAL( ( PawnMaton1.Location - PawnMaton2.Location) cross vect(0,0,1) )  );
	}

	EVENT Tick(float dt)
	{
		LOCAL VECTOR vDirMaton2_Player;

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// on teste la distance entre les deux matons pour faire demarrer le second
		vDirMaton1_Maton2 = PawnMaton1.Location - PawnMaton2.Location;
		vDirMaton1_Player = PlayerPawn.Location - PawnMaton1.Location;
		vDirMaton2_Player = PlayerPawn.Location - PawnMaton2.Location;

		if ( vSize(vDirMaton1_Maton2) > 0.85*DistanceMatons && vSize(vDirMaton1_Player) < 0.35*DistanceMatons )
		{
//		   log( "..."@PorteInit.Name@"is in state"@PorteInit.GetStateName() );
//			PawnMaton2.UnlockDoor(PorteInit);
//			log( "now"@PorteInit.Name@"is in state"@PorteInit.GetStateName() );
			PorteInit.MoveTime=0.5;
			PorteInit.SetCollision(false,false,false);
			PawnMaton2.CloseDoor(PorteInit);
//			LOG ( "FERMETURE PORTE"@PorteInit );
//			if ( PorteInit!=none && !PorteInit.bClosed )
//				PorteInit.PlayerTrigger(self,self);
			PawnMaton2.PeeredActor = none;
			GotoState('STA_Escorting');
		}
	}
}


//_____________________________________________________________________________
STATE STA_Escorting
{
	EVENT BeginState()
	{
		Log("ENTER : STA_Escorting");
		ControllerMaton1.RotationSpeed=359;
		ControllerMaton2.RotationSpeed=359;
		//VitesseEscorte=0.1;
		ControllerMaton1.WantedSpeed=VitesseMaton1;
		//VitesseEscorte=0.1;
		ControllerMaton2.WantedSpeed=VitesseMaton2;
		ControllerMaton1.AccelerationFactor=1.0;
		ControllerMaton2.AccelerationFactor=1.0;
		ControllerMaton2.LockedActor=PlayerPawn;
	}

	EVENT Tick(float dt)
	{

		TimeStamp+=dt;

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// ajustement de la vitesse du second maton
		AjusteVitesseMaton2(dt);

		// test si XIII commence a descendre l escalier
		TestXIIIDansEscalier();

		// comportement du second maton
		// on cherche toujours a bloquer le joueur dans le couloir
		// un leger deplacement a gauche ou a droite devrait suffire

		// on regarde si on change de section de chemin
		vDirCentralMaton2_Chemin2 = vPosCentralMaton2 - vPosChemin2;
		vDirCentralMaton2_Chemin2.z = 0;
		if ( vSize(vDirCentralMaton2_Chemin2) < 5)
		{
			log(self@"---> POINT ATTEINT"@Chemin[Maton2Index]);
			// on traite le cas particulier a l entree des escaliers
			if (Chemin[Maton2Index] == CheminStop)
			{
				ControllerMaton2.StopMove();
				ControllerMaton2.LockedActor=none;
				GotoState('STA_AttenteEscalier');
				return;
			}

			Maton2Index ++;


			// le second maton s arrete juste avant la fin du chemin
			if (Maton2Index == (Chemin.Length - 2))
			{
				GotoState('STA_EndOfEscort');
				return;
			}


			// on gere les portes differemment
			if ( bPasseUnePorte )
			{
				// on regarde si on vient de passer une porte
				if ( Chemin[Maton2Index - 2].IsA('Porte') )
				{
					bPasseUnePorte = false;
					vPosChemin1 = Chemin[Maton2Index - 1].Location;
					vPosChemin2 = Chemin[Maton2Index].Location;
				}
			}
			else
			{
				// on prend en compte les portes pour le point suivant du chemin
				if ( Chemin[Maton2Index].IsA('Porte') )
				{
					Maton2Index ++;
					vPosChemin1 = Chemin[Maton2Index - 2].Location;
					vPosChemin2 = Chemin[Maton2Index].Location;
					// le passage d'une porte est problematique, il faut recentrer le maton2
					bPasseUnePorte = true;
					log(self@"---> PASSE UNE PORTE"@Chemin[Maton2Index - 2]@Chemin[Maton2Index]);
				}
				else
				{
					vPosChemin1 = Chemin[Maton2Index - 1].Location;
					vPosChemin2 = Chemin[Maton2Index].Location;
					log(self@"---> CONTINUE SON CHEMIN"@Chemin[Maton2Index - 1]@Chemin[Maton2Index]);
				}
			}
		}
		// calcul des positions et des directions
		vPosPlayer = PlayerPawn.Location;
		vPosMaton2 = PawnMaton2.Location;
		vDirChemin1_Chemin2 = vPosChemin2 - vPosChemin1;
		vDirChemin1_Player = vPosPlayer - vPosChemin1;
		vDirChemin1_Maton2 = vPosMaton2 - vPosChemin1;
		vDirChemin1_Chemin2.z = 0;
		vDirChemin1_Player.z = 0;
		vDirChemin1_Maton2.z = 0;
		// calcul des distances par rapport a l axe Chemin1-Chemin2
		fDistChemin1CentrePlayer = (vDirChemin1_Chemin2 dot vDirChemin1_Player)/vSize(vDirChemin1_Chemin2);
		vPosCentralPlayer = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentrePlayer;
		vPosCentralPlayer.z = vPosPlayer.z;
		fDistChemin1CentreMaton2 = (vDirChemin1_Chemin2 dot vDirChemin1_Maton2)/vSize(vDirChemin1_Chemin2);
		vPosCentralMaton2 = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentreMaton2;
		fDecalageCentrePlayer = vSize(vPosPlayer - vPosCentralPlayer);
		vOrthogonalChemin = Normal(vPosPlayer - vPosCentralPlayer);
		vOrthogonalChemin.z = 0;
		// pour passer les portes, on reajuste le decalage max autorisable pour le maton2
		if ( bPasseUnePorte )
			fDecalageMax = 0;
		else
			fDecalageMax = 50;
		fDecalageCentreMaton2 = FMin(fDecalageCentrePlayer,fDecalageMax);
		SetLocation(vPosCentralMaton2 + fDecalageCentreMaton2*vOrthogonalChemin + Normal(vDirChemin1_Chemin2)*40);
		ControllerMaton2.CineMoveTo(self);
		//log(self@"---> DECALAGE MAX ="@fDecalageMax);

		// en cas de collision avec le joueur, on file un coup de matraque
		TestMatraquageMaton2();
	}
begin:
	sleep(0.6);
	PorteInit.SetCollision(true,true,true);

}


//_____________________________________________________________________________
STATE STA_Matraquage
{
	EVENT BeginState()
	{
		Log("ENTER : STA_Matraquage");

		ControllerMaton2.StopMove();
		ControllerMaton2.Focus = PlayerPawn;
		ControllerMaton2.PlayAni('matrak4',3.0,0.1);
		//PawnMaton2.PlayAnim(ControllerMaton2.CurrentAnim,3.0,0.1);
		PawnMaton2.BumpedActor=none;
		bTapeSurLaGueuleDeXIIIMaton2 = false;
		fTempsMatraquage = 0;
	}

	EVENT Tick( float dt )
	{

		TimeStamp+=dt;

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// test si XIII commence a descendre l escalier
		TestXIIIDansEscalier();

		// comportement du secon maton qui donne un coup de matraque au joueur
		fTempsMatraquage += dt;

		if ( bTapeSurLaGueuleDeXIIIMaton2 )
		{
			if ( fTempsMatraquage > 0.7 )
			{
				//log(self@"--> FIN COUP DE MATRAQUE");
				PlayerPawn.SpeedFactorLimit = 1.0;
				if ( bPauseMaton2 )
				{
					if ( bPauseEscalierMaton2 )
						GotoState('STA_AttenteEscalier');
					else
						GotoState('STA_AttenteCouloir');
				}
				else
				{
					if ( bEscortingEscalierMaton2 )
						GotoState('STA_EscortingEscalier');
					else
						GotoState('STA_Escorting');
				}
			}
		}
		else
		{
			if ( fTempsMatraquage > 0.35 )
			{
				bTapeSurLaGueuleDeXIIIMaton2 = true;
				vDirChemin1_Chemin2 = vPosChemin2 - vPosChemin1;
				vDirChemin1_Chemin2.z = 0;
				// dommages constants quelque soit la difficulte choisie = x pts par coup de matraque
				PlayerPawn.TakeDamage(fDegatCoupDeMatraque*1.5/((1+Level.Game.Difficulty)*0.15+Level.AdjustDifficulty/100), PawnMaton2, Location, vect(0,0,0), Class'XIII.DTFisted');
				//PlayerPawn.AddVelocity(Normal(vDirChemin1_Chemin2)*1500);
				PlayerPawn.AddVelocity(Normal(vDirChemin1_Chemin2)*2200);
				PlayerPawn.SpeedFactorLimit = 0.0;
			}
		}
	}
}


//_____________________________________________________________________________
STATE STA_AttenteCouloir
{
	EVENT BeginState()
	{
		Log("ENTER : STA_AttenteCouloir");

		PawnMaton2.WaitAnim='waitmatrak';
		PawnMaton2.WalkAnim='marchematrakhand';
		DefaultWalkAnimVelocity = PawnMaton2.WalkAnimVelocity;
		PawnMaton2.WalkAnimVelocity = 140;
		ControllerMaton2.WantedSpeed=0.45;
		bPauseMaton2 = true;
	}

	EVENT Tick( float dt )
	{
		local vector vPos1, vPos2, vPos3, vPosStrafe, vPosStrafeOld;

		TimeStamp+=dt;

		ControllerMaton2.LockedActor = PlayerPawn;
		ControllerMaton2.Focus = PlayerPawn;
		//ControllerMaton2.PlayAni('StrafeD');

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// comportement du second maton
		TestMatraquageMaton2();

		// test si XIII commence a descendre l escalier
		TestXIIIDansEscalier();

		// calcul des positions et des directions
		vPosPlayer = PlayerPawn.Location;
		vPosMaton2 = PawnMaton2.Location;
		vDirChemin1_Chemin2 = vPosChemin2 - vPosChemin1;
		vDirChemin1_Player = vPosPlayer - vPosChemin1;
		vDirChemin1_Maton2 = vPosMaton2 - vPosChemin1;
		vDirChemin1_Chemin2.z = 0;
		vDirChemin1_Player.z = 0;
		vDirChemin1_Maton2.z = 0;
		// calcul des distances par rapport a l axe Chemin1-Chemin2
		fDistChemin1CentrePlayer = (vDirChemin1_Chemin2 dot vDirChemin1_Player)/vSize(vDirChemin1_Chemin2);
		vPosCentralPlayer = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentrePlayer;
		vPosCentralPlayer.z = vPosPlayer.z;
		fDistChemin1CentreMaton2 = (vDirChemin1_Chemin2 dot vDirChemin1_Maton2)/vSize(vDirChemin1_Chemin2);
		vPosCentralMaton2 = vPosChemin1 + Normal(vDirChemin1_Chemin2)*fDistChemin1CentreMaton2;
		fDecalageCentrePlayer = vSize(vPosPlayer - vPosCentralPlayer);
		vOrthogonalChemin = Normal(vPosPlayer - vPosCentralPlayer);
		vOrthogonalChemin.z = 0;
		fDecalageCentreMaton2 = FMin(fDecalageCentrePlayer,50);
		SetLocation(vPosCentralMaton2 + fDecalageCentreMaton2*vOrthogonalChemin);
		ControllerMaton2.CineMoveTo(self,true);

		// on regarde si l ecart entre les deux matons est redevenu normal
		vDirMaton1_Maton2 = PawnMaton1.Location - PawnMaton2.Location;
		vDirMaton1_Maton2.z = 0;
		if ( (( !bXIIIDansEscalier ) && ( vSize(vDirMaton1_Maton2) > 0.95*DistanceMatons ))
			|| (( bXIIIDansEscalier ) && ( vSize(vDirMaton1_Maton2) > 0.35*DistanceMatons )) )
		{
			bPauseMaton2 = false;
			PawnMaton2.WaitAnim='waitmatrak';
			PawnMaton2.WalkAnim='marchematrakhand';
			PawnMaton2.WalkAnimVelocity = DefaultWalkAnimVelocity;
			ControllerMaton2.WantedSpeed = VitesseMaton2;
			if ( bEscortingEscalierMaton2 )
				GotoState('STA_EscortingEscalier');
			else
				GotoState('STA_Escorting');
		}
	}
}


//_____________________________________________________________________________
STATE STA_AttenteEscalier
{
	EVENT BeginState()
	{
		Log("ENTER : STA_AttenteDevantLesEscaliers");

		ControllerMaton2.StopMove();
		ControllerMaton2.LockedActor=none;
		ControllerMaton2.Focus = PlayerPawn;
		ControllerMaton2.LoopAni(PawnMaton1.WaitAnim);
		bPauseMaton2 = true;
		bPauseEscalierMaton2 = true;
	}

	EVENT Tick( float dt )
	{

		TimeStamp+=dt;

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// comportement du second maton
		TestMatraquageMaton2();

		// test si XIII commence a descendre l escalier
		TestXIIIDansEscalier();


		if ( bXIIIDansEscalier )
		{
			bPauseMaton2 = false;
			bPauseEscalierMaton2 = false;
			Maton2Index += 3;
			vPosChemin2 = Chemin[Maton2Index].Location;
			GotoState('STA_EscortingEscalier');
		}
	}
}


//_____________________________________________________________________________
STATE STA_EscortingEscalier
{
	EVENT BeginState()
	{
		Log("ENTER : STA_EscortingEscalier");

		ControllerMaton2.RotationSpeed=359;
		ControllerMaton2.WantedSpeed=VitesseMaton2;
		ControllerMaton2.AccelerationFactor=1.0;
		ControllerMaton2.LockedActor=PlayerPawn;
		ControllerMaton2.CineMoveTo(Chemin[Maton2Index]);
		bEscortingEscalierMaton2 = true;
	}

	EVENT Tick(float dt)
	{

		TimeStamp+=dt;

		// comportement du premier maton
		FirstKeeperBehavior(dt);

		// comportement du second maton
		TestMatraquageMaton2();

		// ajustement de la vitesse du second maton
		AjusteVitesseMaton2(dt);

		// on regarde si on change de section de chemin
		vDirMaton2_Chemin2 = PawnMaton2.Location - vPosChemin2;
		vDirMaton2_Chemin2.z = 0;
		if ( vSize(vDirMaton2_Chemin2) < 5)
		{
			Maton2Index ++;

			// le second maton s arrete juste avant la fin du chemin
			if (Maton2Index == (Chemin.Length - 2))
			{
				if (!bFinCheminMaton1)
				{
					ControllerMaton1.StopMove();
					ControllerMaton1.LockedActor=none;
				}
				ControllerMaton2.StopMove();
				ControllerMaton2.LockedActor=none;
				TriggerEvent(event, self, PawnMaton1);
				GotoState('STA_EndOfEscort');
				return;
			}

			// on prend en compte les portes pour le point suivant du chemin
			vPosChemin2 = Chemin[Maton2Index].Location;
			ControllerMaton2.CineMoveTo(Chemin[Maton2Index]);
		}
	}
}


//_____________________________________________________________________________
// gestion de la fin
// -> interaction des objets
// -> verrouillage des portes
// -> restitution des poings
STATE STA_EndOfEscort
{
	EVENT Tick( float dt )
	{
		// comportement du premier maton
		FirstKeeperBehavior(dt);

		if ( bFinCheminMaton1 )
		{
			ControllerMaton1.StopMove();
			ControllerMaton1.LockedActor=none;
			TriggerEvent(event, self, PawnMaton1);
			Disable('Tick');
		}
	}

	EVENT Trigger(actor Other,Pawn EventInstigator)
	{
		local XIIIPorte PorteATraiter;
		local Inventory Inv;

		// je m occupe des portes
		for (i=0;i<ObjetsSansInteraction.Length;i++)
		{
			ObjetATraiter = ObjetsSansInteraction[i];
			if ( ObjetATraiter.IsA('Porte') )
			{
				Porte(ObjetATraiter).bNoInteractionIcon = false;
				PawnMaton1.CloseDoor(Porte(ObjetATraiter));
			}
		}

		// on redonne les poings au joueur
		Level.Game.BaseMutator.DefaultWeaponName = "XIII.Fists";
		Level.Game.AddDefaultInventory(PlayerPawn);

		PawnMaton1.bInteractive = true;
		PawnMaton2.bInteractive = true;

		// on remplace la collision de la map
		ColCouloirEscorte.bWorldGeometry = false;
		ColCouloirEscorte.bBlockActors = false;
		ColCouloirEscorte.bBlockPlayers = false;
		ColCouloirEscorte.bBlockZeroExtentTraces = false;
		ColCouloirEscorte.bBlockNonZeroExtentTraces = false;
		ColCouloirEscorte.Destroy();
		ColEscalierEscorte.bWorldGeometry = false;
		ColEscalierEscorte.bBlockActors = false;
		ColEscalierEscorte.bBlockPlayers = false;
		ColEscalierEscorte.bBlockZeroExtentTraces = false;
		ColEscalierEscorte.bBlockNonZeroExtentTraces = false;
		ColEscalierEscorte.Destroy();
		Destroy();
		return;
	}
}


//_____________________________________________________________________________


defaultproperties
{
     DistanceMatons=600.000000
     VitesseMaton1=0.330000
     VitesseMaton2=0.330000
     fDegatCoupDeMatraque=15.000000
}
