// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SoftLightWeapon_MAT"
{
	Properties
	{
		[Header(Texture)]_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Normal2("Normal 2", 2D) = "bump" {}
		_Metallic_Smoothness("Metallic_Smoothness", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HDR][Header(Specular)]_ColorSpec("Color Spec", Color) = (1,0.7098039,0.5411765,1)
		_Specsomething("Spec something", Float) = 2
		_IntensitySpecular("Intensity Specular", Range( 0 , 0.2)) = 0
		[Header(Shadow)]_Shadow("Shadow", Range( 0 , 1)) = 0.65
		[Header(Fresnel)]_ColorFresnel("Color Fresnel", Color) = (1,1,1,1)
		_FresnelBias("Fresnel Bias", Float) = -0.13
		_FresnelScale("Fresnel Scale", Float) = 1.87
		_FresnelPower("Fresnel Power", Float) = 3
		_FresnelIntesity("Fresnel Intesity", Range( 0 , 0.1)) = 0
		[Header(Hafl Lambert)]_Value("Value", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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

		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Normal2;
		uniform float4 _Normal2_ST;
		uniform float _Value;
		uniform sampler2D _Metallic_Smoothness;
		uniform float4 _Metallic_Smoothness_ST;
		uniform float _Smoothness;
		uniform float _Shadow;
		uniform float4 _ColorFresnel;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FresnelIntesity;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _Specsomething;
		uniform float4 _ColorSpec;
		uniform float _IntensitySpecular;

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
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo60 = tex2D( _Albedo, uv_Albedo );
			float2 uv_Normal2 = i.uv_texcoord * _Normal2_ST.xy + _Normal2_ST.zw;
			float3 Normal_285 = (WorldNormalVector( i , UnpackNormal( tex2D( _Normal2, uv_Normal2 ) ) ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult32 = dot( Normal_285 , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 HalfLambert62 = saturate( ( (dotResult32*_Value + _Value) * ase_lightColor.rgb * ase_lightColor.a ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_Metallic_Smoothness = i.uv_texcoord * _Metallic_Smoothness_ST.xy + _Metallic_Smoothness_ST.zw;
			float4 Metallic_Smoothness18 = tex2D( _Metallic_Smoothness, uv_Metallic_Smoothness );
			float4 temp_cast_2 = (_Smoothness).xxxx;
			float dotResult36 = dot( Metallic_Smoothness18 , temp_cast_2 );
			Unity_GlossyEnvironmentData g78 = UnityGlossyEnvironmentSetup( dotResult36, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular78 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g78 );
			float3 Sature_Color_Smooth57 = indirectSpecular78;
			float smoothstepResult51 = smoothstep( -0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow54 = smoothstepResult51;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV49 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode49 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV49, _FresnelPower ) );
			float4 Fresnel70 = saturate( ( saturate( _ColorFresnel ) * fresnelNode49 * _FresnelIntesity ) );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 WorldNormal8 = (WorldNormalVector( i , UnpackNormal( tex2D( _Normal, uv_Normal ) ) ));
			float dotResult15 = dot( ( ase_worldViewDir + ase_worldlightDir ) , WorldNormal8 );
			float smoothstepResult40 = smoothstep( 1.69 , 2.7 , pow( dotResult15 , _Specsomething ));
			float3 LightColor_Color9 = ase_lightColor.rgb;
			float4 Specular68 = saturate( ( ( smoothstepResult40 * saturate( ( _ColorSpec * float4( LightColor_Color9 , 0.0 ) ) ) ) * _IntensitySpecular ) );
			c.rgb = ( ( Albedo60 * float4( HalfLambert62 , 0.0 ) * float4( ( Sature_Color_Smooth57 + Shadow54 ) , 0.0 ) ) + Fresnel70 + Specular68 ).rgb;
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
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float4 Emission73 = tex2D( _Emission, uv_Emission );
			o.Emission = Emission73.rgb;
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
-9;81;1162;650;4035.737;189.3401;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3418.76,-832.7424;Inherit;False;1306.627;750.0878;;12;76;73;69;60;56;18;10;9;8;7;4;2;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;2;-2841.62,-781.7424;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;3;-2086.375,-546.9231;Inherit;False;1824.918;627;;19;68;59;53;52;47;43;40;33;30;29;24;19;17;16;15;14;13;6;5;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-2520.969,-776.5804;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;81;-2848.149,-1031.369;Inherit;True;Property;_Normal2;Normal 2;2;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-2336.133,-782.7413;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;7;-2747.701,-297.2342;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-1982.442,-486.6972;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;6;-2009.31,-326.3372;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;82;-2499.498,-1027.207;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1769.878,-483.1972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;11;-1114.953,-922.6262;Inherit;False;1001;349;;8;54;51;41;39;35;25;23;83;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2283.356,-1031.196;Inherit;False;Normal_2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;12;-3413.934,-25.70369;Inherit;False;974.7129;335.418;;9;62;58;50;45;44;32;31;22;21;Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-2567.793,-277.5183;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1789.376,-315.8883;Inherit;False;8;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;-3367.523,-562.1681;Inherit;True;Property;_Metallic_Smoothness;Metallic_Smoothness;3;0;Create;True;0;0;0;False;0;False;-1;None;17bb4ed394025c64db6b506569049c15;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;-3346.977,27.0906;Inherit;False;85;Normal_2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;15;-1621.376,-482.8882;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1545.457,-35.92275;Inherit;False;9;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2098.969,-833.0933;Inherit;False;962.2527;253.4271;;5;57;36;27;26;78;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;21;-3363.934,126.7143;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightAttenuation;83;-1000.137,-864.3843;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1064.953,-776.6263;Inherit;False;Property;_Shadow;Shadow;9;1;[Header];Create;True;1;Shadow;0;0;False;0;False;0.65;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-1555.621,-211.4911;Inherit;False;Property;_ColorSpec;Color Spec;6;2;[HDR];[Header];Create;True;1;Specular;0;0;False;0;False;1,0.7098039,0.5411765,1;0.9386792,0.9493017,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-3075.482,-563.4001;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1586.974,-368.4042;Inherit;False;Property;_Specsomething;Spec something;7;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1384.731,-389.5692;Inherit;False;Constant;_Min;Min;5;0;Create;True;0;0;0;False;0;False;1.69;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-1397.506,-485.9193;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2048.969,-695.6663;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1384.732,-314.3153;Inherit;False;Constant;_Max;Max;5;0;Create;True;0;0;0;False;0;False;2.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1311.085,-205.5631;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-781.4495,-868.2783;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-3096.455,168.5707;Inherit;False;Property;_Value;Value;15;1;[Header];Create;True;1;Hafl Lambert;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;32;-3132.892,31.32992;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2081.554,98.0873;Inherit;False;1127.634;542.9862;;10;70;61;55;49;48;46;42;38;37;34;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2047.526,-781.4953;Inherit;False;18;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;42;-1843.376,148.0873;Inherit;False;Property;_ColorFresnel;Color Fresnel;10;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-2031.555,314.0733;Inherit;False;Property;_FresnelBias;Fresnel Bias;11;0;Create;True;0;0;0;False;0;False;-0.13;-2.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;-656.9533,-869.6262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2031.555,473.0735;Inherit;False;Property;_FresnelPower;Fresnel Power;13;0;Create;True;0;0;0;False;0;False;3;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;36;-1776.297,-775.7004;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-1145.735,-316.1782;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-755.9533,-689.6262;Inherit;False;Constant;_Maxshadow;Max shadow;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;-2910.221,29.29629;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;45;-3180.899,294.0243;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;40;-1167.506,-488.9193;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2031.555,395.0735;Inherit;False;Property;_FresnelScale;Fresnel Scale;12;0;Create;True;0;0;0;False;0;False;1.87;5.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-757.9533,-769.6263;Inherit;False;Constant;_Minshadow;Min shadow;9;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-962.5065,-489.9193;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;51;-499.9533,-868.6262;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-1618.555,153.0735;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;49;-1829.555,327.0733;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;78;-1632.979,-770.0247;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2651.966,224.7216;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1122.458,-239.9231;Inherit;False;Property;_IntensitySpecular;Intensity Specular;8;0;Create;True;0;0;0;False;0;False;0;0.033;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1815.826,509.7457;Inherit;False;Property;_FresnelIntesity;Fresnel Intesity;14;0;Create;True;0;0;0;False;0;False;0;0.0602;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1460.555,212.0734;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;56;-3368.76,-780.2773;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;3c4b40125f30da940abc7434d4fd766c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1396.718,-783.0933;Inherit;False;Sature_Color_Smooth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-337.9532,-872.6262;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-2515.821,125.4361;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-795.4576,-491.9232;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;59;-639.4576,-492.9232;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-822.2769,573.1221;Inherit;False;54;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-2441.213,29.67843;Inherit;False;HalfLambert;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;61;-1316.233,214.6564;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-3075.482,-780.2773;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-859.2769,503.1221;Inherit;False;57;Sature_Color_Smooth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-715.2769,418.1222;Inherit;False;62;HalfLambert;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1177.921,211.4822;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-582.2769,506.1221;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;69;-2804.384,-559.7031;Inherit;True;Property;_Emission;Emission;4;0;Create;True;0;0;0;False;0;False;-1;None;7d065b4dec0f7d3479aa86926de29fa2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-485.4576,-496.9232;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-710.2769,333.1223;Inherit;False;60;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-2512.344,-560.9352;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-475.2768,368.1222;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-450.9659,562.584;Inherit;False;68;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-452.9659,487.584;Inherit;False;70;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-238.3201,182.0982;Inherit;False;73;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-177.966,368.5841;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-2565.328,-198.6542;Inherit;False;LightColor_Intensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-21,86;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SoftLightWeapon_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;8;0;4;0
WireConnection;82;0;81;0
WireConnection;14;0;5;0
WireConnection;14;1;6;0
WireConnection;85;0;82;0
WireConnection;9;0;7;1
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;18;0;10;0
WireConnection;24;0;15;0
WireConnection;24;1;16;0
WireConnection;29;0;19;0
WireConnection;29;1;17;0
WireConnection;25;0;83;0
WireConnection;25;1;23;0
WireConnection;32;0;22;0
WireConnection;32;1;21;0
WireConnection;39;0;25;0
WireConnection;36;0;27;0
WireConnection;36;1;26;0
WireConnection;43;0;29;0
WireConnection;44;0;32;0
WireConnection;44;1;31;0
WireConnection;44;2;31;0
WireConnection;40;0;24;0
WireConnection;40;1;30;0
WireConnection;40;2;33;0
WireConnection;52;0;40;0
WireConnection;52;1;43;0
WireConnection;51;0;39;0
WireConnection;51;1;35;0
WireConnection;51;2;41;0
WireConnection;48;0;42;0
WireConnection;49;1;34;0
WireConnection;49;2;37;0
WireConnection;49;3;38;0
WireConnection;78;1;36;0
WireConnection;50;0;44;0
WireConnection;50;1;45;1
WireConnection;50;2;45;2
WireConnection;55;0;48;0
WireConnection;55;1;49;0
WireConnection;55;2;46;0
WireConnection;57;0;78;0
WireConnection;54;0;51;0
WireConnection;58;0;50;0
WireConnection;53;0;52;0
WireConnection;53;1;47;0
WireConnection;59;0;53;0
WireConnection;62;0;58;0
WireConnection;61;0;55;0
WireConnection;60;0;56;0
WireConnection;70;0;61;0
WireConnection;65;0;64;0
WireConnection;65;1;63;0
WireConnection;68;0;59;0
WireConnection;73;0;69;0
WireConnection;74;0;66;0
WireConnection;74;1;67;0
WireConnection;74;2;65;0
WireConnection;75;0;74;0
WireConnection;75;1;72;0
WireConnection;75;2;71;0
WireConnection;76;0;7;2
WireConnection;0;2;77;0
WireConnection;0;13;75;0
ASEEND*/
//CHKSM=89E22FD365B51A1FAA689E545BA410B8511A1D5D