// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WarningShader"
{
	Properties
	{
		[Header(Texture)]_TextTexture("Text Texture", 2D) = "white" {}
		[a]_WarningLine("WarningLine", 2D) = "white" {}
		[Header(Variable Color)]_Flashing("Flashing", Float) = 0
		_OpacityCenter("Opacity Center", Range( 0 , 1)) = 0
		[Header(Local Vertex Offset)]_Closing("Closing", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		ColorMask RGB
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _Closing;
		uniform float _Flashing;
		uniform sampler2D _TextTexture;
		uniform sampler2D _WarningLine;
		uniform float _OpacityCenter;


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
			float3 ase_vertex3Pos = v.vertex.xyz;
			v.vertex.xyz += ( float3(0,2,0) * -_Closing * (ase_vertex3Pos.y*0.5 + 0.0) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			Gradient gradient510 = NewGradient( 0, 4, 2, float4( 1, 0.02849725, 0, 0 ), float4( 1, 0.3908732, 0, 0.2735332 ), float4( 1, 0.6806139, 0.1556604, 0.8264744 ), float4( 1, 0.7652577, 0.3820755, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float mulTime505 = _Time.y * 2.0;
			float2 panner463 = ( 1.0 * _Time.y * float2( 0.1,0 ) + i.uv_texcoord);
			float2 TextureCoordinatesText468 = panner463;
			float TextureCoordinatesV473 = i.uv_texcoord.y;
			float4 temp_output_489_0 = ( saturate( tex2D( _TextTexture, TextureCoordinatesText468 ) ) + saturate( ( saturate( ceil( ( abs( ( 1.0 - ( TextureCoordinatesV473 * 2.0 ) ) ) - 0.05 ) ) ) * ( 1.0 - saturate( tex2D( _WarningLine, TextureCoordinatesText468 ).r ) ) ) ) );
			o.Emission = saturate( ( saturate( SampleGradient( gradient510, (sin( ( UNITY_PI + ( mulTime505 * _Flashing ) ) )*0.5 + 0.5) ) ) * temp_output_489_0 ) ).rgb;
			o.Alpha = saturate( ( temp_output_489_0 + _OpacityCenter ) ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows noshadow exclude_path:deferred vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
0;73;1011;618;3332.092;3904.005;4.170485;False;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;465;-3437.977,-3455.117;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;473;-3179.531,-3322.119;Inherit;False;TextureCoordinatesV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;467;-3389.671,-3343.731;Inherit;False;Constant;_Speed;Speed;14;0;Create;True;0;0;0;False;0;False;0.1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;474;-3339.453,-2574.493;Inherit;False;473;TextureCoordinatesV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;-3308.659,-2495.852;Inherit;False;Constant;_LineMask;LineMask;14;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;463;-3190.851,-3455.052;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-3085.659,-2568.852;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;468;-3010.52,-3458.835;Inherit;False;TextureCoordinatesText;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;507;-2676.206,-3006.374;Inherit;False;Constant;_TimeColor;Time Color;14;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;477;-2943.659,-2568.852;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;484;-2996.16,-2374.544;Inherit;False;468;TextureCoordinatesText;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;505;-2519.206,-2998.374;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-2504.207,-2931.374;Inherit;False;Property;_Flashing;Flashing;3;1;[Header];Create;True;1;Variable Color;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;478;-2787.135,-2569.067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-2826.135,-2491.067;Inherit;False;Constant;_Subtract;Subtract;14;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;479;-2664.135,-2569.067;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;503;-2383.266,-3069.802;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;504;-2358.207,-2999.374;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;483;-2715.83,-2396.888;Inherit;True;Property;_WarningLine;WarningLine;1;0;Create;True;0;0;0;False;1;a;False;-1;None;7c5183928e3b06f479a8b36de0e6d794;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;485;-2430.205,-2369.596;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;482;-2522.023,-2569.684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;502;-2213.782,-3068.572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3032.319,-2765.558;Inherit;False;468;TextureCoordinatesText;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;481;-2398.377,-2570.142;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;529;-2284.229,-2372.424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;501;-2102.207,-3068.93;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;509;-2096.786,-2867.083;Inherit;False;Constant;_ScaleOffset;Scale/Offset;15;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;462;-2750.317,-2787.958;Inherit;True;Property;_TextTexture;Text Texture;0;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;e443a296b9fd3fe4a85cfba2243a4c3c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;508;-1894.987,-3069.217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;528;-2107.236,-2571.61;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;510;-1895.724,-3149.528;Inherit;False;0;4;2;1,0.02849725,0,0;1,0.3908732,0,0.2735332;1,0.6806139,0.1556604,0.8264744;1,0.7652577,0.3820755,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SaturateNode;488;-1864.851,-2571.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;511;-1674.473,-3124.258;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;470;-2437.313,-2794.587;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;535;-1356.849,-2252.27;Inherit;False;Property;_Closing;Closing;5;1;[Header];Create;True;1;Local Vertex Offset;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;429;-1324.46,-2169.419;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;444;-1301.511,-2031.269;Inherit;False;Constant;_PointCenter;PointCenter;2;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;534;-1685.071,-2584.584;Inherit;False;Property;_OpacityCenter;Opacity Center;4;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;489;-1624.668,-2800.309;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;514;-1379.386,-3125.676;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;440;-1122.297,-2128.089;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;312;-1311.548,-2405.357;Inherit;False;Constant;_Higher;Higher;0;0;Create;True;0;0;0;False;0;False;0,2,0;0,2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;515;-1219.574,-3128.773;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;438;-1075.055,-2247.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;497;-1393.582,-2799.729;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;-891.5474,-2399.518;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;518;-1006.521,-3129.352;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;496;-1274.582,-2798.729;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-364.1218,-2942.733;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;WarningShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;ForwardOnly;14;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;50;10;25;True;1;False;2;5;False;-1;10;False;-1;0;4;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;24;-1;0;False;18;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;473;0;465;2
WireConnection;463;0;465;0
WireConnection;463;2;467;0
WireConnection;475;0;474;0
WireConnection;475;1;476;0
WireConnection;468;0;463;0
WireConnection;477;0;475;0
WireConnection;505;0;507;0
WireConnection;478;0;477;0
WireConnection;479;0;478;0
WireConnection;479;1;480;0
WireConnection;504;0;505;0
WireConnection;504;1;506;0
WireConnection;483;1;484;0
WireConnection;485;0;483;1
WireConnection;482;0;479;0
WireConnection;502;0;503;0
WireConnection;502;1;504;0
WireConnection;481;0;482;0
WireConnection;529;0;485;0
WireConnection;501;0;502;0
WireConnection;462;1;469;0
WireConnection;508;0;501;0
WireConnection;508;1;509;0
WireConnection;508;2;509;0
WireConnection;528;0;481;0
WireConnection;528;1;529;0
WireConnection;488;0;528;0
WireConnection;511;0;510;0
WireConnection;511;1;508;0
WireConnection;470;0;462;0
WireConnection;489;0;470;0
WireConnection;489;1;488;0
WireConnection;514;0;511;0
WireConnection;440;0;429;2
WireConnection;440;1;444;0
WireConnection;515;0;514;0
WireConnection;515;1;489;0
WireConnection;438;0;535;0
WireConnection;497;0;489;0
WireConnection;497;1;534;0
WireConnection;310;0;312;0
WireConnection;310;1;438;0
WireConnection;310;2;440;0
WireConnection;518;0;515;0
WireConnection;496;0;497;0
WireConnection;0;2;518;0
WireConnection;0;9;496;0
WireConnection;0;11;310;0
ASEEND*/
//CHKSM=BA1AC4DBC9C9D8E293EF1020517CBEC2DD36BF75