// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PhoenixWall"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 6.83
		[Header(Texture)]_NoisePrimary("NoisePrimary", 2D) = "white" {}
		_NoiseSecondary("NoiseSecondary", 2D) = "white" {}
		_NoiseSmoke("NoiseSmoke", 2D) = "white" {}
		_TexturedLine("Textured Line", 2D) = "white" {}
		[Header(FlowMaps)]_FlowMapLine("FlowMap Line", 2D) = "white" {}
		_FlowMapEgdes("FlowMap Egdes", 2D) = "white" {}
		[Header(Height  W5idth)]_MaskPainting("MaskPainting", Range( 0.2 , 0.5)) = 0.3
		_EgdesAmountHorizontal("Egdes Amount Horizontal", Range( -4 , 11.4)) = 1
		_HigherFlame("HigherFlame", Range( 0 , 1)) = 0
		[HDR][Header(Color)]_HighFlameOne("High Flame One", Color) = (1,0.4156863,0.3333333,0)
		[HDR]_HighFlameTwo("High Flame Two", Color) = (0.4509804,0.04705882,0,1)
		_LowFlameOne("Low Flame One", Color) = (1,0.4156863,0.3333333,1)
		[HDR]_LowFlameTwo("Low Flame Two", Color) = (1,0.9058824,0.6470588,1)
		_Intensity("Intensity", Range( 0 , 2)) = 1.1
		_SpeedNoisePrimary("SpeedNoisePrimary", Vector) = (1,1,0,0)
		_SpeedNoiseSecondary("SpeedNoiseSecondary", Vector) = (1,1,0,0)
		_IntesityMask("IntesityMask", Float) = 0.43
		_EdgesLowFlame("EdgesLowFlame", Float) = 0.35
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _HighFlameOne;
		uniform float4 _HighFlameTwo;
		uniform sampler2D _NoisePrimary;
		uniform float2 _SpeedNoisePrimary;
		uniform sampler2D _NoiseSecondary;
		uniform float2 _SpeedNoiseSecondary;
		uniform float _Intensity;
		uniform float _MaskPainting;
		uniform sampler2D _NoiseSmoke;
		uniform float4 _NoiseSmoke_ST;
		uniform float _HigherFlame;
		uniform float4 _LowFlameOne;
		uniform float4 _LowFlameTwo;
		uniform float _IntesityMask;
		uniform float _EdgesLowFlame;
		uniform sampler2D _TexturedLine;
		uniform sampler2D _FlowMapLine;
		uniform float _EgdesAmountHorizontal;
		uniform sampler2D _FlowMapEgdes;
		uniform float _Cutoff = 6.83;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 TextureCoordinates530 = i.uv_texcoord;
			float2 panner525 = ( 1.0 * _Time.y * _SpeedNoisePrimary + TextureCoordinates530);
			float2 panner526 = ( 1.0 * _Time.y * _SpeedNoiseSecondary + TextureCoordinates530);
			float NoiseTogether540 = ( tex2D( _NoisePrimary, panner525 ).r * ( tex2D( _NoiseSecondary, panner526 ).r * _Intensity ) );
			float VertexTexCoordV550 = i.uv_texcoord.y;
			float2 uv_NoiseSmoke = i.uv_texcoord * _NoiseSmoke_ST.xy + _NoiseSmoke_ST.zw;
			float SmokedMask570 = saturate( ( ( saturate( NoiseTogether540 ) + saturate( ( VertexTexCoordV550 + _MaskPainting ) ) ) * pow( tex2D( _NoiseSmoke, uv_NoiseSmoke ).g , -0.15 ) * 0.69 ) );
			float MaskFlameHigh627 = saturate( ( saturate( ( ( 1.0 - NoiseTogether540 ) + 1.0 ) ) * SmokedMask570 * saturate( ( VertexTexCoordV550 + _HigherFlame ) ) ) );
			float4 lerpResult693 = lerp( saturate( _HighFlameOne ) , saturate( _HighFlameTwo ) , MaskFlameHigh627);
			float MaskFlameLow630 = saturate( ( (0.8 + (VertexTexCoordV550 - 1.1) * (-0.45 - 0.8) / (0.4 - 1.1)) + ( saturate( ( ( saturate( NoiseTogether540 ) + saturate( ( VertexTexCoordV550 + -0.36 ) ) ) * pow( SmokedMask570 , _IntesityMask ) ) ) - _EdgesLowFlame ) ) );
			float4 lerpResult699 = lerp( saturate( _LowFlameOne ) , saturate( _LowFlameTwo ) , MaskFlameLow630);
			float4 temp_output_705_0 = saturate( lerpResult699 );
			float4 lerpResult703 = lerp( saturate( lerpResult693 ) , temp_output_705_0 , MaskFlameLow630);
			float2 panner641 = ( 1.0 * _Time.y * float2( 0,0.7 ) + TextureCoordinates530);
			float2 temp_cast_1 = (1.0).xx;
			float2 panner638 = ( 1.0 * _Time.y * temp_cast_1 + TextureCoordinates530);
			float4 lerpResult637 = lerp( float4( panner641, 0.0 , 0.0 ) , tex2D( _FlowMapLine, panner638 ) , 0.05);
			float4 LineMask657 = saturate( ( saturate( tex2D( _TexturedLine, lerpResult637.rg ) ) * saturate( (1.2 + (VertexTexCoordV550 - 1.18) * (0.4 - 1.2) / (0.71 - 1.18)) ) ) );
			float4 lerpResult709 = lerp( saturate( lerpResult703 ) , temp_output_705_0 , LineMask657);
			float4 Emission713 = lerpResult709;
			o.Emission = Emission713.rgb;
			o.Alpha = 1;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 temp_cast_4 = (ase_vertex3Pos.z).xx;
			float2 temp_cast_5 = (0.3).xx;
			float2 panner679 = ( 1.0 * _Time.y * temp_cast_5 + TextureCoordinates530);
			float2 temp_cast_7 = (0.1).xx;
			float2 panner673 = ( 1.0 * _Time.y * temp_cast_7 + TextureCoordinates530);
			float4 lerpResult680 = lerp( float4( panner679, 0.0 , 0.0 ) , tex2D( _FlowMapEgdes, panner673 ) , 0.5);
			float EgdesMask683 = saturate( ( 1.0 - ( ( distance( temp_cast_4 , float2( 0,0 ) ) + ( 1.0 - _EgdesAmountHorizontal ) ) * tex2D( _NoisePrimary, lerpResult680.rg ).r ) ) );
			clip( saturate( ( ( MaskFlameHigh627 + MaskFlameLow630 + LineMask657 ) * EgdesMask683 ) ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;891;614;1589.61;6171.292;1.521673;True;False
Node;AmplifyShaderEditor.CommentaryNode;778;-4905.421,-6763.103;Inherit;False;563.21;756.3154;Comment;10;529;530;549;550;719;722;721;723;548;545;Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;529;-4851.818,-6712.103;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;624;-4318.112,-6769.414;Inherit;False;1534.078;1249.698;Comment;28;563;546;561;559;552;566;557;564;551;558;553;554;536;526;525;539;528;527;562;534;535;538;531;540;537;569;570;567;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;530;-4635.818,-6713.103;Inherit;False;TextureCoordinates;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;536;-4181.146,-6413.174;Inherit;False;Property;_SpeedNoiseSecondary;SpeedNoiseSecondary;25;0;Create;True;0;0;0;False;0;False;1,1;0.5,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;535;-4190.015,-6488.27;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;534;-4187.58,-6625.723;Inherit;False;Property;_SpeedNoisePrimary;SpeedNoisePrimary;24;0;Create;True;0;0;0;False;0;False;1,1;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;526;-3915.413,-6483.731;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;-4196.448,-6700.819;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;525;-3918.733,-6696.09;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-3699.916,-6310;Inherit;False;Property;_Intensity;Intensity;23;0;Create;True;0;0;0;False;0;False;1.1;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;527;-3725.065,-6510.166;Inherit;True;Property;_NoiseSecondary;NoiseSecondary;2;0;Create;True;0;0;0;False;0;False;-1;None;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;528;-3725.892,-6719.414;Inherit;True;Property;_NoisePrimary;NoisePrimary;1;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;0d8d0814bb62dad4e95ac3acc389a961;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-3417.354,-6483.299;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;549;-4836.901,-6162.788;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;550;-4642.165,-6160.63;Inherit;False;VertexTexCoordV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;537;-3253.969,-6690.983;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;551;-4225.458,-6128.21;Inherit;False;550;VertexTexCoordV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;552;-4272.458,-6032.211;Inherit;False;Property;_MaskPainting;MaskPainting;15;1;[Header];Create;True;1;Height  W5idth;0;0;False;0;False;0.3;0.2;0.2;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;540;-3032.033,-6689.211;Inherit;False;NoiseTogether;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;546;-3983.311,-6123.89;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;558;-3983.842,-6200.354;Inherit;False;540;NoiseTogether;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;561;-4268.113,-5850.148;Inherit;True;Property;_NoiseSmoke;NoiseSmoke;3;0;Create;True;0;0;0;False;0;False;-1;None;e55aca2a6ff2b0d4ea6e7b26f6e7a265;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;562;-3986.514,-5845.263;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;557;-3770.841,-6132.354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;564;-3950.948,-5634.927;Inherit;False;Constant;_Higherexp;Higher exp;41;0;Create;True;0;0;0;False;0;False;-0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;553;-3768.383,-6054.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-3726.014,-5634.716;Inherit;False;Constant;_IntesetyFlame;IntesetyFlame;29;0;Create;True;0;0;0;False;0;False;0.69;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;563;-3730.218,-5821.658;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;554;-3620.558,-6109.022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;631;-2741.918,-6773.38;Inherit;False;1955.239;802.4146;Comment;23;598;599;600;602;603;604;606;607;608;609;610;611;612;613;615;616;617;618;619;614;620;622;630;Mask Flame Low;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;-3470.789,-6109.168;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;600;-2682.556,-6215.55;Inherit;False;Constant;_MaskLowFlame;MaskLowFlame;31;0;Create;True;0;0;0;False;0;False;-0.36;-0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;569;-3259.228,-6109.405;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;598;-2691.918,-6291.006;Inherit;False;550;VertexTexCoordV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;-3118.935,-6117.404;Inherit;False;SmokedMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;599;-2454.555,-6287.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;604;-2545.958,-6405.044;Inherit;False;540;NoiseTogether;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;602;-2334.241,-6288.591;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;610;-2421.711,-6085.965;Inherit;False;Property;_IntesityMask;IntesityMask;26;0;Create;True;0;0;0;False;0;False;0.43;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;606;-2335.958,-6400.044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;628;-2733.758,-5866.104;Inherit;False;1296.695;431.0547;Comment;14;588;586;585;587;589;591;590;592;594;593;596;597;623;627;Mask Flame High;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;609;-2448.424,-6160.351;Inherit;False;570;SmokedMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;603;-2184.459,-6313.727;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;-2651.96,-5550.049;Inherit;False;Property;_HigherFlame;HigherFlame;17;0;Create;True;0;0;0;False;0;False;0;0.6935008;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;-2683.758,-5816.104;Inherit;False;540;NoiseTogether;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;592;-2596.392,-5628.711;Inherit;False;550;VertexTexCoordV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;608;-2235.125,-6158.687;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;607;-2047.796,-6310.277;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;586;-2463.24,-5810.894;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-2477.988,-5740.147;Inherit;False;Constant;_HigherFixed;HigherFixed;40;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;593;-2353.959,-5625.049;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;-2002.663,-6507.498;Inherit;False;Constant;_MinNewMask;MinNewMask;41;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;587;-2295.504,-5811.64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;616;-2002.663,-6648.498;Inherit;False;Constant;_MinOldMask;MinOldMask;41;0;Create;True;0;0;0;False;0;False;1.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;596;-2232.621,-5625.533;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;619;-2001.663,-6436.498;Inherit;False;Constant;_MaxNewMask;MaxNewMask;41;0;Create;True;0;0;0;False;0;False;-0.45;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;684;-2718.563,-5371.639;Inherit;False;2042.796;777.396;Comment;20;675;674;676;679;673;678;680;671;670;663;666;664;667;668;669;681;682;683;717;787;EgdesMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;611;-1846.175,-6309.878;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;658;-4865.644,-5448.529;Inherit;False;2081.487;810.6035;Comment;21;638;639;640;642;644;645;633;641;637;634;647;651;650;649;652;648;653;654;655;657;786;Line Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-1848.601,-6223.016;Inherit;False;Property;_EdgesLowFlame;EdgesLowFlame;27;0;Create;True;0;0;0;False;0;False;0.35;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;617;-2003.663,-6575.498;Inherit;False;Constant;_MaxOldMask;MaxOldMask;41;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;614;-2070.304,-6723.38;Inherit;False;550;VertexTexCoordV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;640;-4800.16,-5171.012;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;612;-1619.601,-6314.016;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;674;-2668.563,-4803.827;Inherit;False;Constant;_SpeedMask;Speed Mask;43;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;589;-2174.214,-5810.07;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-2281.129,-5712.908;Inherit;False;570;SmokedMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;615;-1700.033,-6626.254;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;639;-4815.644,-5098.227;Inherit;False;Constant;_SpeedFlowMapLine;Speed FlowMap Line;43;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;675;-2653.08,-4876.612;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;597;-2064.622,-5691.533;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-2437.299,-5104.129;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;-2032.044,-5809.441;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;642;-4584.38,-5398.529;Inherit;False;530;TextureCoordinates;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;673;-2367.689,-4871.874;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;717;-2439.016,-5032.112;Inherit;False;Constant;_SpeedDistortionMask1;Speed Distortion Mask 1;50;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;620;-1378.325,-6467.202;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;638;-4514.77,-5166.274;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;644;-4540.98,-5307.329;Inherit;False;Constant;_SpeedDistortion;Speed Distortion;43;0;Create;True;0;0;0;False;0;False;0,0.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;786;-4334.556,-5221.417;Inherit;True;Property;_FlowMapLine;FlowMap Line;13;1;[Header];Create;True;1;FlowMaps;0;0;False;0;False;-1;None;7bdfa49f68e9b2441b54a6d151567d0b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;623;-1831.96,-5806.996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;678;-2076.725,-4709.243;Inherit;False;Constant;_Distortion2;Distortion 2;32;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;622;-1176.558,-6468.008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;787;-2193.116,-4900.739;Inherit;True;Property;_FlowMapEgdes;FlowMap Egdes;14;0;Create;True;0;0;0;False;0;False;-1;None;7bdfa49f68e9b2441b54a6d151567d0b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;641;-4306.182,-5393.329;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;645;-4310.805,-4994.643;Inherit;False;Constant;_DistortionFlowMapLine;DistortionFlowMapLine;31;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;663;-1820.21,-5321.639;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;666;-1814.968,-5175.796;Inherit;False;Constant;_PositionPlane;PositionPlane;44;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;669;-1870.968,-5056.796;Inherit;False;Property;_EgdesAmountHorizontal;Egdes Amount Horizontal;16;0;Create;True;0;0;0;False;0;False;1;0.4;-4;11.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;679;-2159.102,-5098.929;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;664;-1616.967,-5239.796;Inherit;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;651;-3990.757,-4829.925;Inherit;False;Constant;_MinNewLineMask;MinNew Line Mask;44;0;Create;True;0;0;0;False;0;False;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;650;-3996.757,-4907.925;Inherit;False;Constant;_MaxoldLineMask;Maxold Line Mask;44;0;Create;True;0;0;0;False;0;False;0.71;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;680;-1880.155,-4930.547;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;714;-4405.573,-4544.109;Inherit;False;1604.194;954.0361;Comment;24;702;699;698;697;695;693;694;691;692;704;705;701;703;706;708;709;711;712;710;713;788;790;791;792;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;647;-3993.046,-5056.106;Inherit;False;550;VertexTexCoordV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;652;-3987.757,-4752.925;Inherit;False;Constant;_MaxNewLineMask;MaxNew Line Mask;44;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;630;-1035.679,-6475.162;Inherit;False;MaskFlameLow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-3996.757,-4981.925;Inherit;False;Constant;_MinoldLineMask;Minold Line Mask;44;0;Create;True;0;0;0;False;0;False;1.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;668;-1608.967,-5053.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;627;-1691.063,-5809.371;Inherit;False;MaskFlameHigh;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;637;-4007.275,-5241.321;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;790;-4349.981,-4326.844;Inherit;False;Property;_HighFlameTwo;High Flame Two;20;1;[HDR];Create;True;0;0;0;False;0;False;0.4509804,0.04705882,0,1;0.4509804,0.04705882,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;671;-1728.054,-4956.919;Inherit;True;Property;_TextureSample7;Texture Sample 7;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;528;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;701;-4349.098,-3705.074;Inherit;False;630;MaskFlameLow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;667;-1464.967,-5239.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;791;-4361.73,-4060.191;Inherit;False;Property;_LowFlameOne;Low Flame One;21;0;Create;True;0;0;0;False;0;False;1,0.4156863,0.3333333,1;1,0.4156863,0.3333333,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;633;-3846.035,-5270.108;Inherit;True;Property;_TexturedLine;Textured Line;12;0;Create;True;0;0;0;False;0;False;-1;None;2cd6dde56b14f9247a1687185effb286;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;792;-4361.674,-3881.93;Inherit;False;Property;_LowFlameTwo;Low Flame Two;22;1;[HDR];Create;True;0;0;0;False;0;False;1,0.9058824,0.6470588,1;1,0.9058824,0.6470588,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;648;-3725.447,-4979.506;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;788;-4351.224,-4497.264;Inherit;False;Property;_HighFlameOne;High Flame One;19;2;[HDR];[Header];Create;True;1;Color;0;0;False;0;False;1,0.4156863,0.3333333,0;1,0.4156863,0.3333333,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;694;-4341.088,-4152.409;Inherit;False;627;MaskFlameHigh;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;697;-4134.264,-4042.797;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;692;-4102.288,-4323.444;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;695;-4028.087,-4160.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;691;-4115.146,-4485.411;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;634;-3546.569,-5189.747;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;670;-1342.416,-5241.579;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;-4138.35,-3874.827;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;702;-4050.875,-3706.453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;653;-3548.741,-4981.727;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;681;-1210.639,-5241.78;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;693;-3933.956,-4346.628;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;654;-3371.8,-5108.967;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;699;-3968.377,-3896.208;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;704;-3775.115,-4213.144;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;682;-1057.626,-5242.896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;706;-3775.069,-3925.621;Inherit;False;630;MaskFlameLow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;705;-3773.427,-4015.687;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;655;-3171.814,-5108.196;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;711;-3558.058,-3989.461;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;657;-3027.158,-5111.32;Inherit;False;LineMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;683;-918.7683,-5246.294;Inherit;False;EgdesMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;703;-3527.244,-4137.699;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;712;-3335.735,-4003.356;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;708;-3376.242,-4135.998;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;686;-1353.41,-5491.118;Inherit;False;683;EgdesMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;660;-1363.249,-5729.658;Inherit;False;627;MaskFlameHigh;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;661;-1367.249,-5655.658;Inherit;False;630;MaskFlameLow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;662;-1362.249,-5581.658;Inherit;False;657;LineMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;710;-3487.85,-3915.981;Inherit;False;657;LineMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;709;-3199.392,-4136.909;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;659;-1131.705,-5678.457;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;687;-1080.41,-5506.118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;713;-3044.378,-4137.59;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;685;-990.005,-5674.656;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;715;-893.7389,-5878.424;Inherit;False;713;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;688;-838.24,-5695.429;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;270;674.6106,2902.456;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;246;722.9166,3162.839;Inherit;False;Constant;_VectorMovimientoXV;Vector Movimiento X V;20;0;Create;True;0;0;0;False;0;False;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;373;2107.844,1841.867;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;254;232.0916,2330.535;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;271;427.9606,2563.812;Inherit;False;Constant;_VectorMovimientoXU;Vector Movimiento X U;22;0;Create;True;0;0;0;False;0;False;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;375;444.0796,1835.678;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;566;-3760.393,-5917.365;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;259;432.1726,2446.733;Inherit;False;1;0;FLOAT;21;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;250;645.9266,2086.188;Inherit;False;Property;_IntesidadenYU;Intesidad en Y U;18;0;Create;True;0;0;0;False;0;False;0;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;258;458.9167,2282.147;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;233.4666,3801.316;Inherit;False;Property;_SpeedIntesidadenXV;Speed Intesidad en X V;4;0;Create;True;0;0;0;False;0;False;1;3;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;248;655.8496,1923.239;Inherit;False;Constant;_VectorMovimientoYU;Vector Movimiento Y U;25;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;257;245.8176,2406.948;Inherit;False;Property;_Float16;Float 16;7;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;245;715.9507,3315.692;Inherit;False;Property;_IntesidadenXV;Intesidad en X V;11;0;Create;True;0;0;0;False;0;False;0;0.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;141.9636,2499.606;Inherit;False;Property;_SpeedIntesidadenYU;Speed Intesidad en Y U;6;0;Create;True;0;0;0;False;0;False;1;5;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;260;608.0156,2334.447;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;267;287.9686,3174.442;Inherit;False;1;0;FLOAT;21;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;65.6096,3109.454;Inherit;False;Property;_Float21;Float 21;9;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;252;1477.873,2234.11;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;301.5106,2918.646;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;262;36.28257,3035.442;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;251;1619.785,2236.591;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;253;697.8107,3638.53;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;491.4147,2920.542;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;719;-4853.687,-6590.589;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;263;26.38364,3216.076;Inherit;False;Property;_SpeedIntesidadenXU;Speed Intesidad en X U;5;0;Create;True;0;0;0;False;0;False;1;1;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-4632.211,-6460.043;Inherit;False;TextureCoordinatesV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;247;908.6096,3478.83;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;548;-4644.838,-6281.717;Inherit;False;VertexTexCoordU;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;545;-4839.574,-6283.874;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;1814.218,1841.588;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;548.7126,3586.229;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;240;299.8016,3488.406;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;269;377.1957,2735.866;Inherit;False;Property;_IntesidadenXU;Intesidad en X U;10;0;Create;True;0;0;0;False;0;False;0;0.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;335.6115,3711.03;Inherit;False;Property;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;2;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;241;321.8866,3634.619;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;243;521.9686,3750.816;Inherit;False;1;0;FLOAT;21;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;1116.005,2000.24;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;261;818.8146,2174.747;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;762;-2646.396,-3149.416;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;763;-2624.396,-3078.416;Inherit;False;Constant;_Multipler;Multipler;29;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;1189.946,3183.089;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;264;-6.654457,2901.682;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;721;-4636.259,-6590.229;Inherit;False;TextureCoordinatesU;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;955.9487,2606.715;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;256;155.5506,2093.564;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;722;-4855.421,-6462.331;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;794;-670.4209,-5931;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;PhoenixWall;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;6.83;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;1;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;530;0;529;0
WireConnection;526;0;535;0
WireConnection;526;2;536;0
WireConnection;525;0;531;0
WireConnection;525;2;534;0
WireConnection;527;1;526;0
WireConnection;528;1;525;0
WireConnection;538;0;527;1
WireConnection;538;1;539;0
WireConnection;550;0;549;2
WireConnection;537;0;528;1
WireConnection;537;1;538;0
WireConnection;540;0;537;0
WireConnection;546;0;551;0
WireConnection;546;1;552;0
WireConnection;562;0;561;0
WireConnection;557;0;558;0
WireConnection;553;0;546;0
WireConnection;563;0;562;1
WireConnection;563;1;564;0
WireConnection;554;0;557;0
WireConnection;554;1;553;0
WireConnection;559;0;554;0
WireConnection;559;1;563;0
WireConnection;559;2;567;0
WireConnection;569;0;559;0
WireConnection;570;0;569;0
WireConnection;599;0;598;0
WireConnection;599;1;600;0
WireConnection;602;0;599;0
WireConnection;606;0;604;0
WireConnection;603;0;606;0
WireConnection;603;1;602;0
WireConnection;608;0;609;0
WireConnection;608;1;610;0
WireConnection;607;0;603;0
WireConnection;607;1;608;0
WireConnection;586;0;585;0
WireConnection;593;0;592;0
WireConnection;593;1;594;0
WireConnection;587;0;586;0
WireConnection;587;1;588;0
WireConnection;596;0;593;0
WireConnection;611;0;607;0
WireConnection;612;0;611;0
WireConnection;612;1;613;0
WireConnection;589;0;587;0
WireConnection;615;0;614;0
WireConnection;615;1;616;0
WireConnection;615;2;617;0
WireConnection;615;3;618;0
WireConnection;615;4;619;0
WireConnection;597;0;596;0
WireConnection;591;0;589;0
WireConnection;591;1;590;0
WireConnection;591;2;597;0
WireConnection;673;0;675;0
WireConnection;673;2;674;0
WireConnection;620;0;615;0
WireConnection;620;1;612;0
WireConnection;638;0;640;0
WireConnection;638;2;639;0
WireConnection;786;1;638;0
WireConnection;623;0;591;0
WireConnection;622;0;620;0
WireConnection;787;1;673;0
WireConnection;641;0;642;0
WireConnection;641;2;644;0
WireConnection;679;0;676;0
WireConnection;679;2;717;0
WireConnection;664;0;663;3
WireConnection;664;1;666;0
WireConnection;680;0;679;0
WireConnection;680;1;787;0
WireConnection;680;2;678;0
WireConnection;630;0;622;0
WireConnection;668;0;669;0
WireConnection;627;0;623;0
WireConnection;637;0;641;0
WireConnection;637;1;786;0
WireConnection;637;2;645;0
WireConnection;671;1;680;0
WireConnection;667;0;664;0
WireConnection;667;1;668;0
WireConnection;633;1;637;0
WireConnection;648;0;647;0
WireConnection;648;1;649;0
WireConnection;648;2;650;0
WireConnection;648;3;651;0
WireConnection;648;4;652;0
WireConnection;697;0;791;0
WireConnection;692;0;790;0
WireConnection;695;0;694;0
WireConnection;691;0;788;0
WireConnection;634;0;633;0
WireConnection;670;0;667;0
WireConnection;670;1;671;1
WireConnection;698;0;792;0
WireConnection;702;0;701;0
WireConnection;653;0;648;0
WireConnection;681;0;670;0
WireConnection;693;0;691;0
WireConnection;693;1;692;0
WireConnection;693;2;695;0
WireConnection;654;0;634;0
WireConnection;654;1;653;0
WireConnection;699;0;697;0
WireConnection;699;1;698;0
WireConnection;699;2;702;0
WireConnection;704;0;693;0
WireConnection;682;0;681;0
WireConnection;705;0;699;0
WireConnection;655;0;654;0
WireConnection;711;0;705;0
WireConnection;657;0;655;0
WireConnection;683;0;682;0
WireConnection;703;0;704;0
WireConnection;703;1;705;0
WireConnection;703;2;706;0
WireConnection;712;0;711;0
WireConnection;708;0;703;0
WireConnection;709;0;708;0
WireConnection;709;1;712;0
WireConnection;709;2;710;0
WireConnection;659;0;660;0
WireConnection;659;1;661;0
WireConnection;659;2;662;0
WireConnection;687;0;686;0
WireConnection;713;0;709;0
WireConnection;685;0;659;0
WireConnection;685;1;687;0
WireConnection;688;0;685;0
WireConnection;270;0;268;0
WireConnection;373;0;372;0
WireConnection;375;0;256;2
WireConnection;566;0;562;1
WireConnection;259;0;255;0
WireConnection;258;0;256;1
WireConnection;258;1;254;0
WireConnection;258;2;257;0
WireConnection;260;0;258;0
WireConnection;260;1;259;0
WireConnection;267;0;263;0
WireConnection;252;0;244;0
WireConnection;252;1;249;0
WireConnection;252;2;272;0
WireConnection;266;0;264;1
WireConnection;266;1;262;0
WireConnection;266;2;265;0
WireConnection;251;0;252;0
WireConnection;253;0;239;0
WireConnection;253;1;243;0
WireConnection;268;0;266;0
WireConnection;268;1;267;0
WireConnection;723;0;722;2
WireConnection;247;0;253;0
WireConnection;548;0;545;1
WireConnection;372;0;375;0
WireConnection;372;1;251;0
WireConnection;239;0;240;2
WireConnection;239;1;241;0
WireConnection;239;2;238;0
WireConnection;243;0;242;0
WireConnection;244;0;248;0
WireConnection;244;1;250;0
WireConnection;244;2;261;0
WireConnection;261;0;260;0
WireConnection;249;0;246;0
WireConnection;249;1;245;0
WireConnection;249;2;247;0
WireConnection;721;0;719;1
WireConnection;272;0;271;0
WireConnection;272;1;269;0
WireConnection;272;2;270;0
WireConnection;794;2;715;0
WireConnection;794;10;688;0
ASEEND*/
//CHKSM=BB5CEFE2A953185A06E1BDD907F87825FE3C8B47