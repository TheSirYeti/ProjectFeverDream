// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StylizedRobotpalooza_MAT"
{
	Properties
	{
		[Header(Texture)]_Basecolor("Basecolor", 2D) = "white" {}
		_NomalMap("Nomal Map", 2D) = "bump" {}
		_Tint("Tint", Color) = (1,1,1,0)
		[Header(Outline)]_OutlineWidth("Outline Width", Range( 0 , 0.01)) = 0
		_ColorOutline("Color Outline", Color) = (0,0,0,0)
		[Header(Rim Value)]_RimPower("Rim Power", Range( 0 , 1)) = 0.4810303
		_Sature("Sature", Float) = 1
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ColorOutline.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
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
		uniform float4 _Tint;
		uniform float _Sature;
		uniform float _Min;
		uniform float _Max;
		uniform float _SpecularPower;
		uniform float4 _Color0;
		uniform float _SpecularIntesity;
		uniform float4 _ColorOutline;
		uniform float _OutlineWidth;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 N_Outline70 = 0;
			v.vertex.xyz += N_Outline70;
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
			float4 temp_output_49_0 = ( tex2D( _Basecolor, uv_Basecolor ) * _Tint );
			float4 M_Basecolor50 = ( temp_output_49_0 * saturate( ( temp_output_49_0 * _Sature ) ) );
			float dotResult120 = dot( ( ase_worldViewDir + ase_worldlightDir ) , N_WorldNormal18 );
			float smoothstepResult123 = smoothstep( _Min , _Max , pow( dotResult120 , _SpecularPower ));
			float4 N_Specular130 = ( ase_lightAtten * ( ( smoothstepResult123 * ( _Color0 * float4( ase_lightColor.rgb , 0.0 ) ) ) * _SpecularIntesity ) );
			c.rgb = saturate( ( N_Rim99 + ( float4( N_Light54 , 0.0 ) * M_Basecolor50 ) + N_Specular130 ) ).rgb;
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
0;73;468;560;-1030.885;1193.043;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;115;-2221.474,-2100.164;Inherit;False;1043.589;737.5994;Comment;10;50;87;84;82;83;49;48;1;45;44;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;44;-2141.538,-1592.565;Inherit;True;Property;_NomalMap;Nomal Map;1;0;Create;True;0;0;0;False;0;False;-1;None;07059d87b4aea004daec09a8f14a68ab;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1845.176,-1596.815;Inherit;False;M_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2867.689,-2082.61;Inherit;False;45;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;17;-2679.525,-2077.911;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-2489.18,-2079.241;Inherit;False;N_WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2172.783,-709.5424;Inherit;False;372.5707;268.5439;;3;21;22;20;Normal Light View;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-2151.634,-664.6393;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-2148.267,-584.8283;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;148;-1257.741,-305.1754;Inherit;False;1820.667;858.0425;;19;157;128;126;130;129;123;142;156;138;155;121;120;154;118;119;131;116;162;161;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-1916.533,-661.1633;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-1301.968,-1263.385;Inherit;False;1857.228;811.5788;;18;99;149;100;150;98;105;110;96;104;103;97;106;101;102;78;76;75;77;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-2198.963,-1140.891;Inherit;False;423.5677;351.9097;;3;8;9;19;Normal Light Dir;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;131;-1207.741,-91.83403;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1764.371,-662.5727;Inherit;False;N_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;116;-1148.609,-255.1755;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;119;-1005.431,9.302177;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;9;-2175.697,-997.9468;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-927.1325,-115.909;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1232.557,-1067.742;Inherit;False;Property;_RimOffset;Rim Offset;7;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1240.608,-1177.87;Inherit;False;25;N_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2166.903,-1081.807;Inherit;False;18;N_WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1065.069,-1166.957;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-2119.112,-1839.94;Inherit;False;Property;_Tint;Tint;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;8;-1893.015,-1080.938;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2171.474,-2049.058;Inherit;True;Property;_Basecolor;Basecolor;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;4f20961f277db764599ba85044805eef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;66;-359.5435,-1964.462;Inherit;False;1115.114;638.0347;;12;54;41;27;62;64;53;158;61;40;159;42;63;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;120;-779.7429,-114.8244;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-794.6892,45.29242;Inherit;False;Property;_SpecularPower;Specular Power;10;1;[Header];Create;True;1;Specular;0;0;False;0;False;0;0.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;-851.7081,-628.2919;Inherit;False;Property;_RimColor;Rim Color;8;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8242262,0.5896226,0;1,0.8235294,0.5882353,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;162;-832.4504,168.5938;Inherit;False;Property;_Color0;Color0;16;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9528301,0.509639,0.4719205,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;155;-582.6892,18.29242;Inherit;False;Property;_Min;Min;11;0;Create;True;0;0;0;False;0;False;0;1.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;101;-846.7081,-756.2922;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightColorNode;138;-788.0234,393.8671;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;121;-601.5029,-112.3974;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;78;-921.9071,-1166.227;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-309.5435,-1629.115;Inherit;False;45;M_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1902.039,-1778.014;Inherit;False;Property;_Sature;Sature;6;0;Create;True;0;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1843.046,-2046.122;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1758.244,-1093.395;Inherit;False;N_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-586.6892,88.29242;Inherit;False;Property;_Max;Max;12;0;Create;True;0;0;0;False;0;False;0;1.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-598.3348,275.7141;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-631.7081,-751.2921;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;123;-404.1454,-107.4482;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-836.0131,-948.9687;Inherit;False;24;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-866.08,-1054.77;Inherit;False;Property;_RimPower;Rim Power;5;1;[Header];Create;True;1;Rim Value;0;0;False;0;False;0.4810303;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;106;-845.5792,-854.1696;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-777.5801,-1168.97;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1742.056,-1813.889;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;53;-93.1741,-1460.692;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;42;-124.4252,-1539.255;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-226.6764,-1768.728;Inherit;False;Property;_ShadowValue;Shadow Value;15;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;61;-148.5806,-1622.114;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-230.4295,-1914.462;Inherit;False;24;N_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-219.6764,-1839.728;Inherit;False;Property;_LightValue;Light Value;14;1;[Header];Create;True;1;Lighting;0;0;False;0;False;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-121.4395,-79.10599;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;98;-594.0802,-1167.77;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-235.0266,126.2118;Inherit;False;Property;_SpecularIntesity;Specular Intesity;13;0;Create;True;0;0;0;False;0;False;0;0.635;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;113.5793,-1632.115;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;84;-1616.963,-1813.042;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;27;4.020266,-1875.272;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;64;263.5276,-1497.311;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-655.2791,-936.4703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;110;-500.0798,-745.966;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;73.31661,-113.4473;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;359.2703,-1868.899;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;129;19.21081,-214.0079;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-290.7443,-1003.764;Inherit;False;Property;_RimIntensity;Rim Intensity;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-339.3007,-1171.838;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1538.257,-2048.937;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;539.097,-1873.313;Inherit;False;N_Light;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;229.5304,-138.1127;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-28.03421,-1162.13;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;73;-1111.561,-1960.925;Inherit;False;726.1443;328.443;;4;70;67;68;69;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1401.885,-2050.164;Inherit;False;M_Basecolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;371.9261,-115.3433;Inherit;False;N_Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1042.284,-1711.244;Inherit;False;Property;_OutlineWidth;Outline Width;3;1;[Header];Create;True;1;Outline;0;0;False;0;False;0;0.0015;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;937.7628,-907.8041;Inherit;False;50;M_Basecolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;907.6022,-1074.489;Inherit;False;54;N_Light;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;197.1725,-1202.822;Inherit;False;N_Rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;68;-1061.561,-1908.202;Inherit;False;Property;_ColorOutline;Color Outline;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1603774,0.06628806,0.009834467,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OutlineNode;67;-820.2035,-1910.092;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;1097.345,-765.5143;Inherit;False;130;N_Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1180.107,-1041.396;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1183.969,-1142.388;Inherit;False;99;N_Rim;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-607.6428,-1910.925;Inherit;False;N_Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;1362.129,-1081.349;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;1460.915,-876.6237;Inherit;False;70;N_Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;32;1477.769,-949.5253;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;6;1725.082,-1142.964;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;StylizedRobotpalooza_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.0015;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;0;44;0
WireConnection;17;0;47;0
WireConnection;18;0;17;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;25;0;21;0
WireConnection;118;0;116;0
WireConnection;118;1;131;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;8;0;19;0
WireConnection;8;1;9;0
WireConnection;120;0;118;0
WireConnection;120;1;119;0
WireConnection;121;0;120;0
WireConnection;121;1;154;0
WireConnection;78;0;76;0
WireConnection;49;0;1;0
WireConnection;49;1;48;0
WireConnection;24;0;8;0
WireConnection;142;0;162;0
WireConnection;142;1;138;1
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;123;0;121;0
WireConnection;123;1;155;0
WireConnection;123;2;156;0
WireConnection;96;0;78;0
WireConnection;82;0;49;0
WireConnection;82;1;83;0
WireConnection;61;0;63;0
WireConnection;161;0;123;0
WireConnection;161;1;142;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;62;0;61;0
WireConnection;62;1;42;0
WireConnection;84;0;82;0
WireConnection;27;0;40;0
WireConnection;27;1;158;0
WireConnection;27;2;159;0
WireConnection;64;0;53;1
WireConnection;105;0;104;0
WireConnection;105;1;106;0
WireConnection;110;0;103;0
WireConnection;126;0;161;0
WireConnection;126;1;157;0
WireConnection;41;0;27;0
WireConnection;41;1;62;0
WireConnection;41;2;64;0
WireConnection;100;0;98;0
WireConnection;100;1;110;0
WireConnection;100;2;105;0
WireConnection;87;0;49;0
WireConnection;87;1;84;0
WireConnection;54;0;41;0
WireConnection;128;0;129;0
WireConnection;128;1;126;0
WireConnection;149;0;100;0
WireConnection;149;1;150;0
WireConnection;50;0;87;0
WireConnection;130;0;128;0
WireConnection;99;0;149;0
WireConnection;67;0;68;0
WireConnection;67;1;69;0
WireConnection;51;0;56;0
WireConnection;51;1;52;0
WireConnection;70;0;67;0
WireConnection;108;0;109;0
WireConnection;108;1;51;0
WireConnection;108;2;132;0
WireConnection;32;0;108;0
WireConnection;6;13;32;0
WireConnection;6;11;72;0
ASEEND*/
//CHKSM=C5DA75D5930DA966E5FEC0E36903F48D04DF4EE6