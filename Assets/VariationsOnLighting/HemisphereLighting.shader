Shader "Andy/HemisphereLighting"
{
	Properties
	{
		_Color ("Diffuse Mat Color", Color)			= (1,1,1,1)
		_UpperHeiColor("Upper Hei Color",Color)		= (1,1,1,1)
		_LowerHeiColor("Lower Hei Color",Color)		= (1,1,1,1)
		_UpVector("Up Vector", Vector)				= (0,1,0,0)
	}
	SubShader
	{
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
				float4 col		: COLOR;
				float4 pos		: SV_POSITION;
			};

			uniform float4 _Color;
			uniform float4 _UpperHeiColor;
			uniform float4 _LowerHeiColor;
			uniform float4 _UpVector;
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;
				
				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				float3 normalDir			= normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				float3 upDir				= normalize(_UpVector);

				float w						= 0.5 * (1 +dot(upDir, normalDir));
				output.col					= (w*_UpperHeiColor) + (1 - w) * _LowerHeiColor * _Color;
				output.pos					= UnityObjectToClipPos(input.vertex);
				return output;
			}
			
			fixed4 frag (vertexOutput i) : COLOR
			{
				
				return i.col;
			}
			ENDCG
		}
	}
}
