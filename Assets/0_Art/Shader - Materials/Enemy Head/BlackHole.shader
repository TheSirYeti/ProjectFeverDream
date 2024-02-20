// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole_HEAD"
{
	Properties
	{
		[Header(Base Header)]_Emission("Emission", 2D) = "white" {}
		_Head_MASK("Head_MASK", 2D) = "white" {}
		[HDR]_ColorFace("Color Face", Color) = (0,0,0,0)
		[IntRange]_ControlFace("Control Face", Range( 0 , 4)) = 0
		_StaticChangeFace("Static Change Face", Range( 0 , 10)) = 0
		[Header(BlackHole)]_Range("Range", Range( 1 , 10)) = 10
		_Effect("Effect", Range( 0 , 10)) = 0
		_BlackHolePositions("Black Hole Positions", Vector) = (-5.453,7.94,17,0)
		[Header(Warning Attack)]_ValueWarning("Value Warning", Range( 0 , 1)) = 0
		_NumberLines("Number Lines", Range( 0 , 300)) = 0
		_SpeedCorners("Speed Corners", Range( 0 , 10)) = 10
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _SpeedCorners;
		uniform float _ValueWarning;
		uniform float _NumberLines;
		uniform float3 _BlackHolePositions;
		uniform float _Range;
		uniform float _Effect;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _ColorFace;
		uniform sampler2D _Head_MASK;
		uniform float _ControlFace;
		uniform float _StaticChangeFace;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float fresnelNdotV850 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode850 = ( 0.0 + 1.2 * pow( 1.0 - fresnelNdotV850, 0.26 ) );
			float4 color852 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float mulTime842 = _Time.y * _SpeedCorners;
			float lerpResult851 = lerp( 3.0 , 1.0 , sin( ( 1.0 * mulTime842 ) ));
			float2 uv_TexCoord857 = v.texcoord.xy * float3(0.2,12,1).xy;
			float4 transform858 = mul(unity_WorldToObject,float4( uv_TexCoord857, 0.0 , 0.0 ));
			float mulTime860 = _Time.y * 0.22;
			float simplePerlin2D865 = snoise( ( transform858 + mulTime860 ).xy*_NumberLines );
			simplePerlin2D865 = simplePerlin2D865*0.5 + 0.5;
			float4 temp_output_867_0 = ( ( saturate( ( ( fresnelNode850 * color852 ) * lerpResult851 ) ) * _ValueWarning ) * simplePerlin2D865 );
			float4 temp_output_872_0 = ( float4( ase_vertexNormal , 0.0 ) * ( temp_output_867_0 * _ValueWarning ) );
			float3 temp_output_517_0 = ( _BlackHolePositions - ase_worldPos );
			float lerpResult521 = lerp( 0.0 , _Range , _Effect);
			float clampResult557 = clamp( ( lerpResult521 - length( temp_output_517_0 ) ) , 0.0 , 1.0 );
			float3 lerpResult523 = lerp( float3( 0,0,0 ) , ( float3( 0,0,0 ) + temp_output_517_0 ) , clampResult557);
			float3 worldToObjDir562 = mul( unity_WorldToObject, float4( lerpResult523, 0 ) ).xyz;
			float3 BlackHole394 = worldToObjDir562;
			v.vertex.xyz += ( temp_output_872_0 + float4( BlackHole394 , 0.0 ) ).rgb;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float2 _MoveFace = float2(1,0);
			float2 uv_TexCoord759 = i.uv_texcoord + float2( 0.5,0.5 );
			float2 temp_cast_0 = (uv_TexCoord759.y).xx;
			float2 panner802 = ( _Time.y * float2( 0,2 ) + temp_cast_0);
			float simplePerlin2D761 = snoise( panner802*_StaticChangeFace );
			simplePerlin2D761 = simplePerlin2D761*0.5 + 0.5;
			float2 uv_TexCoord664 = i.uv_texcoord * ( float2( 0,0.8 ) + 0.2 ) + ( ( 0.2 * _MoveFace * ( ( _MoveFace + -1.0 ).x + _ControlFace ) ) + (( simplePerlin2D761 * 0.1 )*0.5 + float2( -0.025,0 ).x) );
			float4 temp_output_660_0 = saturate( ( saturate( _ColorFace ) * tex2D( _Head_MASK, uv_TexCoord664 ) ) );
			float4 Head_Mask658 = temp_output_660_0;
			float4 Emission358 = ( tex2D( _Emission, uv_Emission ) + Head_Mask658 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV850 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode850 = ( 0.0 + 1.2 * pow( 1.0 - fresnelNdotV850, 0.26 ) );
			float4 color852 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float mulTime842 = _Time.y * _SpeedCorners;
			float lerpResult851 = lerp( 3.0 , 1.0 , sin( ( 1.0 * mulTime842 ) ));
			float2 uv_TexCoord857 = i.uv_texcoord * float3(0.2,12,1).xy;
			float4 transform858 = mul(unity_WorldToObject,float4( uv_TexCoord857, 0.0 , 0.0 ));
			float mulTime860 = _Time.y * 0.22;
			float simplePerlin2D865 = snoise( ( transform858 + mulTime860 ).xy*_NumberLines );
			simplePerlin2D865 = simplePerlin2D865*0.5 + 0.5;
			float4 temp_output_867_0 = ( ( saturate( ( ( fresnelNode850 * color852 ) * lerpResult851 ) ) * _ValueWarning ) * simplePerlin2D865 );
			float4 temp_output_872_0 = ( float4( ase_vertexNormal , 0.0 ) * ( temp_output_867_0 * _ValueWarning ) );
			o.Emission = ( Emission358 + saturate( temp_output_872_0 ) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
0;73;947;619;1210.021;4272.161;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;805;-3073.055,-4314.687;Inherit;False;1992.826;937.0022;Comment;21;669;668;672;741;707;743;739;742;718;796;759;760;803;802;763;761;793;767;789;664;806;Change Face;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;759;-3023.055,-3859.653;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0.5,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;707;-2408.485,-4066.969;Inherit;False;Constant;_MoveFace;Move Face;5;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;806;-2369.449,-3908.507;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;760;-2815.487,-3858.311;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;803;-2785.89,-3585.581;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;802;-2569.738,-3764.89;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;743;-2193.3,-3970.692;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;763;-2730.841,-3493.682;Inherit;False;Property;_StaticChangeFace;Static Change Face;6;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;739;-2051.655,-3979.992;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;892;-3078.332,-1779.955;Inherit;False;Property;_SpeedCorners;Speed Corners;12;0;Create;True;0;0;0;False;0;False;10;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-2140.901,-3824.992;Inherit;False;Property;_ControlFace;Control Face;5;1;[IntRange];Create;True;0;0;0;False;0;False;0;4;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;761;-2394.625,-3743.437;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;843;-2773.571,-1872.166;Inherit;False;Constant;_MSIN;MSIN;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;669;-1919.747,-4132.996;Inherit;False;Constant;_PointOffset;Point Offset;7;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;767;-2132.416,-3740.719;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;793;-1917.789,-3656.123;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;0;False;0;False;-0.025,0;-0.025,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;742;-1811.9,-3980.992;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;842;-2779.984,-1771.533;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;840;-2070.39,-2216.608;Inherit;False;1951.677;999.1895;;21;869;867;866;865;864;863;860;859;858;857;855;854;853;852;850;848;845;878;889;888;891;Heavy attack JP;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;844;-2623.068,-1828.803;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-1662.737,-4083.507;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;789;-1748.622,-3739.969;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;668;-1917.158,-4264.687;Inherit;False;Constant;_Tilling;Tilling;6;0;Create;True;0;0;0;False;0;False;0,0.8;0,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;672;-1697.831,-4238.187;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;846;-2505.144,-1907.469;Inherit;False;Constant;_QUEWSSOSO;QUE WSSOSO;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;848;-2020.39,-2020.185;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;0;False;0;False;0.26;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;849;-2492.064,-1827.841;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;564;-3303.082,-3203.327;Inherit;False;1649.081;545.574;;13;515;517;521;519;520;558;557;523;562;394;882;883;886;BlackHole;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;847;-2496.144,-1987.469;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;796;-1492.167,-4087.939;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;804;-983.9185,-4530.609;Inherit;False;1500.909;1246.833;Comment;22;359;572;356;573;352;729;360;357;363;731;654;730;350;660;657;355;658;353;661;358;659;364;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;845;-2019.987,-2102.929;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;1.2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;886;-3234.572,-3007.255;Inherit;False;Property;_BlackHolePositions;Black Hole Positions;9;0;Create;True;0;0;0;False;0;False;-5.453,7.94,17;-5.453,7.94,17;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;853;-2038.116,-1729.215;Inherit;False;Constant;_Vector1;Vector 1;20;0;Create;True;0;0;0;False;0;False;0.2,12,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;851;-2238.607,-1944.617;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;850;-1825.511,-2160.658;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;664;-1322.229,-4195.646;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;852;-1740.402,-1895.271;Inherit;False;Constant;_ColorWaring;Color Waring;2;0;Create;True;0;0;0;False;0;False;1,0,0.008883953,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;515;-3220.458,-3153.327;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;729;-933.9186,-4480.609;Inherit;False;Property;_ColorFace;Color Face;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;883;-3247.848,-2783.123;Inherit;False;Property;_Effect;Effect;8;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;654;-891.3375,-4232.384;Inherit;True;Property;_Head_MASK;Head_MASK;3;0;Create;True;0;0;0;False;0;False;-1;None;1af0e5fd342c8ae458ef5cb4b99cfc9a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;854;-1233.177,-1945.657;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;517;-2955.957,-3060.084;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;857;-1868.312,-1699.827;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;731;-688.6188,-4348.747;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;855;-1495.428,-2160.076;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;878;-1933.67,-1542.21;Inherit;False;Constant;_SpeedWarning;Speed Warning;17;0;Create;True;0;0;0;False;0;False;0.22;0;0.22;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;882;-3254.235,-2855.494;Inherit;False;Property;_Range;Range;7;1;[Header];Create;True;1;BlackHole;0;0;False;0;False;10;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;858;-1648.492,-1725.152;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;521;-2807.106,-2816.754;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;730;-547.3249,-4248.159;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LengthOpNode;519;-2719.054,-2961.875;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;860;-1634.342,-1547.331;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;-992.8752,-2159.206;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;520;-2576.981,-2845.327;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;891;-1503.51,-1487.517;Inherit;False;Property;_NumberLines;Number Lines;11;0;Create;True;0;0;0;False;0;False;0;300;0;300;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;864;-1396.562,-1658.734;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;863;-866.1478,-2153.466;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;888;-1029.847,-1883.144;Inherit;False;Property;_ValueWarning;Value Warning;10;1;[Header];Create;True;1;Warning Attack;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;660;-401.2451,-4241.879;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;557;-2405.667,-2909.405;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-2645.655,-3084.22;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;865;-1181.951,-1693.94;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;658;-241.142,-4241.356;Inherit;False;Head_Mask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;866;-706.7407,-2149.663;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;661;-521.4699,-3617.907;Inherit;False;658;Head_Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;523;-2298.407,-3108.725;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;353;-696.7399,-3810.663;Inherit;True;Property;_Emission;Emission;2;1;[Header];Create;True;1;Base Header;0;0;False;0;False;-1;None;b5ff3d9dc192ef2438f37d643b149540;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;867;-588.4925,-1717.345;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;889;-559.9536,-1440.569;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;871;173.0802,-1694.158;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;562;-2108.156,-3111.076;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;870;-54.93372,-1863.776;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;659;-285.6269,-3804.088;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-1878.001,-3107.958;Inherit;False;BlackHole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;444.9722,-1909.001;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-132.8827,-3810.999;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;582.5897,-1629.649;Inherit;False;394;BlackHole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;875;618.2088,-2071.34;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;558.6696,-2364.265;Inherit;False;358;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;271.6381,-3923.858;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;572;-168.1527,-3653.011;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;350;-696.6828,-4013.588;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;b5ff3d9dc192ef2438f37d643b149540;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;359;-169.6707,-3501.754;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;21.32917,-3504.754;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;352;-704.4401,-3513.775;Inherit;True;Property;_MetallicSmoothness;Metallic Smoothness;1;0;Create;True;0;0;0;False;0;False;-1;None;2e233506deb0fdb479a9ee59ed045b37;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;657;-223.0009,-4040.671;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;-414.6892,-3512.863;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;876;859.8047,-1863.316;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;-432.338,-2146.496;Inherit;False;FresnelWarning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-101.0326,-4037.427;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;573;22.84723,-3656.011;Inherit;False;WorldNormalBueno;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;874;828.1179,-2284.383;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;271.9911,-3846.311;Inherit;False;LightColor_Intesity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;360;97.12117,-3942.122;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1107.514,-2195.625;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;BlackHole_HEAD;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;760;0;759;0
WireConnection;802;0;760;1
WireConnection;802;1;803;0
WireConnection;743;0;707;0
WireConnection;743;1;806;0
WireConnection;739;0;743;0
WireConnection;761;0;802;0
WireConnection;761;1;763;0
WireConnection;767;0;761;0
WireConnection;742;0;739;0
WireConnection;742;1;741;0
WireConnection;842;0;892;0
WireConnection;844;0;843;0
WireConnection;844;1;842;0
WireConnection;718;0;669;0
WireConnection;718;1;707;0
WireConnection;718;2;742;0
WireConnection;789;0;767;0
WireConnection;789;2;793;0
WireConnection;672;0;668;0
WireConnection;672;1;669;0
WireConnection;849;0;844;0
WireConnection;796;0;718;0
WireConnection;796;1;789;0
WireConnection;851;0;847;0
WireConnection;851;1;846;0
WireConnection;851;2;849;0
WireConnection;850;2;845;0
WireConnection;850;3;848;0
WireConnection;664;0;672;0
WireConnection;664;1;796;0
WireConnection;654;1;664;0
WireConnection;854;0;851;0
WireConnection;517;0;886;0
WireConnection;517;1;515;0
WireConnection;857;0;853;0
WireConnection;731;0;729;0
WireConnection;855;0;850;0
WireConnection;855;1;852;0
WireConnection;858;0;857;0
WireConnection;521;1;882;0
WireConnection;521;2;883;0
WireConnection;730;0;731;0
WireConnection;730;1;654;0
WireConnection;519;0;517;0
WireConnection;860;0;878;0
WireConnection;859;0;855;0
WireConnection;859;1;854;0
WireConnection;520;0;521;0
WireConnection;520;1;519;0
WireConnection;864;0;858;0
WireConnection;864;1;860;0
WireConnection;863;0;859;0
WireConnection;660;0;730;0
WireConnection;557;0;520;0
WireConnection;558;1;517;0
WireConnection;865;0;864;0
WireConnection;865;1;891;0
WireConnection;658;0;660;0
WireConnection;866;0;863;0
WireConnection;866;1;888;0
WireConnection;523;1;558;0
WireConnection;523;2;557;0
WireConnection;867;0;866;0
WireConnection;867;1;865;0
WireConnection;889;0;888;0
WireConnection;871;0;867;0
WireConnection;871;1;889;0
WireConnection;562;0;523;0
WireConnection;659;0;353;0
WireConnection;659;1;661;0
WireConnection;394;0;562;0
WireConnection;872;0;870;0
WireConnection;872;1;871;0
WireConnection;358;0;659;0
WireConnection;875;0;872;0
WireConnection;363;0;360;1
WireConnection;356;0;359;0
WireConnection;657;0;660;0
WireConnection;657;1;350;0
WireConnection;357;0;352;0
WireConnection;876;0;872;0
WireConnection;876;1;460;0
WireConnection;869;0;867;0
WireConnection;355;0;657;0
WireConnection;573;0;572;0
WireConnection;874;0;447;0
WireConnection;874;1;875;0
WireConnection;364;0;360;2
WireConnection;0;2;874;0
WireConnection;0;11;876;0
ASEEND*/
//CHKSM=AFF239EC98905431E3D2D6E66C38448D92238AA7