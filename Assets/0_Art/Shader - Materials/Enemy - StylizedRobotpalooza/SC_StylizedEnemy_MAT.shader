// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SC_StylizedEnemy_MAT"
{
	Properties
	{
		[Header(Texture)]_Basecolor("Basecolor", 2D) = "white" {}
		_NomalMap("Nomal Map", 2D) = "bump" {}
		_ColorAlbedo("Color Albedo", Color) = (1,1,1,0)
		[Header(Outline)]_OutlineWidth("Outline Width", Range( 0 , 1)) = 1
		[Header(Rim Value)]_RimPower("Rim Power", Range( 0 , 1)) = 0.4810303
		_Sature("Sature", Float) = 4.55
		_RimOffset("Rim Offset", Float) = 1
		[HDR]_RimColor("Rim Color", Color) = (1,0.8242262,0.5896226,0)
		_RimIntensity("Rim Intensity", Range( 0 , 1)) = 1
		[Header(Specular)]_SpecularPower("Specular Power", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SpecularIntesity("Specular Intesity", Range( 0 , 1)) = 0
		[Header(Lighting)]_LightValue("Light Value", Float) = 0
		_ShadowValue("Shadow Value", Float) = 0
		_ColorSpecular("Color Specular", Color) = (0,0,0,0)
		[Header(Warning attack)]_NumberLines("Number Lines", Range( 0 , 300)) = 5
		_SpeedWarning("Speed Warning", Range( 0 , 1)) = 0
		_SpeedCorners("Speed Corners", Range( 0 , 10)) = 10
		_ValueWarning("Value Warning", Range( 0 , 1)) = 0
		[Header(Blackhole)]_Effect("Effect", Range( 0 , 10)) = 0
		_Range("Range", Range( 0 , 10)) = 1
		_BlackHolePositions("Black Hole Positions", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0"}
		ZWrite On
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline alpha:fade  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float4 color68 = IsGammaSpace() ? float4(0.09411765,0.1019608,0.1215686,0) : float4(0.009134057,0.01032983,0.01370208,0);
			float EffecBlackHole288 = ( _Effect * 2.0 );
			o.Emission = color68.rgb;
			o.Alpha = saturate( ( 1.0 - EffecBlackHole288 ) );
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZWrite On
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
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
		uniform float _SpeedWarning;
		uniform float _NumberLines;
		uniform float3 _BlackHolePositions;
		uniform float _Range;
		uniform float _Effect;
		uniform sampler2D _NomalMap;
		uniform float4 _NomalMap_ST;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform float _LightValue;
		uniform float _ShadowValue;
		uniform sampler2D _Basecolor;
		uniform float4 _Basecolor_ST;
		uniform float4 _ColorAlbedo;
		uniform float _Sature;
		uniform float _Min;
		uniform float _Max;
		uniform float _SpecularPower;
		uniform float4 _ColorSpecular;
		uniform float _SpecularIntesity;
		uniform float _OutlineWidth;


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
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float fresnelNdotV166 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode166 = ( 0.0 + 1.2 * pow( 1.0 - fresnelNdotV166, 3.0 ) );
			float4 color167 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float mulTime213 = _Time.y * _SpeedCorners;
			float lerpResult218 = lerp( 0.8 , 1.0 , sin( ( 1.0 * mulTime213 ) ));
			float2 uv_TexCoord175 = v.texcoord.xy * float3(0.2,12,1).xy;
			float4 transform190 = mul(unity_WorldToObject,float4( uv_TexCoord175, 0.0 , 0.0 ));
			float mulTime186 = _Time.y * _SpeedWarning;
			float simplePerlin2D174 = snoise( ( transform190 + mulTime186 ).xy*_NumberLines );
			simplePerlin2D174 = simplePerlin2D174*0.5 + 0.5;
			float4 temp_output_177_0 = ( ( saturate( ( ( fresnelNode166 * color167 ) * lerpResult218 ) ) * _ValueWarning ) * simplePerlin2D174 );
			float3 temp_output_233_0 = ( _BlackHolePositions - ase_worldPos );
			float lerpResult235 = lerp( 0.0 , _Range , _Effect);
			float clampResult238 = clamp( ( lerpResult235 - length( temp_output_233_0 ) ) , 0.0 , 1.0 );
			float3 lerpResult240 = lerp( float3( 0,0,0 ) , ( temp_output_233_0 + float3( 0,0,0 ) ) , clampResult238);
			float3 worldToObjDir241 = mul( unity_WorldToObject, float4( lerpResult240, 0 ) ).xyz;
			float3 BlackHole242 = worldToObjDir241;
			float3 N_Outline70 = 0;
			v.vertex.xyz += ( ( float4( ase_vertexNormal , 0.0 ) * ( temp_output_177_0 * ( _ValueWarning / 100.0 ) ) ) + float4( BlackHole242 , 0.0 ) + float4( N_Outline70 , 0.0 ) ).rgb;
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
			float2 uv_NomalMap = i.uv_texcoord * _NomalMap_ST.xy + _NomalMap_ST.zw;
			float3 M_Normal45 = UnpackNormal( tex2D( _NomalMap, uv_NomalMap ) );
			float3 N_WorldNormal18 = (WorldNormalVector( i , M_Normal45 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult21 = dot( N_WorldNormal18 , ase_worldViewDir );
			float N_ViewDir25 = dotResult21;
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
			float dotResult8 = dot( N_WorldNormal18 , ase_worldlightDir );
			float N_LightDir24 = dotResult8;
			float4 N_Rim99 = ( ( pow( ( 1.0 - saturate( ( N_ViewDir25 * _RimOffset ) ) ) , _RimPower ) * saturate( ( ase_lightColor * _RimColor ) ) * ( N_LightDir24 * ase_lightAtten ) ) * _RimIntensity );
			UnityGI gi61 = gi;
			float3 diffNorm61 = WorldNormalVector( i , M_Normal45 );
			gi61 = UnityGI_Base( data, 1, diffNorm61 );
			float3 indirectDiffuse61 = gi61.indirect.diffuse + diffNorm61 * 0.0001;
			float3 N_Light54 = ( (N_LightDir24*_LightValue + _ShadowValue) * ( indirectDiffuse61 + ase_lightAtten ) * ase_lightColor.rgb );
			float2 uv_Basecolor = i.uv_texcoord * _Basecolor_ST.xy + _Basecolor_ST.zw;
			float4 temp_output_49_0 = ( tex2D( _Basecolor, uv_Basecolor ) * _ColorAlbedo );
			float4 M_Basecolor50 = ( temp_output_49_0 * saturate( ( temp_output_49_0 * _Sature ) ) );
			float dotResult120 = dot( ( ase_worldViewDir + ase_worldlightDir ) , N_WorldNormal18 );
			float smoothstepResult123 = smoothstep( _Min , _Max , pow( dotResult120 , _SpecularPower ));
			float4 N_Specular130 = ( ase_lightAtten * ( ( smoothstepResult123 * ( _ColorSpecular * float4( ase_lightColor.rgb , 0.0 ) ) ) * _SpecularIntesity ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV166 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode166 = ( 0.0 + 1.2 * pow( 1.0 - fresnelNdotV166, 3.0 ) );
			float4 color167 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float mulTime213 = _Time.y * _SpeedCorners;
			float lerpResult218 = lerp( 0.8 , 1.0 , sin( ( 1.0 * mulTime213 ) ));
			float2 uv_TexCoord175 = i.uv_texcoord * float3(0.2,12,1).xy;
			float4 transform190 = mul(unity_WorldToObject,float4( uv_TexCoord175, 0.0 , 0.0 ));
			float mulTime186 = _Time.y * _SpeedWarning;
			float simplePerlin2D174 = snoise( ( transform190 + mulTime186 ).xy*_NumberLines );
			simplePerlin2D174 = simplePerlin2D174*0.5 + 0.5;
			float4 temp_output_177_0 = ( ( saturate( ( ( fresnelNode166 * color167 ) * lerpResult218 ) ) * _ValueWarning ) * simplePerlin2D174 );
			float4 FresnelWarning172 = temp_output_177_0;
			c.rgb = ( N_Rim99 + ( float4( N_Light54 , 0.0 ) * M_Basecolor50 ) + N_Specular130 + FresnelWarning172 ).rgb;
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
0;73;806;655;1443.478;2008.503;1;True;False
Node;AmplifyShaderEditor.SamplerNode;44;-2141.538,-1592.565;Inherit;True;Property;_NomalMap;Nomal Map;1;0;Create;True;0;0;0;False;0;False;-1;None;dccd8827f6d3a9c4da1e0815ee27955c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1852.946,-1589.045;Inherit;False;M_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2867.689,-2082.61;Inherit;False;45;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;17;-2679.525,-2077.911;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-2489.18,-2079.241;Inherit;False;N_WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-2151.634,-664.6393;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-2148.267,-584.8283;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;225;-2191.116,1190.436;Inherit;False;Property;_SpeedCorners;Speed Corners;18;0;Create;True;0;0;0;False;0;False;10;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;148;-1257.741,-305.1754;Inherit;False;1820.667;858.0425;;18;157;128;126;130;129;123;142;156;138;155;121;120;154;118;119;131;116;162;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;213;-1903.357,1172.183;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-1916.533,-661.1633;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-1896.944,1071.55;Inherit;False;Constant;_MSIN;MSIN;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;163;-1193.763,727.1077;Inherit;False;1951.677;999.1895;;21;171;176;190;175;178;172;177;174;188;169;186;168;166;187;167;165;164;196;219;226;264;Heavy attack JP;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-1746.441,1114.913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-1301.968,-1263.385;Inherit;False;1857.228;811.5788;;18;99;149;100;150;98;105;110;96;104;103;97;106;101;102;78;76;75;77;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;116;-1148.609,-255.1755;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1764.371,-662.5727;Inherit;False;N_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;229;-892.3767,2203.123;Inherit;False;1649.081;545.574;;13;242;241;240;239;238;237;236;235;233;231;294;296;298;BlackHole;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;131;-1207.741,-91.83403;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;119;-1005.431,9.302177;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1240.608,-1177.87;Inherit;False;25;N_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-1143.361,840.7867;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;1.2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1232.557,-1067.742;Inherit;False;Property;_RimOffset;Rim Offset;6;0;Create;True;0;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;216;-1615.438,1115.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;231;-809.7527,2253.123;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;115;-2221.474,-2100.164;Inherit;False;1043.589;737.5994;Comment;2;48;289;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-816.5529,2629.359;Inherit;False;Property;_Effect;Effect;20;1;[Header];Create;True;1;Blackhole;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-1143.763,923.5316;Inherit;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;298;-819.116,2396.824;Inherit;False;Property;_BlackHolePositions;Black Hole Positions;22;0;Create;True;0;0;0;False;0;False;0,0,0;-7.86,3.779,2.827;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2166.903,-1081.807;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-1627.518,1036.247;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;9;-2175.697,-998.9468;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;215;-1619.518,956.2471;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-927.1325,-115.909;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;48;-2119.112,-1839.94;Inherit;False;Property;_ColorAlbedo;Color Albedo;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.9103774,0.9462264,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;154;-794.6892,45.29242;Inherit;False;Property;_SpecularPower;Specular Power;9;1;[Header];Create;True;1;Specular;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2171.474,-2049.058;Inherit;True;Property;_Basecolor;Basecolor;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;512497a17b5909a40977fa931400431b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-555.9156,2837.436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-359.5435,-1964.462;Inherit;False;1115.114;638.0347;;12;54;41;62;27;64;40;159;42;158;61;53;63;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;167;-863.7759,1048.445;Inherit;False;Constant;_ColorWaring;Color Waring;2;0;Create;True;0;0;0;False;0;False;1,0,0.008883953,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;294;-822.7505,2553.573;Inherit;False;Property;_Range;Range;21;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;8;-1893.015,-1080.938;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;166;-948.884,783.0577;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;178;-1161.489,1214.501;Inherit;False;Constant;_Vector0;Vector 0;20;0;Create;True;0;0;0;False;0;False;0.2,12,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;120;-779.7429,-114.8244;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;233;-545.2518,2346.366;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1065.069,-1166.957;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;218;-1361.98,999.0989;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1033.157,1400.385;Inherit;False;Property;_SpeedWarning;Speed Warning;17;0;Create;True;0;0;0;False;0;False;0;0.227;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;-400.8692,2828.086;Inherit;False;EffecBlackHole;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-582.6892,18.29242;Inherit;False;Property;_Min;Min;10;0;Create;True;0;0;0;False;0;False;0;1.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;-991.6856,1243.889;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;101;-846.7081,-756.2922;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;78;-921.9071,-1166.227;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;219;-356.5505,998.0591;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-309.5435,-1629.115;Inherit;False;45;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-618.801,783.6397;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1758.244,-1093.395;Inherit;False;N_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1902.039,-1778.014;Inherit;False;Property;_Sature;Sature;5;0;Create;True;0;0;0;False;0;False;4.55;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;162;-832.4504,168.5938;Inherit;False;Property;_ColorSpecular;Color Specular;15;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7877358,0.9218967,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1843.046,-2046.122;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;102;-851.7081,-628.2919;Inherit;False;Property;_RimColor;Rim Color;7;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8242262,0.5896226,0;0.5990566,0.6481517,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;236;-308.3487,2444.575;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;121;-601.5029,-112.3974;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-586.6892,88.29242;Inherit;False;Property;_Max;Max;11;0;Create;True;0;0;0;False;0;False;0;1.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;235;-396.4007,2589.696;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;138;-788.0234,393.8671;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-116.2485,784.5106;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1742.056,-1813.889;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-1398.004,-1550.598;Inherit;False;288;EffecBlackHole;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-219.6764,-1839.728;Inherit;False;Property;_LightValue;Light Value;13;1;[Header];Create;True;1;Lighting;0;0;False;0;False;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;42;-124.4252,-1539.255;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-631.7081,-751.2921;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-226.6764,-1768.728;Inherit;False;Property;_ShadowValue;Shadow Value;14;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;53;-93.1741,-1460.692;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;97;-866.08,-1054.77;Inherit;False;Property;_RimPower;Rim Power;4;1;[Header];Create;True;1;Rim Value;0;0;False;0;False;0.4810303;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;237;-166.2757,2561.123;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;106;-845.5792,-854.1696;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;190;-771.8658,1218.564;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;123;-404.1454,-107.4482;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-777.5801,-1168.97;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;186;-757.7153,1396.385;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;61;-148.5806,-1622.114;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-230.4295,-1914.462;Inherit;False;24;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-598.3348,275.7141;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-836.0131,-948.9687;Inherit;False;24;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;84;-1616.963,-1813.042;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-206.3803,940.7578;Inherit;False;Property;_ValueWarning;Value Warning;19;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;290;-1201.004,-1553.598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;98;-594.0802,-1167.77;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-121.4395,-79.10599;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;113.5793,-1632.115;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;169;10.47891,790.2505;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;-234.9498,2322.229;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;64;263.5276,-1497.311;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-611.5999,1462.692;Inherit;False;Property;_NumberLines;Number Lines;16;1;[Header];Create;True;1;Warning attack;0;0;False;0;False;5;300;0;300;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;73;-1111.561,-1960.925;Inherit;False;726.1443;328.443;;4;70;67;69;68;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;110;-500.0798,-745.966;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;-519.9351,1284.982;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-655.2791,-936.4703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-235.0266,126.2118;Inherit;False;Property;_SpecularIntesity;Specular Intesity;12;0;Create;True;0;0;0;False;0;False;0;0.296;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;238;-5.26664,2572.526;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;27;4.020266,-1882.272;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;174;-305.3239,1249.776;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;129;19.21081,-214.0079;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;169.886,794.053;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;291;-1022.452,-1541.238;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;68;-1061.561,-1908.202;Inherit;False;Constant;_ColorOutline;Color Outline;3;0;Create;True;0;0;0;False;0;False;0.09411765,0.1019608,0.1215686,0;0.09429512,0.1005943,0.1226415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1538.257,-2048.937;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;73.31661,-113.4473;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1176.2,-1726.752;Inherit;False;Property;_OutlineWidth;Outline Width;3;1;[Header];Create;True;1;Outline;0;0;False;0;False;1;0.0035;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-339.3007,-1171.838;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;359.2703,-1868.899;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-290.7443,-1003.764;Inherit;False;Property;_RimIntensity;Rim Intensity;8;0;Create;True;0;0;0;False;0;False;1;0.525;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;240;91.89294,2299.712;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-28.03421,-1162.13;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;67;-820.2035,-1910.092;Inherit;False;0;False;Transparent;1;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;539.097,-1873.313;Inherit;False;N_Light;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;241;286.664,2302.717;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;328.3686,1233.473;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1401.885,-2050.164;Inherit;False;M_Basecolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;229.5304,-138.1127;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;264;183.4672,1519.699;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;898.9279,-1343.759;Inherit;False;54;N_Light;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;597.0544,2302.291;Inherit;False;BlackHole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-607.6428,-1910.925;Inherit;False;N_Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;547.4627,966.5771;Inherit;False;FresnelWarning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;222;671.9249,1075.915;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;669.5171,1350.525;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;901.6351,-1254.156;Inherit;False;50;M_Basecolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;189.4021,-1202.822;Inherit;False;N_Rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;338.9261,-97.34331;Inherit;False;N_Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;1031.075,-776.895;Inherit;False;70;N_Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;1145.074,-637.0512;Inherit;False;242;BlackHole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;1048.182,-1084.638;Inherit;False;172;FresnelWarning;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;911.2542,1250.024;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1095.843,-1382.139;Inherit;False;99;N_Rim;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1093.28,-1291.547;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;1092.418,-1187.266;Inherit;False;130;N_Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;1309.502,-1230.9;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;252;1413.839,-812.3949;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;6;1657.082,-1237.964;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SC_StylizedEnemy_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.0015;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;15;-2198.963,-1140.891;Inherit;False;423.5677;351.9097;;0;Normal Light Dir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2172.783,-709.5424;Inherit;False;372.5707;268.5439;;0;Normal Light View;1,1,1,1;0;0
WireConnection;45;0;44;0
WireConnection;17;0;47;0
WireConnection;18;0;17;0
WireConnection;213;0;225;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;214;0;212;0
WireConnection;214;1;213;0
WireConnection;25;0;21;0
WireConnection;216;0;214;0
WireConnection;118;0;116;0
WireConnection;118;1;131;0
WireConnection;293;0;296;0
WireConnection;8;0;19;0
WireConnection;8;1;9;0
WireConnection;166;2;165;0
WireConnection;166;3;164;0
WireConnection;120;0;118;0
WireConnection;120;1;119;0
WireConnection;233;0;298;0
WireConnection;233;1;231;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;218;0;215;0
WireConnection;218;1;217;0
WireConnection;218;2;216;0
WireConnection;288;0;293;0
WireConnection;175;0;178;0
WireConnection;78;0;76;0
WireConnection;219;0;218;0
WireConnection;168;0;166;0
WireConnection;168;1;167;0
WireConnection;24;0;8;0
WireConnection;49;0;1;0
WireConnection;49;1;48;0
WireConnection;236;0;233;0
WireConnection;121;0;120;0
WireConnection;121;1;154;0
WireConnection;235;1;294;0
WireConnection;235;2;296;0
WireConnection;196;0;168;0
WireConnection;196;1;219;0
WireConnection;82;0;49;0
WireConnection;82;1;83;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;237;0;235;0
WireConnection;237;1;236;0
WireConnection;190;0;175;0
WireConnection;123;0;121;0
WireConnection;123;1;155;0
WireConnection;123;2;156;0
WireConnection;96;0;78;0
WireConnection;186;0;187;0
WireConnection;61;0;63;0
WireConnection;142;0;162;0
WireConnection;142;1;138;1
WireConnection;84;0;82;0
WireConnection;290;0;289;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;161;0;123;0
WireConnection;161;1;142;0
WireConnection;62;0;61;0
WireConnection;62;1;42;0
WireConnection;169;0;196;0
WireConnection;239;0;233;0
WireConnection;64;0;53;1
WireConnection;110;0;103;0
WireConnection;188;0;190;0
WireConnection;188;1;186;0
WireConnection;105;0;104;0
WireConnection;105;1;106;0
WireConnection;238;0;237;0
WireConnection;27;0;40;0
WireConnection;27;1;158;0
WireConnection;27;2;159;0
WireConnection;174;0;188;0
WireConnection;174;1;176;0
WireConnection;171;0;169;0
WireConnection;171;1;226;0
WireConnection;291;0;290;0
WireConnection;87;0;49;0
WireConnection;87;1;84;0
WireConnection;126;0;161;0
WireConnection;126;1;157;0
WireConnection;100;0;98;0
WireConnection;100;1;110;0
WireConnection;100;2;105;0
WireConnection;41;0;27;0
WireConnection;41;1;62;0
WireConnection;41;2;64;0
WireConnection;240;1;239;0
WireConnection;240;2;238;0
WireConnection;149;0;100;0
WireConnection;149;1;150;0
WireConnection;67;0;68;0
WireConnection;67;2;291;0
WireConnection;67;1;69;0
WireConnection;54;0;41;0
WireConnection;241;0;240;0
WireConnection;177;0;171;0
WireConnection;177;1;174;0
WireConnection;50;0;87;0
WireConnection;128;0;129;0
WireConnection;128;1;126;0
WireConnection;264;0;226;0
WireConnection;242;0;241;0
WireConnection;70;0;67;0
WireConnection;172;0;177;0
WireConnection;262;0;177;0
WireConnection;262;1;264;0
WireConnection;99;0;149;0
WireConnection;130;0;128;0
WireConnection;223;0;222;0
WireConnection;223;1;262;0
WireConnection;51;0;56;0
WireConnection;51;1;52;0
WireConnection;108;0;109;0
WireConnection;108;1;51;0
WireConnection;108;2;132;0
WireConnection;108;3;173;0
WireConnection;252;0;223;0
WireConnection;252;1;243;0
WireConnection;252;2;276;0
WireConnection;6;13;108;0
WireConnection;6;11;252;0
ASEEND*/
//CHKSM=6EA0DA980262169E3B66B439F3F9A6DDD56F2E91