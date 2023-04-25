// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole"
{
	Properties
	{
		[Header(Texture)]_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_MetallicSmoothness("Metallic Smoothness", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_Range("Range", Range( 0 , 10)) = 0
		_Effect("Effect", Range( 0 , 10)) = 0
		[HDR][Header(Specular)]_ColorSpecular("Color Specular", Color) = (0,0,0,0)
		_Specularsomething("Specular something", Float) = 0
		_IntensitySpecular("Intensity Specular", Range( 0 , 0.2)) = 0.1
		[HDR][Header(Fresnel)]_ColorFresnel("Color Fresnel", Color) = (0,0,0,0)
		_FresnelIntesity("Fresnel Intesity", Range( 0 , 1)) = 0.3
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		[Header(Gradient)]_TurningOFF("Turning OFF", Range( 0 , 1)) = 0
		_BlackHolePosition("Black Hole Position", Vector) = (0,0,0,0)
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
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float _TurningOFF;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _MetallicSmoothness;
		uniform float4 _MetallicSmoothness_ST;
		uniform float _Smoothness;
		uniform float _Shadow;
		uniform float4 _ColorFresnel;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FresnelIntesity;
		uniform float _Specularsomething;
		uniform float _IntensitySpecular;
		uniform float4 _ColorSpecular;

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
			v.vertex.xyz += BlackHole394;
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
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 WorldNormal356 = (WorldNormalVector( i , UnpackNormal( tex2D( _Normal, uv_Normal ) ) ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult440 = dot( WorldNormal356 , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 HalfLambert445 = saturate( ( (dotResult440*0.5 + 0.5) * ase_lightColor.rgb * ase_lightColor.a ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_MetallicSmoothness = i.uv_texcoord * _MetallicSmoothness_ST.xy + _MetallicSmoothness_ST.zw;
			float4 Metallic_Smoothness357 = tex2D( _MetallicSmoothness, uv_MetallicSmoothness );
			float4 temp_cast_3 = (_Smoothness).xxxx;
			float dotResult367 = dot( Metallic_Smoothness357 , temp_cast_3 );
			Unity_GlossyEnvironmentData g369 = UnityGlossyEnvironmentSetup( dotResult367, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular369 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g369 );
			float3 Sature_Color370 = indirectSpecular369;
			float smoothstepResult376 = smoothstep( 0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow379 = smoothstepResult376;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV421 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode421 = ( -0.13 + _FresnelScale * pow( 1.0 - fresnelNdotV421, _FresnelPower ) );
			float4 Fresnel426 = saturate( ( _ColorFresnel * fresnelNode421 * _FresnelIntesity ) );
			float dotResult399 = dot( ( ase_worldViewDir + ase_worldlightDir ) , WorldNormal356 );
			float smoothstepResult403 = smoothstep( 1.69 , 2.7 , pow( dotResult399 , _Specularsomething ));
			float3 LightColor_Color363 = ase_lightColor.rgb;
			float4 Specular416 = ( ( smoothstepResult403 * _IntensitySpecular ) * saturate( ( _ColorSpecular * float4( LightColor_Color363 , 0.0 ) ) ) );
			c.rgb = ( Gradient432 * ( ( Albedo355 * float4( HalfLambert445 , 0.0 ) * float4( ( Sature_Color370 + Shadow379 ) , 0.0 ) ) + Fresnel426 + Specular416 ) ).rgb;
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
0;73;864;655;2487.952;3042.031;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;365;-2671.457,-3843.924;Inherit;False;1284.767;696.8401;;12;352;350;353;351;359;355;357;356;358;360;363;364;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;351;-2099.859,-3793.785;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;359;-1801.69,-3790.924;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;417;-344.586,-3830.873;Inherit;False;1901.797;623;;18;404;405;403;406;408;409;410;396;400;399;397;401;412;414;413;416;407;508;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;380;-1353.211,-3527.701;Inherit;False;954.9435;342;;8;373;374;375;372;376;378;377;379;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;-183.6244,-2798.845;Inherit;False;834;316;;7;442;440;441;439;443;474;470;Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;396;-261.7083,-3778.15;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-1610.69,-3793.924;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;352;-2594.182,-3562.424;Inherit;True;Property;_MetallicSmoothness;Metallic Smoothness;2;0;Create;True;0;0;0;False;0;False;-1;None;1517a836104074d41b8d6a0f2202c945;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;508;-287.1652,-3607.508;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;371;-1364.557,-3844.317;Inherit;False;898.2434;267.1379;;5;367;369;370;366;368;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;-2304.431,-3561.513;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;-53.91708,-3775.732;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-1303.211,-3382.204;Inherit;False;Property;_Shadow;Shadow;5;0;Create;True;0;0;0;False;0;False;0;0.578;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-132.6244,-2748.845;Inherit;False;356;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;372;-1213.611,-3472.504;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;564;-3005.53,-3096.815;Inherit;False;1649.081;545.574;;13;516;515;388;517;389;521;519;520;558;557;523;562;394;BlackHole;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;360;-2080.03,-3358.895;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;400;-55.51595,-3673.86;Inherit;False;356;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;441;-133.6244,-2665.845;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;443;70.3755,-2605.845;Inherit;False;Constant;_HalfLambert;HalfLambert;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;-1279.364,-3792.105;Inherit;False;357;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-1314.557,-3693.179;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;374;-1028.012,-3474.404;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;36.21091,-3589.873;Inherit;False;Property;_Specularsomething;Specular something;9;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;440;88.37548,-2744.845;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1905.512,-3340.63;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;515;-2922.906,-3046.815;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;516;-2925.086,-2905.517;Inherit;False;Property;_BlackHolePosition;Black Hole Position;16;0;Create;True;0;0;0;False;0;False;0,0,0;-5.406998,7.839999,17.572;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;399;150.9835,-3775.539;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;427;-1316.803,-3118.129;Inherit;False;1104.624;546.2673;;9;421;423;419;420;424;425;422;426;461;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1010.269,-3376.701;Inherit;False;Constant;_Minshadow;Min shadow;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;442;231.3755,-2745.845;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;-1266.803,-2754.247;Inherit;False;Property;_FresnelPower;Fresnel Power;14;0;Create;True;0;0;0;False;0;False;0;4.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;404;294.7661,-3681.14;Inherit;False;Constant;_Min;Min;9;0;Create;True;0;0;0;False;0;False;1.69;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;470;275.4141,-2629.26;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;401;295.5475,-3776.109;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;367;-1042.557,-3790.179;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;422;-1260.803,-2908.997;Inherit;False;Constant;_FresnelBias;Fresnel Bias;13;0;Create;True;0;0;0;False;0;False;-0.13;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;407;134.2109,-3492.873;Inherit;False;Property;_ColorSpecular;Color Specular;8;2;[HDR];[Header];Create;True;1;Specular;0;0;False;0;False;0,0,0,0;0.6666667,0.8117648,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;378;-1013.269,-3301.701;Inherit;False;Constant;_Maxshadow;Max shadow;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;144.2109,-3323.873;Inherit;False;363;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;405;298.541,-3605.072;Inherit;False;Constant;_Max;Max;9;0;Create;True;0;0;0;False;0;False;2.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;423;-1264.972,-2831.33;Inherit;False;Property;_FresnelScale;Fresnel Scale;13;0;Create;True;0;0;0;False;0;False;0;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;375;-910.2689,-3474.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2953.129,-2748.199;Inherit;False;Property;_Range;Range;6;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;517;-2658.405,-2953.571;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-2955.53,-2671.8;Inherit;False;Property;_Effect;Effect;7;0;Create;True;0;0;0;False;0;False;0;3.9;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-1072.221,-2687.862;Inherit;False;Property;_FresnelIntesity;Fresnel Intesity;12;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;421;-1079.831,-2894.61;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;376;-776.7776,-3477.872;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;511.0256,-2748.346;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;369;-919.5418,-3791.177;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;414;488.719,-3639.414;Inherit;False;Property;_IntensitySpecular;Intensity Specular;10;0;Create;True;0;0;0;False;0;False;0.1;0.172;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;461;-1075.326,-3073.856;Inherit;False;Property;_ColorFresnel;Color Fresnel;11;2;[HDR];[Header];Create;True;1;Fresnel;0;0;False;0;False;0,0,0,0;0.4392157,0.7960785,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;368.2109,-3487.873;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;521;-2509.552,-2710.241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;519;-2421.502,-2855.362;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;403;484.1436,-3775.836;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;520;-2279.427,-2738.814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;433;-185.0577,-3133.511;Inherit;False;876.2718;277.7463;;3;430;432;462;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;410;514.2111,-3487.873;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;487;679.4617,-2753.446;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-804.5872,-3062.504;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;350;-2621.457,-3785.093;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;9e47c0b660db86d458e76c64a3720616;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;743.4684,-3777.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;370;-673.3133,-3798.317;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;-622.2687,-3477.701;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;863.4793,-2754.928;Inherit;False;HalfLambert;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-172.5974,-2030.139;Inherit;False;379;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;450;-175.5975,-2108.138;Inherit;False;370;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;1002.211,-3776.873;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-135.0577,-2998.083;Inherit;False;Property;_TurningOFF;Turning OFF;15;1;[Header];Create;True;1;Gradient;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-2348.102,-2977.707;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;425;-575.1487,-3063.399;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;557;-2108.115,-2802.892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-2310.431,-3782.513;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;1153.568,-3774.34;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;452;39.78596,-2105.428;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;-436.1783,-3068.129;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-38.42969,-2207.701;Inherit;False;445;HalfLambert;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCGrayscale;462;216.3151,-3025.466;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-35.00183,-2284.919;Inherit;False;355;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;523;-2000.855,-3002.213;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;166.7333,-2007.966;Inherit;False;416;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;219.9854,-2214.69;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;432;467.2141,-3083.511;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;353;-2087.104,-3565.173;Inherit;True;Property;_Emission;Emission;3;0;Create;True;0;0;0;False;0;False;-1;None;3d71c2897a5a39c4d90505b0a9b566d0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;457;171.7144,-1921.583;Inherit;False;426;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;562;-1810.604,-3004.563;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;488;407.2455,-2212.836;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;459;398.3194,-2288.752;Inherit;False;432;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-1580.449,-3001.445;Inherit;False;BlackHole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-1801.251,-3565.513;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;588.3085,-2126.598;Inherit;False;394;BlackHole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;458;593.2739,-2232.676;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;593.3907,-2415.447;Inherit;False;358;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-1905.159,-3263.084;Inherit;False;LightColor_Intesity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;759.962,-2456.236;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BlackHole;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;359;0;351;0
WireConnection;356;0;359;0
WireConnection;357;0;352;0
WireConnection;397;0;396;0
WireConnection;397;1;508;0
WireConnection;374;0;372;0
WireConnection;374;1;373;0
WireConnection;440;0;439;0
WireConnection;440;1;441;0
WireConnection;363;0;360;1
WireConnection;399;0;397;0
WireConnection;399;1;400;0
WireConnection;442;0;440;0
WireConnection;442;1;443;0
WireConnection;442;2;443;0
WireConnection;401;0;399;0
WireConnection;401;1;412;0
WireConnection;367;0;366;0
WireConnection;367;1;368;0
WireConnection;375;0;374;0
WireConnection;517;0;516;0
WireConnection;517;1;515;0
WireConnection;421;1;422;0
WireConnection;421;2;423;0
WireConnection;421;3;424;0
WireConnection;376;0;375;0
WireConnection;376;1;377;0
WireConnection;376;2;378;0
WireConnection;474;0;442;0
WireConnection;474;1;470;1
WireConnection;474;2;470;2
WireConnection;369;1;367;0
WireConnection;408;0;407;0
WireConnection;408;1;409;0
WireConnection;521;1;388;0
WireConnection;521;2;389;0
WireConnection;519;0;517;0
WireConnection;403;0;401;0
WireConnection;403;1;404;0
WireConnection;403;2;405;0
WireConnection;520;0;521;0
WireConnection;520;1;519;0
WireConnection;410;0;408;0
WireConnection;487;0;474;0
WireConnection;420;0;461;0
WireConnection;420;1;421;0
WireConnection;420;2;419;0
WireConnection;406;0;403;0
WireConnection;406;1;414;0
WireConnection;370;0;369;0
WireConnection;379;0;376;0
WireConnection;445;0;487;0
WireConnection;413;0;406;0
WireConnection;413;1;410;0
WireConnection;558;1;517;0
WireConnection;425;0;420;0
WireConnection;557;0;520;0
WireConnection;355;0;350;0
WireConnection;416;0;413;0
WireConnection;452;0;450;0
WireConnection;452;1;451;0
WireConnection;426;0;425;0
WireConnection;462;0;430;0
WireConnection;523;1;558;0
WireConnection;523;2;557;0
WireConnection;454;0;448;0
WireConnection;454;1;449;0
WireConnection;454;2;452;0
WireConnection;432;0;462;0
WireConnection;562;0;523;0
WireConnection;488;0;454;0
WireConnection;488;1;457;0
WireConnection;488;2;503;0
WireConnection;394;0;562;0
WireConnection;358;0;353;0
WireConnection;458;0;459;0
WireConnection;458;1;488;0
WireConnection;364;0;360;2
WireConnection;0;2;447;0
WireConnection;0;13;458;0
WireConnection;0;11;460;0
ASEEND*/
//CHKSM=B27B150DF6085D514E59F6AB263F5A303C739792