// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TornadoCenter_MAT"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		[HDR]_ColorBase("Color Base", Color) = (0,0,0,0)
		_Float0("Float 0", Range( 0 , 1.3)) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0.4774879
		_Float2("Float 2", Float) = 0
		_Float3("Float 3", Float) = 0
		_Float4("Float 4", Float) = 0
		_Vector1("Vector 1", Vector) = (0.5,0.5,0,0)
		_Float9("Float 9", Range( 0 , 2.5)) = 0
		_Float10("Float 10", Float) = 0
		_Float11("Float 11", Float) = 0
		_Float5("Float 5", Float) = 0
		_Float6("Float 6", Float) = 0
		_Float7("Float 7", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _ColorBase;
		uniform float _Float6;
		uniform float _Float2;
		uniform float _Float3;
		uniform sampler2D _TextureSample0;
		uniform float2 _Vector0;
		uniform float _Float0;
		uniform float _Float5;
		uniform float _Opacity;
		uniform float _Float7;
		uniform float _Float4;
		uniform float2 _Vector1;
		uniform float _Float10;
		uniform float _Float9;
		uniform float _Float11;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 temp_cast_0 = (_Float2).xxxx;
			float4 temp_cast_1 = (_Float3).xxxx;
			float mulTime9 = _Time.y * _Float0;
			float2 uv_TexCoord11 = i.uv_texcoord + ( _Vector0 * mulTime9 );
			float4 temp_cast_2 = (( _Opacity / _Float7 )).xxxx;
			float4 smoothstepResult13 = smoothstep( temp_cast_0 , temp_cast_1 , ( ( tex2D( _TextureSample0, uv_TexCoord11 ) * _Float5 ) - temp_cast_2 ));
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 lerpResult31 = lerp( float4( 0,0,0,0 ) , smoothstepResult13 , saturate( ( ( ( 1.0 - ase_vertex3Pos.y ) * _Float4 ) + 0.0 ) ));
			float clampResult169 = clamp( ( ( 1.0 - ( distance( ase_vertex3Pos , float3( _Vector1 ,  0.0 ) ) * _Float10 ) ) + _Float9 ) , 0.0 , 1.0 );
			float4 temp_output_171_0 = ( lerpResult31 * pow( clampResult169 , _Float11 ) );
			o.Emission = saturate( ( ( saturate( _ColorBase ) * _Float6 ) * temp_output_171_0 ) ).rgb;
			o.Alpha = temp_output_171_0.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;889;621;746.3546;587.1309;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;8;-2516.062,-420.2295;Inherit;False;Property;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0;1.3;0;1.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;6;-2230.063,-605.2294;Inherit;False;Property;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0,0;0.5,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;9;-2240.063,-412.2295;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2030.063,-506.2295;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;153;-1053.737,346.9388;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;156;-1049.066,524.197;Inherit;False;Property;_Vector1;Vector 1;8;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.02,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;163;-796.3488,581.2625;Inherit;False;Property;_Float10;Float 10;10;0;Create;True;0;0;0;False;0;False;0;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;152;-843.2606,368.3727;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;19;-1341.612,34.91683;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1874.603,-539.1899;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1690.025,-286.5969;Inherit;False;Property;_Opacity;Opacity;4;0;Create;True;0;0;0;False;0;False;0.4774879;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1157.9,33.42214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-1570.566,-367.8025;Inherit;False;Property;_Float5;Float 5;12;0;Create;True;0;0;0;False;0;False;0;1.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1660.734,-560.751;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;f3b03ac87c18f4244a7086e9788910fe;7e4ac535c04ac8a40aeef9e10ddb297c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;187;-1517.998,-199.5451;Inherit;False;Property;_Float7;Float 7;14;0;Create;True;0;0;0;False;0;False;0;2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-622.6396,373.6246;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1315.249,203.5858;Inherit;False;Property;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-600.118,499.436;Inherit;False;Property;_Float9;Float 9;9;0;Create;True;0;0;0;False;0;False;0;1.904071;0;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-997.3333,35.01373;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;166;-494.7654,371.7613;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-1271.416,-553.6677;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;186;-1369.998,-310.5451;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;12;-1100.372,-556.8129;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-858.1818,36.84484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1168.072,-358.144;Inherit;False;Property;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1164.591,-280.6009;Inherit;False;Property;_Float3;Float 3;6;0;Create;True;0;0;0;False;0;False;0;-0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;164;-333.6582,367.3218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-384.7292,605.5679;Inherit;False;Property;_Float11;Float 11;11;0;Create;True;0;0;0;False;0;False;0;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;-732.6125,37.38424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;180;-362.3695,-374.4043;Inherit;False;Property;_ColorBase;Color Base;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.740566,0.9432488,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-713.687,-524.3991;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;169;-224.791,361.9844;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;179;-148.4911,-369.6458;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;167;-39.31793,339.5526;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-145.2736,-183.307;Inherit;False;Property;_Float6;Float 6;13;0;Create;True;0;0;0;False;0;False;0;1.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;31;-469.2436,-132.6013;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-4.273621,-334.307;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;42.67529,-17.00433;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;145.6615,-284.4958;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;181;401.7264,-256.307;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;30;609.9545,-216.3477;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TornadoCenter_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;5;0;6;0
WireConnection;5;1;9;0
WireConnection;152;0;153;0
WireConnection;152;1;156;0
WireConnection;11;1;5;0
WireConnection;23;0;19;2
WireConnection;1;1;11;0
WireConnection;162;0;152;0
WireConnection;162;1;163;0
WireConnection;20;0;23;0
WireConnection;20;1;21;0
WireConnection;166;0;162;0
WireConnection;175;0;1;0
WireConnection;175;1;176;0
WireConnection;186;0;14;0
WireConnection;186;1;187;0
WireConnection;12;0;175;0
WireConnection;12;1;186;0
WireConnection;36;0;20;0
WireConnection;164;0;166;0
WireConnection;164;1;158;0
WireConnection;32;0;36;0
WireConnection;13;0;12;0
WireConnection;13;1;15;0
WireConnection;13;2;16;0
WireConnection;169;0;164;0
WireConnection;179;0;180;0
WireConnection;167;0;169;0
WireConnection;167;1;168;0
WireConnection;31;1;13;0
WireConnection;31;2;32;0
WireConnection;182;0;179;0
WireConnection;182;1;183;0
WireConnection;171;0;31;0
WireConnection;171;1;167;0
WireConnection;177;0;182;0
WireConnection;177;1;171;0
WireConnection;181;0;177;0
WireConnection;30;2;181;0
WireConnection;30;9;171;0
ASEEND*/
//CHKSM=7E62332DCE3FECDC4DD6BA300189A30465EC7E76