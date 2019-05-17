Shader "Andy/GlossyTexture"
{
	Properties
	{
		_MainTex	("Texture", 2D)					= "white" {}
		_Color("Diffuse Mat Color", Color) = (1,1,1,1)
		_SpecColor("Spec Mat Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10

	}
		SubShader
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode"  = "ForwardBase"
			}
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex		vert
				#pragma fragment	frag


				#include "UnityCG.cginc"

				uniform float4		_LightColor0;
				uniform sampler2D	_MainTex;
				uniform float4		_Color;
				uniform float4		_SpecColor;
				uniform float		_Shininess;


				struct vertexInput 
				{
					float4 vertex	:POSITION;
					float3 normal	:NORMAL;
					float4 texcoord	:TEXCOORD0;
				};
			
				struct vertexOutput
				{
					float4 pos			:SV_POSITION;
					float4 posWorld		:TEXCOORD0;
					float4 normalDir	:TEXCOORD1;
					float4 tex			:TEXCOORD2;
				};

			
				vertexOutput vert (vertexInput input)
				{
					vertexOutput output;

					float4x4 modelMatrix		= unity_ObjectToWorld;
					float4x4 modelMatrixInverse = unity_WorldToObject;

					output.pos					= input.vertex;
					output.tex					= input.texcoord;
					output.posWorld				= UnityObjectToClipPos(input.vertex);
					return output;
				}
			
				fixed4 frag (vertexOutput input) : SV_Target
				{

					float3 normalDir			= normalize(input.normalDir);

					float3 viewDir				= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
					float3 lightDir;
					float atten;
					
					if (_WorldSpaceLightPos0.w == 0) 
					{
						atten		= 1;
						lightDir	= normalize(_WorldSpaceLightPos0.xyz);
					}
					else 
					{
						float3 viewToSource = normalize(_WorldSpaceLightPos0.xyz - input.posWorld.xyz);
						float  distance		= length(viewToSource);
						atten				= 1 / distance;
						lightDir			= normalize(viewToSource);
					}

					float4 texColor			= tex2D(_MainTex, input.tex.xy);
					float3 ambeintLight		= UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb * texColor.rgb;
					float3 diffuseReflect	= _Color.rgb * texColor.rgb * _LightColor0.rgb * max(0, dot(lightDir, normalDir)) * atten;

					float3 specReflect;

					if (dot(normalDir, lightDir) < 0) 
					{
						specReflect = float3(0, 0, 0);
					}
					else 
					{
						specReflect = atten * _LightColor0.rgb
							* _SpecColor.rgb * (1.0 - texColor.a)* pow(max(0.0, dot(
								reflect(-lightDir, normalDir),
								viewDir)), _Shininess);
					}





					return float4(ambeintLight + specReflect + diffuseReflect, 0);
				}
				ENDCG
			}
		}
}
