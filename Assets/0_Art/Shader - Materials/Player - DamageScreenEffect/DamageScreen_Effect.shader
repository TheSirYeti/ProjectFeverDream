// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DamageScreen_Effect"
{
	Properties
	{
		_BorderUOne("Border U One", Float) = 30
		_BorderUTwo("Border U Two", Float) = 10
		_BorderVOne("Border V One", Float) = 30
		_BorderVTwo("Border V Two", Float) = 10
		_ColorEmission("Color Emission", Color) = (0.7647059,0.1843137,0.1843137,0)
		_ColorShadow("Color Shadow", Color) = (0.3584906,0,0,0)
		_ControlScreenLeft("ControlScreenLeft", Range( 0 , 1)) = 1
		_ControlScreenRight("ControlScreenRight", Range( 0 , 1)) = 1
		_ControlScreenDown("ControlScreenDown", Range( 0 , 1)) = 1
		_ControlScreenUP("ControlScreenUP", Range( 0 , 1)) = 1

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
			
			uniform float4 _ColorShadow;
			uniform float4 _ColorEmission;
			uniform float _BorderUOne;
			uniform float _ControlScreenLeft;
			uniform float _ControlScreenRight;
			uniform float _BorderVOne;
			uniform float _ControlScreenDown;
			uniform float _ControlScreenUP;
			uniform float _BorderUTwo;
			uniform float _BorderVTwo;


			
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
				float U_TexCoord221 = i.texcoord.xy.x;
				float BorderUOne258 = _BorderUOne;
				float EXPScreen307 = 3.5;
				float V_TexCoord298 = i.texcoord.xy.y;
				float BorderVOne358 = _BorderVOne;
				float4 lerpResult188 = lerp( _ColorShadow , _ColorEmission , ( ( pow( saturate( ( 1.0 - ( U_TexCoord221 * BorderUOne258 ) ) ) , 3.5 ) * _ControlScreenLeft ) + saturate( ( pow( ( 1.0 - ( ( 1.0 - U_TexCoord221 ) * BorderUOne258 ) ) , EXPScreen307 ) * _ControlScreenRight ) ) + saturate( ( pow( saturate( ( 1.0 - ( V_TexCoord298 * BorderVOne358 ) ) ) , EXPScreen307 ) * _ControlScreenDown ) ) + saturate( ( pow( saturate( ( 1.0 - ( ( 1.0 - V_TexCoord298 ) * BorderVOne358 ) ) ) , EXPScreen307 ) * _ControlScreenUP ) ) ));
				float BorderUTwo267 = _BorderUTwo;
				float BorderVTwo360 = _BorderVTwo;
				float4 lerpResult187 = lerp( saturate( tex2D( _MainTex, uv_MainTex ) ) , saturate( lerpResult188 ) , ( ( pow( saturate( ( 1.0 - ( U_TexCoord221 * BorderUTwo267 ) ) ) , 3.5 ) * _ControlScreenLeft ) + saturate( ( pow( ( 1.0 - ( ( 1.0 - U_TexCoord221 ) * BorderUTwo267 ) ) , EXPScreen307 ) * _ControlScreenRight ) ) + saturate( ( pow( saturate( ( 1.0 - ( V_TexCoord298 * BorderVOne358 ) ) ) , EXPScreen307 ) * _ControlScreenDown ) ) + saturate( ( pow( saturate( ( 1.0 - ( ( 1.0 - V_TexCoord298 ) * BorderVTwo360 ) ) ) , EXPScreen307 ) * _ControlScreenUP ) ) ));
				

				float4 color = saturate( lerpResult187 );
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;747;655;5254.849;282.7356;1;False;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;325;-5223.365,-346.3118;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;352;-4711.208,1455.203;Inherit;False;1635.317;590.4203;;21;331;332;350;336;333;335;351;334;338;344;337;343;339;345;341;340;346;342;347;348;349;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-5183.335,108.4997;Inherit;False;Property;_BorderVOne;Border V One;8;0;Create;True;0;0;0;False;0;False;30;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;298;-4992.076,-241.6562;Inherit;False;V_TexCoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;329;-4703.575,809.4089;Inherit;False;1502.935;589.0045;;19;301;302;300;303;312;313;314;304;315;311;310;316;305;309;319;317;320;318;321;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-4995.266,-326.7827;Inherit;False;U_TexCoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;326;-4706.429,211.9696;Inherit;False;1461.519;537.8771;;18;235;287;260;236;264;266;292;308;291;275;262;241;272;286;276;261;273;214;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-4624.814,1505.203;Inherit;False;298;V_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-5004.335,108.4997;Inherit;False;BorderVOne;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-5177.932,-126.4433;Inherit;False;Property;_BorderUOne;Border U One;0;0;Create;True;0;0;0;False;0;False;30;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;302;-4639.83,966.6194;Inherit;False;358;BorderVOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-4643.086,261.9696;Inherit;False;221;U_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-4637.681,859.4089;Inherit;False;298;V_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-5182.335,204.4998;Inherit;False;Property;_BorderVTwo;Border V Two;9;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;350;-4430.386,1511.477;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;-4508.002,1610.997;Inherit;False;358;BorderVOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-4996.88,-127.3067;Inherit;False;BorderUOne;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;327;-4703.794,-399.646;Inherit;False;1424.55;549.8545;;17;16;299;259;9;268;14;222;21;31;205;15;32;34;209;27;211;307;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;336;-4661.208,1780.308;Inherit;False;298;V_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-4273.712,1508.53;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;287;-4455.681,266.8601;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-4643.871,-349.646;Inherit;False;221;U_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-4656.429,356.7962;Inherit;False;258;BorderUOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;-4405.54,864.1523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-4361.656,-188.3431;Inherit;False;Constant;_EXPScreen;EXPScreen;0;0;Create;True;0;0;0;False;0;False;3.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-5008.847,201.2656;Inherit;False;BorderVTwo;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-5181.446,-36.77982;Inherit;False;Property;_BorderUTwo;Border U Two;1;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;259;-4646.794,-210.0761;Inherit;False;258;BorderUOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;267;-4994.324,-28.73732;Inherit;False;BorderUTwo;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-4643.355,536.9449;Inherit;False;221;U_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-4426.486,-321.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-4282.974,267.4193;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-4636.426,1128.849;Inherit;False;298;V_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;351;-4477.114,1786.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;-4639.575,1236.059;Inherit;False;358;BorderVOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;303;-4270.463,862.123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-4088.976,-186.3445;Inherit;False;EXPScreen;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;334;-4145.712,1509.333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;-4528.825,1883.269;Inherit;False;360;BorderVTwo;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-4294.535,1780.802;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;-4642.866,38.23017;Inherit;False;267;BorderUTwo;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;292;-4131.156,265.9977;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-4169.534,398.9673;Inherit;False;307;EXPScreen;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;338;-4000.738,1508.482;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-4149.124,973.605;Inherit;False;307;EXPScreen;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;-4024.376,1620.815;Inherit;False;307;EXPScreen;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-4289.741,-320.8267;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;291;-4467.953,539.9248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;304;-4125.486,861.2716;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;314;-4419.285,1133.592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-4644.587,633.8466;Inherit;False;267;BorderUTwo;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-4638.953,-53.86147;Inherit;False;221;U_TexCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-4425.406,-25.20729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-3690.448,1660.252;Inherit;False;Property;_ControlScreenUP;ControlScreenUP;7;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;315;-4284.208,1131.563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;305;-3916.593,860.4845;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;-4159.458,1778.773;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-4279.448,541.3646;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-3815.195,1013.042;Inherit;False;Property;_ControlScreenDown;ControlScreenDown;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;275;-3875.549,397.6379;Inherit;False;Property;_ControlScreenRight;ControlScreenRight;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;343;-3791.845,1507.695;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;-4121.267,-319.8784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;241;-3924.768,269.3983;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;15;-3955.55,-319.9385;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;-4136.349,1929.623;Inherit;False;307;EXPScreen;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-3404.94,1513.366;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-4261.099,1282.413;Inherit;False;307;EXPScreen;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;341;-4014.483,1777.921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;286;-4141.876,536.6829;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-3799.677,-200.2173;Inherit;False;Property;_ControlScreenLeft;ControlScreenLeft;4;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;-4139.231,1130.711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;-3529.687,866.1557;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-4266.409,-26.25427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-3573.779,266.3327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;316;-3927.641,1129.136;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;347;-3240.893,1511.405;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;276;-3410.635,265.5529;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-3445.13,-320.1159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;-4048.013,-52.42959;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;320;-3365.64,864.1949;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;261;-3928.247,525.7434;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;342;-3802.894,1776.346;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-2886.583,-517.2625;Inherit;False;Property;_ColorEmission;Color Emission;2;0;Create;True;0;0;0;False;0;False;0.7647059,0.1843137,0.1843137,0;0.990566,0.7803044,0.7803044,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;38;-2884.6,-702.5571;Inherit;False;Property;_ColorShadow;Color Shadow;3;0;Create;True;0;0;0;False;0;False;0.3584906,0,0,0;0.1886792,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-3411.71,1774.853;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;318;-3536.457,1127.643;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-3579.334,524.3533;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;-2847.375,-322.7537;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;96;-2881.913,-929.7158;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;27;-3904.298,-66.67616;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;188;-2562.962,-541.3246;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;349;-3251.594,1769.736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;214;-3409.91,524.1083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-3441.244,-65.16988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;321;-3376.341,1122.526;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;95;-2734.37,-933.5447;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;297;-2835.073,520.0959;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-2428.483,-927.7511;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;192;-2324.223,-542.4257;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;187;-2118.682,-560.0733;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;219;-1881.434,-560.094;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;180;-1748.441,-560.1077;Float;False;True;-1;2;ASEMaterialInspector;0;2;DamageScreen_Effect;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;298;0;325;2
WireConnection;221;0;325;1
WireConnection;358;0;354;0
WireConnection;350;0;331;0
WireConnection;258;0;11;0
WireConnection;333;0;350;0
WireConnection;333;1;332;0
WireConnection;287;0;235;0
WireConnection;300;0;301;0
WireConnection;300;1;302;0
WireConnection;360;0;356;0
WireConnection;267;0;29;0
WireConnection;9;0;299;0
WireConnection;9;1;259;0
WireConnection;236;0;287;0
WireConnection;236;1;260;0
WireConnection;351;0;336;0
WireConnection;303;0;300;0
WireConnection;307;0;16;0
WireConnection;334;0;333;0
WireConnection;337;0;351;0
WireConnection;337;1;335;0
WireConnection;292;0;236;0
WireConnection;338;0;334;0
WireConnection;14;0;9;0
WireConnection;291;0;264;0
WireConnection;304;0;303;0
WireConnection;314;0;313;0
WireConnection;314;1;312;0
WireConnection;31;0;222;0
WireConnection;31;1;268;0
WireConnection;315;0;314;0
WireConnection;305;0;304;0
WireConnection;305;1;309;0
WireConnection;339;0;337;0
WireConnection;262;0;291;0
WireConnection;262;1;266;0
WireConnection;343;0;338;0
WireConnection;343;1;344;0
WireConnection;21;0;14;0
WireConnection;241;0;292;0
WireConnection;241;1;308;0
WireConnection;15;0;21;0
WireConnection;15;1;16;0
WireConnection;346;0;343;0
WireConnection;346;1;345;0
WireConnection;341;0;339;0
WireConnection;286;0;262;0
WireConnection;310;0;315;0
WireConnection;317;0;305;0
WireConnection;317;1;319;0
WireConnection;32;0;31;0
WireConnection;272;0;241;0
WireConnection;272;1;275;0
WireConnection;316;0;310;0
WireConnection;316;1;311;0
WireConnection;347;0;346;0
WireConnection;276;0;272;0
WireConnection;209;0;15;0
WireConnection;209;1;205;0
WireConnection;34;0;32;0
WireConnection;320;0;317;0
WireConnection;261;0;286;0
WireConnection;261;1;308;0
WireConnection;342;0;341;0
WireConnection;342;1;340;0
WireConnection;348;0;342;0
WireConnection;348;1;345;0
WireConnection;318;0;316;0
WireConnection;318;1;319;0
WireConnection;273;0;261;0
WireConnection;273;1;275;0
WireConnection;296;0;209;0
WireConnection;296;1;276;0
WireConnection;296;2;320;0
WireConnection;296;3;347;0
WireConnection;27;0;34;0
WireConnection;27;1;16;0
WireConnection;188;0;38;0
WireConnection;188;1;41;0
WireConnection;188;2;296;0
WireConnection;349;0;348;0
WireConnection;214;0;273;0
WireConnection;211;0;27;0
WireConnection;211;1;205;0
WireConnection;321;0;318;0
WireConnection;95;0;96;0
WireConnection;297;0;211;0
WireConnection;297;1;214;0
WireConnection;297;2;321;0
WireConnection;297;3;349;0
WireConnection;193;0;95;0
WireConnection;192;0;188;0
WireConnection;187;0;193;0
WireConnection;187;1;192;0
WireConnection;187;2;297;0
WireConnection;219;0;187;0
WireConnection;180;0;219;0
ASEEND*/
//CHKSM=1AF19BEA993BBEDB171E64A8F855C2FA0287BD37