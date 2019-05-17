// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/BasicRGB"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			
			#include "UnityCG.cginc"
			struct vertexOutput 
			{
				float4 pos: SV_POSITION;
				float4 col: TEXCOORD0;
			};
			
			vertexOutput vert (float4 vertexPos : POSITION)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(vertexPos);
				output.col = vertexPos + float4(0.5, 0.5, 0.5, 0.0);
				return output;
			}
			
			fixed4 frag(vertexOutput input) : COLOR
			{
				
				return input.col;
			}
			ENDCG
		}
	}
}
