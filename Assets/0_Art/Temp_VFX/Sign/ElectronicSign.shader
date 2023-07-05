// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ElectronicSign"
{
	Properties
	{
		_Poster("Poster", 2D) = "white" {}
		_SignStatic("SignStatic", Range( 0 , 50)) = 0
		_pixels("pixels", 2D) = "white" {}
		_PixelsValue("PixelsValue", Vector) = (30,30,0,0)
		_NoiseValue("NoiseValue", Range( 0 , 1)) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _pixels;
		uniform float2 _PixelsValue;
		uniform sampler2D _Poster;
		uniform float _SignStatic;
		uniform float _NoiseValue;


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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord27 = i.uv_texcoord * _PixelsValue;
			float2 temp_cast_0 = (i.uv_texcoord.y).xx;
			float2 panner6 = ( _Time.y * float2( 0,2 ) + temp_cast_0);
			float simplePerlin2D11 = snoise( panner6*_SignStatic );
			simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
			float2 appendResult31 = (float2(0.0 , _NoiseValue));
			float2 uv_TexCoord21 = i.uv_texcoord + ( simplePerlin2D11 * appendResult31 );
			o.Emission = ( ( tex2D( _pixels, uv_TexCoord27 ) * 0.3 ) + ( tex2D( _Poster, uv_TexCoord21 ) * 2.0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
702;73;659;655;-145.7885;83.78125;1;False;False
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1960.026,399.6689;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1983.952,244.2702;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-1834.537,478.6857;Inherit;False;Property;_SignStatic;SignStatic;1;0;Create;True;0;0;0;False;0;False;0;50;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;6;-1725.972,302.4597;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1552.465,592.8922;Inherit;False;Property;_NoiseValue;NoiseValue;4;0;Create;True;0;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;11;-1533.245,318.2337;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1265.761,543.4292;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;26;-560.7614,-30.09807;Inherit;False;Property;_PixelsValue;PixelsValue;3;0;Create;True;0;0;0;False;0;False;30,30;30,30;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1172.044,308.6212;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0.1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-380.8154,-52.47527;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-944.8115,290.3441;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-145.8043,-79.70098;Inherit;True;Property;_pixels;pixels;2;0;Create;True;0;0;0;False;0;False;-1;5d3e98ec0de0645409f933416f87f295;5d3e98ec0de0645409f933416f87f295;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-20.95569,124.4107;Inherit;False;Constant;_PixelsOpacity;PixelsOpacity;5;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-167.4069,306.3003;Inherit;True;Property;_Poster;Poster;0;0;Create;True;0;0;0;False;0;False;-1;9a292b5dd3af0ed43b44d0bb86428e5e;b6e8e850897ec3c42bc08a48e76aeb24;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-32.47953,559.3525;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;217.0443,7.41069;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;177.3873,288.0961;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;445.7885,85.21875;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;642.2797,74.41845;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ElectronicSign;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;2
WireConnection;6;1;3;0
WireConnection;11;0;6;0
WireConnection;11;1;8;0
WireConnection;31;1;25;0
WireConnection;13;0;11;0
WireConnection;13;1;31;0
WireConnection;27;0;26;0
WireConnection;21;1;13;0
WireConnection;28;1;27;0
WireConnection;23;1;21;0
WireConnection;32;0;28;0
WireConnection;32;1;33;0
WireConnection;34;0;23;0
WireConnection;34;1;35;0
WireConnection;36;0;32;0
WireConnection;36;1;34;0
WireConnection;0;2;36;0
ASEEND*/
//CHKSM=3A0AA0C2866FF60FBA32D8D4200CC910B479BEE9