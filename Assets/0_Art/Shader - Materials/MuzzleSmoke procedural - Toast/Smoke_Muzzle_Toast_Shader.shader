// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Smoke_Muzzle_Toast_Shader"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Main("Main", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_Float0("Float 0", Float) = 0
		_Float1("Float 1", Float) = 1
		_Float2("Float 2", Float) = 0
		_Float3("Float 3", Float) = 1
		_Float7("Float 7", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
				uniform sampler2D _Main;
				uniform float4 _Main_ST;
				uniform sampler2D _Noise;
				uniform float _Float7;
				uniform float _Float0;
				uniform float _Float1;
				uniform float _Float2;
				uniform float _Float3;


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

					float2 uv_Main = i.texcoord.xy * _Main_ST.xy + _Main_ST.zw;
					float4 temp_cast_0 = (1.53).xxxx;
					float2 texCoord28 = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
					float4 temp_cast_1 = (texCoord28.x).xxxx;
					float2 texCoord23 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float4 temp_cast_2 = (_Float0).xxxx;
					float4 temp_cast_3 = (_Float1).xxxx;
					float4 temp_cast_4 = (_Float2).xxxx;
					float4 temp_cast_5 = (_Float3).xxxx;
					float4 smoothstepResult13 = smoothstep( temp_cast_0 , temp_cast_1 , (temp_cast_4 + (( tex2D( _Noise, texCoord23 ) * _Float7 ) - temp_cast_2) * (temp_cast_5 - temp_cast_4) / (temp_cast_3 - temp_cast_2)));
					float4 temp_output_5_0 = saturate( ( tex2D( _Main, uv_Main ) * saturate( smoothstepResult13 ) ) );
					float4 appendResult2 = (float4(temp_output_5_0.rgb , temp_output_5_0.r));
					

					fixed4 col = ( appendResult2 * i.color );
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
0;73;927;655;2349.073;538.4791;2.473567;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-2072.196,43.9507;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1825.872,-49.66835;Inherit;True;Property;_Noise;Noise;1;0;Create;True;0;0;0;False;0;False;-1;None;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-1808.333,188.5118;Inherit;False;Property;_Float7;Float 7;8;0;Create;True;0;0;0;False;0;False;0;4.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1574.993,515.0576;Inherit;False;Property;_Float3;Float 3;5;0;Create;True;0;0;0;False;0;False;1;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1581.312,314.4131;Inherit;False;Property;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1574.993,233.8392;Inherit;False;Property;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0;-0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1570.253,421.8449;Inherit;False;Property;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;0;2.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1491.35,80.12401;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1320.632,159.5849;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1306.731,371.5597;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;1.53;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1333.684,480.9352;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-1080.137,163.3722;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1217.823,-215.3847;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;0;False;0;False;-1;1cdaac8e51ca52f4a80a4ac368d24acc;1cdaac8e51ca52f4a80a4ac368d24acc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;16;-833.4362,160.0637;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-595.4764,-45.57851;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;5;-148.0827,-16.84947;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;39.71112,-46.00703;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;32;42.47052,72.31071;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2383.394,165.6994;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1351.317,633.0367;Inherit;False;Property;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;0;1;-1.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2544.959,161.5394;Inherit;False;Property;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;0.41;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;198.2024,-36.61015;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;24;-2402.079,-6.696945;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2213.845,88.11591;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;412.9656,-44.51923;Float;False;True;-1;2;ASEMaterialInspector;0;7;Smoke_Muzzle_Toast_Shader;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;3;1;23;0
WireConnection;29;0;3;0
WireConnection;29;1;30;0
WireConnection;8;0;29;0
WireConnection;8;1;9;0
WireConnection;8;2;10;0
WireConnection;8;3;11;0
WireConnection;8;4;12;0
WireConnection;13;0;8;0
WireConnection;13;1;15;0
WireConnection;13;2;28;1
WireConnection;16;0;13;0
WireConnection;4;0;1;0
WireConnection;4;1;16;0
WireConnection;5;0;4;0
WireConnection;2;0;5;0
WireConnection;2;3;5;0
WireConnection;27;0;26;0
WireConnection;33;0;2;0
WireConnection;33;1;32;0
WireConnection;25;0;24;0
WireConnection;25;1;27;0
WireConnection;0;0;33;0
ASEEND*/
//CHKSM=C3BEC40333257E5B360D012DC8625F8242EFA835