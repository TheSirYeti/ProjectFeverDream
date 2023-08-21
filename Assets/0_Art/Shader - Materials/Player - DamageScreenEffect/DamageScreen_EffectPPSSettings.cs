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
	[Tooltip( "Border U One" )]
	public FloatParameter _BorderUOne = new FloatParameter { value = 30f };
	[Tooltip( "Border U Two" )]
	public FloatParameter _BorderUTwo = new FloatParameter { value = 10f };
	[Tooltip( "Border V One" )]
	public FloatParameter _BorderVOne = new FloatParameter { value = 30f };
	[Tooltip( "Border V Two" )]
	public FloatParameter _BorderVTwo = new FloatParameter { value = 10f };
	[Tooltip( "Color Emission" )]
	public ColorParameter _ColorEmission = new ColorParameter { value = new Color(0.7647059f,0.1843136f,0.1843136f,0f) };
	[Tooltip( "Color Shadow" )]
	public ColorParameter _ColorShadow = new ColorParameter { value = new Color(0.3584905f,0f,0f,0f) };
	[Tooltip( "ControlScreenLeft" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _ControlScreenLeft = new FloatParameter { value = 0f };
	[Tooltip( "ControlScreenRight" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _ControlScreenRight = new FloatParameter { value = 1f };
	[Tooltip( "ControlScreenDown" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _ControlScreenDown = new FloatParameter { value = 1f };
	[Tooltip( "ControlScreenUP" )]
    [Range(0.0f, 1.0f)]
    public FloatParameter _ControlScreenUP = new FloatParameter { value = 1f };
}

public sealed class DamageScreen_EffectPPSRenderer : PostProcessEffectRenderer<DamageScreen_EffectPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DamageScreen_Effect" ) );
		sheet.properties.SetFloat( "_BorderUOne", settings._BorderUOne );
		sheet.properties.SetFloat( "_BorderUTwo", settings._BorderUTwo );
		sheet.properties.SetFloat( "_BorderVOne", settings._BorderVOne );
		sheet.properties.SetFloat( "_BorderVTwo", settings._BorderVTwo );
		sheet.properties.SetColor( "_ColorEmission", settings._ColorEmission );
		sheet.properties.SetColor( "_ColorShadow", settings._ColorShadow );
		sheet.properties.SetFloat( "_ControlScreenLeft", settings._ControlScreenLeft );
		sheet.properties.SetFloat( "_ControlScreenRight", settings._ControlScreenRight );
		sheet.properties.SetFloat( "_ControlScreenDown", settings._ControlScreenDown );
		sheet.properties.SetFloat( "_ControlScreenUP", settings._ControlScreenUP );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
