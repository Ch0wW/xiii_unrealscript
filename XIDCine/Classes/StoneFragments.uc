//-----------------------------------------------------------
// XIIIFragment3DEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class StoneFragments extends XIIIFragment3DEmitter;



defaultproperties
{
     Begin Object Class=MeshEmitter Name=StoneFragmentsA
         StaticMesh=StaticMesh'StaticSanc01.roche_fx'
         UseMeshBlendMode=False
         FadeOut=True
         Initialized=True
         FadeOutStartTime=1.000000
         StartLocationRange=(X=(Min=-100.000000,Max=-100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         StartSizeRange=(X=(Min=0.500000,Max=0.800000))
         ParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
         Name="StoneFragmentsA"
     End Object
     Emitters(0)=MeshEmitter'XIDCine.StoneFragments.StoneFragmentsA'
}
