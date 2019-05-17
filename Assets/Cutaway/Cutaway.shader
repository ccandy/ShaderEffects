Shader "Andy/Cutaway2
"
{
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }

		LOD 100

		Pass
		{

			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			
			#include "UnityCG.cginc"

			struct vertexInput 
			{
				float4 vertex			: POSITION;
			};
			struct vertexOutput
			{
				float2 posInObjCoord	: TEXCOORD0;
				float4 vertex			: SV_POSITION;
			};

			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;
				output.vertex			= UnityObjectToClipPos(input.vertex);
				output.posInObjCoord	= input.vertex;
				return output;

			}
			
			fixed4 frag (vertexOutput input) : SV_Target
			{
				if (input.posInObjCoord.y > 0.0)
				{
					discard;
				}
				return float4(1.0,0,0,1);
			}
			ENDCG
		}

		Pass
		{

			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
				// make fog work


				#include "UnityCG.cginc"

				struct vertexInput
				{
					float4 vertex			: POSITION;
				};
				struct vertexOutput
				{
					float2 posInObjCoord	: TEXCOORD0;
					float4 vertex			: SV_POSITION;
				};


				vertexOutput vert(vertexInput input)
				{
					vertexOutput output;
					output.vertex = UnityObjectToClipPos(input.vertex);
					output.posInObjCoord = input.vertex;
					return output;

				}

				fixed4 frag(vertexOutput input) : SV_Target
				{
					if (input.posInObjCoord.y > 0.0)
					{
						discard;
					}
					return float4(0,1,0,1);
				}
				ENDCG
			}




	}
}
