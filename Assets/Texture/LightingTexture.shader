// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/LightingTexture"
{
	Properties
	{
		_MainTex	("Texture",			2D)		= "white" {}
		_Color		("Color",			Color) = (1,1,1,1)
		_SpecColor	("Spec Color",		Color) = (1,1,1,1)
		_Shininess	("_Shininess",		Float) = 10
	}
		SubShader
		{
			Tags
			{
				"RenderType"	= "Opaque"
				"LightMode"		= "ForwardBase"
			}
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex		vert
				#pragma fragment	frag


				#include "UnityCG.cginc"

				uniform float4		_LightColor0;
				
				uniform sampler2D 	_MainTex;
				uniform float4		_MainTex_ST;
				uniform float4		_Color;
				uniform float4		_SpecColor;
				uniform float		_Shininess;

				struct vertexInput 
				{
					float4 vertex	:POSITION;
					float4 normal	:NORMAL;
					float4 texcoord :TEXCOORD0;
				};
			
				struct vertexOutput
				{
					float4 pos			:SV_POSITION;
					float4 tex			:TEXCOORD0;
					float3 diffuseColor	:TEXCOORD1;
					float3 specColor	:TEXCOORD2;

				};

				
			
				vertexOutput vert (vertexInput input)
				{
					vertexOutput output;
					
					float4x4 modelMatrix		= unity_ObjectToWorld;
					float4x4 modelMatrixInverse = unity_WorldToObject;
					
					float3	tempNormal			= mul(input.normal, modelMatrixInverse);
					float3	normalDir			= normalize(float3(tempNormal.x, tempNormal.y, tempNormal.z));
					
					float3  tempViewDir			= _WorldSpaceCameraPos - mul(modelMatrix, input.vertex);
					float3  viewDir				= normalize(float3(tempViewDir.x, tempViewDir.y, tempViewDir.z));

					float3 lightDir;
					float atten;

					if (_WorldSpaceLightPos0.w == 0.0)
					{
						atten		= 1.0;
						lightDir	= normalize(_WorldSpaceLightPos0.xyz);
					}
					else 
					{
						float3 viewToVertex = _WorldSpaceLightPos0.xyz - mul(modelMatrix, input.vertex);
						float distance		= length(viewToVertex);
						atten				= 1 / distance;
						lightDir			= normalize(viewToVertex);
					}

					float3 ambientLighting	= UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseRef		= _LightColor0.rgb * _Color.rgb * max(dot(lightDir, normalDir), 0) * atten;

					float3 specReflect;

					if (dot(viewDir, normalDir) < 0) 
					{
						specReflect = float4(0, 0, 0, 1);
					}
					else 
					{
						specReflect = atten * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(
								reflect(-lightDir, normalDir),
								viewDir)), _Shininess);
					}

					output.diffuseColor = ambientLighting + diffuseRef;
					output.specColor	= specReflect;
					output.tex			= input.texcoord;
					output.pos			= UnityObjectToClipPos(input.vertex);

					return output;
				}
			
				fixed4 frag (vertexOutput input) : SV_Target
				{
					return float4(input.specColor + input.diffuseColor * tex2D(_MainTex,input.tex.xy),1.0);
				}
				ENDCG
		}
	}
}
