// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole"
{
	Properties
	{
		_Effect("Effect", Range( 0 , 10)) = 0
		_Range("Range", Range( 0 , 10)) = 0
		_BlackHolePosition("Black Hole Position", Vector) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_HalfLambert("Half Lambert", Float) = 0.55
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		_ColorFresnel("Color Fresnel", Color) = (0.4386792,0.7948788,1,0)
		_IntensetySpecular("Intensety Specular", Range( 0 , 0.2)) = 0.6515115
		_Color1("Color 1", Color) = (0.6933962,0.8990011,1,0)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_Specsomething("Spec something", Float) = 5
		_Turningoff("Turning off", Range( 0 , 1)) = 0
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
		uniform sampler2D _TextureSample3;
		uniform float4 _TextureSample3_ST;
		uniform float _Turningoff;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _HalfLambert;
		uniform sampler2D _TextureSample2;
		uniform float4 _TextureSample2_ST;
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


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_output_36_0 = ( _BlackHolePosition - ase_worldPos );
			float lerpResult42 = lerp( 0.0 , _Range , _Effect);
			float clampResult46 = clamp( ( lerpResult42 - length( temp_output_36_0 ) ) , 0.0 , 1.0 );
			float3 Blackhole310 = ( ( float3( 0,0,0 ) + temp_output_36_0 ) * clampResult46 );
			v.vertex.xyz += Blackhole310;
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
			Gradient gradient266 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.7075472, 0.7075472, 0.7075472, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float4 Albedo304 = tex2D( _TextureSample1, uv_TextureSample1 );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float3 WorldNormal274 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _TextureSample0, uv_TextureSample0 ) ) )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult74 = dot( WorldNormal274 , ase_worldlightDir );
			float SoftLight286 = (dotResult74*_HalfLambert + _HalfLambert);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			float4 Metallic_Smoothness306 = tex2D( _TextureSample2, uv_TextureSample2 );
			float4 temp_cast_1 = (_Smoothness).xxxx;
			float dotResult124 = dot( Metallic_Smoothness306 , temp_cast_1 );
			Unity_GlossyEnvironmentData g102 = UnityGlossyEnvironmentSetup( dotResult124, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular102 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g102 );
			float3 Sature_Color288 = indirectSpecular102;
			float smoothstepResult245 = smoothstep( -0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow292 = smoothstepResult245;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV183 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode183 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV183, _FresnelPower ) );
			float4 Fresnel296 = saturate( ( fresnelNode183 * _ColorFresnel * _FresnelIntensity ) );
			float dotResult194 = dot( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) , WorldNormal274 );
			float smoothstepResult198 = smoothstep( 1.69 , 2.7 , pow( dotResult194 , _Specsomething ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 LightColor_Color278 = ase_lightColor.rgb;
			float4 Specular301 = saturate( ( ( smoothstepResult198 * saturate( ( _Color1 * float4( LightColor_Color278 , 0.0 ) ) ) ) * _IntensetySpecular ) );
			c.rgb = ( SampleGradient( gradient266, _Turningoff ) * ( ( Albedo304 * SoftLight286 * float4( ( Sature_Color288 + Shadow292 ) , 0.0 ) ) + Fresnel296 + Specular301 ) ).rgb;
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
			float2 uv_TextureSample3 = i.uv_texcoord * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
			float4 Emission305 = tex2D( _TextureSample3, uv_TextureSample3 );
			o.Emission = Emission305.rgb;
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
0;73;711;655;2098.232;4313.163;4.309418;False;False
Node;AmplifyShaderEditor.CommentaryNode;312;-3750.178,-4508.952;Inherit;False;1229.436;654.4583;;12;71;75;277;274;88;278;306;283;86;304;103;305;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;71;-3224.869,-4265.16;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;75;-2930.041,-4260.616;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;315;-1206.519,-3796.942;Inherit;False;1941.457;648.8451;;19;191;263;295;193;220;194;261;298;196;217;300;200;299;198;202;219;201;213;301;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;277;-3214.46,-4063.458;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightPos;263;-1156.519,-3589.538;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-2744.742,-4264.241;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;191;-1146.873,-3743.28;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-3011.901,-4047.07;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;320;-906.8145,-4216.114;Inherit;False;1085.601;366.446;;8;241;242;243;290;244;291;245;292;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-920.1987,-3735.987;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;88;-3228.544,-4458.952;Inherit;True;Property;_TextureSample2;Texture Sample 2;6;0;Create;True;0;0;0;False;0;False;-1;None;1517a836104074d41b8d6a0f2202c945;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;295;-917.8459,-3559.521;Inherit;False;274;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-2941.713,-4458.272;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;346;-920.5495,-4664.31;Inherit;False;940.3551;367.2012;;5;109;307;124;102;288;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;-630.4864,-3264.097;Inherit;False;278;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-856.8146,-4096.767;Inherit;False;Property;_Shadow;Shadow;16;0;Create;True;0;0;0;False;0;False;0;0.1411765;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;242;-836.5675,-4166.115;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;194;-748.4411,-3735.437;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;220;-631.6924,-3449.763;Inherit;False;Property;_Color1;Color 1;14;0;Create;True;0;0;0;False;0;False;0.6933962,0.8990011,1,0;0.6650944,0.8121902,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;261;-701.9429,-3569.962;Inherit;False;Property;_Specsomething;Spec something;17;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-463.6639,-3632.761;Inherit;False;Constant;_Min;Min;14;0;Create;True;0;0;0;False;0;False;1.69;1.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-541.2507,-4145.957;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;347;-3735.115,-3806.8;Inherit;False;1336.353;427.6599;;5;276;317;72;74;286;Soft Light / Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;314;-2354.985,-3798.784;Inherit;False;1114.338;666.9041;;9;185;186;187;183;224;190;189;188;296;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;200;-460.89,-3555.515;Inherit;False;Constant;_Max;Max;12;0;Create;True;0;0;0;False;0;False;2.7;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;-398.002,-3446.679;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-870.5495,-4413.108;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;196;-536.7648,-3739.572;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;307;-854.7023,-4579.459;Inherit;False;306;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;313;-2501.622,-4498.603;Inherit;False;1562.448;611.662;;12;35;38;36;43;44;42;40;41;46;39;70;310;Black Hole;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;317;-3167.849,-3768.489;Inherit;False;479.2825;377.6606;Half Lambert;2;76;152;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-454.9799,-3964.67;Inherit;False;Constant;_MaxShadow;Max Shadow;21;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;124;-597.3216,-4576.889;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-3685.115,-3706.922;Inherit;False;274;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;72;-3672.539,-3611.41;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-2237.539,-4268.348;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;299;-252.371,-3450.619;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-2304.985,-3428.852;Inherit;False;Property;_FresnelBias;Fresnel Bias;10;0;Create;True;0;0;0;False;0;False;0;-0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;244;-404.7121,-4147.277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-2301.265,-3247.881;Inherit;False;Property;_FresnelPower;Fresnel Power;11;0;Create;True;0;0;0;False;0;False;0;2.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;-272.0751,-3739.026;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-2312.974,-3341.366;Inherit;False;Property;_FresnelScale;Fresnel Scale;9;0;Create;True;0;0;0;False;0;False;0;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-459.281,-4046.27;Inherit;False;Constant;_Minshadow;Min shadow;20;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;38;-2248.836,-4442.778;Inherit;False;Property;_BlackHolePosition;Black Hole Position;2;0;Create;True;0;0;0;False;0;False;0,0,0;0,16.06,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;224;-2058.054,-3334.8;Inherit;False;Property;_FresnelIntensity;Fresnel Intensity;15;0;Create;True;0;0;0;False;0;False;0;0.3144474;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-3117.849,-3506.829;Inherit;False;Property;_HalfLambert;Half Lambert;5;0;Create;True;0;0;0;False;0;False;0.55;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;74;-3398.765,-3705.298;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-62.80896,-3739.191;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2446.62,-4091.94;Inherit;False;Property;_Range;Range;1;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;102;-445.6047,-4610.116;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2451.622,-4002.943;Inherit;False;Property;_Effect;Effect;0;0;Create;True;0;0;0;False;0;False;0;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;245;-233.108,-4137.087;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;183;-2085.755,-3557.031;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-73.80085,-3550.923;Inherit;False;Property;_IntensetySpecular;Intensety Specular;13;0;Create;True;0;0;0;False;0;False;0.6515115;0.1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2001.923,-4317.732;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;190;-2107.807,-3748.784;Inherit;False;Property;_ColorFresnel;Color Fresnel;12;0;Create;True;0;0;0;False;0;False;0.4386792,0.7948788,1,0;0.4386792,0.7948788,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;292;-45.21385,-4146.69;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;42;-2132.619,-4123.94;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;40;-1823.307,-4212.771;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;219.1274,-3741.932;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-1750.357,-3673.665;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;86;-3700.178,-4456.316;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;9e47c0b660db86d458e76c64a3720616;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;-2956.566,-3718.489;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;-204.1944,-4614.31;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-2622.762,-3719.54;Inherit;False;SoftLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-3416.259,-4454.438;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-1666.057,-4117.497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-1195.6,-2532.201;Inherit;False;288;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-1170.294,-2447.126;Inherit;False;292;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;188;-1545.979,-3675.594;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;213;366.6705,-3739.34;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;345;-972.444,-2545.841;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-1560.937,-4443.19;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-1196.069,-2691.56;Inherit;False;304;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;301;510.9367,-3746.942;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;296;-1424.646,-3680.862;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;321;-1207.14,-3032.591;Inherit;False;652.3912;276.2451;Comment;3;268;266;265;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;46;-1511.152,-4125.805;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-1189.52,-2613.959;Inherit;False;286;SoftLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1341.393,-4444.052;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;302;-853.1019,-2452.39;Inherit;False;301;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;103;-3697.41,-4264.527;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;3d71c2897a5a39c4d90505b0a9b566d0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;297;-828.8696,-2555.793;Inherit;False;296;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-835.0851,-2685.073;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-1157.14,-2909.122;Inherit;False;Property;_Turningoff;Turning off;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;266;-1094.491,-2982.591;Inherit;False;0;2;2;1,1,1,0;0.7075472,0.7075472,0.7075472,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-541.7899,-2677.848;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-1163.173,-4448.603;Inherit;False;Blackhole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;-3412.272,-4264.785;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;265;-883.7486,-2981.346;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;311;-270.8467,-2684.269;Inherit;False;310;Blackhole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-3011.611,-3970.496;Inherit;False;LightColor_Intensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-280.1542,-3006.481;Inherit;False;305;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;-283.1615,-2810.982;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-80.16676,-3039.956;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BlackHole;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;75;0;71;0
WireConnection;274;0;75;0
WireConnection;278;0;277;1
WireConnection;193;0;191;0
WireConnection;193;1;263;1
WireConnection;306;0;88;0
WireConnection;194;0;193;0
WireConnection;194;1;295;0
WireConnection;243;0;242;0
WireConnection;243;1;241;0
WireConnection;300;0;220;0
WireConnection;300;1;298;0
WireConnection;196;0;194;0
WireConnection;196;1;261;0
WireConnection;124;0;307;0
WireConnection;124;1;109;0
WireConnection;299;0;300;0
WireConnection;244;0;243;0
WireConnection;198;0;196;0
WireConnection;198;1;217;0
WireConnection;198;2;200;0
WireConnection;74;0;276;0
WireConnection;74;1;72;0
WireConnection;219;0;198;0
WireConnection;219;1;299;0
WireConnection;102;1;124;0
WireConnection;245;0;244;0
WireConnection;245;1;290;0
WireConnection;245;2;291;0
WireConnection;183;1;185;0
WireConnection;183;2;186;0
WireConnection;183;3;187;0
WireConnection;36;0;38;0
WireConnection;36;1;35;0
WireConnection;292;0;245;0
WireConnection;42;1;43;0
WireConnection;42;2;44;0
WireConnection;40;0;36;0
WireConnection;201;0;219;0
WireConnection;201;1;202;0
WireConnection;189;0;183;0
WireConnection;189;1;190;0
WireConnection;189;2;224;0
WireConnection;76;0;74;0
WireConnection;76;1;152;0
WireConnection;76;2;152;0
WireConnection;288;0;102;0
WireConnection;286;0;76;0
WireConnection;304;0;86;0
WireConnection;41;0;42;0
WireConnection;41;1;40;0
WireConnection;188;0;189;0
WireConnection;213;0;201;0
WireConnection;345;0;289;0
WireConnection;345;1;294;0
WireConnection;39;1;36;0
WireConnection;301;0;213;0
WireConnection;296;0;188;0
WireConnection;46;0;41;0
WireConnection;70;0;39;0
WireConnection;70;1;46;0
WireConnection;85;0;308;0
WireConnection;85;1;287;0
WireConnection;85;2;345;0
WireConnection;184;0;85;0
WireConnection;184;1;297;0
WireConnection;184;2;302;0
WireConnection;310;0;70;0
WireConnection;305;0;103;0
WireConnection;265;0;266;0
WireConnection;265;1;268;0
WireConnection;283;0;277;2
WireConnection;267;0;265;0
WireConnection;267;1;184;0
WireConnection;0;2;309;0
WireConnection;0;13;267;0
WireConnection;0;11;311;0
ASEEND*/
//CHKSM=806E5F03E8378AB4AA4385EC3FE630BF20F0AE94