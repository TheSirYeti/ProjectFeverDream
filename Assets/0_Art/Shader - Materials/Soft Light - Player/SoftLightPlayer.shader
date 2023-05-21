// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SoftLightPlayer"
{
	Properties
	{
		[Header(Texture)]_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
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
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
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
			float4 Albedo125 = tex2D( _Albedo, uv_Albedo );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 WorldNormal127 = (WorldNormalVector( i , UnpackNormal( tex2D( _Normal, uv_Normal ) ) ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult199 = dot( WorldNormal127 , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 HalfLambert204 = saturate( ( (dotResult199*_Value + _Value) * ase_lightColor.rgb * ase_lightColor.a ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_Metallic_Smoothness = i.uv_texcoord * _Metallic_Smoothness_ST.xy + _Metallic_Smoothness_ST.zw;
			float4 Metallic_Smoothness126 = tex2D( _Metallic_Smoothness, uv_Metallic_Smoothness );
			float4 temp_cast_2 = (_Smoothness).xxxx;
			float dotResult142 = dot( Metallic_Smoothness126 , temp_cast_2 );
			Unity_GlossyEnvironmentData g144 = UnityGlossyEnvironmentSetup( dotResult142, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular144 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g144 );
			float3 Sature_Color_Smooth145 = indirectSpecular144;
			float smoothstepResult177 = smoothstep( -0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow181 = smoothstepResult177;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV186 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode186 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV186, _FresnelPower ) );
			float4 Fresnel195 = saturate( ( saturate( _ColorFresnel ) * fresnelNode186 * _FresnelIntesity ) );
			float dotResult150 = dot( ( ase_worldViewDir + ase_worldlightDir ) , WorldNormal127 );
			float smoothstepResult154 = smoothstep( 1.69 , 2.7 , pow( dotResult150 , _Specsomething ));
			float3 LightColor_Color136 = ase_lightColor.rgb;
			float4 Specular171 = saturate( ( ( smoothstepResult154 * saturate( ( _ColorSpec * float4( LightColor_Color136 , 0.0 ) ) ) ) * _IntensitySpecular ) );
			c.rgb = ( ( Albedo125 * float4( HalfLambert204 , 0.0 ) * float4( ( Sature_Color_Smooth145 + Shadow181 ) , 0.0 ) ) + Fresnel195 + Specular171 ).rgb;
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
			float4 Emission128 = tex2D( _Emission, uv_Emission );
			o.Emission = Emission128.rgb;
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
0;73;1005;655;3677.124;1758.198;3.266988;False;False
Node;AmplifyShaderEditor.CommentaryNode;140;-2869.604,-1765.717;Inherit;False;1306.627;750.0878;;12;131;129;130;132;134;127;128;125;126;135;136;137;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;131;-2256.464,-1715.717;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;7c2d5f4f6b3e24741b2651c538c0c05c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;172;-1537.22,-1479.898;Inherit;False;1824.918;627;;19;167;154;158;162;163;164;161;157;168;169;170;151;150;148;147;159;152;171;221;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;129;-1971.813,-1709.555;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;147;-1433.286,-1419.672;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;221;-1460.154,-1259.312;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;135;-2198.545,-1230.209;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-1786.977,-1715.716;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-2018.637,-1210.493;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;132;-2818.367,-1495.143;Inherit;True;Property;_Metallic_Smoothness;Metallic_Smoothness;2;0;Create;True;0;0;0;False;0;False;-1;None;089785cec4c4b754a9157a45810ea198;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;182;-565.7974,-1855.601;Inherit;False;1001;349;;8;175;173;174;176;177;179;178;181;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;205;-2864.778,-958.6785;Inherit;False;974.7129;335.418;;7;197;199;200;202;204;220;222;Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-1240.22,-1248.863;Inherit;False;127;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-1220.722,-1416.172;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;150;-1072.22,-1415.863;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1037.818,-1301.379;Inherit;False;Property;_Specsomething;Spec something;6;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-996.3013,-968.8976;Inherit;False;136;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;173;-514.7714,-1799.596;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-2526.326,-1496.375;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;161;-1006.465,-1144.466;Inherit;False;Property;_ColorSpec;Color Spec;5;2;[HDR];[Header];Create;True;1;Specular;0;0;False;0;False;1,0.7098039,0.5411765,1;1,0.7098039,0.5411765,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;146;-1549.814,-1766.068;Inherit;False;962.2527;253.4271;;5;143;142;141;144;145;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;200;-2814.778,-806.2605;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;197;-2797.821,-905.8842;Inherit;False;127;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-515.7972,-1709.601;Inherit;False;Property;_Shadow;Shadow;8;1;[Header];Create;True;1;Shadow;0;0;False;0;False;0.65;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;152;-848.35,-1418.894;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-232.2934,-1801.253;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1499.814,-1628.641;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-1498.37,-1714.47;Inherit;False;126;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;196;-1532.399,-834.8875;Inherit;False;1127.634;542.9862;;10;183;184;185;186;191;192;193;194;195;217;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-761.929,-1138.538;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-835.5753,-1322.544;Inherit;False;Constant;_Min;Min;5;0;Create;True;0;0;0;False;0;False;1.69;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-2547.299,-764.4041;Inherit;False;Property;_Value;Value;14;1;[Header];Create;True;1;Hafl Lambert;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;199;-2583.736,-901.6449;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-835.5756,-1247.29;Inherit;False;Constant;_Max;Max;5;0;Create;True;0;0;0;False;0;False;2.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-1482.399,-618.9014;Inherit;False;Property;_FresnelBias;Fresnel Bias;10;0;Create;True;0;0;0;False;0;False;-0.13;-0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-208.7972,-1702.601;Inherit;False;Constant;_Minshadow;Min shadow;9;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;142;-1227.141,-1708.675;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-1482.399,-537.9012;Inherit;False;Property;_FresnelScale;Fresnel Scale;11;0;Create;True;0;0;0;False;0;False;1.87;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1482.399,-459.9011;Inherit;False;Property;_FresnelPower;Fresnel Power;12;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;176;-107.7972,-1802.601;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;154;-618.35,-1421.894;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-206.7972,-1622.601;Inherit;False;Constant;_Maxshadow;Max shadow;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;183;-1294.22,-784.8875;Inherit;False;Property;_ColorFresnel;Color Fresnel;9;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;158;-596.5795,-1249.153;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;202;-2361.065,-903.6785;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;224;-2631.743,-638.9505;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;217;-1266.67,-423.229;Inherit;False;Property;_FresnelIntesity;Fresnel Intesity;13;0;Create;True;0;0;0;False;0;False;0;0.1;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-573.3015,-1172.898;Inherit;False;Property;_IntensitySpecular;Intensity Specular;7;0;Create;True;0;0;0;False;0;False;0;0.09;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;185;-1069.399,-779.9013;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;186;-1280.399,-605.9014;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-2102.81,-708.2532;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;144;-1094.561,-1711.068;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;177;49.20277,-1801.601;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-413.3503,-1422.894;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-246.3015,-1424.898;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;211.2028,-1805.601;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-911.3987,-720.9014;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;130;-2819.604,-1713.252;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;65c8a32678370aa4ba55a197b8c22769;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-847.5616,-1716.068;Inherit;False;Sature_Color_Smooth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;223;-1966.665,-807.5387;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;170;-90.30154,-1425.898;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-2526.326,-1713.252;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;194;-767.0771,-718.3184;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;-1892.057,-903.2964;Inherit;False;HalfLambert;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-273.1208,-359.8525;Inherit;False;181;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;-310.1208,-429.8525;Inherit;False;145;Sature_Color_Smooth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;211;-33.12079,-426.8525;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-161.1208,-599.8525;Inherit;False;125;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-166.1208,-514.8525;Inherit;False;204;HalfLambert;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;63.69849,-1429.898;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;134;-2255.228,-1492.678;Inherit;True;Property;_Emission;Emission;3;0;Create;True;0;0;0;False;0;False;-1;None;5fbeb9843a2a78e49b132d069afdc8f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-628.765,-721.4926;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;98.19012,-370.3906;Inherit;False;171;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;96.19012,-445.3906;Inherit;False;195;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;-1963.188,-1493.91;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;73.87921,-564.8525;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;212;371.1901,-564.3906;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-2016.172,-1131.629;Inherit;False;LightColor_Intensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;310.8359,-750.8766;Inherit;False;128;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;606.2961,-803.9115;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SoftLightPlayer;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;129;0;131;0
WireConnection;127;0;129;0
WireConnection;136;0;135;1
WireConnection;148;0;147;0
WireConnection;148;1;221;0
WireConnection;150;0;148;0
WireConnection;150;1;151;0
WireConnection;126;0;132;0
WireConnection;152;0;150;0
WireConnection;152;1;162;0
WireConnection;174;0;173;0
WireConnection;174;1;175;0
WireConnection;159;0;161;0
WireConnection;159;1;167;0
WireConnection;199;0;197;0
WireConnection;199;1;200;0
WireConnection;142;0;141;0
WireConnection;142;1;143;0
WireConnection;176;0;174;0
WireConnection;154;0;152;0
WireConnection;154;1;163;0
WireConnection;154;2;164;0
WireConnection;158;0;159;0
WireConnection;202;0;199;0
WireConnection;202;1;220;0
WireConnection;202;2;220;0
WireConnection;185;0;183;0
WireConnection;186;1;191;0
WireConnection;186;2;192;0
WireConnection;186;3;193;0
WireConnection;222;0;202;0
WireConnection;222;1;224;1
WireConnection;222;2;224;2
WireConnection;144;1;142;0
WireConnection;177;0;176;0
WireConnection;177;1;178;0
WireConnection;177;2;179;0
WireConnection;157;0;154;0
WireConnection;157;1;158;0
WireConnection;168;0;157;0
WireConnection;168;1;169;0
WireConnection;181;0;177;0
WireConnection;184;0;185;0
WireConnection;184;1;186;0
WireConnection;184;2;217;0
WireConnection;145;0;144;0
WireConnection;223;0;222;0
WireConnection;170;0;168;0
WireConnection;125;0;130;0
WireConnection;194;0;184;0
WireConnection;204;0;223;0
WireConnection;211;0;209;0
WireConnection;211;1;208;0
WireConnection;171;0;170;0
WireConnection;195;0;194;0
WireConnection;128;0;134;0
WireConnection;210;0;206;0
WireConnection;210;1;207;0
WireConnection;210;2;211;0
WireConnection;212;0;210;0
WireConnection;212;1;213;0
WireConnection;212;2;214;0
WireConnection;137;0;135;2
WireConnection;0;2;216;0
WireConnection;0;13;212;0
ASEEND*/
//CHKSM=5C6349B93B620BBDF15476C0FA1F4ADE139B6A9E