//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIEcumeEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIEcumeEmitterA
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(Y=0.200000)
         Acceleration=(Y=10.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         Initialized=True
         FadeOutStartTime=3.500000
         FadeInEndTime=0.500000
         MaxParticles=400
         StartLocationRange=(Y=(Min=-5000.000000,Max=5000.000000))
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=200.000000,Max=300.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.ecume'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=4.500000,Max=4.500000)
         StartVelocityRange=(X=(Min=20.000000,Max=50.000000))
         Name="XIIIEcumeEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.XIIIEcumeEmitter.XIIIEcumeEmitterA'
}
