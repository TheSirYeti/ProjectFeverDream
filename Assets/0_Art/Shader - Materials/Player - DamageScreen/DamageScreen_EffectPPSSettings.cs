// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( DamageScreen_EffectPPSRenderer ), PostProcessEvent.AfterStack, "DamageScreen_Effect", false )]
public sealed class DamageScreen_EffectPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Color 2" )]
	public ColorParameter _Color2 = new ColorParameter { value = new Color(0.3490565f,0f,0f,0f) };
	[Tooltip( "Texture Sample 1" )]
	public TextureParameter _TextureSample1 = new TextureParameter {  };
}

public sealed class DamageScreen_EffectPPSRenderer : PostProcessEffectRenderer<DamageScreen_EffectPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DamageScreen_Effect" ) );
		sheet.properties.SetColor( "_Color2", settings._Color2 );
		if(settings._TextureSample1.value != null) sheet.properties.SetTexture( "_TextureSample1", settings._TextureSample1 );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
