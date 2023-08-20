// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SpeedEffect_Shader"
{
	Properties
	{
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_AmountNoise("Amount Noise", Range( 0 , 1)) = 0.6705883
		_SatureNoise("Sature Noise", Range( 0 , 1)) = 0.4269153
		_Alpha("Alpha", Float) = 0.5
		_HardEgdesNoise("Hard Egdes Noise", Range( -1 , 0)) = -0.2
		_Color("Color", Color) = (0.9669811,0.9759491,1,1)
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
			#include "UnityShaderVariables.cginc"
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
			
			uniform float4 _Color;
			uniform float _AmountNoise;
			uniform float _SatureNoise;
			uniform float _HardEgdesNoise;
			uniform sampler2D _NoiseTexture;
			uniform float _Alpha;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

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
				float2 appendResult52 = (float2(ase_ppsScreenPosFragNorm.x , ase_ppsScreenPosFragNorm.y));
				float temp_output_57_0 = ( _AmountNoise * 0.5 );
				float temp_output_1_0_g10 = temp_output_57_0;
				float2 CenteredUV15_g8 = ( i.texcoord.xy - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float cos143 = cos( 86.4 );
				float sin143 = sin( 86.4 );
				float2 rotator143 = mul( appendResult23_g8 - float2( 0.5,0.5 ) , float2x2( cos143 , -sin143 , sin143 , cos143 )) + float2( 0.5,0.5 );
				float simplePerlin2D135 = snoise( (rotator143*float2( 6.32,0.2 ) + ( float3(0,1,0) * _Time.y ).xy)*5.0 );
				simplePerlin2D135 = simplePerlin2D135*0.5 + 0.5;
				float lerpResult146 = lerp( saturate( ( ( distance( appendResult52 , float2( 0.5,0.5 ) ) - temp_output_1_0_g10 ) / ( ( _SatureNoise + temp_output_57_0 ) - temp_output_1_0_g10 ) ) ) , simplePerlin2D135 , _HardEgdesNoise);
				float2 CenteredUV15_g9 = ( i.texcoord.xy - float2( 0.5,0.5 ) );
				float2 break17_g9 = CenteredUV15_g9;
				float2 appendResult23_g9 = (float2(( length( CenteredUV15_g9 ) * 1.0 * 2.0 ) , ( atan2( break17_g9.x , break17_g9.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float cos88 = cos( 86.4 );
				float sin88 = sin( 86.4 );
				float2 rotator88 = mul( appendResult23_g9 - float2( 0.5,0.5 ) , float2x2( cos88 , -sin88 , sin88 , cos88 )) + float2( 0.5,0.5 );
				float4 temp_output_130_0 = ( tex2D( _MainTex, uv_MainTex ) + ( _Color * ( saturate( ( lerpResult146 * tex2D( _NoiseTexture, (rotator88*float2( 6.32,0.2 ) + ( float3(0,1,0) * _Time.y ).xy) ) ) ) * saturate( _Alpha ) ) ) );
				float4 appendResult121 = (float4(temp_output_130_0.rgb , temp_output_130_0.r));
				

				float4 color = appendResult121;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;1021;553;-2399.489;1457.921;1.221802;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;1351.951,-1861.69;Inherit;False;910.5632;660.166;Comment;10;57;55;58;56;59;54;51;50;52;49;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;58;1447.87,-1812.69;Inherit;False;Property;_AmountNoise;Amount Noise;1;0;Create;True;0;0;0;False;0;False;0.6705883;0.6705883;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;1322.969,-352.9977;Inherit;False;1288.977;642.7421;;11;116;117;91;68;92;118;111;88;115;97;64;Move Center;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;136;1650.387,-544.0914;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;51;1401.951,-1534.143;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;1570.625,-1722.122;Inherit;False;Constant;_ILerpA;ILerp A;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;1718.251,-1760.985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;1622.509,-1507.122;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;54;1599.09,-1365.526;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;116;1738.054,168.625;Inherit;False;Constant;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;1427.558,-1641.238;Inherit;False;Property;_SatureNoise;Sature Noise;2;0;Create;True;0;0;0;False;0;False;0.4269153;0.4269153;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;138;1760.926,-690.7934;Inherit;False;Constant;_Vector5;Vector 5;7;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;141;1522.146,-649.9633;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;0;False;0;False;86.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;140;1766.825,-542.2994;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;139;1355.248,-1015.715;Inherit;True;Polar Coordinates;-1;;8;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;137;1448.808,-771.0973;Inherit;False;Constant;_Vector4;Vector 4;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;50;1770.597,-1454.674;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;1988.058,-670.7233;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;118;1778.647,21.9234;Inherit;False;Constant;_Vector3;Vector 3;7;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;143;1807.373,-1010.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;1843.09,-1645.79;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;117;1859.489,178.7444;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;92;1466.529,-58.38063;Inherit;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;144;1810.994,-879.1503;Inherit;False;Constant;_Vector6;Vector 6;7;0;Create;True;0;0;0;False;0;False;6.32,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;91;1647.03,-56.83362;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;86.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;68;1372.969,-302.9977;Inherit;True;Polar Coordinates;-1;;9;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;2015.771,75.3015;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode;88;1828.201,-235.8596;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;49;1997.518,-1673.053;Inherit;True;Inverse Lerp;-1;;10;09cbe79402f023141a4dc1fddd4c9511;0;3;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;145;2052.262,-1013.927;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;111;1823.715,-96.43392;Inherit;False;Constant;_Vector2;Vector 2;7;0;Create;True;0;0;0;False;0;False;6.32,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;135;2296.482,-934.7833;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;2276.261,-702.7228;Inherit;False;Property;_HardEgdesNoise;Hard Egdes Noise;4;0;Create;True;0;0;0;False;0;False;-0.2;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;97;2064.984,-218.2103;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;148;2412.306,-1148.462;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;64;2291.944,-273.409;Inherit;True;Property;_NoiseTexture;Noise Texture;0;0;Create;True;0;0;0;False;0;False;-1;1adb1b7aa225268479537efed0551df3;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;146;2598.73,-1073.59;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;2937.545,-1045.74;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;133;2947.259,-927.48;Inherit;False;Property;_Alpha;Alpha;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;147;3099.985,-943.3555;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;131;3070.084,-1045.562;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;3230.366,-1046.377;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;3223.533,-1364.063;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;129;3109.411,-1222.95;Inherit;False;Property;_Color;Color;5;0;Create;True;0;0;0;False;0;False;0.9669811,0.9759491,1,1;0.9669811,0.9759491,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;3383.927,-1365.571;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;3440.891,-1088.846;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;3717.917,-1114.478;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;3857.692,-1116.732;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;4022.581,-1114.085;Float;False;True;-1;2;ASEMaterialInspector;0;2;SpeedEffect_Shader;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;57;0;58;0
WireConnection;57;1;55;0
WireConnection;52;0;51;1
WireConnection;52;1;51;2
WireConnection;140;0;136;0
WireConnection;50;0;52;0
WireConnection;50;1;54;0
WireConnection;142;0;138;0
WireConnection;142;1;140;0
WireConnection;143;0;139;0
WireConnection;143;1;137;0
WireConnection;143;2;141;0
WireConnection;59;0;56;0
WireConnection;59;1;57;0
WireConnection;117;0;116;0
WireConnection;115;0;118;0
WireConnection;115;1;117;0
WireConnection;88;0;68;0
WireConnection;88;1;92;0
WireConnection;88;2;91;0
WireConnection;49;1;57;0
WireConnection;49;2;59;0
WireConnection;49;3;50;0
WireConnection;145;0;143;0
WireConnection;145;1;144;0
WireConnection;145;2;142;0
WireConnection;135;0;145;0
WireConnection;97;0;88;0
WireConnection;97;1;111;0
WireConnection;97;2;115;0
WireConnection;148;0;49;0
WireConnection;64;1;97;0
WireConnection;146;0;148;0
WireConnection;146;1;135;0
WireConnection;146;2;149;0
WireConnection;120;0;146;0
WireConnection;120;1;64;0
WireConnection;147;0;133;0
WireConnection;131;0;120;0
WireConnection;132;0;131;0
WireConnection;132;1;147;0
WireConnection;1;0;2;0
WireConnection;128;0;129;0
WireConnection;128;1;132;0
WireConnection;130;0;1;0
WireConnection;130;1;128;0
WireConnection;121;0;130;0
WireConnection;121;3;130;0
WireConnection;0;0;121;0
ASEEND*/
//CHKSM=2B4C3194EA98857FEA9A92A9D91F6AB2EC72D2C3