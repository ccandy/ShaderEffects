Shader "Andy/BasicImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D)		= "white" {}
		_Color ("Tint Color", Color)	= (1,1,1,1)
	}
	SubShader
	{
		// No culling or depth
		Cull Off 
		ZWrite Off 
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexInput
			{
				float4 vertex	: POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos		: SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;
				output.pos		= UnityObjectToClipPos(input.vertex);
				output.texcoord = input.texcoord;
				return output;
			}
			
			uniform sampler2D	_MainTex;
			uniform float4		_MainTex_ST;
			uniform float4		_Color;



			float4 frag (vertexOutput input) : COLOR
			{
				float4 col = tex2D(_MainTex, input.texcoord);
				return col * _Color;
			}
			ENDCG
		}
	}
}
