// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hit_Chips_Shader"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_Float1("Float 1", Float) = 0
		_Float2("Float 2", Float) = 0
		_Float3("Float 3", Float) = 0
		_Float4("Float 4", Float) = 0
		_Float6("Float 6", Float) = -7.42
		_Float0("Float 0", Float) = -2.19
		_Float5("Float 5", Float) = 0
		_Float7("Float 7", Float) = 0
		_Float8("Float 8", Float) = 0
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
				uniform sampler2D _TextureSample0;
				uniform float4 _TextureSample0_ST;
				uniform float _Float0;
				uniform float _Float6;
				uniform float _Float5;
				uniform float _Float7;
				uniform float _Float8;
				uniform sampler2D _TextureSample1;
				uniform float2 _Vector0;
				uniform float _Float1;
				uniform float _Float3;
				uniform float _Float4;
				uniform float _Float2;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.ase_texcoord3.xyz = v.ase_texcoord1.xyz;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord3.w = 0;

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

					float2 uv_TextureSample0 = i.texcoord.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
					float4 temp_output_9_0 = saturate( tex2D( _TextureSample0, uv_TextureSample0 ) );
					float3 texCoord53 = i.ase_texcoord3.xyz;
					texCoord53.xy = i.ase_texcoord3.xyz.xy * float2( 1,1 ) + float2( 0,0 );
					float4 temp_cast_1 = (_Float7).xxxx;
					float4 temp_cast_2 = (_Float8).xxxx;
					float2 texCoord13 = i.texcoord.xy * float2( 1,1 ) + ( _Vector0 * texCoord53.y );
					float4 temp_cast_3 = (( 1.0 - texCoord53.x )).xxxx;
					float4 temp_cast_4 = (_Float1).xxxx;
					float4 temp_cast_5 = (_Float3).xxxx;
					float4 temp_cast_6 = (_Float4).xxxx;
					float4 temp_cast_7 = (_Float2).xxxx;
					float4 smoothstepResult87 = smoothstep( temp_cast_1 , temp_cast_2 , (temp_cast_6 + (( tex2D( _TextureSample1, texCoord13 ) - temp_cast_3 ) - temp_cast_4) * (temp_cast_7 - temp_cast_6) / (temp_cast_5 - temp_cast_4)));
					float4 appendResult2 = (float4(temp_output_9_0.rgb , ( temp_output_9_0 * saturate( ( saturate( ( (_Float6 + (i.texcoord.xy.y - _Float0) * (_Float5 - _Float6) / (1.0 - _Float0)) + texCoord53.z ) ) + saturate( smoothstepResult87 ) ) ) ).r));
					

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
0;73;959;624;3398.559;1524.205;3.444776;True;False
Node;AmplifyShaderEditor.Vector2Node;21;-2196.817,-138.1948;Inherit;False;Property;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;0,0;0,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-2223.398,-437.6724;Inherit;False;1;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1938.417,-143.7279;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1807.267,-339.7514;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;43;-1356.178,-421.012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-1588.58,-282.926;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1368.364,169.24;Inherit;False;Property;_Float3;Float 3;5;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1647.309,-661.6754;Inherit;False;Property;_Float5;Float 5;10;0;Create;True;0;0;0;False;0;False;0;1.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-1715.232,-759.9496;Inherit;False;Property;_Float6;Float 6;8;0;Create;True;0;0;0;False;0;False;-7.42;-7.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;61;-1747.178,-1064.932;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1381.537,91.6466;Inherit;False;Property;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;0;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1364.653,239.5591;Inherit;False;Property;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;0;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;-1143.471,-319.936;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1363.538,304.6462;Inherit;False;Property;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;0;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1717.332,-904.3495;Inherit;False;Property;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;-2.19;-1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-881.6178,239.8416;Inherit;False;Property;_Float7;Float 7;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;26;-966.0212,18.42008;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;81;-1528.557,-916.3103;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-850.9845,324.9347;Inherit;False;Property;_Float8;Float 8;12;0;Create;True;0;0;0;False;0;False;0;0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;87;-665.481,11.79193;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1258.669,-701.0283;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-506.4101,11.32239;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;77;-722.8364,-415.2166;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-641.4427,-675.9147;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;cc5e6b0797ae95f46a694c39316c85cf;cc5e6b0797ae95f46a694c39316c85cf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-488.1724,-234.247;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;9;-330.5685,-639.2845;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;76;-343.1912,-178.4715;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-225.6569,-2.977618;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;-68.80785,-676.8392;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;90;25.14244,-268.3881;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-1561.908,-511.4812;Inherit;False;Property;_Float9;Float 9;7;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;196.2831,-399.7205;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;94;472.5716,-369.5608;Float;False;True;-1;2;ASEMaterialInspector;0;7;Hit_Chips_Shader;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;54;0;21;0
WireConnection;54;1;53;2
WireConnection;13;1;54;0
WireConnection;43;0;53;1
WireConnection;16;1;13;0
WireConnection;34;0;16;0
WireConnection;34;1;43;0
WireConnection;26;0;34;0
WireConnection;26;1;27;0
WireConnection;26;2;29;0
WireConnection;26;3;30;0
WireConnection;26;4;28;0
WireConnection;81;0;61;2
WireConnection;81;1;82;0
WireConnection;81;3;84;0
WireConnection;81;4;86;0
WireConnection;87;0;26;0
WireConnection;87;1;88;0
WireConnection;87;2;89;0
WireConnection;72;0;81;0
WireConnection;72;1;53;3
WireConnection;19;0;87;0
WireConnection;77;0;72;0
WireConnection;78;0;77;0
WireConnection;78;1;19;0
WireConnection;9;0;1;0
WireConnection;76;0;78;0
WireConnection;15;0;9;0
WireConnection;15;1;76;0
WireConnection;2;0;9;0
WireConnection;2;3;15;0
WireConnection;91;0;2;0
WireConnection;91;1;90;0
WireConnection;94;0;91;0
ASEEND*/
//CHKSM=36C463AFB33D4497301A21F57AF995548C2D867E