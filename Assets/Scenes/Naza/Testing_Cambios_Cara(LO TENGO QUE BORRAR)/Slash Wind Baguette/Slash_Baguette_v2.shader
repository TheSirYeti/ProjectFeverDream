// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Slash_Baguette_v2"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Main("Main", 2D) = "white" {}
		_Opacity("Opacity", Range( 0 , 20)) = 0
		_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		_SpeedTextureNoise("Speed Texture + Noise", Vector) = (0,0,0,0)
		_Emission("Emission", 2D) = "white" {}
		_EmissionFloat("Emission Float", Range( 0 , 1)) = 0
		_Remap("Remap", Vector) = (0,1,-1,6.18)
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_Vector0("Vector 0", Vector) = (0,-1,0,0)
		_MaskLeft("Mask Left", Float) = 1.68
		_IntensityMaskL("Intensity Mask L", Float) = 4.53
		_MaskRight("Mask Right", Float) = 1.73
		_IntensityMaskR("Intensity Mask R", Float) = 5.11

	}


	Category 
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off 
			ZWrite Off
			ZTest LEqual
			
			Pass {
			
				CGPROGRAM
				
				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"
				#define ASE_NEEDS_FRAG_COLOR


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					float4 ase_texcoord1 : TEXCOORD1;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
				};
				
				
				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				uniform float4 _ShadowColor;
				uniform sampler2D _Emission;
				uniform float2 _Vector0;
				uniform float4 _Remap;
				uniform float _EmissionFloat;
				uniform sampler2D _Main;
				uniform float _Opacity;
				uniform sampler2D _DissolveTexture;
				uniform float4 _SpeedTextureNoise;
				uniform float4 _DissolveTexture_ST;
				uniform float _MaskLeft;
				uniform float _IntensityMaskL;
				uniform float _MaskRight;
				uniform float _IntensityMaskR;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
					float4 screenPos = ComputeScreenPos(ase_clipPos);
					o.ase_texcoord4 = screenPos;
					
					o.ase_texcoord3.xy = v.ase_texcoord1.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord3.zw = 0;

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					float4 RGB_VertexColor103 = i.color;
					float2 texCoord92 = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float X_UV_TextureCoordinates93 = texCoord92.x;
					float2 texCoord71 = i.texcoord.xy * float2( 1,1 ) + ( _Vector0 * ( float2( 0,1 ).x + X_UV_TextureCoordinates93 ) );
					float2 temp_cast_0 = (0.0).xx;
					float2 temp_cast_1 = (1.0).xx;
					float2 clampResult72 = clamp( texCoord71 , temp_cast_0 , temp_cast_1 );
					float2 OffSetMove108 = clampResult72;
					float4 temp_cast_2 = (_Remap.x).xxxx;
					float4 temp_cast_3 = (_Remap.y).xxxx;
					float4 temp_cast_4 = (_Remap.z).xxxx;
					float4 temp_cast_5 = (_Remap.w).xxxx;
					float4 screenPos = i.ase_texcoord4;
					float4 clampResult6 = clamp( ( tex2D( _Main, OffSetMove108 ) * _Opacity ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
					float ALPHA_VertexColor104 = i.color.a;
					float2 appendResult43 = (float2(_SpeedTextureNoise.z , _SpeedTextureNoise.w));
					float4 uvs4_DissolveTexture = i.texcoord;
					uvs4_DissolveTexture.xy = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float2 panner44 = ( 1.0 * _Time.y * appendResult43 + uvs4_DissolveTexture.xy);
					float T_TextureCoordinates34 = uvs4_DissolveTexture.w;
					float4 Dissolve98 = ( tex2D( _DissolveTexture, panner44 ) * saturate( T_TextureCoordinates34 ) );
					float Texcoord_V168 = i.texcoord.xy.y;
					float clampResult145 = clamp( ( saturate( ( 1.0 - ( saturate( ( Texcoord_V168 + ( 1.0 - _MaskLeft ) ) ) * _IntensityMaskL ) ) ) * saturate( ( 1.0 - ( saturate( ( ( 1.0 - Texcoord_V168 ) + ( 1.0 - _MaskRight ) ) ) * _IntensityMaskR ) ) ) ) , 0.0 , 1.0 );
					float Mask_Border171 = saturate( clampResult145 );
					float4 appendResult7 = (float4(( ( _ShadowColor * RGB_VertexColor103 ) + ( saturate( (temp_cast_4 + (tex2D( _Emission, OffSetMove108 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)) ) * _EmissionFloat * RGB_VertexColor103 ) ).rgb , ( screenPos.y * ( clampResult6 * ALPHA_VertexColor104 * Dissolve98 * Mask_Border171 ) ).r));
					

					fixed4 col = appendResult7;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;775;497;1324.017;743.5183;2.112059;True;False
Node;AmplifyShaderEditor.CommentaryNode;178;-3048.606,875.5928;Inherit;False;2455.296;693.2451;;25;169;142;139;173;174;177;137;144;163;165;166;171;145;170;175;150;152;146;162;176;148;160;161;136;168;Mask Border;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;136;-2998.606,937.2269;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;111;-3466.856,-471.4243;Inherit;False;1484.217;710.504;Comment;14;63;65;92;93;68;71;67;72;73;74;108;129;132;182;Offset movement;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-2797.999,978.7729;Inherit;False;Texcoord_V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-2554.899,1009.55;Inherit;False;Property;_MaskLeft;Mask Left;9;0;Create;True;0;0;0;False;0;False;1.68;1.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-2606.23,1307.521;Inherit;False;Property;_MaskRight;Mask Right;11;0;Create;True;0;0;0;False;0;False;1.73;1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2605.106,1225.174;Inherit;False;168;Texcoord_V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;92;-3222.936,50.55055;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;152;-2434.276,1229.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;142;-2410.907,1015.546;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;150;-2437.217,1309.162;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;63;-3341.847,-284.2174;Inherit;False;Constant;_MoveVector;Move Vector;5;0;Create;True;0;0;0;False;0;False;0,1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2977.811,122.0552;Inherit;False;X_UV_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-2474.034,927.089;Inherit;False;168;Texcoord_V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;-2257.907,929.546;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;-2278.374,1229.013;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-3370.981,-128.8152;Inherit;False;93;X_UV_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;65;-3172.204,-238.9366;Inherit;False;FLOAT;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-3015.889,-194.9704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;132;-3348.486,-412.1969;Inherit;False;Property;_Vector0;Vector 0;8;0;Create;True;0;0;0;False;0;False;0,-1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;176;-2228.8,1452.838;Inherit;False;Property;_IntensityMaskR;Intensity Mask R;12;0;Create;True;0;0;0;False;0;False;5.11;3.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;162;-2074.424,1229.034;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-2257.624,1144.544;Inherit;False;Property;_IntensityMaskL;Intensity Mask L;10;0;Create;True;0;0;0;False;0;False;4.53;1.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;177;-2052.718,929.3281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-2933.569,-408.0262;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1943.108,1227.309;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-2668.054,331.3877;Inherit;False;2091.692;470.8356;Comment;11;34;33;32;43;44;11;41;14;38;98;135;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1914.102,928.2969;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2789.961,-297.5877;Inherit;False;Constant;_ClampOffsetMin;Clamp Offset Min;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2788.378,-221.8583;Inherit;False;Constant;_ClampOffsetMax;Clamp Offset Max;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;41;-2618.054,381.3877;Inherit;False;Property;_SpeedTextureNoise;Speed Texture + Noise;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-2431.903,570.3367;Inherit;False;0;11;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;144;-1713.891,929.5791;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;160;-1734.291,1227.103;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;71;-2800.17,-424.9113;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;163;-1549.585,930.1436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2144.957,686.2233;Inherit;False;T_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;72;-2522.914,-418.2929;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-2325.087,457.3894;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;161;-1584.79,1226.49;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;44;-2151.005,435.8017;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-2375.676,-423.5372;Inherit;False;OffSetMove;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1861.023,612.0827;Inherit;False;34;T_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-1310.091,930.802;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1935.729,-789.7342;Inherit;False;1326.277;1030.194;Comment;19;2;4;3;6;51;54;52;58;60;106;61;102;103;104;110;109;57;107;56;Texture Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-1897.172,-439.4369;Inherit;False;108;OffSetMove;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;-1917.053,407.49;Inherit;True;Property;_DissolveTexture;Dissolve Texture;2;0;Create;True;0;0;0;False;0;False;-1;None;6bf57f43cb88827429a6d6acbed2197f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;135;-1606.94,565.0997;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;145;-1092.845,930.803;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1877.917,-59.37231;Inherit;False;108;OffSetMove;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;166;-943.5759,930.2053;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1583.006,433.0845;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;51;-1703.523,-475.0055;Inherit;True;Property;_Emission;Emission;4;0;Create;True;0;0;0;False;0;False;-1;None;f3b03ac87c18f4244a7086e9788910fe;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;54;-1590.764,-271.9765;Inherit;False;Property;_Remap;Remap;6;0;Create;True;0;0;0;False;0;False;0,1,-1,6.18;0,1,-1,6.18;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;102;-1685.17,-719.1654;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1679.082,-79.60471;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;0;False;0;False;-1;None;6898645bab901c843a9ebdaed1c8869b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1648.716,124.46;Inherit;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;0;False;0;False;0;6;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1513.443,-629.1301;Inherit;False;ALPHA_VertexColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1509.787,-724.4974;Inherit;False;RGB_VertexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-817.3061,925.5928;Inherit;False;Mask_Border;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1415.927,433.4969;Inherit;False;Dissolve;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1348.583,-71.09934;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;52;-1332.225,-470.7418;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-599.2181,-12.84231;Inherit;False;104;ALPHA_VertexColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-1160.403,-557.3598;Inherit;False;103;RGB_VertexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;60;-1181.345,-739.7342;Inherit;False;Property;_ShadowColor;Shadow Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;100;-589.6168,72.52568;Inherit;False;98;Dissolve;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-591.7125,171.4485;Inherit;False;171;Mask_Border;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1134.702,-389.0732;Inherit;False;Property;_EmissionFloat;Emission Float;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;6;-1199.267,-70.65625;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;58;-1133.317,-471.1171;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1136.798,-293.378;Inherit;False;103;RGB_VertexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;113;-430.4375,-379.3121;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-883.315,-733.9821;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-771.4517,-472.5589;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-334.7973,-72.556;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-198.4133,-313.4858;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-321.5305,-503.4401;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-131.7338,-504.8749;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-2145.957,597.2238;Inherit;False;W_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-2960.217,45.75964;Inherit;False;UV_TextureCoordinates;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;23.09528,-509.6216;Float;False;True;-1;2;ASEMaterialInspector;0;7;Slash_Baguette_v2;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;168;0;136;2
WireConnection;152;0;170;0
WireConnection;142;0;173;0
WireConnection;150;0;175;0
WireConnection;93;0;92;1
WireConnection;139;0;169;0
WireConnection;139;1;142;0
WireConnection;146;0;152;0
WireConnection;146;1;150;0
WireConnection;65;0;63;0
WireConnection;67;0;65;0
WireConnection;67;1;129;0
WireConnection;162;0;146;0
WireConnection;177;0;139;0
WireConnection;68;0;132;0
WireConnection;68;1;67;0
WireConnection;148;0;162;0
WireConnection;148;1;176;0
WireConnection;137;0;177;0
WireConnection;137;1;174;0
WireConnection;144;0;137;0
WireConnection;160;0;148;0
WireConnection;71;1;68;0
WireConnection;163;0;144;0
WireConnection;34;0;32;4
WireConnection;72;0;71;0
WireConnection;72;1;73;0
WireConnection;72;2;74;0
WireConnection;43;0;41;3
WireConnection;43;1;41;4
WireConnection;161;0;160;0
WireConnection;44;0;32;0
WireConnection;44;2;43;0
WireConnection;108;0;72;0
WireConnection;165;0;163;0
WireConnection;165;1;161;0
WireConnection;11;1;44;0
WireConnection;135;0;38;0
WireConnection;145;0;165;0
WireConnection;166;0;145;0
WireConnection;14;0;11;0
WireConnection;14;1;135;0
WireConnection;51;1;109;0
WireConnection;2;1;110;0
WireConnection;104;0;102;4
WireConnection;103;0;102;0
WireConnection;171;0;166;0
WireConnection;98;0;14;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;52;0;51;0
WireConnection;52;1;54;1
WireConnection;52;2;54;2
WireConnection;52;3;54;3
WireConnection;52;4;54;4
WireConnection;6;0;3;0
WireConnection;58;0;52;0
WireConnection;61;0;60;0
WireConnection;61;1;106;0
WireConnection;56;0;58;0
WireConnection;56;1;57;0
WireConnection;56;2;107;0
WireConnection;8;0;6;0
WireConnection;8;1;105;0
WireConnection;8;2;100;0
WireConnection;8;3;172;0
WireConnection;114;0;113;2
WireConnection;114;1;8;0
WireConnection;62;0;61;0
WireConnection;62;1;56;0
WireConnection;7;0;62;0
WireConnection;7;3;114;0
WireConnection;33;0;32;3
WireConnection;182;0;92;0
WireConnection;1;0;7;0
ASEEND*/
//CHKSM=5281373DDA5F95CCA0850202EA6090F008149042