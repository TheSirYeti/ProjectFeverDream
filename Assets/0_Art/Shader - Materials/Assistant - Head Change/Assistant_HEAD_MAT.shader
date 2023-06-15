// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Assistant_HEAD_MAT"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (1,0,0,0)
		_Float0("Float 0", Range( 0 , 0.45)) = 0
		_Float1("Float 1", Float) = 0
		_Linemouth("Line mouth", Float) = 0
		_Vector1("Vector 1", Vector) = (0,0.85,0,0)
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		[IntRange]_ControlFace1("Control Face", Range( 0 , 3)) = 0
		_Tilling("Tilling", Vector) = (0,1.26,0,0)
		_Vector2("Vector 2", Vector) = (0.1666,0,0,0)
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

		uniform sampler2D _TextureSample2;
		uniform float2 _Tilling;
		uniform float2 _Vector2;
		uniform float _ControlFace1;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _Float1;
		uniform float2 _Vector0;
		uniform float _Float0;
		uniform float2 _Vector1;
		uniform float _Linemouth;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 _MoveFace1 = float2(1,0);
			float2 uv_TexCoord205 = i.uv_texcoord * ( _Tilling + _Vector2 ) + ( _Vector2 * _MoveFace1 * ( ( _MoveFace1 + float2( -1,0 ) ).x + _ControlFace1 ) );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float V_TextureCoordinates110 = i.uv_texcoord.y;
			float temp_output_113_0 = ceil( ( ( 1.0 - V_TextureCoordinates110 ) + _Float1 ) );
			float2 panner7 = ( 1.0 * _Time.y * ( _Vector0 * _Float0 ) + i.uv_texcoord);
			o.Emission = ( ( ( tex2D( _TextureSample2, uv_TexCoord205 ) + tex2D( _TextureSample0, uv_TextureSample0 ) ) * ( 1.0 - temp_output_113_0 ) ) + ( tex2D( _TextureSample0, (panner7*1.0 + ( _Vector1 * ( 1.0 - _Linemouth ) )) ) * temp_output_113_0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
2;81;675;584;2550.638;1452.324;2.24557;True;False
Node;AmplifyShaderEditor.Vector2Node;197;-2713.668,-729.7701;Inherit;False;Constant;_MoveFace1;Move Face;19;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;116;-2576.748,-283.4056;Inherit;False;787.672;556.9271;Comment;6;6;110;92;11;91;7;Movimiento boca;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;204;-2546.483,-649.4933;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2526.748,-233.4057;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;203;-2406.238,-651.4943;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;195;-2605.483,-500.4943;Inherit;False;Property;_ControlFace1;Control Face;7;1;[IntRange];Create;True;0;0;0;False;0;False;0;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2305.14,-121.0005;Inherit;False;V_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-2107.852,422.4716;Inherit;False;Property;_Linemouth;Line mouth;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;-2283.483,-655.4943;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;207;-2333.74,-859.3809;Inherit;False;Property;_Vector2;Vector 2;10;0;Create;True;0;0;0;False;0;False;0.1666,0;0.1666,0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;92;-2415.494,157.5214;Inherit;False;Property;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0;0.3041377;0;0.45;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1870.722,-418.0743;Inherit;False;110;V_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;11;-2362.866,9.09552;Inherit;False;Property;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;200;-2410.741,-1041.187;Inherit;False;Property;_Tilling;Tilling;9;0;Create;True;0;0;0;False;0;False;0,1.26;0,0.85;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;-2134.32,-758.0072;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-2169.414,-912.687;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;114;-1628.464,-414.5393;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;119;-1970.57,287.7668;Inherit;False;Property;_Vector1;Vector 1;5;0;Create;True;0;0;0;False;0;False;0,0.85;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2118.669,95.87724;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-1629.806,-341.9743;Inherit;False;Property;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;0;-0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;-1945.728,428.6727;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;205;-1999.501,-825.1185;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1773.161,316.6775;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;7;-1980.506,-232.5201;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1455.088,-414.6898;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;-1730.786,-818.8557;Inherit;True;Property;_TextureSample2;Texture Sample 2;6;0;Create;True;0;0;0;False;0;False;-1;None;e0fd1b7f985fc3c49b5df50029aa3510;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CeilOpNode;113;-1247.564,-414.5391;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;122;-1575.118,-16.75546;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1435.682,-1151.158;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;e9a1b9957893e41448390f087c867701;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-1104.989,-878.3366;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1246.699,-57.29585;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;115;-1016.191,-461.6877;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-841.3032,-553.4614;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-938.337,-186.0397;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-689.2715,-145.6632;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-2545.33,-829.4962;Inherit;False;Property;_PointOffset;Point Offset;8;0;Create;True;0;0;0;False;0;False;2.05;0.1666;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-327.1436,-467.0093;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Assistant_HEAD_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;134;-2459.733,305.457;Inherit;False;118.3005;100;0: TALKING;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;136;-2165.754,302.8563;Inherit;False;138.4455;100;0.3: LINE;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;135;-2324.675,303.9747;Inherit;False;138.4455;100;0.15: NEUTRAL;0;;1,1,1,1;0;0
WireConnection;204;0;197;0
WireConnection;203;0;204;0
WireConnection;110;0;6;2
WireConnection;198;0;203;0
WireConnection;198;1;195;0
WireConnection;201;0;207;0
WireConnection;201;1;197;0
WireConnection;201;2;198;0
WireConnection;202;0;200;0
WireConnection;202;1;207;0
WireConnection;114;0;111;0
WireConnection;91;0;11;0
WireConnection;91;1;92;0
WireConnection;123;0;120;0
WireConnection;205;0;202;0
WireConnection;205;1;201;0
WireConnection;121;0;119;0
WireConnection;121;1;123;0
WireConnection;7;0;6;0
WireConnection;7;2;91;0
WireConnection;109;0;114;0
WireConnection;109;1;112;0
WireConnection;137;1;205;0
WireConnection;113;0;109;0
WireConnection;122;0;7;0
WireConnection;122;2;121;0
WireConnection;192;0;137;0
WireConnection;192;1;1;0
WireConnection;4;1;122;0
WireConnection;115;0;113;0
WireConnection;13;0;192;0
WireConnection;13;1;115;0
WireConnection;18;0;4;0
WireConnection;18;1;113;0
WireConnection;12;0;13;0
WireConnection;12;1;18;0
WireConnection;0;2;12;0
ASEEND*/
//CHKSM=C8D22D8CA3BE84BFDC9A99F818F3366DDD7ADA63