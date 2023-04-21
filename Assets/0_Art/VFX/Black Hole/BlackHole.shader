// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlackHole"
{
	Properties
	{
		_Subtract("Subtract", Float) = 0
		_Radius("Radius", Float) = 0
		_Falloff("Fall off", Float) = 0
		_SubstractSphereMask("Substract Sphere Mask", Float) = 0
		_Color0("Color 0", Color) = (0,0.08349856,0.8396226,1)
		_Color1("Color 1", Color) = (0,0.09941673,1,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform float _Subtract;
		uniform float _Radius;
		uniform float _Falloff;
		uniform float _SubstractSphereMask;
		uniform float4 _Color0;
		uniform float4 _Color1;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 _Postion = float3(-8.53,1.83,0);
			float3 temp_cast_0 = (_Subtract).xxx;
			float temp_output_81_9 = saturate( pow( ( distance( ase_worldPos , _Postion ) / _Radius ) , _Falloff ) );
			float3 lerpResult36 = lerp( float3( 0,0,0 ) , ( ( ase_worldPos + ( 1.0 - _Postion ) ) - temp_cast_0 ) , ( temp_output_81_9 - _SubstractSphereMask ));
			v.vertex.xyz += lerpResult36;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 _Postion = float3(-8.53,1.83,0);
			float temp_output_81_9 = saturate( pow( ( distance( ase_worldPos , _Postion ) / _Radius ) , _Falloff ) );
			float4 lerpResult32 = lerp( _Color0 , _Color1 , temp_output_81_9);
			o.Emission = lerpResult32.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;73;1023;655;2336.225;898.5153;2.077263;True;False
Node;AmplifyShaderEditor.Vector3Node;22;-1622.661,-84.90755;Inherit;False;Constant;_Postion;Postion;0;0;Create;True;0;0;0;False;0;False;-8.53,1.83,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;23;-1545.264,66.33262;Inherit;False;Property;_Radius;Radius;1;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1554.238,142.3128;Inherit;False;Property;_Falloff;Fall off;2;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-1344.219,-164.2032;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;25;-1359.722,-315.7119;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;81;-1335.325,-34.99001;Inherit;False;Sphere Mask Private;-1;;13;7f281f6107eb8af4882b4b33df5d1bda;0;3;4;FLOAT3;0,0,0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;FLOAT;9
Node;AmplifyShaderEditor.RangedFloatNode;31;-1329.096,96.22371;Inherit;False;Property;_SubstractSphereMask;Substract Sphere Mask;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1169.752,-129.1544;Inherit;False;Property;_Subtract;Subtract;0;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1129.086,-250.1539;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-1029.787,67.61907;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-1080.626,-662.4565;Inherit;False;Property;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;0,0.08349856,0.8396226,1;1,0.5691917,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;34;-1085.67,-475.8022;Inherit;False;Property;_Color1;Color 1;5;0;Create;True;0;0;0;False;0;False;0,0.09941673,1,0;0,0.09803915,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-935.0423,-224.982;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;32;-759.1536,-636.9183;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;36;-715.1771,-233.9159;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-416.8369,-585.1413;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BlackHole;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;22;0
WireConnection;81;4;22;0
WireConnection;81;6;23;0
WireConnection;81;7;24;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;30;0;81;9
WireConnection;30;1;31;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;32;0;33;0
WireConnection;32;1;34;0
WireConnection;32;2;81;9
WireConnection;36;1;28;0
WireConnection;36;2;30;0
WireConnection;0;2;32;0
WireConnection;0;11;36;0
ASEEND*/
//CHKSM=6406F9B38BAF01979A9227437C77ED04483CB26F