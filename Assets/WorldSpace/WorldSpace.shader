// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/WorldSpace2"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct vertexInput
			{
				float4 vertex : POSITION;
			};

			struct vertexOutput
			{
				float4 pos			:	SV_POSITION;
				float4 pos_in_world	:	TEXCOORD0;
			};

			
			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;
				o.pos			= UnityObjectToClipPos(v.vertex);
				o.pos_in_world	= mul(unity_ObjectToWorld, v.vertex);

				return o;
			}
			
			fixed4 frag (vertexOutput i) : SV_Target
			{
				float dis = distance(i.pos_in_world, float4(0,0,0,1));

			if (dis < 1.0) 
			{
				return float4(0.1, 1, 0.1, 1.0);
				
			}
			else 
			{
				return float4(1, 0.1, 0.1, 1.0);
			}


			}
			ENDCG
		}
	}
}
