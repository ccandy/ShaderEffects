Shader "Andy/Billboard"
{
	Properties
	{
		_MainTex	("Texture", 2D)		= "white" {}
		_ScaleX		("Scale X", Float)	= 1.0
		_ScaleY		("Scale Y", Float)	= 1.0
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
		}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			
			#include "UnityCG.cginc"

			struct vertexInput
			{
				float4 vertex	: POSITION;
				float4 tex		: TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos		:	SV_POSITION;
				float4 tex		:	TEXCOORD0;
			};

			uniform sampler2D	_MainTex;
			uniform float		_ScaleX;
			uniform float		_ScaleY;
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;

				output.pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(input.vertex.x, input.vertex.y, 0, 0) + float4(_ScaleX, _ScaleY, 1, 1));
				output.tex = input.tex;
				return output;
			}
			
			float4 frag (vertexOutput input) : COLOR
			{		
				return tex2D(_MainTex, float2(input.tex.xy));
			}
			ENDCG
		}
	}
}
