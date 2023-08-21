// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LowHP_Effect"
{
	Properties
	{
		_ColorBorder("Color Border", Color) = (0.227451,0.02745098,0.003921569,1)
		_AmountCorners("Amount Corners", Float) = 1.65
		_SmoothCorners("Smooth Corners", Float) = 5
		_BlendCorners("Blend Corners", Float) = 0.5
		_SpeedCorners("Speed Corners", Float) = 0
		_IntesityCornersMin("Intesity Corners Min", Float) = 1
		_IntesityCornersMax("Intesity Corners Max", Float) = 1.07
		_Grayscale("Grayscale", Float) = 0.7
		_ScaleNoise("Scale Noise", Float) = 7
		_SpeedNoise("Speed Noise", Float) = 0.1
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
			
			uniform float _Grayscale;
			uniform float4 _ColorBorder;
			uniform float _AmountCorners;
			uniform float _SmoothCorners;
			uniform float _IntesityCornersMin;
			uniform float _IntesityCornersMax;
			uniform float _SpeedCorners;
			uniform float _BlendCorners;
			uniform float _SpeedNoise;
			uniform float _ScaleNoise;


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
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,1,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_193_0 = saturate( tex2D( _MainTex, uv_MainTex ) );
				float grayscale220 = Luminance(temp_output_193_0.rgb);
				float4 temp_cast_1 = (grayscale220).xxxx;
				float4 lerpResult223 = lerp( temp_output_193_0 , temp_cast_1 , _Grayscale);
				float2 appendResult157 = (float2(ase_ppsScreenPosFragNorm.x , ase_ppsScreenPosFragNorm.y));
				float mulTime260 = _Time.y * _SpeedCorners;
				float lerpResult268 = lerp( _IntesityCornersMin , _IntesityCornersMax , sin( ( 1.0 * mulTime260 ) ));
				float myVarName2291 = lerpResult268;
				float MaskMovment293 = ( ( pow( ( distance( appendResult157 , float2( 0.5,0.5 ) ) * _AmountCorners ) , _SmoothCorners ) * myVarName2291 ) - _BlendCorners );
				float mulTime286 = _Time.y * _SpeedNoise;
				float2 texCoord270 = i.texcoord.xy * float2( 1,1 ) + ( float3(0,1,0) * mulTime286 ).xy;
				float simplePerlin2D269 = snoise( texCoord270*_ScaleNoise );
				simplePerlin2D269 = simplePerlin2D269*0.5 + 0.5;
				float A289 = saturate( ( MaskMovment293 * saturate( ( MaskMovment293 + simplePerlin2D269 ) ) ) );
				float4 lerpResult215 = lerp( lerpResult223 , saturate( _ColorBorder ) , A289);
				

				float4 color = saturate( lerpResult215 );
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;847;540;5626.03;1514.495;2.952989;False;False
Node;AmplifyShaderEditor.CommentaryNode;298;-5732.134,-350.4688;Inherit;False;1252.649;399.8829;Comment;3;305;310;309;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-5702.919,-69.29834;Inherit;False;Property;_SpeedCorners;Speed Corners;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;296;-5430.477,-945.4517;Inherit;False;1774.677;461.3735;Comment;13;156;45;157;43;88;69;232;292;90;293;301;302;303;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-5674.931,-190.0377;Inherit;False;Constant;_MSIN;MSIN;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;260;-5525.344,-66.40504;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;156;-5380.477,-895.4517;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-5321.43,-131.6744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;45;-5368.79,-705.8733;Inherit;False;Constant;_CenterMask;Center Mask;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;310;-5139.694,-290.3405;Inherit;False;Property;_IntesityCornersMin;Intesity Corners Min;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;263;-5135.614,-130.7127;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-5134.694,-209.3405;Inherit;False;Property;_IntesityCornersMax;Intesity Corners Max;6;0;Create;True;0;0;0;False;0;False;1.07;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;157;-5200.251,-866.0083;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-5041.056,-601.7054;Inherit;False;Property;_AmountCorners;Amount Corners;1;0;Create;True;0;0;0;False;0;False;1.65;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;43;-5044.718,-866.2483;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;268;-4882.156,-247.4888;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;291;-4703.485,-258.7566;Inherit;False;myVarName2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;299;-4439.367,-343.7608;Inherit;False;1906.039;518.2726;Comment;13;85;294;286;283;284;270;269;274;278;275;295;313;314;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;301;-4778.502,-597.3912;Inherit;False;Property;_SmoothCorners;Smooth Corners;2;0;Create;True;0;0;0;False;0;False;5;1.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-4788.443,-863.0525;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-4399.188,63.61826;Inherit;False;Property;_SpeedNoise;Speed Noise;9;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-4548.944,-859.5143;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;292;-4541.272,-609.3625;Inherit;False;291;myVarName2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;283;-4250.537,-124.4288;Inherit;False;Constant;_VectorNoise;Vector Noise;9;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;303;-4317.738,-600.8901;Inherit;False;Property;_BlendCorners;Blend Corners;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;232;-4279.3,-859.1573;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;286;-4237.98,63.51184;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-4107.609,-861.3379;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;-4062.52,-13.33014;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;293;-3879.8,-865.8412;Inherit;False;MaskMovment;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;314;-3824.188,25.61826;Inherit;False;Property;_ScaleNoise;Scale Noise;8;0;Create;True;0;0;0;False;0;False;7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-3930.569,-118.4557;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;295;-3623.035,-223.9043;Inherit;False;293;MaskMovment;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;269;-3647.629,-135.0098;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;297;-3598.506,-969.9902;Inherit;False;1105.327;513.3486;Comment;9;96;95;193;220;223;218;290;300;312;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;274;-3385.098,-152.1405;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;96;-3548.506,-913.3924;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;294;-3171.956,-292.3763;Inherit;False;293;MaskMovment;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;278;-3166.114,-149.2747;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;95;-3367.292,-919.9902;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-2985.821,-171.3705;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-2699.665,-170.4919;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-3082.113,-913.1905;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-2487.295,-174.2767;Inherit;False;A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;-2886.651,-761.4889;Inherit;False;Property;_Grayscale;Grayscale;7;0;Create;True;0;0;0;False;0;False;0.7;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;300;-3097.219,-665.1548;Inherit;False;Property;_ColorBorder;Color Border;0;0;Create;True;0;0;0;False;0;False;0.227451,0.02745098,0.003921569,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;220;-2906.639,-844.4877;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-2853.62,-588.4664;Inherit;False;289;A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;223;-2675.179,-914.0472;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;218;-2849.982,-662.3019;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;215;-2406.015,-912.9348;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;229;-2248.796,-914.5042;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;180;-2100.786,-923.0764;Float;False;True;-1;2;ASEMaterialInspector;0;2;LowHP_Effect;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;260;0;305;0
WireConnection;266;0;265;0
WireConnection;266;1;260;0
WireConnection;263;0;266;0
WireConnection;157;0;156;1
WireConnection;157;1;156;2
WireConnection;43;0;157;0
WireConnection;43;1;45;0
WireConnection;268;0;310;0
WireConnection;268;1;309;0
WireConnection;268;2;263;0
WireConnection;291;0;268;0
WireConnection;88;0;43;0
WireConnection;88;1;302;0
WireConnection;69;0;88;0
WireConnection;69;1;301;0
WireConnection;232;0;69;0
WireConnection;232;1;292;0
WireConnection;286;0;313;0
WireConnection;90;0;232;0
WireConnection;90;1;303;0
WireConnection;284;0;283;0
WireConnection;284;1;286;0
WireConnection;293;0;90;0
WireConnection;270;1;284;0
WireConnection;269;0;270;0
WireConnection;269;1;314;0
WireConnection;274;0;295;0
WireConnection;274;1;269;0
WireConnection;278;0;274;0
WireConnection;95;0;96;0
WireConnection;275;0;294;0
WireConnection;275;1;278;0
WireConnection;85;0;275;0
WireConnection;193;0;95;0
WireConnection;289;0;85;0
WireConnection;220;0;193;0
WireConnection;223;0;193;0
WireConnection;223;1;220;0
WireConnection;223;2;312;0
WireConnection;218;0;300;0
WireConnection;215;0;223;0
WireConnection;215;1;218;0
WireConnection;215;2;290;0
WireConnection;229;0;215;0
WireConnection;180;0;229;0
ASEEND*/
//CHKSM=A0ED52307A04AA07404F5A8F8ED69214018D7525