// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( LowHP_EffectPPSRenderer ), PostProcessEvent.AfterStack, "LowHP_Effect", false )]
public sealed class LowHP_EffectPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Color Border" )]
	public ColorParameter _ColorBorder = new ColorParameter { value = new Color(0.2274509f,0.02745098f,0.003921569f,1f) };
	[Tooltip( "Amount Corners" )]
    [Range(0.0f, 1.65f)]
    public FloatParameter _AmountCorners = new FloatParameter { value = 1.6f };
	[Tooltip( "Smooth Corners" )]
	public FloatParameter _SmoothCorners = new FloatParameter { value = 5f };
	[Tooltip( "Blend Corners" )]
	public FloatParameter _BlendCorners = new FloatParameter { value = 0.5f };
	[Tooltip( "Speed Corners" )]
	public FloatParameter _SpeedCorners = new FloatParameter { value = 1f };
	[Tooltip( "Intesity Corners Min" )]
	public FloatParameter _IntesityCornersMin = new FloatParameter { value = 1f };
	[Tooltip( "Intesity Corners Max" )]
	public FloatParameter _IntesityCornersMax = new FloatParameter { value = 1.07f };
	[Tooltip( "Grayscale" )]
    [Range(0.0f, 0.7f)]
    public FloatParameter _Grayscale = new FloatParameter { value = 1f };
	[Tooltip( "Scale Noise" )]
	public FloatParameter _ScaleNoise = new FloatParameter { value = 7f };
	[Tooltip( "Speed Noise" )]
	public FloatParameter _SpeedNoise = new FloatParameter { value = 0.1f };
}

public sealed class LowHP_EffectPPSRenderer : PostProcessEffectRenderer<LowHP_EffectPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "LowHP_Effect" ) );
		sheet.properties.SetColor( "_ColorBorder", settings._ColorBorder );
		sheet.properties.SetFloat( "_AmountCorners", settings._AmountCorners );
		sheet.properties.SetFloat( "_SmoothCorners", settings._SmoothCorners );
		sheet.properties.SetFloat( "_BlendCorners", settings._BlendCorners );
		sheet.properties.SetFloat( "_SpeedCorners", settings._SpeedCorners );
		sheet.properties.SetFloat( "_IntesityCornersMin", settings._IntesityCornersMin );
		sheet.properties.SetFloat( "_IntesityCornersMax", settings._IntesityCornersMax );
		sheet.properties.SetFloat( "_Grayscale", settings._Grayscale );
		sheet.properties.SetFloat( "_ScaleNoise", settings._ScaleNoise );
		sheet.properties.SetFloat( "_SpeedNoise", settings._SpeedNoise );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
