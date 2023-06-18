// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DoorScreen"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_MAIN("MAIN", 2D) = "white" {}
		_Ring("Ring", 2D) = "white" {}
		_Padlock("Padlock", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Controlcolor("Control color", Range( 0 , 1)) = 1
		_Pointoffset("Point offset", Vector) = (0.62,2.04,0,0)
		_Colorlock("Color lock", Color) = (0.8,0.7599906,0,1)
		_SpeedWave("Speed Wave", Float) = 0
		_Wave("Wave", Float) = 30
		_Vector1("Vector 1", Vector) = (0.625,0.92,0,0)
		_Controlring("Control ring", Range( 0 , 1)) = 0
		_Colorunlock("Color unlock", Color) = (1,1,1,1)
		_NoInteractive("No Interactive", Range( 0 , 1)) = 0
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

		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _MAIN;
		uniform float4 _MAIN_ST;
		uniform float4 _Colorunlock;
		uniform float4 _Colorlock;
		uniform float _Controlcolor;
		uniform sampler2D _Padlock;
		uniform float2 _Pointoffset;
		uniform sampler2D _Ring;
		uniform float2 _Vector1;
		uniform float _Controlring;
		uniform float _NoInteractive;
		uniform float _Wave;
		uniform float _SpeedWave;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			o.Normal = UnpackNormal( tex2D( _TextureSample0, uv_TextureSample0 ) );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float2 uv_MAIN = i.uv_texcoord * _MAIN_ST.xy + _MAIN_ST.zw;
			float4 tex2DNode3 = tex2D( _MAIN, uv_MAIN );
			float4 lerpResult68 = lerp( saturate( _Colorunlock ) , saturate( _Colorlock ) , _Controlcolor);
			float2 _Tilling = float2(4.5,4.5);
			float2 uv_TexCoord14 = i.uv_texcoord * _Tilling + _Pointoffset;
			float2 _MoveFace = float2(0,0.15);
			float2 uv_TexCoord23 = i.uv_texcoord * _Tilling + ( _Vector1 + ( _Vector1 * _MoveFace * ( _MoveFace.y + ( 1.0 - _Controlring ) ) ) );
			float4 lerpResult118 = lerp( saturate( ( lerpResult68 * ( saturate( tex2D( _Padlock, uv_TexCoord14 ) ) + ( saturate( tex2D( _Ring, uv_TexCoord23 ) ) * ceil( ( i.uv_texcoord.y + -0.71 ) ) ) ) ) ) , float4( 0,0,0,0 ) , ( 1.0 - _NoInteractive ));
			float mulTime90 = _Time.y * _SpeedWave;
			float4 temp_output_25_0 = ( saturate( ( tex2DNode3 + saturate( lerpResult118 ) ) ) * saturate( tex2D( _Mask, uv_Mask ) ) * saturate( ( saturate( sin( ( ( i.uv_texcoord.y * UNITY_PI * _Wave ) + mulTime90 ) ) ) - -0.8 ) ) );
			o.Albedo = ( ( ( 1.0 - UnpackNormal( tex2D( _Mask, uv_Mask ) ).r ) * tex2DNode3 ) + temp_output_25_0 ).rgb;
			o.Emission = temp_output_25_0.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;920;610;5025.394;441.5119;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;111;-4514.236,-47.16866;Inherit;False;Property;_Controlring;Control ring;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;38;-4524.759,-242.2067;Inherit;False;Constant;_MoveFace;Move Face;5;0;Create;True;0;0;0;False;0;False;0,0.15;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;47;-4217.685,-43.01035;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;40;-4217.241,-165.2176;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;30;-4216.825,-394.8792;Inherit;False;Property;_Vector1;Vector 1;10;0;Create;True;0;0;0;False;0;False;0.625,0.92;0.625,0.86;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-4065.622,-161.4487;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-3921.054,-265.0775;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-3852.397,-369.6691;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;10;-4145.447,-749.8276;Inherit;False;Constant;_Tilling;Tilling;6;0;Create;True;0;0;0;False;0;False;4.5,4.5;4.5,4.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;11;-3850.347,-661.3282;Inherit;False;Property;_Pointoffset;Point offset;6;0;Create;True;0;0;0;False;0;False;0.62,2.04;0.62,1.98;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;59;-3615.601,-84.76228;Inherit;False;Constant;_Fixmask;Fix mask;10;0;Create;True;0;0;0;False;0;False;-0.71;-0.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-3736.364,-436.4605;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;55;-3631.35,-229.1554;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-3493.326,-711.8112;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-3503.036,-466.0554;Inherit;True;Property;_Ring;Ring;2;0;Create;True;0;0;0;False;0;False;-1;None;b223f7ffd3857d04e95d2f91fd99cbd7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-3371.921,-178.1613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-3168.878,-451.5543;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CeilOpNode;58;-3245.383,-205.5735;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-3250.915,-719.4001;Inherit;True;Property;_Padlock;Padlock;3;0;Create;True;0;0;0;False;0;False;-1;None;ae93128d0bed60f4dbbbc27d5d3bdbef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;64;-3354.614,-1165.076;Inherit;False;Property;_Colorlock;Color lock;7;0;Create;True;0;0;0;False;0;False;0.8,0.7599906,0,1;1,0.04438343,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;67;-3368.357,-1374.578;Inherit;False;Property;_Colorunlock;Color unlock;12;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;71;-3148.478,-1143.621;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;18;-2933.08,-711.0986;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;70;-3097.815,-1271.171;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-2967.664,-454.7055;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3191.329,-975.9181;Inherit;False;Property;_Controlcolor;Control color;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1694.395,486.4925;Inherit;False;Property;_SpeedWave;Speed Wave;8;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;86;-1832.364,270.5016;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1826.092,361.7008;Inherit;False;Property;_Wave;Wave;9;0;Create;True;0;0;0;False;0;False;30;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-1879.031,142.7608;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2698.956,-637.363;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;68;-2856.274,-1095.64;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2207.674,-823.4901;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-2164.951,-554.3209;Inherit;False;Property;_NoInteractive;No Interactive;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1615.075,221.1776;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;90;-1517.794,424.2592;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;122;-1880.522,-611.9501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;120;-1932.07,-804.3428;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1354.95,288.3894;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;99;-1155.853,217.7237;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;118;-1737.453,-804.565;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-918.7754,273.1083;Inherit;False;Constant;_SubstractLine;Substract Line;13;0;Create;True;0;0;0;False;0;False;-0.8;-0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;-856.9399,88.89325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;121;-1548.07,-812.3428;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-1618.29,-1193.243;Inherit;True;Property;_MAIN;MAIN;1;0;Create;True;0;0;0;False;0;False;-1;None;ba7cff183b1c96d4193a3591fe01ae30;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1254.719,-934.3936;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-709.546,48.94989;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;109;-1613.435,-1482.953;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;0;False;0;False;-1;None;fca86da79df6dab4bab774cafbdb9d4e;True;0;True;bump;Auto;True;Instance;24;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;24;-1229.783,-473.7342;Inherit;True;Property;_Mask;Mask;4;0;Create;True;0;0;0;False;0;False;-1;None;81783ce36b9110542b1c93436d80e6e5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;73;-908.1846,-466.1539;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;74;-971.3122,-762.0056;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1266.069,-1411.449;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;104;-697.6598,-196.7465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1113.462,-1341.459;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-482.839,-508.9782;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-310.6652,-216.8437;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;fca86da79df6dab4bab774cafbdb9d4e;fca86da79df6dab4bab774cafbdb9d4e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-663.8221,-1180.06;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-70.44936,-760.2001;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;DoorScreen;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;111;0
WireConnection;40;0;38;0
WireConnection;41;0;40;1
WireConnection;41;1;47;0
WireConnection;36;0;30;0
WireConnection;36;1;38;0
WireConnection;36;2;41;0
WireConnection;46;0;30;0
WireConnection;46;1;36;0
WireConnection;23;0;10;0
WireConnection;23;1;46;0
WireConnection;14;0;10;0
WireConnection;14;1;11;0
WireConnection;4;1;23;0
WireConnection;60;0;55;2
WireConnection;60;1;59;0
WireConnection;19;0;4;0
WireConnection;58;0;60;0
WireConnection;5;1;14;0
WireConnection;71;0;64;0
WireConnection;18;0;5;0
WireConnection;70;0;67;0
WireConnection;62;0;19;0
WireConnection;62;1;58;0
WireConnection;65;0;18;0
WireConnection;65;1;62;0
WireConnection;68;0;70;0
WireConnection;68;1;71;0
WireConnection;68;2;69;0
WireConnection;63;0;68;0
WireConnection;63;1;65;0
WireConnection;85;0;84;2
WireConnection;85;1;86;0
WireConnection;85;2;89;0
WireConnection;90;0;87;0
WireConnection;122;0;119;0
WireConnection;120;0;63;0
WireConnection;88;0;85;0
WireConnection;88;1;90;0
WireConnection;99;0;88;0
WireConnection;118;0;120;0
WireConnection;118;2;122;0
WireConnection;108;0;99;0
WireConnection;121;0;118;0
WireConnection;17;0;3;0
WireConnection;17;1;121;0
WireConnection;102;0;108;0
WireConnection;102;1;103;0
WireConnection;73;0;24;0
WireConnection;74;0;17;0
WireConnection;81;0;109;1
WireConnection;104;0;102;0
WireConnection;79;0;81;0
WireConnection;79;1;3;0
WireConnection;25;0;74;0
WireConnection;25;1;73;0
WireConnection;25;2;104;0
WireConnection;82;0;79;0
WireConnection;82;1;25;0
WireConnection;0;0;82;0
WireConnection;0;1;1;0
WireConnection;0;2;25;0
ASEEND*/
//CHKSM=A7E8F515B1233D2E1A7CCBBF7D753D2305CBFD65