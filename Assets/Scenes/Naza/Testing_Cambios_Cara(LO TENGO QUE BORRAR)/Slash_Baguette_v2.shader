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
		_Vector0("Vector 0", Vector) = (0,1,-2,1)
		_EmissionFloat("Emission Float", Range( 0 , 1)) = 0
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
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
				#include "UnityShaderVariables.cginc"
				#define ASE_NEEDS_FRAG_COLOR


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
				uniform float4 _ShadowColor;
				uniform sampler2D _Emission;
				uniform float4 _Emission_ST;
				uniform float4 _Vector0;
				uniform float _EmissionFloat;
				uniform sampler2D _Main;
				uniform float4 _Main_ST;
				uniform float _Opacity;
				uniform sampler2D _DissolveTexture;
				uniform float4 _SpeedTextureNoise;
				uniform float4 _DissolveTexture_ST;


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

					float2 uv_Emission = i.texcoord.xy * _Emission_ST.xy + _Emission_ST.zw;
					float4 temp_cast_0 = (_Vector0.x).xxxx;
					float4 temp_cast_1 = (_Vector0.y).xxxx;
					float4 temp_cast_2 = (_Vector0.z).xxxx;
					float4 temp_cast_3 = (_Vector0.w).xxxx;
					float2 uv_Main = i.texcoord.xy * _Main_ST.xy + _Main_ST.zw;
					float4 clampResult6 = clamp( ( tex2D( _Main, uv_Main ) * _Opacity ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
					float2 appendResult43 = (float2(_SpeedTextureNoise.z , _SpeedTextureNoise.w));
					float4 uvs4_DissolveTexture = i.texcoord;
					uvs4_DissolveTexture.xy = i.texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
					float2 panner44 = ( 1.0 * _Time.y * appendResult43 + uvs4_DissolveTexture.xy);
					float T_TextureCoordinates34 = uvs4_DissolveTexture.w;
					float W_TextureCoordinates33 = uvs4_DissolveTexture.z;
					float ifLocalVar23 = 0;
					if( ( tex2D( _DissolveTexture, panner44 ).r * T_TextureCoordinates34 ) >= W_TextureCoordinates33 )
					ifLocalVar23 = 0.0;
					else
					ifLocalVar23 = 1.0;
					float4 appendResult7 = (float4(( ( _ShadowColor * i.color ) + ( saturate( (temp_cast_2 + (tex2D( _Emission, uv_Emission ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) ) * _EmissionFloat * i.color ) ).rgb , ( clampResult6 * i.color.a * ifLocalVar23 ).r));
					

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
676;526;941;473;2120.573;1255.486;2.351987;True;False
Node;AmplifyShaderEditor.Vector4Node;41;-2317.908,425.6238;Inherit;False;Property;_SpeedTextureNoise;Speed Texture + Noise;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;43;-2071.941,501.6249;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-2138.758,244.9728;Inherit;False;0;11;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;54;-1202.523,-679.7416;Inherit;False;Property;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0,1,-2,1;0,1,-1,6.18;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;51;-1287.025,-909.2939;Inherit;True;Property;_Emission;Emission;4;0;Create;True;0;0;0;False;0;False;-1;None;df7238bb516e617438fffce00e67a451;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;44;-1897.86,480.0374;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1864.612,367.2598;Inherit;False;T_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1314.393,-68.29653;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;0;False;0;False;-1;None;bfbd2b8a82a67544bbf5c8bd216e35a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1530.899,571.052;Inherit;False;34;T_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1865.612,278.2599;Inherit;False;W_TextureCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-1549.446,349.4173;Inherit;True;Property;_DissolveTexture;Dissolve Texture;2;0;Create;True;0;0;0;False;0;False;-1;None;6bf57f43cb88827429a6d6acbed2197f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1286.372,142.242;Inherit;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;0;False;0;False;0;4.783979;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;52;-928.9825,-689.5069;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1060.557,602.8448;Inherit;False;Constant;_Saturacion;Saturacion;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1056.557,684.5173;Inherit;False;Constant;_Opacityy;Opacityy???;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;9;-863.8228,-292.1368;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;60;-782.0746,-954.7258;Inherit;False;Property;_ShadowColor;Shadow Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9245283,0.9245283,0.9245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;58;-661.0894,-631.3002;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-973.3723,-61.75793;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-856.2994,-482.6509;Inherit;False;Property;_EmissionFloat;Emission Float;6;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1067.762,373.7183;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1149.998,509.552;Inherit;False;33;W_TextureCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;6;-805.3724,-59.75794;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;23;-851.6536,372.6598;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-430.1105,-617.4905;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-484.045,-949.9864;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-562.9968,-58.45919;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-260.3092,-779.6685;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-72.78782,-338.8731;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;118.1423,-346.3183;Float;False;True;-1;2;ASEMaterialInspector;0;7;Slash_Baguette_v2;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;43;0;41;3
WireConnection;43;1;41;4
WireConnection;44;0;32;0
WireConnection;44;2;43;0
WireConnection;34;0;32;4
WireConnection;33;0;32;3
WireConnection;11;1;44;0
WireConnection;52;0;51;0
WireConnection;52;1;54;1
WireConnection;52;2;54;2
WireConnection;52;3;54;3
WireConnection;52;4;54;4
WireConnection;58;0;52;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;14;0;11;1
WireConnection;14;1;38;0
WireConnection;6;0;3;0
WireConnection;23;0;14;0
WireConnection;23;1;39;0
WireConnection;23;2;25;0
WireConnection;23;3;25;0
WireConnection;23;4;26;0
WireConnection;56;0;58;0
WireConnection;56;1;57;0
WireConnection;56;2;9;0
WireConnection;61;0;60;0
WireConnection;61;1;9;0
WireConnection;8;0;6;0
WireConnection;8;1;9;4
WireConnection;8;2;23;0
WireConnection;62;0;61;0
WireConnection;62;1;56;0
WireConnection;7;0;62;0
WireConnection;7;3;8;0
WireConnection;1;0;7;0
ASEEND*/
//CHKSM=853FC65D40705A5AD31E97B3A9D985B6751CA19E