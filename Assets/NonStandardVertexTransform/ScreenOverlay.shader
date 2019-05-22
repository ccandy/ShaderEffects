Shader "Andy/ScreenOverlay"
{
	Properties
	{
		_MainTex	("Texture", 2D)		= "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_X("X", Float) = 0.0
		_Y("Y", Float) = 0.0
		_Width("Width", Float) = 128
		_Height("Height", Float) = 128
	}
		SubShader
		{
			Tags
			{
				"RenderType" = "Opaque"
				"Quene" = "Overlay"
			}


			LOD 100

			Pass
			{

				Blend SrcAlpha OneMinusSrcAlpha
				ZTest Always


				CGPROGRAM
				#pragma vertex		vert
				#pragma fragment	frag


				#include "UnityCG.cginc"
				struct vertexInput
				{
					float4 vertex	: POSITION;
					float4 texcoord : TEXCOORD0;
				};

				struct vertexOutput
				{
					float4 pos		: SV_POSITION;
					float4 tex 		: TEXCOORD0;
				};

				uniform sampler2D	_MainTex;
				uniform float4		_Color;
				uniform float		_X;
				uniform float		_Y;
				uniform float		_Width;
				uniform float		_Height;

				vertexOutput vert (vertexInput input)
				{
					vertexOutput output;

					float2 rasterPos = float2(_X + _ScreenParams.x / 2.0 + _Width * (input.vertex.x +0.5),
											  _Y + _ScreenParams.y / 2.0 + _Height * (input.vertex.y + 0.5));
					output.pos		 = float4(2 * rasterPos.x / _ScreenParams.x - 1, _ProjectionParams.x *(2 * rasterPos.y/_ScreenParams.y - 1), _ProjectionParams.y,1.0);
					output.tex		 = float4(input.vertex.x + 0.5, input.vertex.y + 0.5, 0,0);
				
					return output;

				}
			
				float4 frag (vertexOutput input) : COLOR
				{
					return _Color * tex2D(_MainTex, input.tex.xy);

				}
				ENDCG
		}
	}
}
