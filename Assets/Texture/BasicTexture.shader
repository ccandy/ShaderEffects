Shader "Andy/BasicTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
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

			uniform sampler2D	_MainTex;
			uniform float4		_MainTex_ST;
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;
				output.tex	= input.texcoord;
				output.pos	= UnityObjectToClipPos(input.vertex);
				return output;
			}
			
			fixed4 frag (vertexOutput input) : SV_Target
			{
				return tex2D(_MainTex,input.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
			}
			ENDCG
		}
	}
}
