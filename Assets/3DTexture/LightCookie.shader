Shader "Andy/LightCookie"
{
	Properties
	{
		_Color("Diffuse Color", Color) = (1,1,1,1)
		_SpecColor("Spec Color",	  Color) = (1,1,1,1)
		_Shininess("Shiniess",	  Float) = 10
	}

		SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"LightMode" = "ForwardBase"
		}
		LOD 100

		Pass
		{

			Blend One One
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			#include "UnityCG.cginc"


			uniform float4		_LightColor0;
			uniform float4x4	_LightMatix0;
			uniform sampler2D	_LightTexture0;

			uniform float4		_Color0;
			uniform float4		_SpecColor;
			uniform float		_Shininess;


			struct vertexInput 
			{
				float4 vertex	:POSITION;
				float3 normal	:NORMAL;
			};

			struct vertexOutput 
			{
				float4 pos		:POSITION;
				float4 posWorld	:TEXCOORD0;
				float4 posLight	:TEXCOORD1;
				float3 normalDir:TEXCOORD2;
			};

			vertexOutput vert(vertexInput input) 
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				output.posWorld				= mul(modelMatrix, input.vertex);
				output.posLight				= mul(_LightMatix0, output.posWorld);
				output.normalDir			= normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.pos					= UnityObjectToClipPos(input.vertex
				);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDir			= normalize(input.normalDir);

				float3 viewDir				= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDir;
				float atten;

				if (_WorldSpaceLightPos0.w == 0.0) 
				{
					atten		= 1.0;
					lightDir	= normalize(_WorldSpaceLightPos0.xyz);
				}
				else 
				{
					float3 viewToSource = _WorldSpaceLightPos0 - input.posWorld.xyz;
					float distance		= length(viewToSource);
					atten				= 1/ distance;
					lightDir			= normalize(viewToSource);
				}

				float3 diffuseRef		= atten * _LightColor0.rgb * _SpecColor.rgb * pow(0,dot(lightDir, normalDir));
				float3 SpecRef;

				if (dot(lightDir, normalDir) < 0) 
				{
					SpecRef				= float3(0,0,0);
				}
				else 
				{
					SpecRef = atten * _LightColor0.rgb
						* _SpecColor.rgb * pow(max(0.0, dot(
							reflect(-lightDir, normalDir),
							viewDir)), _Shininess);
				}

				float cookieAtten		= 1.0;
				if (_WorldSpaceLightPos0.w == 0.0) 
				{
					cookieAtten = tex2D(_LightTexture0, input.posLight.xy).a;

				}
				else 
				{
					cookieAtten = tex2D(_LightTexture0, input.posLight.xy / input.posLight.w + float2(0.5, 0.5)).a;
				}

				return float4(cookieAtten * (diffuseRef + SpecRef), 1.0);











			}


			
			
			ENDCG
			
		}
	}
}
