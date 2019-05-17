Shader "Andy/CutOffAlpha"
{
	Properties
	{
		_MainTex	("Texture", 2D)				= "white" {}
		_Cutoff		("Alpha Cut off", Float)	= 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Off

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			
			uniform sampler2D	_MainTex;
			uniform float		_Cutoff;

			#include "UnityCG.cginc"
			
			struct vertexInput 
			{
				float4 vertex	:POSITION;
				float4 texcoord	:TEXCOORD0;
			};
			
			struct vertexOutput
			{
				float4 pos		:SV_POSITION;
				float4 tex		:TEXCOORD0;
			};

			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;
				output.tex	= input.texcoord;
				output.pos	= UnityObjectToClipPos(input.vertex);
				return output;
			}
			
			fixed4 frag (vertexOutput input) : SV_Target
			{
				float4 textureColor = tex2D(_MainTex, input.tex.xy);
				if (textureColor.a < _Cutoff) 
				{
					discard;
				}

				return textureColor;


			}
			ENDCG
		}
	}
}
