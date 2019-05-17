Shader "Andy/BlendWithBack"
{
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Cull Front
			ZWrite	Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			#include "UnityCG.cginc"
			
			float4 vert (float4 vertexPos:POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
				
			}
			
			fixed4 frag (void) : COLOR
			{
				return float4(0,1,0,0.3);
			}
			ENDCG
		}

		Pass
		{
			Cull Back
			ZWrite	Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			#include "UnityCG.cginc"

			float4 vert(float4 vertexPos:POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);

			}

			fixed4 frag(void) : COLOR
			{
				return float4(1,0,0,0.3);
			}
			ENDCG
		}

	}
}
