// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ButtonOutline"
{
	Properties
	{
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
			half filler;
		};

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color3 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 color5 = IsGammaSpace() ? float4(1,0.7534727,0,0) : float4(1,0.5279478,0,0);
			float mulTime7 = _Time.y * 4.0;
			float4 lerpResult4 = lerp( color3 , color5 , sin( mulTime7 ));
			o.Emission = lerpResult4.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
826;73;785;551;920.9181;-102.1896;1;False;False
Node;AmplifyShaderEditor.RangedFloatNode;8;-781.1729,289.9832;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-650.3012,336.304;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-481.4344,-25.97114;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-483.0985,162.91;Inherit;False;Constant;_Color1;Color 0;0;0;Create;True;0;0;0;False;0;False;1,0.7534727,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;6;-448.9336,351.2436;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;-207.8238,61.50972;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ButtonOutline;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;8;0
WireConnection;6;0;7;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;6;0
WireConnection;2;2;4;0
ASEEND*/
//CHKSM=B9286CC066A1FBEEAB1FB3832EA2A178434F8555