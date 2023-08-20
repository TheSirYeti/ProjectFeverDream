// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( BorderCinematic_EffectPPSRenderer ), PostProcessEvent.AfterStack, "BorderCinematic_Effect", true )]
public sealed class BorderCinematic_EffectPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Slider Border" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _SliderBorder = new FloatParameter { value = 0f };
}

public sealed class BorderCinematic_EffectPPSRenderer : PostProcessEffectRenderer<BorderCinematic_EffectPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "BorderCinematic_Effect" ) );
		sheet.properties.SetFloat( "_SliderBorder", settings._SliderBorder );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
