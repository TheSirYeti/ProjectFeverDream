// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SoftLightPlayer"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_HalfLambert("Half Lambert", Float) = 0.55
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_ColorFresnel("Color Fresnel", Color) = (0.4386792,0.7948788,1,0)
		_IntensetySpecular("Intensety Specular", Range( 0 , 0.2)) = 0.6515115
		_Color1("Color 1", Color) = (0.6933962,0.8990011,1,0)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_Specsomething("Spec something", Float) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
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

		uniform sampler2D _TextureSample2;
		uniform float4 _TextureSample2_ST;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _HalfLambert;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform float _Smoothness;
		uniform float _Shadow;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _ColorFresnel;
		uniform float _FresnelIntensity;
		uniform float _Specsomething;
		uniform float4 _Color1;
		uniform float _IntensetySpecular;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			float4 Albedo70 = tex2D( _TextureSample2, uv_TextureSample2 );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float3 WorldNormal5 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _TextureSample0, uv_TextureSample0 ) ) )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult43 = dot( WorldNormal5 , ase_worldlightDir );
			float SoftLight75 = (dotResult43*_HalfLambert + _HalfLambert);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float4 Metallic_Smoothness15 = tex2D( _TextureSample1, uv_TextureSample1 );
			float4 temp_cast_0 = (_Smoothness).xxxx;
			float dotResult114 = dot( Metallic_Smoothness15 , temp_cast_0 );
			Unity_GlossyEnvironmentData g115 = UnityGlossyEnvironmentSetup( dotResult114, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular115 = UnityGI_IndirectSpecular( data, 0.5, ase_worldNormal, g115 );
			float3 Sature_Color72 = indirectSpecular115;
			float smoothstepResult62 = smoothstep( -0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow73 = smoothstepResult62;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV57 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode57 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV57, _FresnelPower ) );
			float4 Fresnel79 = saturate( ( fresnelNode57 * _ColorFresnel * _FresnelIntensity ) );
			float dotResult16 = dot( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) , WorldNormal5 );
			float smoothstepResult34 = smoothstep( 1.69 , 2.7 , pow( dotResult16 , _Specsomething ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 LightColor_Color12 = ase_lightColor.rgb;
			float4 Specular77 = saturate( ( ( smoothstepResult34 * saturate( ( _Color1 * float4( LightColor_Color12 , 0.0 ) ) ) ) * _IntensetySpecular ) );
			c.rgb = ( ( Albedo70 * SoftLight75 * float4( ( Sature_Color72 + Shadow73 ) , 0.0 ) ) + Fresnel79 + Specular77 ).rgb;
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
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
0;73;962;655;5069.279;2079.485;3.762584;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3972.794,-1579.314;Inherit;False;1229.436;654.4583;;12;82;81;70;63;21;15;12;9;6;5;4;2;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;2;-3447.485,-1335.522;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;7c2d5f4f6b3e24741b2651c538c0c05c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;4;-3152.657,-1330.978;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;3;-1497.842,-1599.309;Inherit;False;1941.457;648.8451;;19;77;69;66;59;58;36;34;27;26;23;22;19;18;16;14;11;10;8;7;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;7;-1447.842,-1391.905;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightColorNode;6;-3437.076,-1133.818;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-1438.196,-1545.646;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-2967.358,-1334.603;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;13;-2710.2,-1239.516;Inherit;False;1085.601;366.446;;8;73;62;52;48;47;45;31;119;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-1209.168,-1361.888;Inherit;False;5;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1211.521,-1538.354;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-3234.517,-1117.429;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;9;-3451.16,-1529.314;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;089785cec4c4b754a9157a45810ea198;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-2659.065,-1052.062;Inherit;False;Property;_Shadow;Shadow;13;0;Create;True;0;0;0;False;0;False;0;0.6521714;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-921.8085,-1066.464;Inherit;False;12;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;119;-2588.109,-1168.665;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;120;-2717.935,-1586.139;Inherit;False;926.2357;270.9017;;5;113;114;112;115;72;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-3164.329,-1528.634;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;16;-1039.763,-1537.803;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-993.2651,-1372.329;Inherit;False;Property;_Specsomething;Spec something;14;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-948.5367,-1253.807;Inherit;False;Property;_Color1;Color 1;11;0;Create;True;0;0;0;False;0;False;0.6933962,0.8990011,1,0;1,0.7114055,0.5424528,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-2344.636,-1169.359;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2645.088,-1518.589;Inherit;False;15;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2667.935,-1431.238;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-754.9862,-1435.127;Inherit;False;Constant;_Min;Min;14;0;Create;True;0;0;0;False;0;False;1.69;1.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-2585.78,-795.6555;Inherit;False;1114.338;666.9041;;9;79;74;65;57;54;51;46;41;35;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;27;-828.0871,-1541.938;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;-3986.052,-780.6279;Inherit;False;1330.248;427.6599;;5;30;29;32;43;75;Soft Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-689.3242,-1249.046;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-752.2123,-1357.882;Inherit;False;Constant;_Max;Max;12;0;Create;True;0;0;0;False;0;False;2.7;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;114;-2387.707,-1516.018;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;29;-3407.096,-730.6279;Inherit;False;479.2825;377.6606;Half Lambert;2;50;44;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2535.78,-425.7226;Inherit;False;Property;_FresnelBias;Fresnel Bias;6;0;Create;True;0;0;0;False;0;False;0;-0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2262.666,-1069.671;Inherit;False;Constant;_Minshadow;Min shadow;16;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2543.769,-338.2375;Inherit;False;Property;_FresnelScale;Fresnel Scale;5;0;Create;True;0;0;0;False;0;False;0;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2258.365,-988.0705;Inherit;False;Constant;_MaxShadow;Max Shadow;17;0;Create;True;0;0;0;False;0;False;1;0.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-3936.052,-680.7499;Inherit;False;5;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;36;-543.6931,-1252.986;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;52;-2203.595,-1160.293;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;30;-3923.475,-585.238;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;35;-2532.06,-244.7517;Inherit;False;Property;_FresnelPower;Fresnel Power;7;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-563.3972,-1541.393;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-2338.602,-745.6555;Inherit;False;Property;_ColorFresnel;Color Fresnel;9;0;Create;True;0;0;0;False;0;False;0.4386792,0.7948788,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-2288.849,-331.6706;Inherit;False;Property;_FresnelIntensity;Fresnel Intensity;12;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-354.1309,-1541.558;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;62;-2036.493,-1160.489;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;115;-2253.125,-1530.218;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;43;-3649.701,-679.1259;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-365.1227,-1353.29;Inherit;False;Property;_IntensetySpecular;Intensety Specular;10;0;Create;True;0;0;0;False;0;False;0.6515115;0.076;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;57;-2316.55,-553.9026;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3357.096,-468.968;Inherit;False;Property;_HalfLambert;Half Lambert;2;0;Create;True;0;0;0;False;0;False;0.55;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-2015.699,-1536.139;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-72.19449,-1544.299;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;50;-3195.813,-680.6279;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1981.153,-670.5356;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1848.599,-1170.092;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-3943.794,-1526.678;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;65c8a32678370aa4ba55a197b8c22769;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1279.669,-249.5156;Inherit;False;73;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-2879.804,-683.4352;Inherit;False;SoftLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-3638.875,-1524.799;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-1280.975,-331.5906;Inherit;False;72;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;74;-1776.775,-672.4655;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;69;75.34859,-1541.707;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1089.069,-312.7381;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1275.267,-490.9852;Inherit;False;70;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1268.719,-413.3842;Inherit;False;75;SoftLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-1655.442,-677.7325;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;219.6147,-1549.309;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-939.6266,-330.9906;Inherit;False;79;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-937.8589,-255.5874;Inherit;False;77;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-950.4086,-486.3839;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-3634.888,-1335.147;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;81;-3937.026,-1335.889;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-3234.227,-1040.856;Inherit;False;LightColor_Intensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1024.357,-635.6408;Inherit;False;82;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-721.7948,-485.6046;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-581.8367,-730.692;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SoftLightPlayer;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;5;0;4;0
WireConnection;11;0;8;0
WireConnection;11;1;7;1
WireConnection;12;0;6;1
WireConnection;15;0;9;0
WireConnection;16;0;11;0
WireConnection;16;1;10;0
WireConnection;45;0;119;0
WireConnection;45;1;31;0
WireConnection;27;0;16;0
WireConnection;27;1;14;0
WireConnection;23;0;19;0
WireConnection;23;1;18;0
WireConnection;114;0;113;0
WireConnection;114;1;112;0
WireConnection;36;0;23;0
WireConnection;52;0;45;0
WireConnection;34;0;27;0
WireConnection;34;1;22;0
WireConnection;34;2;26;0
WireConnection;58;0;34;0
WireConnection;58;1;36;0
WireConnection;62;0;52;0
WireConnection;62;1;47;0
WireConnection;62;2;48;0
WireConnection;115;1;114;0
WireConnection;43;0;32;0
WireConnection;43;1;30;0
WireConnection;57;1;46;0
WireConnection;57;2;41;0
WireConnection;57;3;35;0
WireConnection;72;0;115;0
WireConnection;66;0;58;0
WireConnection;66;1;59;0
WireConnection;50;0;43;0
WireConnection;50;1;44;0
WireConnection;50;2;44;0
WireConnection;65;0;57;0
WireConnection;65;1;51;0
WireConnection;65;2;54;0
WireConnection;73;0;62;0
WireConnection;75;0;50;0
WireConnection;70;0;63;0
WireConnection;74;0;65;0
WireConnection;69;0;66;0
WireConnection;111;0;85;0
WireConnection;111;1;87;0
WireConnection;79;0;74;0
WireConnection;77;0;69;0
WireConnection;90;0;88;0
WireConnection;90;1;86;0
WireConnection;90;2;111;0
WireConnection;82;0;81;0
WireConnection;21;0;6;2
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;92;2;89;0
WireConnection;0;13;92;0
ASEEND*/
//CHKSM=EC09579F98D96A5B038A1D29309A71D670B74EE7