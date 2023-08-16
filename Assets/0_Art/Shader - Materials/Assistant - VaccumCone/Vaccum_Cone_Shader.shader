// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vaccum_Cone_Shader"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Noiseone("Noise one", 2D) = "white" {}
		_MinOldNO("Min Old NO", Float) = 0
		_TllingNoiseOne("Tlling Noise One", Vector) = (0,0,0,0)
		_TllingNoisetwo("Tlling Noise two", Vector) = (0,0,0,0)
		_SpeedWave("Speed Wave", Float) = 0
		_Wave("Wave", Float) = 30
		_ControlWave("ControlWave", Float) = 0
		_Altura("Altura", Vector) = (0,1,1,0)
		_SpeedNoise("Speed Noise", Range( 0 , 10)) = 0
		_SpeedNoisetwo("Speed Noise two", Range( 0 , 1)) = 0
		_MinOld("Min Old", Float) = 0
		_OpacityExternal("OpacityExternal", Range( 0 , 1)) = 1
		_MinNew("Min New", Float) = 0
		_MaxNew("Max New", Float) = 1
		_Noisetwo("Noise two", 2D) = "white" {}
		_Float0("Float 0", Float) = 0
		_MaxOldNO("Max Old NO", Float) = 1
		_MinNewNO("Min New NO", Float) = 0
		_MaxNewNO("Max New NO", Float) = 1
		_Base("Base", Color) = (0.7877358,0.9796853,1,0)
		_Saturacion("Saturacion", Range( 1 , 3)) = 1
		_Float1("Float 1", Float) = 0
		_Float2("Float 2", Float) = 0

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
				uniform float _Float1;
				uniform float _Float2;
				uniform sampler2D _Noisetwo;
				uniform float2 _TllingNoisetwo;
				uniform float _SpeedNoisetwo;
				uniform float _Float0;
				uniform sampler2D _Noiseone;
				uniform float2 _TllingNoiseOne;
				uniform float _SpeedNoise;
				uniform float _MinOldNO;
				uniform float _MaxOldNO;
				uniform float _MinNewNO;
				uniform float _MaxNewNO;
				uniform float _Saturacion;
				uniform float _MinOld;
				uniform float _OpacityExternal;
				uniform float _MinNew;
				uniform float _MaxNew;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					float2 texCoord17 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float V_Texcoord28 = texCoord17.y;
					float mulTime19 = _Time.y * _SpeedWave;
					

					v.vertex.xyz += ( _Altura * sin( ( ( V_Texcoord28 * UNITY_PI * _Wave ) + mulTime19 ) ) * _ControlWave );
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

					float mulTime51 = _Time.y * _SpeedNoisetwo;
					float2 texCoord49 = i.texcoord.xy * _TllingNoisetwo + ( float2( 1,-1 ) * mulTime51 );
					float smoothstepResult90 = smoothstep( _Float1 , _Float2 , ( tex2D( _Noisetwo, texCoord49 ) + _Float0 ));
					float mulTime10 = _Time.y * _SpeedNoise;
					float2 texCoord5 = i.texcoord.xy * _TllingNoiseOne + ( float2( 0.3,-1 ) * mulTime10 );
					float4 temp_cast_0 = (_MinOldNO).xxxx;
					float4 temp_cast_1 = (_MaxOldNO).xxxx;
					float4 temp_cast_2 = (_MinNewNO).xxxx;
					float4 temp_cast_3 = (_MaxNewNO).xxxx;
					float4 temp_output_3_0 = saturate( ( smoothstepResult90 + (temp_cast_2 + (tex2D( _Noiseone, texCoord5 ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) ) );
					float2 texCoord17 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float V_Texcoord28 = texCoord17.y;
					float4 appendResult72 = (float4(( ( _Base * temp_output_3_0 ) * _Saturacion ).rgb , ( temp_output_3_0 * ( 1.0 - saturate( (_MinNew + (( 1.0 - V_Texcoord28 ) - _MinOld) * (_MaxNew - _MinNew) / (_OpacityExternal - _MinOld)) ) ) ).r));
					

					fixed4 col = appendResult72;
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
0;73;889;621;2087.365;1209.943;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;52;-2616.471,-962.563;Inherit;False;Property;_SpeedNoisetwo;Speed Noise two;9;0;Create;True;0;0;0;False;0;False;0;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2287.771,-97.99207;Inherit;False;Property;_SpeedNoise;Speed Noise;8;0;Create;True;0;0;0;False;0;False;0;4.442182;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;51;-2333.816,-956.8734;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;47;-2337.828,-1106.752;Inherit;False;Constant;_OffsetTillingtwo;Offset Tilling two;3;0;Create;True;0;0;0;False;0;False;1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;8;-2009.127,-242.181;Inherit;False;Constant;_OffsetTilling;Offset Tilling;3;0;Create;True;0;0;0;False;0;False;0.3,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-2005.115,-92.30243;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;48;-2239.854,-1308.469;Inherit;False;Property;_TllingNoisetwo;Tlling Noise two;3;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2130.263,-1066.244;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-2574.041,137.3099;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1801.563,-201.6732;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;12;-1911.154,-443.8973;Inherit;False;Property;_TllingNoiseOne;Tlling Noise One;2;0;Create;True;0;0;0;False;0;False;0,0;1,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1966.521,-1120.855;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-1590.09,-807.6855;Inherit;False;Property;_Float0;Float 0;15;0;Create;True;0;0;0;False;0;False;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-2331.598,262.3468;Inherit;False;V_Texcoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1637.821,-256.2838;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-1701.866,-1054.248;Inherit;True;Property;_Noisetwo;Noise two;14;0;Create;True;0;0;0;False;0;False;-1;None;7e4ac535c04ac8a40aeef9e10ddb297c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-1359.435,-858.0338;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1286.724,-710.3381;Inherit;False;Property;_Float1;Float 1;21;0;Create;True;0;0;0;False;0;False;0;-0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1321.75,-0.7420883;Inherit;False;Property;_MaxOldNO;Max Old NO;16;0;Create;True;0;0;0;False;0;False;1;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1300.14,187.6865;Inherit;False;Property;_MaxNewNO;Max New NO;18;0;Create;True;0;0;0;False;0;False;1;0.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1312.964,88.31941;Inherit;False;Property;_MinNewNO;Min New NO;17;0;Create;True;0;0;0;False;0;False;0;-0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1412.729,-284.2299;Inherit;True;Property;_Noiseone;Noise one;0;0;Create;True;0;0;0;False;0;False;-1;16aa8fb6f94c2c74f9d2ae03a2574388;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1317.156,-97.48706;Inherit;False;Property;_MinOldNO;Min Old NO;1;0;Create;True;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-1435.776,667.0514;Inherit;False;28;V_Texcoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1286.404,-622.0367;Inherit;False;Property;_Float2;Float 2;22;0;Create;True;0;0;0;False;0;False;0;0.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1320.751,992.5032;Inherit;False;Property;_MinNew;Min New;12;0;Create;True;0;0;0;False;0;False;0;-1.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-1256.776,685.0515;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;56;-1013.241,-255.7531;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1530.575,867.2722;Inherit;False;Property;_OpacityExternal;OpacityExternal;11;0;Create;True;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;90;-1076.393,-767.6971;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1308.484,1078.824;Inherit;False;Property;_MaxNew;Max New;13;0;Create;True;0;0;0;False;0;False;1;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1315.278,782.7043;Inherit;False;Property;_MinOld;Min Old;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-773.8237,-334.0745;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-1313.172,312.3411;Inherit;False;28;V_Texcoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;40;-1083.358,687.3118;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1331.633,586.7726;Inherit;False;Property;_SpeedWave;Speed Wave;4;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;15;-1336.528,408.8708;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1330.256,500.07;Inherit;False;Property;_Wave;Wave;5;0;Create;True;0;0;0;False;0;False;30;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;-396.0543,-456.1602;Inherit;False;Property;_Base;Base;19;0;Create;True;0;0;0;False;0;False;0.7877358,0.9796853,1,0;0.8745098,0.972549,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1017.119,477.1326;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1119.239,359.5468;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;3;-595.754,-241.1045;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;38;-821.1282,693.5533;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-134.2135,-276.8973;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-246.2113,-145.9465;Inherit;False;Property;_Saturacion;Saturacion;20;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-681.5958,696.2397;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-846.3737,360.4069;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-710.6868,481.3387;Inherit;False;Property;_ControlWave;ControlWave;6;0;Create;True;0;0;0;False;0;False;0;-0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-83.15962,45.10915;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;86.08629,-182.9699;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;24;-692.8231,208.3967;Inherit;False;Property;_Altura;Altura;7;0;Create;True;0;0;0;False;0;False;0,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;21;-660.0162,356.0928;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-2332.011,175.8042;Inherit;False;U_Texcoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;642.3337,-144.2194;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2330.011,93.80419;Inherit;False;UV_Texcoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-493.926,309.795;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;71;880.6859,-140.8835;Float;False;True;-1;2;ASEMaterialInspector;0;7;Vaccum_Cone_Shader;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;51;0;52;0
WireConnection;10;0;26;0
WireConnection;50;0;47;0
WireConnection;50;1;51;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;28;0;17;2
WireConnection;5;0;12;0
WireConnection;5;1;9;0
WireConnection;45;1;49;0
WireConnection;89;0;45;0
WireConnection;89;1;54;0
WireConnection;1;1;5;0
WireConnection;35;0;32;0
WireConnection;56;0;1;0
WireConnection;56;1;4;0
WireConnection;56;2;57;0
WireConnection;56;3;58;0
WireConnection;56;4;59;0
WireConnection;90;0;89;0
WireConnection;90;1;91;0
WireConnection;90;2;92;0
WireConnection;46;0;90;0
WireConnection;46;1;56;0
WireConnection;40;0;35;0
WireConnection;40;1;41;0
WireConnection;40;2;42;0
WireConnection;40;3;43;0
WireConnection;40;4;44;0
WireConnection;19;0;14;0
WireConnection;18;0;29;0
WireConnection;18;1;15;0
WireConnection;18;2;16;0
WireConnection;3;0;46;0
WireConnection;38;0;40;0
WireConnection;61;0;60;0
WireConnection;61;1;3;0
WireConnection;39;0;38;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;37;0;3;0
WireConnection;37;1;39;0
WireConnection;62;0;61;0
WireConnection;62;1;63;0
WireConnection;21;0;20;0
WireConnection;30;0;17;1
WireConnection;72;0;62;0
WireConnection;72;3;37;0
WireConnection;31;0;17;0
WireConnection;23;0;24;0
WireConnection;23;1;21;0
WireConnection;23;2;25;0
WireConnection;71;0;72;0
WireConnection;71;1;23;0
ASEEND*/
//CHKSM=760006909D12A4130CCEB32101DAB89C2D259967