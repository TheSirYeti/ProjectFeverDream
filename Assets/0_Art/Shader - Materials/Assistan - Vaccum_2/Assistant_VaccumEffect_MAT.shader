// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Assistant_VaccumEffect_MAT"
{
	Properties
	{
		[Header(Value)]_MaskNoisePrincipal("Mask Noise Principal", Range( 0 , 0.15)) = -0.38
		_MaskBorder("Mask Border", Range( 0 , 0.15)) = -0.38
		_SpeedNoisePrincipal("Speed Noise Principal", Float) = 0
		_SpeedNoiseBorder("Speed Noise Border", Float) = 0
		_FadeEffect("Fade Effect", Range( 0 , 1)) = 0
		[Header(Texture)]_NoisePrincipal("Noise Principal", 2D) = "white" {}
		_NoiseBorder("Noise Border", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,0)
		_Opacity("Opacity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform float _MaskBorder;
		uniform sampler2D _NoiseBorder;
		uniform float _SpeedNoiseBorder;
		uniform float _MaskNoisePrincipal;
		uniform sampler2D _NoisePrincipal;
		uniform float _SpeedNoisePrincipal;
		uniform float _FadeEffect;
		uniform float _Opacity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float V_TexCoordinates105 = i.uv_texcoord.y;
			float4 temp_cast_0 = (0.03).xxxx;
			float4 temp_cast_1 = (0.32).xxxx;
			float2 N_Dir115 = float2( 0,-1 );
			float mulTime49 = _Time.y * _SpeedNoiseBorder;
			float2 uv_TexCoord52 = i.uv_texcoord * float2( 4,0.1 ) + ( N_Dir115 * mulTime49 );
			float4 smoothstepResult56 = smoothstep( temp_cast_0 , temp_cast_1 , saturate( tex2D( _NoiseBorder, uv_TexCoord52 ) ));
			float4 N_Border110 = ( saturate( (0.44 + (( V_TexCoordinates105 + _MaskBorder ) - 0.9) * (1.02 - 0.44) / (1.0 - 0.9)) ) * smoothstepResult56 );
			float4 temp_cast_2 = (-1.58).xxxx;
			float4 temp_cast_3 = (0.46).xxxx;
			float2 temp_cast_4 = (2.0).xx;
			float mulTime83 = _Time.y * 10.0;
			float2 uv_TexCoord72 = i.uv_texcoord * temp_cast_4 + ( N_Dir115 * mulTime83 );
			float cos81 = cos( radians( 60.0 ) );
			float sin81 = sin( radians( 60.0 ) );
			float2 rotator81 = mul( uv_TexCoord72 - float2( 0.5,0.5 ) , float2x2( cos81 , -sin81 , sin81 , cos81 )) + float2( 0.5,0.5 );
			float4 smoothstepResult69 = smoothstep( temp_cast_2 , temp_cast_3 , tex2D( _NoiseBorder, rotator81 ));
			float4 N_Distortion118 = smoothstepResult69;
			float4 temp_cast_5 = (0.18).xxxx;
			float4 temp_cast_6 = (0.45).xxxx;
			float mulTime41 = _Time.y * _SpeedNoisePrincipal;
			float2 uv_TexCoord2 = i.uv_texcoord * float2( 6,0.15 ) + ( N_Dir115 * mulTime41 );
			float4 smoothstepResult8 = smoothstep( temp_cast_5 , temp_cast_6 , saturate( tex2D( _NoisePrincipal, uv_TexCoord2 ) ));
			float4 N_NoisePrincipal123 = ( saturate( (0.25 + (( V_TexCoordinates105 + _MaskNoisePrincipal ) - 0.68) * (1.24 - 0.25) / (1.0 - 0.68)) ) * saturate( smoothstepResult8 ) );
			float4 temp_output_68_0 = ( N_Distortion118 * N_NoisePrincipal123 );
			float4 N_MassEffect112 = saturate( ( ( temp_output_68_0 * ( V_TexCoordinates105 + ( ( 1.0 - _FadeEffect ) / -0.7 ) ) ) * 10.0 ) );
			float4 temp_output_99_0 = ( saturate( ( N_Border110 + temp_output_68_0 ) ) * N_MassEffect112 );
			o.Emission = saturate( ( saturate( _Color ) * temp_output_99_0 ) ).rgb;
			o.Alpha = ( temp_output_99_0 * _Opacity ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;910;576;1764.135;3466.18;1.9;True;False
Node;AmplifyShaderEditor.CommentaryNode;128;-3974.366,-2852.43;Inherit;False;515.8247;361.5132;;4;48;115;58;105;Variable Generic;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;48;-3924.366,-2654.917;Inherit;False;Constant;_DirNoise;Dir Noise;3;0;Create;True;0;0;0;False;0;False;0,-1;0,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;125;-3260.924,-2314.76;Inherit;False;2191.855;1006.878;;23;43;41;121;42;13;2;120;16;27;21;36;17;10;9;24;26;8;23;19;65;123;130;132;Noise Principal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-3693.312,-2653.884;Inherit;False;N_Dir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-3210.924,-1423.882;Inherit;False;Property;_SpeedNoisePrincipal;Speed Noise Principal;2;0;Create;True;0;0;0;False;0;False;0;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-2967.969,-1588.423;Inherit;False;115;N_Dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;41;-2989.621,-1422.383;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;-3260.083,-3622.813;Inherit;False;1773.717;477.5667;;15;82;83;117;75;78;85;80;72;77;81;71;67;69;118;70;Noise Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-2789.924,-1589.882;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-3913.676,-2802.43;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-3210.083,-3342.179;Inherit;False;Constant;_SpeedDistortion;Speed Distortion;12;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;13;-2850.114,-1768.782;Inherit;False;Constant;_TillingNoisePrincipal;Tilling Noise Principal;2;0;Create;True;0;0;0;False;0;False;6,0.15;6,0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;83;-3025.842,-3337.048;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-3014.323,-3466.304;Inherit;False;115;N_Dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2617.718,-1745.843;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-3701.542,-2759.497;Inherit;False;V_TexCoordinates;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2886.407,-3572.813;Inherit;False;Constant;_TillingDistortion;Tilling Distortion;23;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;127;-3260.957,-3112.8;Inherit;False;2066.42;757.4419;;21;47;49;116;50;51;57;52;106;61;59;60;62;53;54;63;55;56;64;18;110;131;Noise Border;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-2796.694,-2264.76;Inherit;False;105;V_TexCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2668.228,-3261.246;Inherit;False;Constant;_Drag;Drag;23;0;Create;True;0;0;0;False;0;False;60;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-2833.602,-3449.365;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2861.762,-2126.169;Inherit;False;Property;_MaskNoisePrincipal;Mask Noise Principal;0;1;[Header];Create;True;1;Value;0;0;False;0;False;-0.38;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;-2410.936,-1773.16;Inherit;True;Property;_NoisePrincipal;Noise Principal;6;1;[Header];Create;True;1;Texture;0;0;False;0;False;-1;None;16aa8fb6f94c2c74f9d2ae03a2574388;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;77;-2527.142,-3258.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-2697.689,-3546.189;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-3210.957,-2517.858;Inherit;False;Property;_SpeedNoiseBorder;Speed Noise Border;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2279.006,-1582.999;Inherit;False;Constant;_MinSmooth;Min Smooth;2;0;Create;True;0;0;0;False;0;False;0.18;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-2110.458,-1766.131;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2565.424,-2244.507;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;80;-2632.868,-3411.317;Inherit;False;Constant;_Center;Center;23;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;-2539.16,-2023.603;Inherit;False;Constant;_MinOld;Min Old ;4;0;Create;True;0;0;0;False;0;False;0.68;0.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2537.733,-1864.924;Inherit;False;Constant;_MaxNew;Max New;4;0;Create;True;0;0;0;False;0;False;1.24;1.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2532.052,-1950.181;Inherit;False;Constant;_MinNew;Min New;5;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2276.178,-1510.61;Inherit;False;Constant;_MaxSmooth;Max Smooth;3;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;81;-2389.164,-3541.392;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;26;-2322.571,-2064.843;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;8;-1975.041,-1772.736;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;49;-3001.554,-2512.427;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-3004.541,-2601.369;Inherit;False;115;N_Dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;23;-1812.777,-1772.861;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2150.593,-3372.542;Inherit;False;Constant;_MinSmoothDistortion;Min Smooth Distortion;14;0;Create;True;0;0;0;False;0;False;-1.58;-1.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;67;-2194.998,-3570.467;Inherit;True;Property;_NoiseDistortion;Noise Distortion;7;0;Create;True;0;0;0;False;0;False;-1;None;7e4ac535c04ac8a40aeef9e10ddb297c;True;0;False;white;Auto;False;Instance;131;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2150.465,-3293.362;Inherit;False;Constant;_MaxSmoothDistortion;Max Smooth Distortion;15;0;Create;True;0;0;0;False;0;False;0.46;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;126;-1146.214,-3113.251;Inherit;False;1424.729;454.3294;;10;88;104;98;97;107;103;91;102;101;112;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2823.779,-2559.509;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;19;-2059.791,-2053.958;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;51;-2896.679,-2760.477;Inherit;False;Constant;_TillingNoiseBorder;Tilling Noise Border;2;0;Create;True;0;0;0;False;0;False;4,0.1;4,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;106;-2679.223,-3062.8;Inherit;False;105;V_TexCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-2655.282,-2607.525;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;88;-1096.214,-2890.25;Inherit;False;Property;_FadeEffect;Fade Effect;5;0;Create;True;0;0;0;False;0;False;0;0.39;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1557.85,-2046.437;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;69;-1883.708,-3562.468;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2748.581,-2977.355;Inherit;False;Property;_MaskBorder;Mask Border;1;0;Create;True;0;0;0;False;0;False;-0.38;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-1710.366,-3568.344;Inherit;False;N_Distortion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-2447.158,-2998.233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;131;-2410.673,-2620.289;Inherit;True;Property;_NoiseBorder;Noise Border;7;0;Create;True;0;0;0;False;0;False;-1;None;7e4ac535c04ac8a40aeef9e10ddb297c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-2478.808,-2890.262;Inherit;False;Constant;_MinOldBorder;Min Old Border;13;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2485.784,-2737.388;Inherit;False;Constant;_MaxNewBorder;Max New Border;16;0;Create;True;0;0;0;False;0;False;1.02;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-1303.069,-2048.023;Inherit;False;N_NoisePrincipal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;104;-822.8969,-2902.38;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2482.712,-2809.151;Inherit;False;Constant;_MinNewBorder;Min New Border;15;0;Create;True;0;0;0;False;0;False;0.44;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-855.4733,-2774.922;Inherit;False;Constant;_Divide;Divide;7;0;Create;True;0;0;0;False;0;False;-0.7;-0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2077.213,-2554.903;Inherit;False;Constant;_MinSmoothBorder;Min Smooth Border;4;0;Create;True;0;0;0;False;0;False;0.03;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-1114.158,-3398.151;Inherit;False;123;N_NoisePrincipal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-1113.623,-3475.262;Inherit;False;118;N_Distortion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-771.2741,-3063.251;Inherit;False;105;V_TexCoordinates;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;97;-691.6733,-2859.422;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;63;-2241.349,-2910.318;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;55;-2069.482,-2632.96;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2081.903,-2471.358;Inherit;False;Constant;_MaxSmoothBorder;Max Smooth Border;6;0;Create;True;0;0;0;False;0;False;0.32;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-904.9478,-3469.058;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;56;-1819.155,-2579.844;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;64;-1972.892,-2908.121;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-524.915,-3039.815;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-443.9921,-3153.756;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-470.2339,-2797.092;Inherit;False;Constant;_Float20;Float 20;26;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1652.426,-2910.827;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1418.537,-2913.89;Inherit;False;N_Border;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-278.9051,-3034.896;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;101;-78.17244,-3053.39;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-780.6755,-3571.797;Inherit;False;110;N_Border;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-584.7285,-3561.899;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;54.51558,-3059.496;Inherit;False;N_MassEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;100;-423.2204,-3559.675;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-446.7677,-3456.369;Inherit;False;112;N_MassEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;137;-403.8964,-3806.086;Inherit;False;Property;_Color;Color;8;0;Create;True;0;0;0;False;0;False;1,0,0,0;0.6862745,0.8392157,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;141;-144.2759,-3752.152;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-232.0517,-3561.244;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;10.12128,-3683.802;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-343.9827,-3349.368;Inherit;False;Property;_Opacity;Opacity;9;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;142;-631.9415,-3362.633;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-55.35413,-3415.033;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;139;238.1031,-3679.495;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-2788.073,-1731.252;Inherit;False;Property;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;15.12;0.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;32;532.4347,-3615.804;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Assistant_VaccumEffect_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;115;0;48;0
WireConnection;41;0;43;0
WireConnection;42;0;121;0
WireConnection;42;1;41;0
WireConnection;83;0;82;0
WireConnection;2;0;13;0
WireConnection;2;1;42;0
WireConnection;105;0;58;2
WireConnection;85;0;117;0
WireConnection;85;1;83;0
WireConnection;130;1;2;0
WireConnection;77;0;78;0
WireConnection;72;0;75;0
WireConnection;72;1;85;0
WireConnection;24;0;130;0
WireConnection;17;0;120;0
WireConnection;17;1;16;0
WireConnection;81;0;72;0
WireConnection;81;1;80;0
WireConnection;81;2;77;0
WireConnection;26;0;17;0
WireConnection;26;1;21;0
WireConnection;26;3;27;0
WireConnection;26;4;36;0
WireConnection;8;0;24;0
WireConnection;8;1;9;0
WireConnection;8;2;10;0
WireConnection;49;0;47;0
WireConnection;23;0;8;0
WireConnection;67;1;81;0
WireConnection;50;0;116;0
WireConnection;50;1;49;0
WireConnection;19;0;26;0
WireConnection;52;0;51;0
WireConnection;52;1;50;0
WireConnection;65;0;19;0
WireConnection;65;1;23;0
WireConnection;69;0;67;0
WireConnection;69;1;70;0
WireConnection;69;2;71;0
WireConnection;118;0;69;0
WireConnection;60;0;106;0
WireConnection;60;1;57;0
WireConnection;131;1;52;0
WireConnection;123;0;65;0
WireConnection;104;0;88;0
WireConnection;97;0;104;0
WireConnection;97;1;98;0
WireConnection;63;0;60;0
WireConnection;63;1;59;0
WireConnection;63;3;61;0
WireConnection;63;4;62;0
WireConnection;55;0;131;0
WireConnection;68;0;119;0
WireConnection;68;1;124;0
WireConnection;56;0;55;0
WireConnection;56;1;53;0
WireConnection;56;2;54;0
WireConnection;64;0;63;0
WireConnection;91;0;107;0
WireConnection;91;1;97;0
WireConnection;143;0;68;0
WireConnection;143;1;91;0
WireConnection;18;0;64;0
WireConnection;18;1;56;0
WireConnection;110;0;18;0
WireConnection;102;0;143;0
WireConnection;102;1;103;0
WireConnection;101;0;102;0
WireConnection;66;0;111;0
WireConnection;66;1;68;0
WireConnection;112;0;101;0
WireConnection;100;0;66;0
WireConnection;141;0;137;0
WireConnection;99;0;100;0
WireConnection;99;1;114;0
WireConnection;136;0;141;0
WireConnection;136;1;99;0
WireConnection;134;0;99;0
WireConnection;134;1;140;0
WireConnection;139;0;136;0
WireConnection;32;2;139;0
WireConnection;32;9;134;0
ASEEND*/
//CHKSM=E7C65A0C296425DEBE2E9879831402090A6A90E8