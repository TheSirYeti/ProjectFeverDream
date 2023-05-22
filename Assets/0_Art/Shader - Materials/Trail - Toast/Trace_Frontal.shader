// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Trace_Frontal"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (1,0.4253451,0,0)
		[HDR]_Color1("Color 1", Color) = (1,0.4914818,0,0)
		_Vector0("Vector 0", Vector) = (0,1,0,0)
		_Speed("Speed", Range( 0 , 1)) = 0
		_Dissolve("Dissolve", Float) = 0
		_Sature("Sature", Range( 0 , 5)) = 2
		_DissolveSpeed("Dissolve Speed", Vector) = (0,0,0,0)
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
				uniform float4 _Color0;
				uniform float4 _Color1;
				uniform float _Sature;
				uniform float2 _DissolveSpeed;
				uniform float _Dissolve;
				uniform sampler2D _TextureSample0;
				uniform float2 _Vector0;
				uniform float _Speed;
				uniform sampler2D _TextureSample1;
				inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
				inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
				inline float valueNoise (float2 uv)
				{
					float2 i = floor(uv);
					float2 f = frac( uv );
					f = f* f * (3.0 - 2.0 * f);
					uv = abs( frac(uv) - 0.5);
					float2 c0 = i + float2( 0.0, 0.0 );
					float2 c1 = i + float2( 1.0, 0.0 );
					float2 c2 = i + float2( 0.0, 1.0 );
					float2 c3 = i + float2( 1.0, 1.0 );
					float r0 = noise_randomValue( c0 );
					float r1 = noise_randomValue( c1 );
					float r2 = noise_randomValue( c2 );
					float r3 = noise_randomValue( c3 );
					float bottomOfGrid = noise_interpolate( r0, r1, f.x );
					float topOfGrid = noise_interpolate( r2, r3, f.x );
					float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
					return t;
				}
				
				float SimpleNoise(float2 UV)
				{
					float t = 0.0;
					float freq = pow( 2.0, float( 0 ) );
					float amp = pow( 0.5, float( 3 - 0 ) );
					t += valueNoise( UV/freq )*amp;
					freq = pow(2.0, float(1));
					amp = pow(0.5, float(3-1));
					t += valueNoise( UV/freq )*amp;
					freq = pow(2.0, float(2));
					amp = pow(0.5, float(3-2));
					t += valueNoise( UV/freq )*amp;
					return t;
				}
				


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

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

					float4 texCoord51 = i.texcoord;
					texCoord51.xy = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float4 UVWT_TextureCoordinates52 = texCoord51;
					float4 lerpResult1 = lerp( _Color0 , _Color1 , UVWT_TextureCoordinates52.x);
					float2 texCoord42 = i.texcoord.xy * float2( 1,1 ) + ( _Time.y * _DissolveSpeed );
					float simpleNoise31 = SimpleNoise( texCoord42*_Dissolve );
					float U_TextureCoordinates53 = texCoord51.x;
					float mulTime16 = _Time.y * _Speed;
					float2 texCoord21 = i.texcoord.xy * float2( 1,1 ) + ( _Vector0 * mulTime16 );
					float4 tex2DNode13 = tex2D( _TextureSample0, texCoord21 );
					float4 temp_output_27_0 = ( saturate( ( ( simpleNoise31 + ( 1.0 - U_TextureCoordinates53 ) ) - U_TextureCoordinates53 ) ) * saturate( ( tex2DNode13 + ( saturate( tex2D( _TextureSample1, texCoord21 ) ) * tex2DNode13 ) ) ) );
					float4 appendResult44 = (float4(( ( lerpResult1 * _Sature ) * temp_output_27_0 ).rgb , temp_output_27_0.r));
					

					fixed4 col = appendResult44;
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
0;73;1205;655;6039.876;1232.536;5.668128;True;False
Node;AmplifyShaderEditor.CommentaryNode;56;-3468.861,772.3952;Inherit;False;1657.567;549.9388;;10;22;19;16;14;21;45;13;46;50;49;Line;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-3460.522,-523.5925;Inherit;False;1464.076;594.695;;11;54;9;4;3;1;33;34;11;51;52;53;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3418.861,1007.013;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;57;-3468.882,115.7362;Inherit;False;1496.812;608.5718;;11;32;42;38;41;39;31;37;24;55;36;25;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;19;-3138.495,874.0918;Inherit;False;Property;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,1;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;16;-3149.109,1016.395;Inherit;False;1;0;FLOAT;0.11;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-3410.522,-459.6494;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;41;-3418.882,276.4927;Inherit;False;Property;_DissolveSpeed;Dissolve Speed;7;0;Create;True;0;0;0;False;0;False;0,0;-0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;38;-3398.75,188.6562;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-3168.614,-392.4676;Inherit;False;U_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2921.489,941.7689;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2766.991,875.886;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-3163.656,216.0215;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-3151.589,465.8438;Inherit;False;53;U_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2967.315,289.4142;Inherit;False;Property;_Dissolve;Dissolve;5;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-3031.056,168.2834;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-2655.714,1092.333;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;None;2cd6dde56b14f9247a1687185effb286;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;24;-2906.34,470.308;Inherit;True;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;46;-2373.948,1106.429;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;36;-2686.514,407.4133;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-3172.793,-468.1417;Inherit;False;UVWT_TextureCoordinates;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-2782.967,165.7362;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-2512.09,849.6408;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;044ad747e9f1aef408edd1b0c1652326;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2959.166,-113.0519;Inherit;False;52;UVWT_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-2462.924,170.3033;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2181.638,1134.063;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;-2707.568,-111.8975;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;4;-2875.186,-295.4249;Inherit;False;Property;_Color1;Color 1;2;1;[HDR];Create;True;0;0;0;False;0;False;1,0.4914818,0,0;0.2735849,0.02854799,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-2876.24,-473.5925;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;0;False;0;False;1,0.4253451,0,0;1,0.4178852,0.3324516,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2046.293,822.3952;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-2207.07,399.002;Inherit;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1;-2564.157,-468.6422;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2549.757,-237.7201;Inherit;False;Property;_Sature;Sature;6;0;Create;True;0;0;0;False;0;False;2;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;-1857.249,558.5123;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;28;-1877.986,394.3713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2299.061,-469.7526;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1694.31,364.8923;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2158.446,-467.429;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-1951.296,-466.0335;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;-1799.357,-464.5414;Float;False;True;-1;2;ASEMaterialInspector;0;7;Trace_Frontal;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;16;0;22;0
WireConnection;53;0;51;1
WireConnection;14;0;19;0
WireConnection;14;1;16;0
WireConnection;21;1;14;0
WireConnection;39;0;38;0
WireConnection;39;1;41;0
WireConnection;42;1;39;0
WireConnection;45;1;21;0
WireConnection;24;0;55;0
WireConnection;46;0;45;0
WireConnection;36;0;24;0
WireConnection;52;0;51;0
WireConnection;31;0;42;0
WireConnection;31;1;32;0
WireConnection;13;1;21;0
WireConnection;37;0;31;0
WireConnection;37;1;36;0
WireConnection;50;0;46;0
WireConnection;50;1;13;0
WireConnection;9;0;54;0
WireConnection;49;0;13;0
WireConnection;49;1;50;0
WireConnection;25;0;37;0
WireConnection;25;1;24;0
WireConnection;1;0;3;0
WireConnection;1;1;4;0
WireConnection;1;2;9;0
WireConnection;29;0;49;0
WireConnection;28;0;25;0
WireConnection;33;0;1;0
WireConnection;33;1;34;0
WireConnection;27;0;28;0
WireConnection;27;1;29;0
WireConnection;11;0;33;0
WireConnection;11;1;27;0
WireConnection;44;0;11;0
WireConnection;44;3;27;0
WireConnection;43;0;44;0
ASEEND*/
//CHKSM=4816605F6BE496DFCB36C7529423293970DFAC54