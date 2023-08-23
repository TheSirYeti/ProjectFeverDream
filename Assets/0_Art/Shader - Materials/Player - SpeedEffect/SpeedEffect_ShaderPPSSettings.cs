// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( SpeedEffect_ShaderPPSRenderer ), PostProcessEvent.AfterStack, "SpeedEffect_Shader", false )]
public sealed class SpeedEffect_ShaderPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Noise Texture" )]
	public TextureParameter _NoiseTexture = new TextureParameter {  };
	[Tooltip( "Amount Noise" )]
	public FloatParameter _AmountNoise = new FloatParameter { value = 0.6705883f };
	[Tooltip( "Sature Noise" )]
	public FloatParameter _SatureNoise = new FloatParameter { value = 0.4269153f };
	[Tooltip( "Alpha" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _Alpha = new FloatParameter { value = 0.54f };
	[Tooltip( "Hard Egdes Noise" )]
	public FloatParameter _HardEgdesNoise = new FloatParameter { value = -0.2f };
	[Tooltip( "Color" )]
	public ColorParameter _Color = new ColorParameter { value = new Color(0.9669811f,0.9759491f,1f,1f) };
}

public sealed class SpeedEffect_ShaderPPSRenderer : PostProcessEffectRenderer<SpeedEffect_ShaderPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "SpeedEffect_Shader" ) );
		if(settings._NoiseTexture.value != null) sheet.properties.SetTexture( "_NoiseTexture", settings._NoiseTexture );
		sheet.properties.SetFloat( "_AmountNoise", settings._AmountNoise );
		sheet.properties.SetFloat( "_SatureNoise", settings._SatureNoise );
		sheet.properties.SetFloat( "_Alpha", settings._Alpha );
		sheet.properties.SetFloat( "_HardEgdesNoise", settings._HardEgdesNoise );
		sheet.properties.SetColor( "_Color", settings._Color );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
