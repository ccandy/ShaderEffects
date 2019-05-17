Shader "Andy/RefractionMap"
{
	Properties
	{
		_Cube("Reflection Map", Cube) = "" {}
		
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
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float3 normalDir: TEXCOORD0;
				float4 pos		: SV_POSITION;
				float3 viewDir	: TEXCOORD1;
			};

			uniform samplerCUBE _Cube;
			
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput o;
				
				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;
				
				o.pos		= UnityObjectToClipPos(input.vertex);
				o.viewDir	= mul(modelMatrix, input.vertex) - _WorldSpaceCameraPos;
				o.normalDir = mul(float4(input.normal,0), modelMatrixInverse).xyz;

				return o;
			}
			
			fixed4 frag (vertexOutput input) : SV_Target
			{
				// sample the texture
				float refractiveIndex = 1.5;
				float3 refractedDir = refract(input.viewDir, normalize(input.normalDir),1/ refractiveIndex);
				
				return texCUBE(_Cube, refractedDir);
			}
			ENDCG
		}
	}
}
