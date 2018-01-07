class MangousteStunnedEmitter extends emitter;

//        ColorScale(0)=(Color=(B=84,G=133,R=130))
//        ColorScale(1)=(relativetime=1.000000,Color=(B=50,G=80,R=79))


 


defaultproperties
{
     Begin Object Class=SpriteEmitter Name=MangousteStunnedEmitterA
         Acceleration=(Z=45.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=84,G=200,R=130))
         ColorScale(1)=(relativetime=1.000000,Color=(B=50,G=150,R=79))
         FadeOutStartTime=0.800000
         MaxParticles=48
         StartLocationOffset=(X=12.000000,Z=74.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=16.000000,Max=16.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=33.000000,Max=33.000000))
         InitialParticlesPerSecond=16.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.extinct_fumeeAD'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         Name="MangousteStunnedEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.MangousteStunnedEmitter.MangousteStunnedEmitterA'
}
