// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/PhongShading"
{
	Properties
	{
		_Color("Diffuse Mat Color", Color)	= (1,1,1,1)
		_SpecColor("Spec Mat Color", Color) = (1,1,1,1)
		_Shininess("Shininess",Float)		= 10
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
			#pragma multi_compile_fwdbase
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
				float4 pos				:SV_POSITION;
				float4 posWorld			:TEXCOORD0;
				float4 normalDir		:TEXCOORD1;
				float4 vertexLighting	:TEXCOORD2;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse	= unity_WorldToObject;
				
				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(input.vertex, modelMatrix);
				output.normalDir			= mul(input.normal, modelMatrixInverse);
				output.vertexLighting		= float4(0, 0, 0,1);

				#ifdef VERTEXLIGHT_ON
				for (int n = 0; n < 4; n++) 
				{
					float4 lightPosition		= float4(unity_4LightPosX0[n], unity_4LightPosY0[n], unity_4LightPosZ0[n], 1.0);
					float3 vertexToLightSource	= lightPosition.xyz - output.posWorld;
					float3 lightDir				= normalize(vertexToLightSource);

				}
				return output;
				#endif
			}

			float frag(vertexOutput input) : COLOR
			{
				return input.col;
			}

			ENDCG
		}
			

	}
}
