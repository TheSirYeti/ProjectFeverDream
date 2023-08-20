// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DamageScreen_Effect"
{
	Properties
	{
		_Float3("Float 3", Float) = 0.44
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _Float3;


			
			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult157 = (float2(ase_ppsScreenPosFragNorm.x , ase_ppsScreenPosFragNorm.y));
				float temp_output_43_0 = distance( appendResult157 , float2( 0.5,0.5 ) );
				

				float4 color = ( saturate( tex2D( _MainTex, uv_MainTex, float2( 0,0 ), float2( 0,0 ) ) ) + saturate( step( _Float3 , temp_output_43_0 ) ) );
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;1021;553;3884.816;267.9659;2.776311;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;156;-3090.749,930.1346;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;45;-3003.91,1178.598;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;157;-2896.749,987.1346;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;96;-2393.108,353.48;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;43;-2763.633,1058.292;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2716.304,813.4088;Inherit;False;Property;_Float3;Float 3;9;0;Create;True;0;0;0;False;0;False;0.44;0.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;95;-2239.942,342.8909;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;135;-2516.652,815.8012;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-2031.539,619.2598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;-1898.292,348.3373;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-4066.723,105.5859;Inherit;False;Property;_Border2;Border2;3;0;Create;True;0;0;0;False;0;False;20;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2826.402,203.6366;Inherit;False;Property;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0.26;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-3731.276,10.92084;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;27;-3375.39,-3.370083;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-2504.472,1041.441;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-4053.01,-198.7744;Inherit;False;Property;_Border;Border;2;0;Create;True;0;0;0;False;0;False;20;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-2229.879,1034.409;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2670.902,1271.195;Inherit;False;Property;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;1.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;18;-2523.025,-184.2614;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;41;-3272.212,-445.3756;Inherit;False;Constant;_Color1;Color 1;6;0;Create;True;0;0;0;False;0;False;0.990566,0.7803044,0.7803044,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-3018.966,57.89645;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;21;-3551.168,-293.4838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2120.022,1261.646;Inherit;False;Property;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;0.17;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-3876.273,8.098782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-2393.772,1292.301;Inherit;False;Property;_exp3;exp3;6;0;Create;True;0;0;0;False;0;False;16;1.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-1538.871,352.7404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-2867.464,-105.3034;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;34;-3564.88,10.87648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;35;-4075.425,-353.0254;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-1944.557,1037.12;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-3862.563,-296.2615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-3717.565,-293.4394;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3528.539,90.49231;Inherit;False;Property;_EXP2;EXP2;1;0;Create;True;0;0;0;False;0;False;3.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;148;-1533.803,675.5721;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;38;-3293.519,225.95;Inherit;False;Constant;_Color0;Color 0;6;0;Create;True;0;0;0;False;0;False;0.8396226,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-3041.876,-243.8312;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2659.86,-112.2207;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-4121.537,-79.51048;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-3508.578,-215.4304;Inherit;False;Property;_EXP;EXP;0;0;Create;True;0;0;0;False;0;False;3.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;15;-3361.679,-307.7304;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;28;-4282.537,-18.51046;Inherit;False;Property;_Vector2;Vector2;4;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;161;-1266.952,346.541;Float;False;True;-1;2;ASEMaterialInspector;0;2;DamageScreen_Effect;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;157;0;156;1
WireConnection;157;1;156;2
WireConnection;43;0;157;0
WireConnection;43;1;45;0
WireConnection;95;0;96;0
WireConnection;135;0;136;0
WireConnection;135;1;43;0
WireConnection;85;0;135;0
WireConnection;141;0;95;0
WireConnection;32;0;31;0
WireConnection;27;0;34;0
WireConnection;27;1;33;0
WireConnection;88;0;43;0
WireConnection;88;1;89;0
WireConnection;69;0;88;0
WireConnection;69;1;81;0
WireConnection;18;0;25;0
WireConnection;36;0;27;0
WireConnection;36;1;38;0
WireConnection;21;0;14;0
WireConnection;31;0;30;1
WireConnection;31;1;29;0
WireConnection;154;0;141;0
WireConnection;154;1;85;0
WireConnection;39;0;40;0
WireConnection;39;1;36;0
WireConnection;34;0;32;0
WireConnection;90;0;69;0
WireConnection;90;1;91;0
WireConnection;9;0;35;1
WireConnection;9;1;11;0
WireConnection;14;0;9;0
WireConnection;40;0;15;0
WireConnection;40;1;41;0
WireConnection;25;0;39;0
WireConnection;25;1;26;0
WireConnection;30;1;28;0
WireConnection;15;0;21;0
WireConnection;15;1;16;0
WireConnection;161;0;154;0
ASEEND*/
//CHKSM=B0BD01CB381D0BE65D6C3706B28F76633CEED484