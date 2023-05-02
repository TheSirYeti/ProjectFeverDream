// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ButtonOutline"
{
	Properties
	{
		_ASEOutlineColor( "Outline Color", Color ) = (0,0,0,0)
		_ASEOutlineWidth( "Outline Width", Float ) = 0
		_Button_Material_2_AlbedoTransparency("Button_Material _2_AlbedoTransparency", 2D) = "white" {}
		_Button_Material_2_Emission_off("Button_Material _2_Emission_off", 2D) = "white" {}
		_Button_Material_2_MetallicSmoothness("Button_Material _2_MetallicSmoothness", 2D) = "white" {}
		_Button_Material_2_Normal("Button_Material _2_Normal", 2D) = "bump" {}
		_TimeScale("TimeScale", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		
		
		
		struct Input {
			half filler;
		};
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Button_Material_2_Normal;
		uniform float4 _Button_Material_2_Normal_ST;
		uniform sampler2D _Button_Material_2_AlbedoTransparency;
		uniform float4 _Button_Material_2_AlbedoTransparency_ST;
		uniform sampler2D _Button_Material_2_Emission_off;
		uniform float4 _Button_Material_2_Emission_off_ST;
		uniform float _TimeScale;
		uniform sampler2D _Button_Material_2_MetallicSmoothness;
		uniform float4 _Button_Material_2_MetallicSmoothness_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Button_Material_2_Normal = i.uv_texcoord * _Button_Material_2_Normal_ST.xy + _Button_Material_2_Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Button_Material_2_Normal, uv_Button_Material_2_Normal ) );
			float2 uv_Button_Material_2_AlbedoTransparency = i.uv_texcoord * _Button_Material_2_AlbedoTransparency_ST.xy + _Button_Material_2_AlbedoTransparency_ST.zw;
			o.Albedo = tex2D( _Button_Material_2_AlbedoTransparency, uv_Button_Material_2_AlbedoTransparency ).rgb;
			float2 uv_Button_Material_2_Emission_off = i.uv_texcoord * _Button_Material_2_Emission_off_ST.xy + _Button_Material_2_Emission_off_ST.zw;
			float4 color52 = IsGammaSpace() ? float4(1,0.875397,0,0) : float4(1,0.7396021,0,0);
			float mulTime50 = _Time.y * _TimeScale;
			float4 lerpResult49 = lerp( tex2D( _Button_Material_2_Emission_off, uv_Button_Material_2_Emission_off ) , color52 , sin( mulTime50 ));
			o.Emission = saturate( lerpResult49 ).rgb;
			float2 uv_Button_Material_2_MetallicSmoothness = i.uv_texcoord * _Button_Material_2_MetallicSmoothness_ST.xy + _Button_Material_2_MetallicSmoothness_ST.zw;
			float4 tex2DNode46 = tex2D( _Button_Material_2_MetallicSmoothness, uv_Button_Material_2_MetallicSmoothness );
			o.Metallic = tex2DNode46.r;
			o.Smoothness = tex2DNode46.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
719;73;921;641;710.191;618.4117;1.827743;False;False
Node;AmplifyShaderEditor.RangedFloatNode;54;-752.6284,190.8251;Inherit;False;Property;_TimeScale;TimeScale;4;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;50;-560.0712,161.9825;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;51;-346.3626,88.65923;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;52;-555.2638,-37.01634;Inherit;False;Constant;_InteractColor;InteractColor;4;0;Create;True;0;0;0;False;0;False;1,0.875397,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-851.6511,-110.3706;Inherit;True;Property;_Button_Material_2_Emission_off;Button_Material _2_Emission_off;1;0;Create;True;0;0;0;False;0;False;-1;f12eb510f236d4849b42b7bad3c07c8c;f12eb510f236d4849b42b7bad3c07c8c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;49;-160.5632,-83.79956;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;47;-2.031729,-288.1241;Inherit;True;Property;_Button_Material_2_Normal;Button_Material _2_Normal;3;0;Create;True;0;0;0;False;0;False;-1;5ed5251f8a848d04e8f8b58bf61bb7c7;5ed5251f8a848d04e8f8b58bf61bb7c7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;61.18085,207.3941;Inherit;True;Property;_Button_Material_2_MetallicSmoothness;Button_Material _2_MetallicSmoothness;2;0;Create;True;0;0;0;False;0;False;-1;5f44b71801274154a80a75bd85bcd7d3;5f44b71801274154a80a75bd85bcd7d3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;53;192.6606,-60.15808;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;79.29501,-512.0108;Inherit;True;Property;_Button_Material_2_AlbedoTransparency;Button_Material _2_AlbedoTransparency;0;0;Create;True;0;0;0;False;0;False;-1;f12eb510f236d4849b42b7bad3c07c8c;0fb53514082bd9546a0df40e67003763;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;15;550.9261,-242.9555;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;ButtonOutline;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;True;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;54;0
WireConnection;51;0;50;0
WireConnection;49;0;45;0
WireConnection;49;1;52;0
WireConnection;49;2;51;0
WireConnection;53;0;49;0
WireConnection;15;0;44;0
WireConnection;15;1;47;0
WireConnection;15;2;53;0
WireConnection;15;3;46;0
WireConnection;15;4;46;0
ASEEND*/
//CHKSM=E4FFC66F6B27B1C15B679E3EC082F3AA9D6BA454