// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vaccum_Cone_Intern_Shader"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Float0("Float 0", Float) = 13.2
		_Vector0("Vector 0", Vector) = (1,0.71,0,0)
		_SpeedNoise("Speed Noise", Range( 0 , 10)) = 0
		_SpeedWave("Speed Wave", Float) = 0
		_MinOld("Min Old", Float) = 0
		_Wave("Wave", Float) = 30
		_OpacityInternal("OpacityInternal", Range( 0 , 0.81)) = 1
		_ControlWave("ControlWave", Float) = 0
		_MinNew("Min New", Float) = 0
		_Altura("Altura", Vector) = (0,1,1,0)
		_MaxNew("Max New", Float) = 1
		_Opacity("Opacity", Float) = 0
		_Base("Base", Color) = (0.7877358,0.9796853,1,0)

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
				uniform float3 _Altura;
				uniform float _Wave;
				uniform float _SpeedWave;
				uniform float _ControlWave;
				uniform float4 _Base;
				uniform sampler2D _TextureSample0;
				uniform float2 _Vector0;
				uniform float _SpeedNoise;
				uniform float _Float0;
				uniform float _MinOld;
				uniform float _OpacityInternal;
				uniform float _MinNew;
				uniform float _MaxNew;
				uniform float _Opacity;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					float2 texCoord22 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float V_Texcoord23 = texCoord22.y;
					float mulTime48 = _Time.y * _SpeedWave;
					

					v.vertex.xyz += ( _Altura * sin( ( ( V_Texcoord23 * UNITY_PI * _Wave ) + mulTime48 ) ) * _ControlWave );
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

					float mulTime9 = _Time.y * _SpeedNoise;
					float2 texCoord12 = i.texcoord.xy * _Vector0 + ( float2( 0.3,-1 ) * mulTime9 );
					float4 temp_output_3_0 = ( tex2D( _TextureSample0, texCoord12 ) * _Float0 );
					float2 texCoord22 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float V_Texcoord23 = texCoord22.y;
					float4 appendResult55 = (float4(( saturate( _Base ) * temp_output_3_0 ).rgb , saturate( ( ( temp_output_3_0 * saturate( ( 1.0 - saturate( (_MinNew + (( 1.0 - V_Texcoord23 ) - _MinOld) * (_MaxNew - _MinNew) / (_OpacityInternal - _MinOld)) ) ) ) ) * saturate( _Opacity ) ) ).r));
					

					fixed4 col = appendResult55;
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
0;73;1105;629;1803.96;-215.5714;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2184.032,196.2782;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1941.589,321.3151;Inherit;False;V_Texcoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1529.258,147.1669;Inherit;False;Property;_SpeedNoise;Speed Noise;4;0;Create;True;0;0;0;False;0;False;0;0.9411765;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1420.887,370.232;Inherit;False;23;V_Texcoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;8;-1250.614,2.977955;Inherit;False;Constant;_OffsetTilling;Offset Tilling;3;0;Create;True;0;0;0;False;0;False;0.3,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;9;-1246.602,152.8565;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1305.862,695.6837;Inherit;False;Property;_MinNew;Min New;10;0;Create;True;0;0;0;False;0;False;0;-0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1425.686,573.4527;Inherit;False;Property;_OpacityInternal;OpacityInternal;8;0;Create;True;0;0;0;False;0;False;1;0.81;0;0.81;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1300.389,485.8849;Inherit;False;Property;_MinOld;Min Old;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-1241.887,388.2321;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1293.595,782.0045;Inherit;False;Property;_MaxNew;Max New;12;0;Create;True;0;0;0;False;0;False;1;0.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;32;-1068.469,390.4924;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;6;-1101.381,-119.9891;Inherit;False;Property;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;1,0.71;2.39,0.29;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1043.05,43.48575;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-879.3079,-11.12486;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;33;-806.2393,396.7339;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-666.7069,399.4203;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-506,165.5;Inherit;False;Property;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;13.2;2.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-632,-55.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;7e4ac535c04ac8a40aeef9e10ddb297c;0d8d0814bb62dad4e95ac3acc389a961;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;47;-726.688,657.9565;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-507.0113,368.2938;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-315,10.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-721.7931,835.8583;Inherit;False;Property;_SpeedWave;Speed Wave;5;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-317.7659,380.8148;Inherit;False;Property;_Opacity;Opacity;13;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-703.332,561.4269;Inherit;False;23;V_Texcoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-720.416,749.1558;Inherit;False;Property;_Wave;Wave;7;0;Create;True;0;0;0;False;0;False;30;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-178.1787,194.2475;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-509.399,608.6326;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-473.6938,-284.3874;Inherit;False;Property;_Base;Base;14;0;Create;True;0;0;0;False;0;False;0.7877358,0.9796853,1,0;0.8112763,0.9245489,0.9716981,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;39;-144.7659,330.8148;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;48;-407.2791,726.2184;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-8.765869,218.8148;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-236.5338,609.4927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-179.4824,-137.7874;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;51;-50.17621,605.1786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-100.8469,730.4244;Inherit;False;Property;_ControlWave;ControlWave;9;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;49.96116,-63.84503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;40;130.2341,226.8148;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;53;-82.98315,457.4825;Inherit;False;Property;_Altura;Altura;11;0;Create;True;0;0;0;False;0;False;0,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;11;-1029.048,-278.559;Inherit;False;Property;_TllingNoiseOne;Tlling Noise One;3;0;Create;True;0;0;0;False;0;False;0,0;1,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;55;518.2286,-47.3186;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;115.914,558.8807;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1942.002,234.7725;Inherit;False;U_Texcoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1940.002,152.7725;Inherit;False;UV_Texcoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;56;761.3889,-44.7278;Float;False;True;-1;2;ASEMaterialInspector;0;7;Vaccum_Cone_Intern_Shader;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;23;0;22;2
WireConnection;9;0;7;0
WireConnection;31;0;26;0
WireConnection;32;0;31;0
WireConnection;32;1;28;0
WireConnection;32;2;27;0
WireConnection;32;3;29;0
WireConnection;32;4;30;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;12;0;6;0
WireConnection;12;1;10;0
WireConnection;33;0;32;0
WireConnection;34;0;33;0
WireConnection;1;1;12;0
WireConnection;36;0;34;0
WireConnection;3;0;1;0
WireConnection;3;1;4;0
WireConnection;35;0;3;0
WireConnection;35;1;36;0
WireConnection;49;0;45;0
WireConnection;49;1;47;0
WireConnection;49;2;44;0
WireConnection;39;0;38;0
WireConnection;48;0;46;0
WireConnection;37;0;35;0
WireConnection;37;1;39;0
WireConnection;50;0;49;0
WireConnection;50;1;48;0
WireConnection;43;0;41;0
WireConnection;51;0;50;0
WireConnection;42;0;43;0
WireConnection;42;1;3;0
WireConnection;40;0;37;0
WireConnection;55;0;42;0
WireConnection;55;3;40;0
WireConnection;54;0;53;0
WireConnection;54;1;51;0
WireConnection;54;2;52;0
WireConnection;25;0;22;1
WireConnection;24;0;22;0
WireConnection;56;0;55;0
WireConnection;56;1;54;0
ASEEND*/
//CHKSM=85A14B9BDB305C25E65B3F07240D17D1E28EBAC6