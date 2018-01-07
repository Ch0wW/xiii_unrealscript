//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MeshSkinList extends Info
  config(MSL);

struct StructMeshSkinInfo
{
  var string SkinReadableName;  // Explicit
  var string SkinName;  // real name of skin in animation package
  var string SkinCode;  // used to give it by URL w/ otpion ?SK=xxxx
  var string SkinRed;   // Used for team games
  var string SkinBlue;  // Used for team games
  var int CodeMesh;     // used for sounds
};

var config array<StructMeshSkinInfo> MeshSkinListInfo;

//_____________________________________________________________________________
static function int StaticFindSkinIndex(string RefSkinCode)
{
    local int i, NbSkins;
    local string sCode;

    sCode = Caps(left(RefskinCode, 4));
    NbSkins = default.MeshSkinListInfo.Length;
    if ( NbSkins > 0 )
    {
      for (i=0; i<NbSkins; i++)
        if ( default.MeshSkinListInfo[i].SkinCode == sCode )
          return i; // found
    }
    return (NbSkins + 1); // not found
}

// default Content of MSL.ini :
/*
[Engine.MeshSkinList]
MeshSkinListInfo=(SkinReadableName="XIII",SkinName="XIIIPersos.XIIIMilitM",SkinCode="S13M",SKinRed="XIIIPersos.Mul_XIIIMilit_RougeTex",SkinBlue="XIIIPersos.Mul_XIIIMilit_BleuTex",CodeMesh=9)
MeshSkinListInfo=(SkinReadableName="Shinyaku",SkinName="XIIIPersos.DanhsuM",SkinCode="DANH",SKinRed="XIIIPersos.Mul_danhsu_rougeTEX",SkinBlue="XIIIPersos.Mul_danhsu_bleuTEX",CodeMesh=14)
MeshSkinListInfo=(SkinReadableName="Trystan",SkinName="XIIIPersos.ScandiM",SkinCode="SCAN",SKinRed="XIIIPersos.Mul_scandi_rougeTEX",SkinBlue="XIIIPersos.Mul_scandi_bleuTEX",CodeMesh=29)
MeshSkinListInfo=(SkinReadableName="Carrington",SkinName="XIIIPersos.CarringtonM",SkinCode="CARR",SKinRed="XIIIPersos.Mul_Carrington_rougeTEX",SkinBlue="XIIIPersos.Mul_Carrington_bleuTEX",CodeMesh=16)
MeshSkinListInfo=(SkinReadableName="John",SkinName="XIIIPersos.GaminM",SkinCode="GAMI",SKinRed="XIIIPersos.Mul_gamin_rougeTEX",SkinBlue="XIIIPersos.Mul_gamin_bleuTEX",CodeMesh=13)
MeshSkinListInfo=(SkinReadableName="Densetsu",SkinName="XIIIPersos.NiheiM",SkinCode="NIHE",SKinRed="XIIIPersos.Mul_nihei_rougeTEX",SkinBlue="XIIIPersos.Mul_nihei_bleuTEX",CodeMesh=6)
MeshSkinListInfo=(SkinReadableName="Roger",SkinName="XIIIPersos.FrenchyM",SkinCode="FR1M",SKinRed="XIIIPersos.Mul_Frenchy_rougeTEX",SkinBlue="XIIIPersos.Mul_Frenchy_bleuTEX",CodeMesh=34)
MeshSkinListInfo=(SkinReadableName="Robert",SkinName="XIIIPersos.Frenchy2M",SkinCode="FR2M",SKinRed="XIIIPersos.Mul_Frenchy2_rougeTEX",SkinBlue="XIIIPersos.Mul_Frenchy2_bleuTEX",CodeMesh=28)
MeshSkinListInfo=(SkinReadableName="Armael",SkinName="XIIIPersos.RastaM",SkinCode="RAST",SKinRed="XIIIPersos.Mul_rasta_rougeTEX",SkinBlue="XIIIPersos.Mul_rasta_bleuTEX",CodeMesh=8)
MeshSkinListInfo=(SkinReadableName="Mongoose",SkinName="XIIIPersos.MangousteM",SkinCode="MONG",SKinRed="XIIIPersos.Mul_Mangouste_rougeTEX",SkinBlue="XIIIPersos.Mul_Mangouste_bleuTEX",CodeMesh=27)
*/

defaultproperties
{
     MeshSkinListInfo(0)=(SkinReadableName="XIII",SkinName="XIIIPersos.XIIIMilitM",SkinCode="S13M",SkinRed="XIIIPersos.Mul_XIIIMilit_RougeTex",SkinBlue="XIIIPersos.Mul_XIIIMilit_BleuTex",CodeMesh=9)
     MeshSkinListInfo(1)=(SkinReadableName="Shinyaku",SkinName="XIIIPersos.DanhsuM",SkinCode="DANH",SkinRed="XIIIPersos.Mul_danhsu_rougeTEX",SkinBlue="XIIIPersos.Mul_danhsu_bleuTEX",CodeMesh=14)
     MeshSkinListInfo(2)=(SkinReadableName="Trystan",SkinName="XIIIPersos.ScandiM",SkinCode="SCAN",SkinRed="XIIIPersos.Mul_scandi_rougeTEX",SkinBlue="XIIIPersos.Mul_scandi_bleuTEX",CodeMesh=29)
     MeshSkinListInfo(3)=(SkinReadableName="Carrington",SkinName="XIIIPersos.CarringtonM",SkinCode="CARR",SkinRed="XIIIPersos.Mul_Carrington_rougeTEX",SkinBlue="XIIIPersos.Mul_Carrington_bleuTEX",CodeMesh=16)
     MeshSkinListInfo(4)=(SkinReadableName="John",SkinName="XIIIPersos.GaminM",SkinCode="GAMI",SkinRed="XIIIPersos.Mul_gamin_rougeTEX",SkinBlue="XIIIPersos.Mul_gamin_bleuTEX",CodeMesh=13)
     MeshSkinListInfo(5)=(SkinReadableName="Densetsu",SkinName="XIIIPersos.NiheiM",SkinCode="NIHE",SkinRed="XIIIPersos.Mul_nihei_rougeTEX",SkinBlue="XIIIPersos.Mul_nihei_bleuTEX",CodeMesh=6)
     MeshSkinListInfo(6)=(SkinReadableName="Roger",SkinName="XIIIPersos.FrenchyM",SkinCode="FR1M",SkinRed="XIIIPersos.Mul_Frenchy_rougeTEX",SkinBlue="XIIIPersos.Mul_Frenchy_bleuTEX",CodeMesh=34)
     MeshSkinListInfo(7)=(SkinReadableName="Robert",SkinName="XIIIPersos.Frenchy2M",SkinCode="FR2M",SkinRed="XIIIPersos.Mul_Frenchy2_rougeTEX",SkinBlue="XIIIPersos.Mul_Frenchy2_bleuTEX",CodeMesh=28)
     MeshSkinListInfo(8)=(SkinReadableName="Armael",SkinName="XIIIPersos.RastaM",SkinCode="RAST",SkinRed="XIIIPersos.Mul_rasta_rougeTEX",SkinBlue="XIIIPersos.Mul_rasta_bleuTEX",CodeMesh=8)
     MeshSkinListInfo(9)=(SkinReadableName="Mongoose",SkinName="XIIIPersos.MangousteM",SkinCode="MONG",SkinRed="XIIIPersos.Mul_Mangouste_rougeTEX",SkinBlue="XIIIPersos.Mul_Mangouste_bleuTEX",CodeMesh=27)
}
