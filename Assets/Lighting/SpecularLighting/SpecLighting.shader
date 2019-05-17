// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/SpecLighting"
{
	Properties
	{
		_Color("Diffuse Mat Color", Color) = (1,1,1,1)
		_SpecColor("Spec Mat Color", Color) = (1,1,1,1)
		_Shininess("Shininess",Float) = 10
	}
		SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex		vert  
			#pragma fragment	frag 

			#include "UnityCG.cginc"


			uniform	float4	_LightColor0;

			uniform	float4	_SpecColor;
			uniform float	_Shininess;
			uniform float4  _Color;

			struct vertexInput 
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
			};

			struct vertexOutput 
			{
				float4 pos		:SV_POSITION;
				float4 col		:COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				float3	normalDirection = normalize(mul(input.normal, modelMatrixInverse));
				float3  viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, input.vertex).xyz);

				float3	lightDir;

				float	atten;

				if (_WorldSpaceLightPos0.w == 0.0) //direction light
				{
					atten = 1.0; // No atten;
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(modelMatrix, input.vertex).xyz;
					float  distance = length(vertexToLightSource);
					atten = 1 / distance;
					lightDir = normalize(vertexToLightSource);
				}


				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT * _Color.rgb;
				float3 diffuseReflection = atten * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDir));
				float3 specReflection;

				if (dot(normalDirection, viewDirection) < 0) //viewer in a wrong direction 
				{
					specReflection = float4(0, 0, 0, 1);
				}
				else
				{
					specReflection = atten * _LightColor0.rgb
						* _SpecColor.rgb * pow(max(0.0, dot(
							reflect(-lightDir, normalDirection),
							viewDirection)), _Shininess);
				}

				output.col		= float4(diffuseReflection + ambientLighting + specReflection, 1);
				//output.col		= _LightColor0;
				output.pos		= UnityObjectToClipPos(input.vertex);
				return output;

			}

			float4 frag(vertexOutput input) : COLOR
			{
				return input.col;
			}

			ENDCG
		}
			

	}
}
