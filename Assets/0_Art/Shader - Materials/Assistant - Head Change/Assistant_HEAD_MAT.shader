// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Assistant_HEAD_MAT"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_SmoothnessMetallic("Smoothness & Metallic", 2D) = "white" {}
		_Maskface("Mask face", 2D) = "white" {}
		_ControlFace("Control Face", Range( 0 , 5)) = 0
		_SpeedTalking("SpeedTalking", Range( 0 , 0.5)) = 0
		_TypeMouth("Type Mouth", Range( 0 , 3)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Maskface;
		uniform float _ControlFace;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _SpeedTalking;
		uniform float _TypeMouth;
		uniform sampler2D _SmoothnessMetallic;
		uniform float4 _SmoothnessMetallic_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float4 Normal216 = tex2D( _Normal, uv_Normal );
			o.Normal = Normal216.rgb;
			float2 _Pointoffset = float2(0.1666,0.15);
			float2 _MoveFace = float2(1,0);
			float2 uv_TexCoord233 = i.uv_texcoord * ( float2( 0,0.85 ) + _Pointoffset ) + ( _Pointoffset * _MoveFace * ( ( _MoveFace + float2( -1,0 ) ).x + _ControlFace ) );
			float2 AjustedFace234 = uv_TexCoord233;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo214 = ( tex2D( _Maskface, AjustedFace234 ) + tex2D( _Albedo, uv_Albedo ) );
			float V_TexCor227 = i.uv_texcoord.y;
			float MaskMouth230 = ceil( ( ( 1.0 - V_TexCor227 ) + -0.57 ) );
			float2 UV_TexCor226 = i.uv_texcoord;
			float2 panner260 = ( 1.0 * _Time.y * ( float2( 1,0 ) * _SpeedTalking ) + UV_TexCor226);
			float2 MovementMouth272 = (panner260*1.0 + ( float2( 0,1 ) * ( ( 1.0 - _TypeMouth ) * 0.0 ) ));
			float4 temp_output_254_0 = ( ( Albedo214 * ( 1.0 - MaskMouth230 ) ) + ( MaskMouth230 * tex2D( _Albedo, MovementMouth272 ) ) );
			o.Albedo = temp_output_254_0.rgb;
			o.Emission = temp_output_254_0.rgb;
			float2 uv_SmoothnessMetallic = i.uv_texcoord * _SmoothnessMetallic_ST.xy + _SmoothnessMetallic_ST.zw;
			float4 SmoothnessMetallic217 = tex2D( _SmoothnessMetallic, uv_SmoothnessMetallic );
			float4 temp_output_279_0 = SmoothnessMetallic217;
			o.Metallic = temp_output_279_0.r;
			o.Smoothness = temp_output_279_0.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;1244;590;4445.958;1584.617;3.448133;True;False
Node;AmplifyShaderEditor.CommentaryNode;250;-3713.332,-1764.528;Inherit;False;1171.961;567.0284;;11;236;233;245;239;244;234;237;247;240;248;249;Ajusted FACE;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;245;-3663.332,-1501.954;Inherit;False;Constant;_MoveFace;Move Face;5;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;251;-2490.67,-1777.307;Inherit;False;1511.416;844.1196;;12;218;209;210;216;215;217;211;208;214;235;212;252;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;244;-3519.628,-1426.855;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;247;-3398.815,-1425.965;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;248;-3565.269,-1313.5;Inherit;False;Property;_ControlFace;Control Face;5;0;Create;True;0;0;0;False;0;False;0;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;252;-1667.179,-1262.928;Inherit;False;504.984;242;;3;224;226;227;Variable general;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;274;-3726.167,-737.5303;Inherit;False;1222.934;564.3849;;13;276;272;265;260;266;275;261;262;269;264;263;270;271;Movemente  Mouth;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;249;-3247.195,-1422.196;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;224;-1617.179,-1202.428;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;239;-3340.277,-1714.528;Inherit;False;Constant;_Tilling;Tilling;5;0;Create;True;0;0;0;False;0;False;0,0.85;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;240;-3344.178,-1581.829;Inherit;False;Constant;_Pointoffset;Point offset;5;0;Create;True;0;0;0;False;0;False;0.1666,0.15;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;271;-3657.861,-341.8598;Inherit;False;Property;_TypeMouth;Type Mouth;7;0;Create;True;0;0;0;False;0;False;2;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-3126.401,-1663.452;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;253;-3712.839,-1128.259;Inherit;False;937.9152;310.1218;;6;230;229;221;228;222;223;Mask mouth;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-3133.401,-1517.452;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-1386.195,-1136.928;Inherit;False;V_TexCor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;270;-3367.861,-338.8598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;263;-3573.915,-603.0732;Inherit;False;Constant;_MoveX;Move X;6;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;226;-1391.195,-1212.928;Inherit;False;UV_TexCor;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-3662.839,-1067.151;Inherit;False;227;V_TexCor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-3676.167,-455.0542;Inherit;False;Property;_SpeedTalking;SpeedTalking;6;0;Create;True;0;0;0;False;0;False;0;0.3;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;233;-2987.157,-1640.064;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;276;-3343.839,-258.7249;Inherit;False;Constant;_Fix;Fix;8;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-3512.48,-979.0725;Inherit;False;Constant;_Maskmouth;Mask mouth;5;0;Create;True;0;0;0;False;0;False;-0.57;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;269;-3342.115,-482.4373;Inherit;False;Constant;_MoveTypeMouth;Move Type Mouth;7;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-3397.418,-601.8278;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;234;-2765.371,-1639.363;Inherit;False;AjustedFace;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;221;-3489.265,-1065.352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-3440.599,-687.5303;Inherit;False;226;UV_TexCor;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-3199.839,-343.7249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;260;-3240.178,-681.5247;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3337.507,-1072.137;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-3098.059,-477.5185;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-2440.67,-1708.08;Inherit;False;234;AjustedFace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;212;-2266.901,-1727.307;Inherit;True;Property;_Maskface;Mask face;4;0;Create;True;0;0;0;False;0;False;-1;None;e0fd1b7f985fc3c49b5df50029aa3510;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CeilOpNode;229;-3124.425,-1072.127;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;208;-2264.356,-1515.505;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;0;False;0;False;-1;None;e9a1b9957893e41448390f087c867701;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;265;-2944.853,-680.8796;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-1950.001,-1618.41;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-2998.924,-1078.258;Inherit;False;MaskMouth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-2744.758,-684.8571;Inherit;False;MovementMouth;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-2216.737,-635.6963;Inherit;False;230;MaskMouth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-2352.227,-471.1311;Inherit;False;272;MovementMouth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-1838.41,-1623.232;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;256;-1960.085,-560.1714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;231;-1979.769,-633.7156;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;258;-2128.783,-492.9865;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;208;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;219;-1995.236,-728.886;Inherit;False;214;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;210;-1635.912,-1724.492;Inherit;True;Property;_SmoothnessMetallic;Smoothness & Metallic;2;0;Create;True;0;0;0;False;0;False;-1;None;303c3fcc727286c4b95277cd573debb0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;209;-2264.448,-1309.842;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-1804.606,-727.1429;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-1729.164,-510.9195;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-1335.912,-1721.826;Inherit;False;SmoothnessMetallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-1971.813,-1310.992;Inherit;False;Normal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;-1550.683,-727.3491;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;211;-1637.623,-1525.556;Inherit;True;Property;_Emission;Emission;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;278;-1333.966,-787.47;Inherit;False;216;Normal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-1345.067,-1525.198;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;-1338.505,-662.6237;Inherit;False;217;SmoothnessMetallic;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1100.216,-775.3839;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Assistant_HEAD_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;244;0;245;0
WireConnection;247;0;244;0
WireConnection;249;0;247;0
WireConnection;249;1;248;0
WireConnection;236;0;239;0
WireConnection;236;1;240;0
WireConnection;237;0;240;0
WireConnection;237;1;245;0
WireConnection;237;2;249;0
WireConnection;227;0;224;2
WireConnection;270;0;271;0
WireConnection;226;0;224;0
WireConnection;233;0;236;0
WireConnection;233;1;237;0
WireConnection;262;0;263;0
WireConnection;262;1;264;0
WireConnection;234;0;233;0
WireConnection;221;0;228;0
WireConnection;275;0;270;0
WireConnection;275;1;276;0
WireConnection;260;0;261;0
WireConnection;260;2;262;0
WireConnection;222;0;221;0
WireConnection;222;1;223;0
WireConnection;266;0;269;0
WireConnection;266;1;275;0
WireConnection;212;1;235;0
WireConnection;229;0;222;0
WireConnection;265;0;260;0
WireConnection;265;2;266;0
WireConnection;215;0;212;0
WireConnection;215;1;208;0
WireConnection;230;0;229;0
WireConnection;272;0;265;0
WireConnection;214;0;215;0
WireConnection;256;0;232;0
WireConnection;231;0;232;0
WireConnection;258;1;273;0
WireConnection;220;0;219;0
WireConnection;220;1;231;0
WireConnection;255;0;256;0
WireConnection;255;1;258;0
WireConnection;217;0;210;0
WireConnection;216;0;209;0
WireConnection;254;0;220;0
WireConnection;254;1;255;0
WireConnection;218;0;211;0
WireConnection;0;0;254;0
WireConnection;0;1;278;0
WireConnection;0;2;254;0
WireConnection;0;3;279;0
WireConnection;0;4;279;0
ASEEND*/
//CHKSM=B39543F7846479AF23034D2A979041F8E2366B90