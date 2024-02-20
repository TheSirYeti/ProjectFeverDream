// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Assistant_HEAD_MAT"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Albedo("Albedo", 2D) = "white" {}
		_Maskface("Mask face", 2D) = "white" {}
		_NomalMap("Nomal Map", 2D) = "bump" {}
		_ControlFace("Control Face", Range( 0 , 5)) = 0
		_SpeedTalking("SpeedTalking", Range( 0 , 0.5)) = 0
		_TypeMouth("Type Mouth", Range( 1 , 3)) = 2
		[Header(Rim Value)]_RimPower("Rim Power", Range( 0 , 1)) = 0.4810303
		_RimOffset("Rim Offset", Float) = 1
		[HDR]_RimColor("Rim Color", Color) = (1,0.8242262,0.5896226,0)
		_RimIntensity("Rim Intensity", Range( 0 , 1)) = 1
		[Header(Specular)]_SpecularPower("Specular Power", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SpecularIntesity("Specular Intesity", Range( 0 , 1)) = 0
		[Header(Lighting)]_LightValue("Light Value", Float) = 0
		_ShadowValue("Shadow Value", Float) = 0
		_Color0("Color0", Color) = (0,0,0,0)
		_Emission("Emission", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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

		uniform sampler2D _Maskface;
		uniform float _ControlFace;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _SpeedTalking;
		uniform float _TypeMouth;
		uniform float _Emission;
		uniform sampler2D _NomalMap;
		uniform float4 _NomalMap_ST;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform float _LightValue;
		uniform float _ShadowValue;
		uniform float _Min;
		uniform float _Max;
		uniform float _SpecularPower;
		uniform float4 _Color0;
		uniform float _SpecularIntesity;
		uniform float _Cutoff = 0.5;

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
			float2 MovementMouth272 = (panner260*1.0 + ( float2( 0,1 ) * ( ( 1.0 - _TypeMouth ) * 0.15 ) ));
			float4 N_ChangeFace373 = ( ( Albedo214 * ( 1.0 - MaskMouth230 ) ) + ( MaskMouth230 * tex2D( _Albedo, MovementMouth272 ).r ) );
			float4 MaskMouthOpacity386 = saturate( ( N_ChangeFace373 + ceil( ( V_TexCor227 + -0.441 ) ) ) );
			float2 uv_NomalMap = i.uv_texcoord * _NomalMap_ST.xy + _NomalMap_ST.zw;
			float3 M_Normal299 = UnpackNormal( tex2D( _NomalMap, uv_NomalMap ) );
			float3 N_WorldNormal300 = (WorldNormalVector( i , M_Normal299 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult303 = dot( N_WorldNormal300 , ase_worldViewDir );
			float N_ViewDir304 = dotResult303;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult315 = dot( N_WorldNormal300 , ase_worldlightDir );
			float N_LightDir325 = dotResult315;
			float4 N_Rim364 = ( ( pow( ( 1.0 - saturate( ( N_ViewDir304 * _RimOffset ) ) ) , _RimPower ) * saturate( ( ase_lightColor * _RimColor ) ) * ( N_LightDir325 * ase_lightAtten ) ) * _RimIntensity );
			UnityGI gi338 = gi;
			float3 diffNorm338 = WorldNormalVector( i , M_Normal299 );
			gi338 = UnityGI_Base( data, 1, diffNorm338 );
			float3 indirectDiffuse338 = gi338.indirect.diffuse + diffNorm338 * 0.0001;
			float3 N_Light295 = ( (N_LightDir325*_LightValue + _ShadowValue) * ( indirectDiffuse338 + ase_lightAtten ) * ase_lightColor.rgb );
			float dotResult318 = dot( ( ase_worldViewDir + ase_worldlightDir ) , N_WorldNormal300 );
			float smoothstepResult334 = smoothstep( _Min , _Max , pow( dotResult318 , _SpecularPower ));
			float4 N_Specular366 = ( ase_lightAtten * ( ( smoothstepResult334 * ( _Color0 * float4( ase_lightColor.rgb , 0.0 ) ) ) * _SpecularIntesity ) );
			c.rgb = saturate( ( N_Rim364 + ( float4( N_Light295 , 0.0 ) * N_ChangeFace373 ) + N_Specular366 ) ).rgb;
			c.a = 1;
			clip( MaskMouthOpacity386.r - _Cutoff );
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
			float2 MovementMouth272 = (panner260*1.0 + ( float2( 0,1 ) * ( ( 1.0 - _TypeMouth ) * 0.15 ) ));
			float4 N_ChangeFace373 = ( ( Albedo214 * ( 1.0 - MaskMouth230 ) ) + ( MaskMouth230 * tex2D( _Albedo, MovementMouth272 ).r ) );
			o.Emission = ( N_ChangeFace373 * _Emission ).rgb;
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
0;73;1396;806;842.6158;1287.155;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;250;-3713.332,-1764.528;Inherit;False;1171.961;567.0284;;11;236;233;245;239;244;234;237;247;240;248;249;Ajusted FACE;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;291;-3705.899,29.59871;Inherit;False;1043.589;737.5994;Comment;10;361;354;348;342;327;320;314;313;299;298;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;245;-3663.332,-1501.954;Inherit;False;Constant;_MoveFace;Move Face;5;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;298;-3625.963,537.1978;Inherit;True;Property;_NomalMap;Nomal Map;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;-3337.371,540.7177;Inherit;False;M_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;251;-2490.67,-1777.307;Inherit;False;1421.727;469.3486;;6;215;208;212;252;214;235;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;244;-3519.628,-1426.855;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-3612.64,-1307.04;Inherit;False;Property;_ControlFace;Control Face;5;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;247;-3398.815,-1425.965;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;252;-1622.221,-1700.78;Inherit;False;504.984;242;;3;224;226;227;Variable general;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-4352.114,47.15267;Inherit;False;299;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;274;-3726.167,-737.5303;Inherit;False;1222.934;564.3849;;13;276;272;265;260;266;275;261;262;269;264;270;271;263;Movemente  Mouth;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;224;-1572.221,-1640.28;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;239;-3340.277,-1714.528;Inherit;False;Constant;_Tilling;Tilling;5;0;Create;True;0;0;0;False;0;False;0,0.85;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;240;-3344.178,-1581.829;Inherit;False;Constant;_Pointoffset;Point offset;6;0;Create;True;0;0;0;False;0;False;0.1666,0.15;0.1666,0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;249;-3247.195,-1422.196;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;294;-4163.95,51.85189;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;271;-3657.861,-341.8598;Inherit;False;Property;_TypeMouth;Type Mouth;8;0;Create;True;0;0;0;False;0;False;2;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-3133.401,-1517.452;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;253;-3712.839,-1128.259;Inherit;False;937.9152;310.1218;;6;230;229;221;228;222;223;Mask mouth;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-3126.401,-1663.452;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-1341.237,-1574.78;Inherit;False;V_TexCor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;289;-3657.208,1420.22;Inherit;False;372.5707;268.5439;;3;303;302;301;Normal Light View;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-3973.605,50.52181;Inherit;False;N_WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-3662.839,-1067.151;Inherit;False;227;V_TexCor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-3636.059,1465.123;Inherit;False;300;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;302;-3632.692,1544.934;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;276;-3343.839,-258.7249;Inherit;False;Constant;_Fix;Fix;8;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;263;-3609.499,-617.2214;Inherit;False;Constant;_MoveX;Move X;6;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;233;-2987.157,-1640.064;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;270;-3367.861,-338.8598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;226;-1346.237,-1650.78;Inherit;False;UV_TexCor;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-3676.167,-455.0542;Inherit;False;Property;_SpeedTalking;SpeedTalking;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;303;-3400.958,1468.599;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-3199.839,-343.7249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;221;-3489.265,-1065.352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;280;-2742.166,1824.587;Inherit;False;1820.667;858.0425;;19;366;360;356;355;351;345;334;333;330;328;324;323;321;318;317;309;307;306;305;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-3397.418,-601.8278;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-3440.599,-687.5303;Inherit;False;226;UV_TexCor;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;269;-3342.115,-482.4373;Inherit;False;Constant;_MoveTypeMouth;Move Type Mouth;7;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;234;-2765.371,-1639.363;Inherit;False;AjustedFace;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-3512.48,-979.0725;Inherit;False;Constant;_Maskmouth;Mask mouth;5;0;Create;True;0;0;0;False;0;False;-0.57;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3337.507,-1072.137;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-3098.059,-477.5185;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-3248.796,1467.19;Inherit;False;N_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;306;-2692.166,2037.929;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;305;-2633.034,1874.587;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;281;-2786.393,866.3777;Inherit;False;1857.228;811.5788;;18;364;362;359;357;353;350;347;344;341;340;337;336;326;322;319;316;310;308;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-2448.359,-1711.249;Inherit;False;234;AjustedFace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;292;-3683.388,988.8717;Inherit;False;423.5677;351.9097;;3;315;312;311;Normal Light Dir;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;260;-3240.178,-681.5247;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;307;-2489.856,2139.065;Inherit;False;300;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-2725.033,951.8927;Inherit;False;304;N_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;312;-3660.122,1130.816;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;311;-3651.328,1047.956;Inherit;False;300;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;310;-2716.982,1062.021;Inherit;False;Property;_RimOffset;Rim Offset;10;0;Create;True;0;0;0;False;0;False;1;3.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;208;-2264.356,-1515.505;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;e9a1b9957893e41448390f087c867701;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;265;-2944.853,-680.8796;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CeilOpNode;229;-3124.425,-1072.127;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;212;-2266.901,-1727.307;Inherit;True;Property;_Maskface;Mask face;3;0;Create;True;0;0;0;False;0;False;-1;None;e0fd1b7f985fc3c49b5df50029aa3510;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;309;-2411.558,2013.854;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;318;-2264.168,2014.938;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-2744.758,-684.8571;Inherit;False;MovementMouth;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;376;-2458.443,-1238.996;Inherit;False;1340.533;515.9002;;10;273;232;258;231;219;256;220;255;254;373;Change_face;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;290;-2574.285,89.22613;Inherit;False;1115.114;638.0347;;12;358;352;349;346;343;339;338;335;332;331;329;295;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-2998.924,-1078.258;Inherit;False;MaskMouth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;315;-3377.44,1048.825;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-1950.001,-1618.41;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;317;-2279.115,2175.055;Inherit;False;Property;_SpecularPower;Specular Power;13;1;[Header];Create;True;1;Specular;0;0;False;0;False;0;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;-2549.494,962.8057;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;-3242.669,1036.368;Inherit;False;N_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-2071.115,2218.055;Inherit;False;Property;_Max;Max;15;0;Create;True;0;0;0;False;0;False;0;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;322;-2336.133,1501.471;Inherit;False;Property;_RimColor;Rim Color;11;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8242262,0.5896226,0;0.1084906,0.4189268,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;323;-2085.928,2017.365;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;326;-2331.133,1373.47;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;330;-2316.876,2298.357;Inherit;False;Property;_Color0;Color0;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5450981,0.7921569,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;321;-2272.449,2523.63;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;329;-2524.285,424.573;Inherit;False;299;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-2067.115,2148.055;Inherit;False;Property;_Min;Min;14;0;Create;True;0;0;0;False;0;False;0;1.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;319;-2406.332,963.5356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-2272.952,-1095.806;Inherit;False;230;MaskMouth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-2408.443,-931.2409;Inherit;False;272;MovementMouth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-1816.103,-1622.09;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;387;-779.4667,183.8816;Inherit;False;1478.05;531.7649;;7;386;394;393;383;381;382;380;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;344;-2350.505,1074.993;Inherit;False;Property;_RimPower;Rim Power;9;1;[Header];Create;True;1;Rim Value;0;0;False;0;False;0.4810303;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;231;-2035.984,-1093.826;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;334;-1888.571,2022.314;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;341;-2330.004,1275.593;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;331;-2339.167,514.4329;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;338;-2363.322,431.574;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;-2320.438,1180.794;Inherit;False;325;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-2434.418,213.9601;Inherit;False;Property;_LightValue;Light Value;17;1;[Header];Create;True;1;Lighting;0;0;False;0;False;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-2082.76,2405.477;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;258;-2184.998,-953.096;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;208;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;219;-2051.451,-1188.996;Inherit;False;214;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-2441.418,284.9601;Inherit;False;Property;_ShadowValue;Shadow Value;18;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-2116.134,1378.47;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;343;-2307.916,592.9959;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;256;-2016.3,-1020.281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;336;-2262.005,960.7927;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;-2445.171,139.2261;Inherit;False;325;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-549.9783,462.6025;Inherit;False;227;V_TexCor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-624.9345,552.6647;Inherit;False;Constant;_Mask;Mask;20;0;Create;True;0;0;0;False;0;False;-0.441;-0.441;-1;-0.441;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;347;-2078.506,961.9927;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;352;-2210.721,171.4162;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;353;-1984.505,1383.797;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-1860.822,-1187.253;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;349;-2101.163,421.573;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;346;-1951.215,556.3769;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-1719.452,2255.975;Inherit;False;Property;_SpecularIntesity;Specular Intesity;16;0;Create;True;0;0;0;False;0;False;0;0.184;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-2139.704,1193.292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;-1605.865,2050.657;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-1785.38,-971.029;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;381;-322.5827,460.0623;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;-1855.472,184.7891;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;-1606.899,-1187.459;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-1775.17,1125.999;Inherit;False;Property;_RimIntensity;Rim Intensity;12;0;Create;True;0;0;0;False;0;False;1;0.744;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;-1411.109,2016.315;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-1823.726,957.9247;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;356;-1465.215,1915.755;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;383;-92.99342,461.0768;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-1675.645,180.3752;Inherit;False;N_Light;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;360;-1254.895,1991.65;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;373;-1341.91,-1185.112;Inherit;False;N_ChangeFace;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-1512.46,967.6327;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-1145.499,2032.419;Inherit;False;N_Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;393;83.57556,272.5628;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-721.8917,-722.6072;Inherit;False;295;N_Light;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-1295.024,926.9407;Inherit;False;N_Rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;375;-828.6998,-580.9938;Inherit;False;373;N_ChangeFace;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;282;-547.5815,-670.3955;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-545.0184,-760.9865;Inherit;False;364;N_Rim;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-548.4437,-566.1149;Inherit;False;366;N_Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;394;316.0672,271.9772;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;285;-360.3596,-720.7483;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;462.5948,268.333;Inherit;False;MaskMouthOpacity;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;371;-620.1874,-1330.213;Inherit;False;Property;_Emission;Emission;20;0;Create;True;0;0;0;False;0;False;0;0.6319106;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-608.5906,-1441.256;Inherit;False;373;N_ChangeFace;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;314;-3603.537,289.8228;Inherit;False;Property;_Tint;Tint;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-2886.311,79.59872;Inherit;False;M_Basecolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;287;-218.9471,-811.1597;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;320;-3327.471,83.64083;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;313;-3653.041,74.58608;Inherit;True;Property;_Basecolor;Basecolor;2;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;e9a1b9957893e41448390f087c867701;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;327;-3386.464,351.7487;Inherit;False;Constant;_Sature;Sature;5;0;Create;True;0;0;0;False;0;False;4.55;4.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-3022.682,80.82577;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;348;-3101.388,316.7208;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-3226.481,315.8737;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-281.4673,-1408.964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-235.6158,-1041.155;Inherit;False;386;MaskMouthOpacity;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-14.51402,-1234.545;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Assistant_HEAD_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;299;0;298;0
WireConnection;244;0;245;0
WireConnection;247;0;244;0
WireConnection;249;0;247;0
WireConnection;249;1;248;0
WireConnection;294;0;293;0
WireConnection;237;0;240;0
WireConnection;237;1;245;0
WireConnection;237;2;249;0
WireConnection;236;0;239;0
WireConnection;236;1;240;0
WireConnection;227;0;224;2
WireConnection;300;0;294;0
WireConnection;233;0;236;0
WireConnection;233;1;237;0
WireConnection;270;0;271;0
WireConnection;226;0;224;0
WireConnection;303;0;301;0
WireConnection;303;1;302;0
WireConnection;275;0;270;0
WireConnection;275;1;276;0
WireConnection;221;0;228;0
WireConnection;262;0;263;0
WireConnection;262;1;264;0
WireConnection;234;0;233;0
WireConnection;222;0;221;0
WireConnection;222;1;223;0
WireConnection;266;0;269;0
WireConnection;266;1;275;0
WireConnection;304;0;303;0
WireConnection;260;0;261;0
WireConnection;260;2;262;0
WireConnection;265;0;260;0
WireConnection;265;2;266;0
WireConnection;229;0;222;0
WireConnection;212;1;235;0
WireConnection;309;0;305;0
WireConnection;309;1;306;0
WireConnection;318;0;309;0
WireConnection;318;1;307;0
WireConnection;272;0;265;0
WireConnection;230;0;229;0
WireConnection;315;0;311;0
WireConnection;315;1;312;0
WireConnection;215;0;212;0
WireConnection;215;1;208;0
WireConnection;316;0;308;0
WireConnection;316;1;310;0
WireConnection;325;0;315;0
WireConnection;323;0;318;0
WireConnection;323;1;317;0
WireConnection;319;0;316;0
WireConnection;214;0;215;0
WireConnection;231;0;232;0
WireConnection;334;0;323;0
WireConnection;334;1;324;0
WireConnection;334;2;328;0
WireConnection;338;0;329;0
WireConnection;333;0;330;0
WireConnection;333;1;321;1
WireConnection;258;1;273;0
WireConnection;337;0;326;0
WireConnection;337;1;322;0
WireConnection;256;0;232;0
WireConnection;336;0;319;0
WireConnection;347;0;336;0
WireConnection;347;1;344;0
WireConnection;352;0;335;0
WireConnection;352;1;339;0
WireConnection;352;2;332;0
WireConnection;353;0;337;0
WireConnection;220;0;219;0
WireConnection;220;1;231;0
WireConnection;349;0;338;0
WireConnection;349;1;331;0
WireConnection;346;0;343;1
WireConnection;350;0;340;0
WireConnection;350;1;341;0
WireConnection;351;0;334;0
WireConnection;351;1;333;0
WireConnection;255;0;256;0
WireConnection;255;1;258;1
WireConnection;381;0;382;0
WireConnection;381;1;380;0
WireConnection;358;0;352;0
WireConnection;358;1;349;0
WireConnection;358;2;346;0
WireConnection;254;0;220;0
WireConnection;254;1;255;0
WireConnection;355;0;351;0
WireConnection;355;1;345;0
WireConnection;357;0;347;0
WireConnection;357;1;353;0
WireConnection;357;2;350;0
WireConnection;383;0;381;0
WireConnection;295;0;358;0
WireConnection;360;0;356;0
WireConnection;360;1;355;0
WireConnection;373;0;254;0
WireConnection;362;0;357;0
WireConnection;362;1;359;0
WireConnection;366;0;360;0
WireConnection;393;0;373;0
WireConnection;393;1;383;0
WireConnection;364;0;362;0
WireConnection;282;0;296;0
WireConnection;282;1;375;0
WireConnection;394;0;393;0
WireConnection;285;0;283;0
WireConnection;285;1;282;0
WireConnection;285;2;284;0
WireConnection;386;0;394;0
WireConnection;361;0;354;0
WireConnection;287;0;285;0
WireConnection;320;0;313;0
WireConnection;320;1;314;0
WireConnection;354;0;320;0
WireConnection;354;1;348;0
WireConnection;348;0;342;0
WireConnection;342;0;320;0
WireConnection;342;1;327;0
WireConnection;370;0;374;0
WireConnection;370;1;371;0
WireConnection;0;2;370;0
WireConnection;0;10;396;0
WireConnection;0;13;287;0
ASEEND*/
//CHKSM=808C2BF560F878451D02771BDE6C0B52A046AA42