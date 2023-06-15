// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole_HEAD"
{
	Properties
	{
		[Header(Texture)]_Albedo("Albedo", 2D) = "white" {}
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
		_FresnelIntesity("Fresnel Intesity", Range( 0 , 1)) = 0.3
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		[Header(Gradient)]_TurningOFF("Turning OFF", Range( 0 , 1)) = 0
		_BlackHolePosition("Black Hole Position", Vector) = (0,0,0,0)
		_ValueWarning("Value Warning", Range( 0 , 1)) = 1
		_Speed("Speed", Float) = 0.1
		_Head_MASK("Head_MASK", 2D) = "white" {}
		[HDR]_ColorFace("Color Face", Color) = (0,0,0,0)
		_Warningposition("Warning position", Vector) = (1,1,1,0)
		[IntRange]_ControlFace("Control Face", Range( 0 , 3)) = 0
		_StaticChangeFace("Static Change Face", Range( 0 , 10)) = 0
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
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
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
		uniform float _ValueWarning;
		uniform float3 _Warningposition;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _ColorFace;
		uniform sampler2D _Head_MASK;
		uniform float _ControlFace;
		uniform float _StaticChangeFace;
		uniform float _TurningOFF;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _MetallicSmoothness;
		uniform float4 _MetallicSmoothness_ST;
		uniform float _Smoothness;
		uniform float _Shadow;
		uniform float _Specularsomething;
		uniform float _IntensitySpecular;
		uniform float4 _ColorSpecular;
		uniform float4 _ColorFresnel;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FresnelIntesity;


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
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_output_517_0 = ( _BlackHolePosition - ase_worldPos );
			float lerpResult521 = lerp( 0.0 , _Range , _Effect);
			float clampResult557 = clamp( ( lerpResult521 - length( temp_output_517_0 ) ) , 0.0 , 1.0 );
			float3 lerpResult523 = lerp( float3( 0,0,0 ) , ( float3( 0,0,0 ) + temp_output_517_0 ) , clampResult557);
			float3 worldToObjDir562 = mul( unity_WorldToObject, float4( lerpResult523, 0 ) ).xyz;
			float3 BlackHole394 = worldToObjDir562;
			float3 ase_vertexNormal = v.normal.xyz;
			float mulTime604 = _Time.y * _Speed;
			float3 OffsetWarning643 = ( ( ase_vertexNormal * sin( ( ( v.texcoord.xy.y + mulTime604 ) * ( _ValueWarning * 500.0 ) ) ) ) * _Warningposition * 1.0 );
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
			float3 temp_cast_4 = (_TurningOFF).xxx;
			float grayscale462 = Luminance(temp_cast_4);
			float Gradient432 = grayscale462;
			float2 _MoveFace = float2(1,0);
			float2 uv_TexCoord759 = i.uv_texcoord + float2( 0.5,0.5 );
			float2 temp_cast_6 = (uv_TexCoord759.y).xx;
			float2 panner802 = ( _Time.y * float2( 0,2 ) + temp_cast_6);
			float simplePerlin2D761 = snoise( panner802*_StaticChangeFace );
			simplePerlin2D761 = simplePerlin2D761*0.5 + 0.5;
			float2 uv_TexCoord664 = i.uv_texcoord * ( float2( 0,0.75 ) + 0.25 ) + ( ( 0.25 * _MoveFace * ( ( _MoveFace + float2( -1,0 ) ).x + _ControlFace ) ) + (( simplePerlin2D761 * 0.1 )*0.5 + float2( -0.025,0 ).x) );
			float4 temp_output_660_0 = saturate( ( saturate( _ColorFace ) * tex2D( _Head_MASK, uv_TexCoord664 ) ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo355 = ( temp_output_660_0 + tex2D( _Albedo, uv_Albedo ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 WorldNormalBueno573 = ase_worldNormal;
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
			float3 HalfLambert445 = saturate( ( (dotResult440*0.5 + 0.5) * ase_lightColor.rgb * ase_lightColor.a ) );
			float2 uv_MetallicSmoothness = i.uv_texcoord * _MetallicSmoothness_ST.xy + _MetallicSmoothness_ST.zw;
			float4 Metallic_Smoothness357 = tex2D( _MetallicSmoothness, uv_MetallicSmoothness );
			float4 temp_cast_9 = (_Smoothness).xxxx;
			float dotResult367 = dot( Metallic_Smoothness357 , temp_cast_9 );
			Unity_GlossyEnvironmentData g369 = UnityGlossyEnvironmentSetup( dotResult367, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular369 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g369 );
			float3 Sature_Color370 = indirectSpecular369;
			float smoothstepResult376 = smoothstep( 0.5 , 1.0 , saturate( ( ase_lightAtten + _Shadow ) ));
			float Shadow379 = smoothstepResult376;
			float3 WorldNormal356 = ase_worldNormal;
			float dotResult399 = dot( ( i.viewDir + ase_worldlightDir ) , WorldNormal356 );
			float smoothstepResult403 = smoothstep( 1.69 , 2.7 , pow( dotResult399 , _Specularsomething ));
			float3 LightColor_Color363 = ase_lightColor.rgb;
			float4 Specular416 = ( ( smoothstepResult403 * _IntensitySpecular ) * saturate( ( _ColorSpecular * float4( LightColor_Color363 , 0.0 ) ) ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV421 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode421 = ( -0.13 + _FresnelScale * pow( 1.0 - fresnelNdotV421, _FresnelPower ) );
			float4 Fresnel426 = saturate( ( _ColorFresnel * fresnelNode421 * _FresnelIntesity ) );
			float fresnelNdotV592 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode592 = ( 0.0 + 1.51 * pow( 1.0 - fresnelNdotV592, 1.86 ) );
			float4 color591 = IsGammaSpace() ? float4(1,0,0.008883953,0) : float4(1,0,0.0006876125,0);
			float4 FresnelWarning638 = ( saturate( ( fresnelNode592 * color591 ) ) * _ValueWarning );
			c.rgb = ( Gradient432 * ( ( Albedo355 * float4( HalfLambert445 , 0.0 ) * float4( ( Sature_Color370 + Shadow379 ) , 0.0 ) ) + Specular416 + Fresnel426 + FresnelWarning638 ) ).rgb;
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
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float2 _MoveFace = float2(1,0);
			float2 uv_TexCoord759 = i.uv_texcoord + float2( 0.5,0.5 );
			float2 temp_cast_1 = (uv_TexCoord759.y).xx;
			float2 panner802 = ( _Time.y * float2( 0,2 ) + temp_cast_1);
			float simplePerlin2D761 = snoise( panner802*_StaticChangeFace );
			simplePerlin2D761 = simplePerlin2D761*0.5 + 0.5;
			float2 uv_TexCoord664 = i.uv_texcoord * ( float2( 0,0.75 ) + 0.25 ) + ( ( 0.25 * _MoveFace * ( ( _MoveFace + float2( -1,0 ) ).x + _ControlFace ) ) + (( simplePerlin2D761 * 0.1 )*0.5 + float2( -0.025,0 ).x) );
			float4 temp_output_660_0 = saturate( ( saturate( _ColorFace ) * tex2D( _Head_MASK, uv_TexCoord664 ) ) );
			float4 Head_Mask658 = temp_output_660_0;
			float4 Emission358 = ( tex2D( _Emission, uv_Emission ) + Head_Mask658 );
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
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
544;73;999;582;5630.554;4189.789;2.232961;True;False
Node;AmplifyShaderEditor.CommentaryNode;805;-5029.79,-4256.835;Inherit;False;1992.826;937.0022;Comment;20;669;668;672;741;707;743;739;742;718;796;759;760;803;802;763;761;793;767;789;664;Change Face;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;759;-4979.79,-3801.803;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0.5,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;803;-4742.625,-3527.731;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;707;-4198.82,-3997.418;Inherit;False;Constant;_MoveFace;Move Face;19;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;760;-4772.221,-3800.461;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PannerNode;802;-4526.472,-3707.04;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;743;-4031.635,-3917.141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;763;-4687.576,-3435.832;Inherit;False;Property;_StaticChangeFace;Static Change Face;22;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-4090.635,-3768.142;Inherit;False;Property;_ControlFace;Control Face;21;1;[IntRange];Create;True;0;0;0;False;0;False;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;739;-3891.39,-3919.142;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;761;-4351.36,-3685.587;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;742;-3768.635,-3923.142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;767;-4089.151,-3682.869;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;669;-3876.482,-4075.144;Inherit;False;Constant;_PointOffset;Point Offset;21;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;804;-2940.653,-4472.757;Inherit;False;1500.909;1246.833;Comment;22;359;572;356;573;352;729;360;357;363;731;654;730;350;660;657;355;658;353;661;358;659;364;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;793;-3874.524,-3598.273;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;0;False;0;False;-0.025,0;-0.025,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;789;-3705.357,-3682.119;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;417;-344.586,-3830.873;Inherit;False;1901.797;623;;18;404;405;403;406;408;409;410;400;399;397;401;412;414;413;416;407;508;569;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;572;-2124.888,-3595.161;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;359;-2126.406,-3443.903;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;668;-3873.893,-4206.835;Inherit;False;Constant;_Tilling;Tilling;21;0;Create;True;0;0;0;False;0;False;0,0.75;0,0.75;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-3619.472,-4025.655;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-1935.406,-3446.903;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;569;-301.4585,-3784.279;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;650;-3013.396,-2418.868;Inherit;False;2061.161;932.0416;;22;602;590;605;604;600;595;591;636;603;592;593;601;594;629;599;648;632;626;649;638;647;643;Heavy attack JP;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;564;-3005.53,-3096.815;Inherit;False;1649.081;545.574;;13;516;515;388;517;389;521;519;520;558;557;523;562;394;BlackHole;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;380;-1353.211,-3527.701;Inherit;False;954.9435;342;;8;373;374;375;372;376;378;377;379;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;796;-3448.902,-4030.087;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;508;-312.6913,-3586.804;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;672;-3654.566,-4180.335;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;573;-1933.888,-3598.161;Inherit;False;WorldNormalBueno;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;446;-183.6244,-2798.845;Inherit;False;834;316;;7;442;440;441;439;443;474;470;Half Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;352;-2661.175,-3455.924;Inherit;True;Property;_MetallicSmoothness;Metallic Smoothness;1;0;Create;True;0;0;0;False;0;False;-1;None;2e233506deb0fdb479a9ee59ed045b37;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;441;-133.6244,-2665.845;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;602;-2797.006,-1723.464;Inherit;False;Property;_Speed;Speed;17;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-132.6244,-2748.845;Inherit;False;573;WorldNormalBueno;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;516;-2925.086,-2905.517;Inherit;False;Property;_BlackHolePosition;Black Hole Position;15;0;Create;True;0;0;0;False;0;False;0,0,0;-5.453,7.94,17.419;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;397;-53.91708,-3775.732;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-1303.211,-3382.204;Inherit;False;Property;_Shadow;Shadow;4;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;-2371.424,-3455.013;Inherit;False;Metallic_Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;664;-3278.964,-4137.794;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;515;-2922.906,-3046.815;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;360;-1859.614,-3884.272;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;372;-1213.611,-3472.504;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;371;-1364.557,-3844.317;Inherit;False;898.2434;267.1379;;5;367;369;370;366;368;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;729;-2890.653,-4422.757;Inherit;False;Property;_ColorFace;Color Face;19;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;400;-55.51595,-3673.86;Inherit;False;356;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;443;70.3755,-2603.845;Inherit;False;Constant;_HalfLambert;HalfLambert;16;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;36.21091,-3589.873;Inherit;False;Property;_Specularsomething;Specular something;8;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;731;-2645.354,-4290.895;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;399;150.9835,-3775.539;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;517;-2658.405,-2953.571;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;590;-2963.396,-2222.444;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;1.86;1.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;374;-1028.012,-3474.404;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-2955.53,-2671.8;Inherit;False;Property;_Effect;Effect;6;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;604;-2615.411,-1724.741;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;654;-2848.072,-4174.532;Inherit;True;Property;_Head_MASK;Head_MASK;18;0;Create;True;0;0;0;False;0;False;-1;None;1af0e5fd342c8ae458ef5cb4b99cfc9a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;366;-1279.364,-3792.105;Inherit;False;357;Metallic_Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;595;-2962.994,-2305.189;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;1.51;1.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;600;-2671.981,-1883.625;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-1685.097,-3866.007;Inherit;False;LightColor_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-1314.557,-3693.179;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;427;-1316.803,-3118.129;Inherit;False;1104.624;546.2673;;9;421;423;419;420;424;425;422;426;461;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;440;88.37548,-2744.845;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;605;-2741.909,-1622.901;Inherit;False;Property;_ValueWarning;Value Warning;16;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2953.129,-2748.199;Inherit;False;Property;_Range;Range;5;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;592;-2768.517,-2362.918;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1010.269,-3376.701;Inherit;False;Constant;_Minshadow;Min shadow;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;521;-2509.552,-2710.241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;519;-2421.502,-2855.362;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;144.2109,-3323.873;Inherit;False;363;LightColor_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;730;-2504.06,-4190.307;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;442;231.3755,-2745.845;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;470;275.4141,-2629.26;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;404;294.7661,-3681.14;Inherit;False;Constant;_Min;Min;11;0;Create;True;0;0;0;False;0;False;1.69;1.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;367;-1042.557,-3790.179;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;591;-2683.409,-2097.531;Inherit;False;Constant;_ColorWaring;Color Waring;2;0;Create;True;0;0;0;False;0;False;1,0,0.008883953,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;423;-1264.972,-2831.33;Inherit;False;Property;_FresnelScale;Fresnel Scale;12;0;Create;True;0;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;378;-1013.269,-3301.701;Inherit;False;Constant;_Maxshadow;Max shadow;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;603;-2419.605,-1879.618;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;-1266.803,-2754.247;Inherit;False;Property;_FresnelPower;Fresnel Power;13;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;401;295.5475,-3776.109;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;405;298.541,-3605.072;Inherit;False;Constant;_Max;Max;9;0;Create;True;0;0;0;False;0;False;2.7;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;-2306.339,-1621.826;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;375;-910.2689,-3474.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;407;134.2109,-3492.873;Inherit;False;Property;_ColorSpecular;Color Specular;7;2;[HDR];[Header];Create;True;1;Specular;0;0;False;0;False;0,0,0,0;0.2249911,0.3790293,0.6037736,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;422;-1260.803,-2908.997;Inherit;False;Constant;_FresnelBias;Fresnel Bias;13;0;Create;True;0;0;0;False;0;False;-0.13;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;511.0256,-2748.346;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;593;-2438.434,-2362.336;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;376;-776.7776,-3477.872;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;660;-2357.98,-4184.027;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;403;484.1436,-3775.836;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;350;-2653.418,-3955.738;Inherit;True;Property;_Albedo;Albedo;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;228b0a530496c8e42a9dbfd790930574;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;520;-2279.427,-2738.814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;368.2109,-3487.873;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;421;-1079.831,-2894.61;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;369;-919.5418,-3791.177;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;414;488.719,-3639.414;Inherit;False;Property;_IntensitySpecular;Intensity Specular;9;0;Create;True;0;0;0;False;0;False;0.1;0.15;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;601;-2146.701,-1876.302;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;461;-1075.326,-3073.856;Inherit;False;Property;_ColorFresnel;Color Fresnel;10;2;[HDR];[Header];Create;True;1;Fresnel;0;0;False;0;False;0,0,0,0;0.4392157,0.7960785,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;-1072.221,-2687.862;Inherit;False;Property;_FresnelIntesity;Fresnel Intesity;11;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-2348.102,-2977.707;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-804.5872,-3062.504;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;-622.2687,-3477.701;Inherit;False;Shadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;410;514.2111,-3487.873;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;370;-673.3133,-3798.317;Inherit;False;Sature_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;599;-1922.655,-1878.148;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;629;-1925.22,-2072.175;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;433;-185.0577,-3133.511;Inherit;False;876.2718;277.7463;;3;430;432;462;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;557;-2108.115,-2802.892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;487;875.4617,-2738.446;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;743.4684,-3777.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;594;-2200.154,-2362.725;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;657;-2179.736,-3982.819;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;523;-2000.855,-3002.213;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-1615.665,-1623.398;Inherit;False;Constant;_WarningMultiply;Warning Multiply;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;450;-233.7009,-2087.802;Inherit;False;370;Sature_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;1053.479,-2741.928;Inherit;False;HalfLambert;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;632;-1970.847,-2363.035;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;658;-2197.877,-4183.504;Inherit;False;Head_Mask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;626;-1646.409,-1995.075;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-2057.768,-3979.576;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-230.7008,-2009.803;Inherit;False;379;Shadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;425;-575.1487,-3063.399;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-135.0577,-2998.083;Inherit;False;Property;_TurningOFF;Turning OFF;14;1;[Header];Create;True;1;Gradient;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;1002.211,-3776.873;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;648;-1636.098,-1782.786;Inherit;False;Property;_Warningposition;Warning position;20;0;Create;True;0;0;0;False;0;False;1,1,1;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;562;-1810.604,-3004.563;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;638;-1693.455,-2368.868;Inherit;False;FresnelWarning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-96.5332,-2187.365;Inherit;False;445;HalfLambert;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;647;-1359.724,-1994.612;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;1175.558,-3769.942;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-93.10538,-2264.583;Inherit;False;355;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;452;-18.3176,-2085.091;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCGrayscale;462;216.3151,-3025.466;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;-436.1783,-3068.129;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;661;-2478.205,-3560.057;Inherit;False;658;Head_Mask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;353;-2653.475,-3752.812;Inherit;True;Property;_Emission;Emission;2;0;Create;True;0;0;0;False;0;False;-1;None;b5ff3d9dc192ef2438f37d643b149540;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;457;113.6109,-1901.247;Inherit;False;426;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;161.8818,-2194.354;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-1176.235,-1999.701;Inherit;False;OffsetWarning;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;108.6298,-1987.629;Inherit;False;416;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;639;114.6494,-1815.271;Inherit;False;638;FresnelWarning;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;659;-2242.362,-3746.237;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;432;467.2141,-3083.511;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-1580.449,-3001.445;Inherit;False;BlackHole;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;485.8032,-1931.023;Inherit;False;643;OffsetWarning;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-2089.618,-3753.148;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;500.8169,-2022.096;Inherit;False;394;BlackHole;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;459;340.2159,-2268.416;Inherit;False;432;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;488;354.142,-2071.5;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-1684.744,-3788.461;Inherit;False;LightColor_Intesity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;458;535.1703,-2212.339;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;640;724.0079,-2011.781;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;593.3907,-2415.447;Inherit;False;358;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;869.3417,-2459.684;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;BlackHole_HEAD;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;760;0;759;0
WireConnection;802;0;760;1
WireConnection;802;1;803;0
WireConnection;743;0;707;0
WireConnection;739;0;743;0
WireConnection;761;0;802;0
WireConnection;761;1;763;0
WireConnection;742;0;739;0
WireConnection;742;1;741;0
WireConnection;767;0;761;0
WireConnection;789;0;767;0
WireConnection;789;2;793;0
WireConnection;718;0;669;0
WireConnection;718;1;707;0
WireConnection;718;2;742;0
WireConnection;356;0;359;0
WireConnection;796;0;718;0
WireConnection;796;1;789;0
WireConnection;672;0;668;0
WireConnection;672;1;669;0
WireConnection;573;0;572;0
WireConnection;397;0;569;0
WireConnection;397;1;508;0
WireConnection;357;0;352;0
WireConnection;664;0;672;0
WireConnection;664;1;796;0
WireConnection;731;0;729;0
WireConnection;399;0;397;0
WireConnection;399;1;400;0
WireConnection;517;0;516;0
WireConnection;517;1;515;0
WireConnection;374;0;372;0
WireConnection;374;1;373;0
WireConnection;604;0;602;0
WireConnection;654;1;664;0
WireConnection;363;0;360;1
WireConnection;440;0;439;0
WireConnection;440;1;441;0
WireConnection;592;2;595;0
WireConnection;592;3;590;0
WireConnection;521;1;388;0
WireConnection;521;2;389;0
WireConnection;519;0;517;0
WireConnection;730;0;731;0
WireConnection;730;1;654;0
WireConnection;442;0;440;0
WireConnection;442;1;443;0
WireConnection;442;2;443;0
WireConnection;367;0;366;0
WireConnection;367;1;368;0
WireConnection;603;0;600;2
WireConnection;603;1;604;0
WireConnection;401;0;399;0
WireConnection;401;1;412;0
WireConnection;636;0;605;0
WireConnection;375;0;374;0
WireConnection;474;0;442;0
WireConnection;474;1;470;1
WireConnection;474;2;470;2
WireConnection;593;0;592;0
WireConnection;593;1;591;0
WireConnection;376;0;375;0
WireConnection;376;1;377;0
WireConnection;376;2;378;0
WireConnection;660;0;730;0
WireConnection;403;0;401;0
WireConnection;403;1;404;0
WireConnection;403;2;405;0
WireConnection;520;0;521;0
WireConnection;520;1;519;0
WireConnection;408;0;407;0
WireConnection;408;1;409;0
WireConnection;421;1;422;0
WireConnection;421;2;423;0
WireConnection;421;3;424;0
WireConnection;369;1;367;0
WireConnection;601;0;603;0
WireConnection;601;1;636;0
WireConnection;558;1;517;0
WireConnection;420;0;461;0
WireConnection;420;1;421;0
WireConnection;420;2;419;0
WireConnection;379;0;376;0
WireConnection;410;0;408;0
WireConnection;370;0;369;0
WireConnection;599;0;601;0
WireConnection;557;0;520;0
WireConnection;487;0;474;0
WireConnection;406;0;403;0
WireConnection;406;1;414;0
WireConnection;594;0;593;0
WireConnection;657;0;660;0
WireConnection;657;1;350;0
WireConnection;523;1;558;0
WireConnection;523;2;557;0
WireConnection;445;0;487;0
WireConnection;632;0;594;0
WireConnection;632;1;605;0
WireConnection;658;0;660;0
WireConnection;626;0;629;0
WireConnection;626;1;599;0
WireConnection;355;0;657;0
WireConnection;425;0;420;0
WireConnection;413;0;406;0
WireConnection;413;1;410;0
WireConnection;562;0;523;0
WireConnection;638;0;632;0
WireConnection;647;0;626;0
WireConnection;647;1;648;0
WireConnection;647;2;649;0
WireConnection;416;0;413;0
WireConnection;452;0;450;0
WireConnection;452;1;451;0
WireConnection;462;0;430;0
WireConnection;426;0;425;0
WireConnection;454;0;448;0
WireConnection;454;1;449;0
WireConnection;454;2;452;0
WireConnection;643;0;647;0
WireConnection;659;0;353;0
WireConnection;659;1;661;0
WireConnection;432;0;462;0
WireConnection;394;0;562;0
WireConnection;358;0;659;0
WireConnection;488;0;454;0
WireConnection;488;1;503;0
WireConnection;488;2;457;0
WireConnection;488;3;639;0
WireConnection;364;0;360;2
WireConnection;458;0;459;0
WireConnection;458;1;488;0
WireConnection;640;0;460;0
WireConnection;640;1;644;0
WireConnection;0;2;447;0
WireConnection;0;13;458;0
WireConnection;0;11;640;0
ASEEND*/
//CHKSM=51BB3EF681071ABD861A096C5DCE4DF2015D2008