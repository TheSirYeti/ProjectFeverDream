// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToastBurn"
{
	Properties
	{
		_Toast_LP_DefaultMaterial_AlbedoTransparency("Toast_LP_DefaultMaterial_AlbedoTransparency", 2D) = "white" {}
		_Toast_LP_DefaultMaterial_MetallicSmoothness("Toast_LP_DefaultMaterial_MetallicSmoothness", 2D) = "white" {}
		_Toast_LP_DefaultMaterial_Normal("Toast_LP_DefaultMaterial_Normal", 2D) = "bump" {}
		_BurnValue("Burn Value", Range( 0.05 , 1)) = 0
		_BurnColor("BurnColor", Color) = (0.1320755,0.05020493,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Toast_LP_DefaultMaterial_Normal;
		uniform float4 _Toast_LP_DefaultMaterial_Normal_ST;
		uniform float4 _BurnColor;
		uniform sampler2D _Toast_LP_DefaultMaterial_AlbedoTransparency;
		uniform float4 _Toast_LP_DefaultMaterial_AlbedoTransparency_ST;
		uniform float _BurnValue;
		uniform sampler2D _Toast_LP_DefaultMaterial_MetallicSmoothness;
		uniform float4 _Toast_LP_DefaultMaterial_MetallicSmoothness_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Toast_LP_DefaultMaterial_Normal = i.uv_texcoord * _Toast_LP_DefaultMaterial_Normal_ST.xy + _Toast_LP_DefaultMaterial_Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Toast_LP_DefaultMaterial_Normal, uv_Toast_LP_DefaultMaterial_Normal ) );
			float2 uv_Toast_LP_DefaultMaterial_AlbedoTransparency = i.uv_texcoord * _Toast_LP_DefaultMaterial_AlbedoTransparency_ST.xy + _Toast_LP_DefaultMaterial_AlbedoTransparency_ST.zw;
			float4 lerpResult5 = lerp( _BurnColor , tex2D( _Toast_LP_DefaultMaterial_AlbedoTransparency, uv_Toast_LP_DefaultMaterial_AlbedoTransparency ) , _BurnValue);
			o.Albedo = lerpResult5.rgb;
			float2 uv_Toast_LP_DefaultMaterial_MetallicSmoothness = i.uv_texcoord * _Toast_LP_DefaultMaterial_MetallicSmoothness_ST.xy + _Toast_LP_DefaultMaterial_MetallicSmoothness_ST.zw;
			float4 tex2DNode2 = tex2D( _Toast_LP_DefaultMaterial_MetallicSmoothness, uv_Toast_LP_DefaultMaterial_MetallicSmoothness );
			o.Metallic = tex2DNode2.r;
			o.Smoothness = tex2DNode2.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
817;73;622;551;932.2882;339.4943;1;False;False
Node;AmplifyShaderEditor.SamplerNode;1;-711.2238,115.4125;Inherit;True;Property;_Toast_LP_DefaultMaterial_AlbedoTransparency;Toast_LP_DefaultMaterial_AlbedoTransparency;0;0;Create;True;0;0;0;False;0;False;-1;d72a4b63ca0a6144bafa3fb7baace857;d72a4b63ca0a6144bafa3fb7baace857;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-797.4902,-17.26971;Inherit;False;Property;_BurnValue;Burn Value;3;0;Create;True;0;0;0;False;0;False;0;1;0.05;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-815.1907,-241.6705;Inherit;False;Property;_BurnColor;BurnColor;4;0;Create;True;0;0;0;False;0;False;0.1320755,0.05020493,0,0;0.0471698,0.01803551,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-291.2358,-232.7622;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-618.585,492.3923;Inherit;True;Property;_Toast_LP_DefaultMaterial_Normal;Toast_LP_DefaultMaterial_Normal;2;0;Create;True;0;0;0;False;0;False;-1;987ad9228f0f5bf4abee4a3abfa33475;987ad9228f0f5bf4abee4a3abfa33475;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-670.912,303.1184;Inherit;True;Property;_Toast_LP_DefaultMaterial_MetallicSmoothness;Toast_LP_DefaultMaterial_MetallicSmoothness;1;0;Create;True;0;0;0;False;0;False;-1;4f9da263d29331d40b5499bc6a470f17;4f9da263d29331d40b5499bc6a470f17;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;20.8,-29.89999;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ToastBurn;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;5;1;1;0
WireConnection;5;2;6;0
WireConnection;0;0;5;0
WireConnection;0;1;3;0
WireConnection;0;3;2;0
WireConnection;0;4;2;0
ASEEND*/
//CHKSM=E5EECA73B4E91A8ECAD2523A2949A004CD78C01A