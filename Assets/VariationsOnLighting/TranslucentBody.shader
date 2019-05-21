Shader "Andy/TranslucentBody"
{
	Properties
	{
		_Color("Diffuse Color", Color) = (1,1,1,1)
		_Waxiness("Waxiness",Range(0,1)) = 0
		_SpecColor("Spec Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
		_TransColor("Translucent Color" ,Color) = (0,0,0,1)
	}
		SubShader
	{

		LOD 100

		Pass
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}


			Cull Front
			Blend One Zero

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			#include "UnityCG.cginc"

			uniform float4	_LightColor0;
			uniform float	_Waxiness;
			uniform float4	_SpecColor;
			uniform float	_Shininess;
			uniform float4	_TransColor;


			struct vertexInput
			{
				float4 vertex		: POSITION;
				float3 normal 		: NORMAL;
			};

			struct vertexOutput
			{
				float4 pos		: SV_POSITION;
				float4 posWorld	: TEXCOORD0;
				float3 normalDir: TEXCOORD1;
			};

			
			
			vertexOutput  vert (vertexInput input)
			{
				vertexOutput output;
				
				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;
				
				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(modelMatrix, output.pos);
				output.normalDir			= normalize(mul(float4(input.normal,0), modelMatrixInverse).xyz);

				return output;
			}
			
			fixed4 frag (vertexOutput input) : COLOR
			{
				float3 normalDir			= normalize(input.normalDir);
				float3 viewDir				= normalize(_WorldSpaceCameraPos.xyz - input.posWorld.xyz);
				
				float3 lightDir;
				float  atten;

				if (_WorldSpaceLightPos0.w == 0) 
				{
					atten		= 1;
					lightDir	= normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 viewSource	= _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance		= length(viewSource);
					atten				= 1 / distance;
					lightDir			= normalize(viewSource);
				}

				float3 ambientLighting	= _TransColor.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
				float3 diffuseRef		= _TransColor.rgb * atten * _LightColor0.rgb * max(0,dot(normalDir, lightDir));

				float silhouetteness    = 1 - abs(dot(viewDir, normalDir));

				return float4(silhouetteness * (ambientLighting + diffuseRef), 1.0);
			}
			ENDCG
		}
	}
}
