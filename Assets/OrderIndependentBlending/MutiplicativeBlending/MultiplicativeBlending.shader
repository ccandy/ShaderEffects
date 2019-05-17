Shader "Andy/MultiplicativeBlending"
{
	
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Cull	Off
			ZWrite	Off
			Blend	Zero OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			#include "UnityCG.cginc"
			
			float4 vert (float4 vertexPos:POSITION) : SV_POSITION
			{
				
				return UnityObjectToClipPos(vertexPos);
			}
			
			fixed4 frag (void) : Color
			{
				
				return float4(1,0,0,0.2);
			}
			ENDCG
		}
	}
}
