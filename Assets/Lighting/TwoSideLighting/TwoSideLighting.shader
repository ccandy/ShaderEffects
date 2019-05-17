// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/TwoSideLighting"
{
	Properties
	{
		_Color("Front Mat Color", Color)				= (1,1,1,1)
		_SpecColor("Spec Mat Color", Color)				= (1,1,1,1)
		_Shininess("Shininess",Float)					= 10
	}
	SubShader
	{
		Pass
		{
			Tags
			{
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
				float4 pos			:SV_POSITION;
				float4 posWorld		:TEXCOORD0;
				float4 normalDir	:TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse	= unity_WorldToObject;

				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(input.vertex, modelMatrix);
				float4 tempNormal			= float4(input.normal.x, input.normal.y, input.normal.z, 0.0);
				float4 tempNormalDir		= mul(tempNormal, modelMatrixInverse);
				output.normalDir			= normalize(float4(tempNormalDir.x, tempNormalDir.y, tempNormalDir.z, 1));
				
				return output;



			}

			float4 frag(vertexOutput input) : COLOR
			{
				float3	normalDir			= normalize(input.normalDir);
				float3	viewDir				= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);

				float3	lightDir;
				float	atten;

				if (_WorldSpaceLightPos0.w == 0.0) // direction light
				{
					atten		= 1;
					lightDir	= normalize(_WorldSpaceLightPos0.xyz);
				}
				else 
				{
					float3	vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float	distance			= length(vertexToLightSource);
					atten						= 1 / distance;
					lightDir					= normalize(vertexToLightSource);
				}

				float3 ambientLight			= _WorldSpaceLightPos0.xyz * _Color.rgb;
				float3 diffuseReflection	= _Color * _LightColor0 * max(dot(lightDir, viewDir), 0) * atten;

				float3 specReflection;
				if (dot(lightDir, normalDir) < 0.0)
				{
					specReflection = float4(0, 0, 0, 1);
				}
				else 
				{
					specReflection = atten * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDir, normalDir),
							viewDir)), _Shininess);
				}



				return float4(ambientLight + diffuseReflection + specReflection, 1);
			}

			ENDCG
		}
			

	}
}
