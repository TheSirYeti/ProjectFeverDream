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
		_IntensetyHalfLambert("Intensety Half Lambert", Range( 0 , 1)) = 0
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
		uniform float _IntensetyHalfLambert;
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
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 LightColor_Color278 = ase_lightColor.rgb;
			float LightColor_Intensity283 = ase_lightColor.a;
			float3 SoftLight286 = ( (dotResult74*_HalfLambert + _HalfLambert) * LightColor_Color278 * ( LightColor_Intensity283 * _IntensetyHalfLambert ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			float4 Metallic_Smoothness306 = tex2D( _TextureSample2, uv_TextureSample2 );
			float4 temp_cast_2 = (_Smoothness).xxxx;
			float dotResult124 = dot( Metallic_Smoothness306 , temp_cast_2 );
			Unity_GlossyEnvironmentData g102 = UnityGlossyEnvironmentSetup( dotResult124, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular102 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g102 );
			UnityGI gi105 = gi;
			float3 diffNorm105 = ase_worldNormal;
			gi105 = UnityGI_Base( data, 1, diffNorm105 );
			float3 indirectDiffuse105 = gi105.indirect.diffuse + diffNorm105 * 0.0001;
			float3 Sature_Color288 = ( indirectSpecular102 + indirectDiffuse105 );
			float smoothstepResult245 = smoothstep( -0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow292 = smoothstepResult245;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV183 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode183 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV183, _FresnelPower ) );
			float4 Fresnel296 = saturate( ( fresnelNode183 * _ColorFresnel * _FresnelIntensity ) );
			float dotResult194 = dot( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) , WorldNormal274 );
			float smoothstepResult198 = smoothstep( 1.69 , 2.7 , pow( dotResult194 , _Specsomething ));
			float4 Specular301 = saturate( ( ( smoothstepResult198 * saturate( ( _Color1 * float4( LightColor_Color278 , 0.0 ) ) ) ) * _IntensetySpecular ) );
			c.rgb = ( SampleGradient( gradient266, _Turningoff ) * ( ( Albedo304 * float4( SoftLight286 , 0.0 ) * float4( Sature_Color288 , 0.0 ) * Shadow292 ) + Fresnel296 + Specular301 ) ).rgb;
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
0;73;900;655;3466.731;5246.873;5.354458;False;False
Node;AmplifyShaderEditor.CommentaryNode;312;-3735.59,-4602.739;Inherit;False;1229.436;654.4583;;12;71;75;277;274;88;278;306;283;86;304;103;305;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;71;-3210.281,-4358.947;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;0291d380e16205a42be30e7683fae739;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;315;-929.0338,-3808.268;Inherit;False;1941.457;648.8451;;19;191;263;295;193;220;194;261;298;196;217;300;200;299;198;202;219;201;213;301;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;75;-2915.453,-4354.403;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-2730.154,-4358.028;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;277;-3199.872,-4157.243;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightPos;263;-879.0338,-3600.864;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;191;-869.3878,-3754.606;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;88;-3213.956,-4552.739;Inherit;True;Property;_TextureSample2;Texture Sample 2;6;0;Create;True;0;0;0;False;0;False;-1;None;1517a836104074d41b8d6a0f2202c945;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;295;-640.3602,-3570.847;Inherit;False;274;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-642.7131,-3747.313;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-2997.313,-4140.854;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;194;-470.9554,-3746.763;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-424.4573,-3581.288;Inherit;False;Property;_Specsomething;Spec something;17;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-2927.125,-4552.059;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;320;-861.5165,-4228.035;Inherit;False;1085.601;366.446;;8;241;242;243;290;244;291;245;292;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;319;-864.1842,-4610.404;Inherit;False;1169.354;376.009;;7;109;307;124;105;102;107;288;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;-353.0008,-3275.423;Inherit;False;278;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;220;-354.2068,-3461.089;Inherit;False;Property;_Color1;Color 1;14;0;Create;True;0;0;0;False;0;False;0.6933962,0.8990011,1,0;0,0.438499,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;318;-3748.848,-3804.053;Inherit;False;1655.585;741.3115;;10;317;282;285;281;284;72;276;74;84;286;Soft Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;314;-2074.359,-3806.473;Inherit;False;1114.338;666.9041;;9;185;186;187;183;224;190;189;188;296;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;-120.5164,-3458.005;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;200;-183.4044,-3566.841;Inherit;False;Constant;_Max;Max;12;0;Create;True;0;0;0;False;0;False;2.7;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;242;-791.2695,-4178.036;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-186.1783,-3644.087;Inherit;False;Constant;_Min;Min;14;0;Create;True;0;0;0;False;0;False;1.69;1.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;307;-798.3371,-4516.747;Inherit;False;306;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-2997.023,-4064.281;Inherit;False;LightColor_Intensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;317;-3169.892,-3754.053;Inherit;False;479.2825;377.6606;Half Lambert;2;76;152;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-811.5166,-4108.688;Inherit;False;Property;_Shadow;Shadow;16;0;Create;True;0;0;0;False;0;False;0;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;313;-2456.324,-4610.657;Inherit;False;1562.448;611.662;;12;35;38;36;43;44;42;40;41;46;39;70;310;Black Hole;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-814.1843,-4350.396;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;72;-3686.271,-3608.663;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;196;-259.2792,-3750.898;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-3698.848,-3704.175;Inherit;False;274;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;-2918.284,-3252.824;Inherit;False;283;LightColor_Intensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-2020.639,-3255.569;Inherit;False;Property;_FresnelPower;Fresnel Power;11;0;Create;True;0;0;0;False;0;False;0;2.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-495.9527,-4157.878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;124;-540.9564,-4514.177;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;74;-3412.497,-3702.551;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;38;-2203.538,-4554.833;Inherit;False;Property;_BlackHolePosition;Black Hole Position;2;0;Create;True;0;0;0;False;0;False;0,0,0;0.08,11.38,-1.645;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;186;-2032.348,-3349.055;Inherit;False;Property;_FresnelScale;Fresnel Scale;9;0;Create;True;0;0;0;False;0;False;0;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-2192.241,-4380.403;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;282;-2946.759,-3178.742;Inherit;False;Property;_IntensetyHalfLambert;Intensety Half Lambert;19;0;Create;True;0;0;0;False;0;False;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;299;25.11465,-3461.945;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-3119.892,-3492.393;Inherit;False;Property;_HalfLambert;Half Lambert;5;0;Create;True;0;0;0;False;0;False;0.55;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;5.410552,-3750.352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-2024.359,-3436.54;Inherit;False;Property;_FresnelBias;Fresnel Bias;10;0;Create;True;0;0;0;False;0;False;0;-0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;-2958.609,-3704.053;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;190;-1827.181,-3756.473;Inherit;False;Property;_ColorFresnel;Color Fresnel;12;0;Create;True;0;0;0;False;0;False;0.4386792,0.7948788,1,0;0.4386792,0.7948788,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-2401.322,-4203.995;Inherit;False;Property;_Range;Range;1;0;Create;True;0;0;0;False;0;False;0;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;244;-354.9117,-4148.812;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-409.6817,-3976.59;Inherit;False;Constant;_MaxShadow;Max Shadow;21;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-413.9828,-4058.19;Inherit;False;Constant;_Minshadow;Min shadow;20;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2406.324,-4114.995;Inherit;False;Property;_Effect;Effect;0;0;Create;True;0;0;0;False;0;False;0;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;105;-428.8183,-4429.044;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-1956.625,-4429.787;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;202;203.6848,-3562.249;Inherit;False;Property;_IntensetySpecular;Intensety Specular;13;0;Create;True;0;0;0;False;0;False;0.6515115;0.08176471;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-2653.11,-3261.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;102;-411.2397,-4560.404;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;224;-1777.428,-3342.488;Inherit;False;Property;_FresnelIntensity;Fresnel Intensity;15;0;Create;True;0;0;0;False;0;False;0;0.3144474;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;214.6767,-3750.517;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-2916.919,-3326.599;Inherit;False;278;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;183;-1805.129,-3564.72;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-2547.138,-3704.631;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;245;-187.8099,-4149.008;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;86;-3685.59,-4550.103;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;9e47c0b660db86d458e76c64a3720616;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;40;-1778.009,-4324.825;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-1469.731,-3681.353;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;496.613,-3753.258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;42;-2087.321,-4235.995;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-128.2615,-4553.426;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;213;644.1561,-3750.666;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-3401.671,-4548.224;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-1620.759,-4229.552;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;81.17079,-4555.597;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;292;0.08430409,-4158.611;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;188;-1265.353,-3683.283;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-2317.263,-3699.864;Inherit;False;SoftLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;46;-1465.854,-4237.86;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-1186.416,-2929.889;Inherit;False;652.3912;276.2451;Comment;3;268;266;265;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;301;788.4223,-3758.268;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-1142.907,-2246.468;Inherit;False;288;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;296;-1144.02,-3688.55;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-1515.639,-4555.245;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-1140.827,-2326.226;Inherit;False;286;SoftLight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-1141.601,-2164.393;Inherit;False;292;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-1147.376,-2403.827;Inherit;False;304;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-786.3919,-2397.34;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;266;-1073.767,-2879.889;Inherit;False;0;2;2;1,1,1,0;0.7075472,0.7075472,0.7075472,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1296.095,-4556.107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-1136.416,-2806.42;Inherit;False;Property;_Turningoff;Turning off;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;103;-3682.822,-4358.314;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;3d71c2897a5a39c4d90505b0a9b566d0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;302;-648.2363,-2255.561;Inherit;False;301;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-650.004,-2330.964;Inherit;False;296;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-1117.875,-4560.657;Inherit;False;Blackhole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GradientSampleNode;265;-863.0247,-2878.644;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;-3397.684,-4358.572;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-430.0966,-2396.257;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;-99.5838,-2423.337;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-96.57648,-2618.836;Inherit;False;305;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-87.26904,-2296.623;Inherit;False;310;Blackhole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;97.41606,-2664.299;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BlackHole;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;75;0;71;0
WireConnection;274;0;75;0
WireConnection;193;0;191;0
WireConnection;193;1;263;1
WireConnection;278;0;277;1
WireConnection;194;0;193;0
WireConnection;194;1;295;0
WireConnection;306;0;88;0
WireConnection;300;0;220;0
WireConnection;300;1;298;0
WireConnection;283;0;277;2
WireConnection;196;0;194;0
WireConnection;196;1;261;0
WireConnection;243;0;242;0
WireConnection;243;1;241;0
WireConnection;124;0;307;0
WireConnection;124;1;109;0
WireConnection;74;0;276;0
WireConnection;74;1;72;0
WireConnection;299;0;300;0
WireConnection;198;0;196;0
WireConnection;198;1;217;0
WireConnection;198;2;200;0
WireConnection;76;0;74;0
WireConnection;76;1;152;0
WireConnection;76;2;152;0
WireConnection;244;0;243;0
WireConnection;36;0;38;0
WireConnection;36;1;35;0
WireConnection;281;0;285;0
WireConnection;281;1;282;0
WireConnection;102;1;124;0
WireConnection;219;0;198;0
WireConnection;219;1;299;0
WireConnection;183;1;185;0
WireConnection;183;2;186;0
WireConnection;183;3;187;0
WireConnection;84;0;76;0
WireConnection;84;1;284;0
WireConnection;84;2;281;0
WireConnection;245;0;244;0
WireConnection;245;1;290;0
WireConnection;245;2;291;0
WireConnection;40;0;36;0
WireConnection;189;0;183;0
WireConnection;189;1;190;0
WireConnection;189;2;224;0
WireConnection;201;0;219;0
WireConnection;201;1;202;0
WireConnection;42;1;43;0
WireConnection;42;2;44;0
WireConnection;107;0;102;0
WireConnection;107;1;105;0
WireConnection;213;0;201;0
WireConnection;304;0;86;0
WireConnection;41;0;42;0
WireConnection;41;1;40;0
WireConnection;288;0;107;0
WireConnection;292;0;245;0
WireConnection;188;0;189;0
WireConnection;286;0;84;0
WireConnection;46;0;41;0
WireConnection;301;0;213;0
WireConnection;296;0;188;0
WireConnection;39;1;36;0
WireConnection;85;0;308;0
WireConnection;85;1;287;0
WireConnection;85;2;289;0
WireConnection;85;3;294;0
WireConnection;70;0;39;0
WireConnection;70;1;46;0
WireConnection;310;0;70;0
WireConnection;265;0;266;0
WireConnection;265;1;268;0
WireConnection;305;0;103;0
WireConnection;184;0;85;0
WireConnection;184;1;297;0
WireConnection;184;2;302;0
WireConnection;267;0;265;0
WireConnection;267;1;184;0
WireConnection;0;2;309;0
WireConnection;0;13;267;0
WireConnection;0;11;311;0
ASEEND*/
//CHKSM=06C5B2C63FEF944DD004009BC125781798431086