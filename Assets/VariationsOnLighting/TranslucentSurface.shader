Shader "Andy/TranslucentSurface"
{
	Properties
	{
		_Color("Diffuse Mat Color", Color)			= (1,1,1,1)
		_SpecColor("Spec Mat Color", Color)			= (1,1,1,1)
		_Shininess("Shininess", Float)				= 10
		_DiffuseTrans("Diffuse Trans Color", Color) = (1,1,1,1)
		_ForwardTrans("Forward Trans Color", Color) = (1,1,1,1)
		_Sharpness("Sharpness", Float)				= 10
	}
		SubShader
	{
		
		LOD 100

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


			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float  _Shininess;
			uniform float  _Sharpness;
			uniform float4 _DiffuseTrans;
			uniform float4 _ForwardTrans;
			uniform float4 _LightColor0;

			struct vertexInput
			{
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
			};

			struct vertexOutput
			{
				float4 posWorld : TEXCOORD0;
				float4 pos		: SV_POSITION;
				float3 normalDir: TEXCOORD1;
			};

			
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(modelMatrix, input.vertex);
				output.normalDir			= normalize(mul(float4(input.normal,0.0), modelMatrixInverse).xyz);
				return output;
			}
			
			fixed4 frag (vertexOutput input) : COLOR
			{
				
				float3 normalDir			= normalize(input.normalDir);
				float3 viewDir				= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);

				normalDir					= faceforward(normalDir, -viewDir, normalDir);
				float3 lightDir;
				float atten;

				if (_WorldSpaceLightPos0.w == 0) 
				{
					atten = 1;
					lightDir				= normalize(_WorldSpaceLightPos0.xyz);
				}
				else 
				{
					float3 viewToSource		= _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance			= length(viewToSource);
					atten					= 1/distance;
					lightDir				= normalize(viewToSource);
				}

				float3 ambientLigting		= UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				float3 diffuseLighting		= _Color.rgb * _LightColor0.rgb * max(0, dot(lightDir, normalDir)) * atten;
				
				float3 specRef;
				if (dot(lightDir, normalDir) < 0) 
				{
					specRef					= float3(0,0,0);
				}
				else 
				{
					specRef					= atten * _LightColor0.rgb * _SpecColor.rgb *pow(max(0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess);
				}

				float3 diffuseTrans			= atten * _LightColor0.rgb * _DiffuseTrans.rgb * max(0,dot(lightDir, -normalDir));
				

				float3 forwardTrans;
				if (dot(lightDir, normalDir) > 0) 
				{
					forwardTrans			= float3(0,0,0);
				}
				else 
				{
					forwardTrans			= atten * _LightColor0.rgb * _ForwardTrans.rgb * pow(max(0, dot(-lightDir, viewDir)), _Sharpness);
				}

				return float4(ambientLigting + diffuseLighting + specRef + forwardTrans + diffuseTrans,1.0);

			}
			ENDCG
		}
	}
}
