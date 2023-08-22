// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole"
{
	Properties
	{
		[Header(Texture)]_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_MetallicSmoothness("Metallic Smoothness", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_Range("Range", Range( 0 , 10)) = 0
		_Effect("Effect", Range( 0 , 10)) = 0
		[HDR][Header(Specular)]_ColorSpecular("Color Specular", Color) = (0,0,0,0)
		_Specularsomething("Specular something", Float) = 0
		_IntensitySpecular("Intensity Specular", Range( 0 , 2)) = 0.1
		[HDR][Header(Fresnel)]_ColorFresnel("Color Fresnel", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_FresnelIntesity("Fresnel Intesity", Range( 0 , 1)) = 0.3
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		[Header(Gradient)]_TurningOFF("Turning OFF", Range( 0 , 1)) = 0
		_HalfLambert("HalfLambert", Float) = 0.5
		_BlackHolePosition("Black Hole Position", Vector) = (0,0,0,0)
		_Speed("Speed", Float) = 0.1
		_ValueWarning("Value Warning", Range( 0 , 1)) = 1
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
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float3 _BlackHolePosition;
		uniform float _Range;
		uniform float _Effect;
		uniform float _Speed;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float _TurningOFF;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _HalfLambert;
		uniform sampler2D _MetallicSmoothness;
		uniform float4 _MetallicSmoothness_ST;
		uniform float _Smoothness;
		uniform float _Shadow;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _Specularsomething;
		uniform float _IntensitySpecular;
		uniform float4 _ColorSpecular;
		uniform float4 _ColorFresnel;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FresnelIntesity;
		uniform float _ValueWarning;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_output_517_0 = ( _BlackHolePosition - ase_worldPos );
			float lerpResult521 = lerp( 0.0 , _Range , _Effect);
			float clampResult557 = clamp( ( lerpResult521 - length( temp_output_517_0 ) ) , 0.0 , 1.0 );
			float3 lerpResult523 = lerp( float3( 0,0,0 ) , ( float3( 0,0,0 ) + temp_output_517_0 ) , clampResult557);
			float3 worldToObjDir562 = mul( unity_WorldToObject, float4( lerpResult523, 0 ) ).xyz;
			float3 BlackHole394 = worldToObjDir562;
			float3 ase_vertexNormal = v.normal.xyz;
			float mulTime604 = _Time.y * _Speed;
			float3 OffsetWarning643 = ( ( ase_vertexNormal * sin( ( ( v.texcoord.xy.y + mulTime604 ) * 0.0 ) ) ) * float3(1,0,0) * 1.0 );
			v.vertex.xyz += ( BlackHole394 + OffsetWarning643 );
			v.vertex.w = 1;
		}

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
			float3 temp_cast_1 = (_TurningOFF).xxx;
			float grayscale462 = Luminance(temp_cast_1);
			float Gradient432 = grayscale462;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo355 = tex2D( _Albedo, uv_Albedo );
			float4 color660 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 WorldNormalBueno573 = (WorldNormalVector( i , tex2D( _Normal, uv_Normal ).rgb ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult440 = dot( WorldNormalBueno573 , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 HalfLambert445 = saturate( ( saturate( ( color660 * (dotResult440*_HalfLambert + _HalfLambert) ) ) * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_MetallicSmoothness = i.uv_texcoord * _MetallicSmoothness_ST.xy + _MetallicSmoothness_ST.zw;
			float4 Metallic_Smoothness357 = tex2D( _MetallicSmoothness, uv_MetallicSmoothness );
			float4 temp_cast_4 = (_Smoothness).xxxx;
			float dotResult367 = dot( Metallic_Smoothness357 , temp_cast_4 );
			Unity_GlossyEnvironmentData g369 = UnityGlossyEnvironmentSetup( dotResult367, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular369 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g369 );
			float3 Sature_Color370 = indirectSpecular369;
			float smoothstepResult376 = smoothstep( 0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow379 = smoothstepResult376;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float3 WorldNormal356 = (WorldNormalVector( i , UnpackNormal( tex2D( _TextureSample0, uv_TextureSample0 ) ) ));
			float dotResult399 = dot( ( ase_worldViewDir + ase_worldlightDir ) , WorldNormal356 );
			float smoothstepResult403 = smoothstep( 1.69 , 2.7 , pow( dotResult399 , _Specularsomething ));
			float3 LightColor_Color363 = ase_lightColor.rgb;
			float4 Specular416 = ( ( smoothstepResult403 * _IntensitySpecular ) * saturate( ( _ColorSpecular * float4( LightColor_Color363 , 0.0 ) ) ) );
			float fresnelNdotV421 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode421 = ( -0.13 + _FresnelScale * pow( 1.0 - fresnelNdotV421, _FresnelPower ) );
			float4 Fresnel426 = saturate( ( _ColorFresnel * fresnelNode421 * _FresnelIntesity ) );
			float fresnelNdotV592 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode592 = ( 0.0 + 1.51 * pow( 1.0 - fresnelNdotV592, 1.86 ) );
			float4 color591 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float4 FresnelWarning638 = ( saturate( ( fresnelNode592 * color591 ) ) * _ValueWarning );
			c.rgb = saturate( ( Gradient432 * ( ( Albedo355 * HalfLambert445 * float4( ( Sature_Color370 + Shadow379 ) , 0.0 ) ) + Specular416 + Fresnel426 + FresnelWarning638 ) ) ).rgb;
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
			float4 Emission358 = tex2D( _Emission, uv_Emission );
			o.Emission = Emission358.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
0;73;850;540;-408.1884;5158.639;1.422685;True;False
Node;AmplifyShaderEditor.SamplerNode;351;-2160.859,-4052.185;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;dccd8827f6d3a9c4da1e0815ee27955c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;572;-1814.503,-4050.212;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;365;-2671.457,-3843.924;Inherit;False;1284.767;696.8401;;12;352;353;359;355;357;356;358;360;363;364;350;574;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;-183.6244,-2798.845;Inherit;False;834;316;;7;442;440;441;439;443;474;470;Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;573;-1623.503,-4053.212;Inherit;False;WorldNormalBueno;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;574;-2107.146,-3789.789;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;441;-133.6244,-2665.845;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;417;-344.586,-3830.873;Inherit;False;1901.797;623;;18;404;405;403;406;408;409;410;400;399;397;401;412;414;413;416;407;508;569;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;359;-1801.69,-3790.924;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;439;-132.6244,-2748.845;Inherit;False;573;WorldNormalBueno;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;352;-2634.131,-3567.218;Inherit;True;Property;_MetallicSmoothness;Metallic Smoothness;2;0;Create;True;0;0;0;False;0;False;-1;None;dffa230107907114ba04297a3b9bb249;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;569;-301.4585,-3784.279;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;380;-1353.211,-3527.701;Inherit;False;954.9435;342;;8;373;374;375;372;376;378;377;379;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;440;88.37548,-2744.845;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-1610.69,-3793.924;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;508;-312.6913,-3586.804;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;443;70.3755,-2603.845;Inherit;False;Property;_HalfLambert;HalfLambert;17;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;564;-3005.53,-3096.815;Inherit;False;1649.081;545.574;;13;516;515;388;517;389;521;519;520;558;557;523;562;394;BlackHole;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;-2304.431,-3561.513;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;-53.91708,-3775.732;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;442;231.3755,-2745.845;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;-55.51595,-3673.86;Inherit;False;356;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-1303.211,-3382.204;Inherit;False;Property;_Shadow;Shadow;5;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;650;-3013.396,-2418.868;Inherit;False;2061.161;932.0416;;22;602;590;605;604;600;595;591;636;603;592;593;601;594;629;599;648;632;626;649;638;647;643;Heavy attack JP;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;372;-1213.611,-3472.504;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;433;-185.0577,-3133.511;Inherit;False;876.2718;277.7463;;4;430;432;462;659;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;660;168.5019,-2960.475;Inherit;False;Constant;_Color0;Color 0;21;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;371;-1364.557,-3844.317;Inherit;False;898.2434;267.1379;;5;367;369;370;366;368;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;360;-2080.03,-3358.895;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;368;-1314.557,-3693.179;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;602;-2797.006,-1723.464;Inherit;False;Property;_Speed;Speed;19;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;515;-2922.906,-3046.815;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;516;-2925.086,-2905.517;Inherit;False;Property;_BlackHolePosition;Black Hole Position;18;0;Create;True;0;0;0;False;0;False;0,0,0;-13.213,7.94,17.419;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;595;-2962.994,-2305.189;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;1.51;1.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;36.21091,-3589.873;Inherit;False;Property;_Specularsomething;Specular something;9;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;590;-2963.396,-2222.444;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;1.86;1.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;427;-1316.803,-3118.129;Inherit;False;1104.624;546.2673;;9;421;423;419;420;424;425;422;426;461;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;-1279.364,-3792.105;Inherit;False;357;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;399;150.9835,-3775.539;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1905.512,-3340.63;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;659;396.6606,-2944.295;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;374;-1028.012,-3474.404;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;600;-2671.981,-1883.625;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;409;144.2109,-3323.873;Inherit;False;363;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;604;-2615.411,-1724.741;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2953.129,-2748.199;Inherit;False;Property;_Range;Range;6;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;407;134.2109,-3492.873;Inherit;False;Property;_ColorSpecular;Color Specular;8;2;[HDR];[Header];Create;True;1;Specular;0;0;False;0;False;0,0,0,0;0.514151,0.764985,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;517;-2658.405,-2953.571;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;592;-2768.517,-2362.918;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;401;295.5475,-3776.109;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;470;275.4141,-2629.26;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;389;-2955.53,-2671.8;Inherit;False;Property;_Effect;Effect;7;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1010.269,-3376.701;Inherit;False;Constant;_Minshadow;Min shadow;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;405;298.541,-3605.072;Inherit;False;Constant;_Max;Max;9;0;Create;True;0;0;0;False;0;False;2.7;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;375;-910.2689,-3474.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;591;-2683.409,-2097.531;Inherit;False;Constant;_ColorWaring;Color Waring;2;0;Create;True;0;0;0;False;0;False;1,0,0.008883953,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;422;-1260.803,-2908.997;Inherit;False;Constant;_FresnelBias;Fresnel Bias;13;0;Create;True;0;0;0;False;0;False;-0.13;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;-1266.803,-2754.247;Inherit;False;Property;_FresnelPower;Fresnel Power;15;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;367;-1042.557,-3790.179;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;404;294.7661,-3681.14;Inherit;False;Constant;_Min;Min;11;0;Create;True;0;0;0;False;0;False;1.69;1.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;378;-1013.269,-3301.701;Inherit;False;Constant;_Maxshadow;Max shadow;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;661;585.6354,-2861.792;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;423;-1264.972,-2831.33;Inherit;False;Property;_FresnelScale;Fresnel Scale;14;0;Create;True;0;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;547.0256,-2739.346;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;421;-1079.831,-2894.61;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;603;-2419.605,-1879.618;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;519;-2421.502,-2855.362;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;521;-2509.552,-2710.241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;368.2109,-3487.873;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;414;488.719,-3639.414;Inherit;False;Property;_IntensitySpecular;Intensity Specular;10;0;Create;True;0;0;0;False;0;False;0.1;0.07;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-1072.221,-2687.862;Inherit;False;Property;_FresnelIntesity;Fresnel Intesity;13;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;376;-776.7776,-3477.872;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;593;-2438.434,-2362.336;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectSpecularLight;369;-919.5418,-3791.177;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;403;484.1436,-3775.836;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;461;-1075.326,-3073.856;Inherit;False;Property;_ColorFresnel;Color Fresnel;11;2;[HDR];[Header];Create;True;1;Fresnel;0;0;False;0;False;0,0,0,0;0.4392157,0.7960785,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;594;-2200.154,-2362.725;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;520;-2279.427,-2738.814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-804.5872,-3062.504;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;350;-2628.706,-3781.95;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;512497a17b5909a40977fa931400431b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;605;-2691.909,-1624.901;Inherit;False;Property;_ValueWarning;Value Warning;20;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;-622.2687,-3477.701;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;370;-673.3133,-3798.317;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;410;514.2111,-3487.873;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;743.4684,-3777.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;487;685.4617,-2751.446;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;601;-2146.701,-1876.302;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;863.4793,-2754.928;Inherit;False;HalfLambert;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;599;-1922.655,-1878.148;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-135.0577,-2998.083;Inherit;False;Property;_TurningOFF;Turning OFF;16;1;[Header];Create;True;1;Gradient;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-2348.102,-2977.707;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;557;-2108.115,-2802.892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;425;-575.1487,-3063.399;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;629;-1925.22,-2072.175;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;450;-233.7009,-2087.802;Inherit;False;370;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;1002.211,-3776.873;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-2310.431,-3782.513;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;632;-1970.847,-2363.035;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-230.7008,-2009.803;Inherit;False;379;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;-436.1783,-3068.129;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;452;-18.3176,-2085.091;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;1175.558,-3769.942;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;648;-1636.098,-1782.786;Inherit;False;Constant;_Warningposition;Warning position;21;0;Create;True;0;0;0;False;0;False;1,0,0;2,1,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;448;-93.10538,-2264.583;Inherit;False;355;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-1615.665,-1623.398;Inherit;False;Constant;_WarningMultiply;Warning Multiply;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;626;-1646.409,-1995.075;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;638;-1693.455,-2368.868;Inherit;False;FresnelWarning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;462;216.3151,-3025.466;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;523;-2000.855,-3002.213;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-96.5332,-2187.365;Inherit;False;445;HalfLambert;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;639;114.6494,-1815.271;Inherit;False;638;FresnelWarning;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;108.6298,-1987.629;Inherit;False;416;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;562;-1810.604,-3004.563;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;161.8818,-2194.354;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;113.6109,-1901.247;Inherit;False;426;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;432;467.2141,-3083.511;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;647;-1359.724,-1994.612;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;459;392.4435,-2263.668;Inherit;False;432;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;488;399.0591,-2113.775;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-1580.449,-3001.445;Inherit;False;BlackHole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-1176.235,-1999.701;Inherit;False;OffsetWarning;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;353;-2087.104,-3565.173;Inherit;True;Property;_Emission;Emission;3;0;Create;True;0;0;0;False;0;False;-1;None;7d065b4dec0f7d3479aa86926de29fa2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-1801.251,-3565.513;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;480.5188,-1833.262;Inherit;False;643;OffsetWarning;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;664;556.0288,-2208.015;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;495.5325,-1924.335;Inherit;False;394;BlackHole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;1091.983,-4880.99;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;640;718.7234,-1914.02;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;593.3907,-2415.447;Inherit;False;358;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-1905.159,-3263.084;Inherit;False;LightColor_Intesity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;-2306.339,-1621.826;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;663;696.0935,-2197.331;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;665;1332.576,-4844.641;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;668;860.181,-5048.969;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;669;962.3453,-4806.467;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;25.19;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;869.3417,-2459.684;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;BlackHole;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;572;0;351;0
WireConnection;573;0;572;0
WireConnection;359;0;574;0
WireConnection;440;0;439;0
WireConnection;440;1;441;0
WireConnection;356;0;359;0
WireConnection;357;0;352;0
WireConnection;397;0;569;0
WireConnection;397;1;508;0
WireConnection;442;0;440;0
WireConnection;442;1;443;0
WireConnection;442;2;443;0
WireConnection;399;0;397;0
WireConnection;399;1;400;0
WireConnection;363;0;360;1
WireConnection;659;0;660;0
WireConnection;659;1;442;0
WireConnection;374;0;372;0
WireConnection;374;1;373;0
WireConnection;604;0;602;0
WireConnection;517;0;516;0
WireConnection;517;1;515;0
WireConnection;592;2;595;0
WireConnection;592;3;590;0
WireConnection;401;0;399;0
WireConnection;401;1;412;0
WireConnection;375;0;374;0
WireConnection;367;0;366;0
WireConnection;367;1;368;0
WireConnection;661;0;659;0
WireConnection;474;0;661;0
WireConnection;474;1;470;1
WireConnection;474;2;470;2
WireConnection;421;1;422;0
WireConnection;421;2;423;0
WireConnection;421;3;424;0
WireConnection;603;0;600;2
WireConnection;603;1;604;0
WireConnection;519;0;517;0
WireConnection;521;1;388;0
WireConnection;521;2;389;0
WireConnection;408;0;407;0
WireConnection;408;1;409;0
WireConnection;376;0;375;0
WireConnection;376;1;377;0
WireConnection;376;2;378;0
WireConnection;593;0;592;0
WireConnection;593;1;591;0
WireConnection;369;1;367;0
WireConnection;403;0;401;0
WireConnection;403;1;404;0
WireConnection;403;2;405;0
WireConnection;594;0;593;0
WireConnection;520;0;521;0
WireConnection;520;1;519;0
WireConnection;420;0;461;0
WireConnection;420;1;421;0
WireConnection;420;2;419;0
WireConnection;379;0;376;0
WireConnection;370;0;369;0
WireConnection;410;0;408;0
WireConnection;406;0;403;0
WireConnection;406;1;414;0
WireConnection;487;0;474;0
WireConnection;601;0;603;0
WireConnection;445;0;487;0
WireConnection;599;0;601;0
WireConnection;558;1;517;0
WireConnection;557;0;520;0
WireConnection;425;0;420;0
WireConnection;413;0;406;0
WireConnection;413;1;410;0
WireConnection;355;0;350;0
WireConnection;632;0;594;0
WireConnection;632;1;605;0
WireConnection;426;0;425;0
WireConnection;452;0;450;0
WireConnection;452;1;451;0
WireConnection;416;0;413;0
WireConnection;626;0;629;0
WireConnection;626;1;599;0
WireConnection;638;0;632;0
WireConnection;462;0;430;0
WireConnection;523;1;558;0
WireConnection;523;2;557;0
WireConnection;562;0;523;0
WireConnection;454;0;448;0
WireConnection;454;1;449;0
WireConnection;454;2;452;0
WireConnection;432;0;462;0
WireConnection;647;0;626;0
WireConnection;647;1;648;0
WireConnection;647;2;649;0
WireConnection;488;0;454;0
WireConnection;488;1;503;0
WireConnection;488;2;457;0
WireConnection;488;3;639;0
WireConnection;394;0;562;0
WireConnection;643;0;647;0
WireConnection;358;0;353;0
WireConnection;664;0;459;0
WireConnection;664;1;488;0
WireConnection;666;0;668;1
WireConnection;666;1;669;0
WireConnection;640;0;460;0
WireConnection;640;1;644;0
WireConnection;364;0;360;2
WireConnection;636;0;605;0
WireConnection;663;0;664;0
WireConnection;665;0;666;0
WireConnection;0;2;447;0
WireConnection;0;13;663;0
WireConnection;0;11;640;0
ASEEND*/
//CHKSM=C3D5B17DA5D2BE29155145BF3F049FCDD222DCFB