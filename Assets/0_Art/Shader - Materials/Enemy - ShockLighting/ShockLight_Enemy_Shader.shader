// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ShockLight_Enemy_Shader"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Slider("Slider", Range( 0 , 1)) = 0
		_Speed("Speed", Float) = 0
		_TextureSample1("Texture Sample 1", 2D) = "white" {}

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
				uniform sampler2D _TextureSample0;
				uniform float _Speed;
				uniform float _Slider;
				uniform sampler2D _TextureSample1;
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
				


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
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

					Gradient gradient32 = NewGradient( 0, 5, 2, float4( 0.4339623, 0.1253669, 0, 0 ), float4( 0.7075472, 0.2021564, 0, 0.08824293 ), float4( 0.9709716, 0.3938324, 0.00119438, 0.2764782 ), float4( 0.9979265, 0.7904897, 0.5913919, 0.4941176 ), float4( 1, 0.9556705, 0.9103774, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
					float mulTime42 = _Time.y * _Speed;
					float2 texCoord36 = i.texcoord.xy * float2( 1,1 ) + ( float2( 1,0 ) * mulTime42 );
					float4 tex2DNode1 = tex2D( _TextureSample0, texCoord36 );
					float4 temp_cast_1 = (( 1.0 - _Slider )).xxxx;
					float4 temp_output_19_0 = saturate( ( 1.0 - step( tex2DNode1 , temp_cast_1 ) ) );
					float2 texCoord52 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float2 texCoord62 = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float4 temp_cast_3 = (texCoord62.x).xxxx;
					float4 appendResult48 = (float4(saturate( ( SampleGradient( gradient32, tex2DNode1.r ) * temp_output_19_0 ) ).rgb , ( temp_output_19_0 * saturate( ceil( ( tex2D( _TextureSample1, texCoord52 ) - temp_cast_3 ) ) ) ).r));
					

					fixed4 col = appendResult48;
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
993;73;649;617;1371.888;831.4401;1.3;False;False
Node;AmplifyShaderEditor.RangedFloatNode;40;-2191.184,-307.142;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;39;-2091.184,-449.142;Inherit;False;Constant;_MoveVector;MoveVector;2;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;42;-2036.089,-302.0785;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1835.184,-346.142;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-1653.782,-392.8322;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1405.049,-168.5772;Inherit;False;Property;_Slider;Slider;1;0;Create;True;0;0;0;False;0;False;0;0.93;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1397.145,-406.6496;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;c6c49c1b469aa01428430f08d931dd94;c6c49c1b469aa01428430f08d931dd94;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;21;-1140.647,-161.9262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1137.139,96.83059;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;67;-1004.31,359.2835;Inherit;False;292;209;;1;62;Custom Noise Substract Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-954.3095,409.2835;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;17;-976.9863,-184.0511;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;61;-907.369,68.93562;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-600.569,114.4356;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;32;-1192.379,-500.7637;Inherit;False;0;5;2;0.4339623,0.1253669,0,0;0.7075472,0.2021564,0,0.08824293;0.9709716,0.3938324,0.00119438,0.2764782;0.9979265,0.7904897,0.5913919,0.4941176;1,0.9556705,0.9103774,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-763.4261,-190.2898;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CeilOpNode;58;-361.5921,71.51184;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;19;-579.306,-209.9941;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;28;-882.0345,-442.9072;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-386.4155,-419.5722;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;57;-196.8565,51.44501;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2675.914,254.1966;Inherit;False;997.2837;323.4189;Comment;5;45;46;43;47;44;Speed Spawn;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;33;-139.8705,-420.1428;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-122.4182,-205.227;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;76.9463,-414.8057;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;44;-2354.771,329.4854;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;43;-2180.76,323.6155;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2625.914,319.2497;Inherit;False;Property;_SpeedSpawn;SpeedSpawn;3;0;Create;True;0;0;0;False;0;False;30;18;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1840.63,304.1966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-1993.199,322.6077;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;49;259.7155,-423.0548;Float;False;True;-1;2;ASEMaterialInspector;0;7;ShockLight_Enemy_Shader;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;42;0;40;0
WireConnection;41;0;39;0
WireConnection;41;1;42;0
WireConnection;36;1;41;0
WireConnection;1;1;36;0
WireConnection;21;0;18;0
WireConnection;17;0;1;0
WireConnection;17;1;21;0
WireConnection;61;1;52;0
WireConnection;60;0;61;0
WireConnection;60;1;62;1
WireConnection;20;0;17;0
WireConnection;58;0;60;0
WireConnection;19;0;20;0
WireConnection;28;0;32;0
WireConnection;28;1;1;0
WireConnection;29;0;28;0
WireConnection;29;1;19;0
WireConnection;57;0;58;0
WireConnection;33;0;29;0
WireConnection;54;0;19;0
WireConnection;54;1;57;0
WireConnection;48;0;33;0
WireConnection;48;3;54;0
WireConnection;44;0;45;0
WireConnection;43;0;44;0
WireConnection;46;1;47;0
WireConnection;47;0;43;0
WireConnection;49;0;48;0
ASEEND*/
//CHKSM=424D475B1DF80C24863B199A31D6FBD947DF8FC4