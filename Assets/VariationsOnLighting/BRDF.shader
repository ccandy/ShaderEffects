Shader "Andy/BRDF"
{
	Properties
	{
		_Color("Diffuse Mat Color", Color)							= (1,1,1,1)
		_SpecColor("Spec Mat Color", Color)							= (1,1,1,1)
		_AlphaX("Roughness in Brush Direction", Float)				= 1
		_AlphaY("Roughness orthogonal to Brush Direction", Float)	= 1
	}
	SubShader
	{
		
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			
			#include "UnityCG.cginc"

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent: TANGENT;
			};

			struct vertexOutput
			{
				float4 pos			: SV_POSITION;
				float4 posWorld		: TEXCOORD0;
				float3 viewDir		: TEXCOORD1;
				float3 normalDir	: TEXCOORD2;
				float3 tangentDir	: TEXCOORD3;
			};


			uniform float4 _LightColor0;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float  _AlphaX;
			uniform float  _AlphaY;
			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(modelMatrix, input.vertex);
				output.viewDir				= normalize(_WorldSpaceCameraPos - output.posWorld.xyz);
				output.normalDir			= normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.tangentDir			= normalize(mul(modelMatrix, float4(input.tangent.xyz,0)).xyz);
				
				return output;
			}
			
			fixed4 frag (vertexOutput input) : COLOR
			{
				float3 lightDir;
				float atten;

				if (_WorldSpaceLightPos0.w = 0.0) 
				{
					atten				= 1;
					lightDir			= normalize(_WorldSpaceLightPos0.xyz);
				}
				else 
				{
					float3 viewToSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance		= length(viewToSource);
					atten				= 1/distance;
					lightDir			= normalize(viewToSource);
				}

				float3 halfwayVector	= normalize(lightDir + input.viewDir);
				float3 binormalDir		= cross(input.normalDir, input.tangentDir);
				float	dotLN			= dot(lightDir, input.normalDir);

				float3 ambientColor		= UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				float3 diffuseRef		= _Color.rgb * _LightColor0.rgb * max(0.0, dotLN);

				float3 specRef;
				if (dotLN < 0.0) 
				{
					specRef				= float3(0,0,0);
				}
				else 
				{
					float dotHN			= dot(halfwayVector, input.normalDir);
					float dotVN			= dot(input.viewDir, input.normalDir);
					float dotHTAlphaX	= dot(halfwayVector, input.tangentDir) / _AlphaX;
					float dotHBAlphaY	= dot(halfwayVector, binormalDir)/_AlphaY;

					specRef				= atten * _LightColor0.rgb * _SpecColor.rgb 
						* sqrt(max(0,dotLN/dotVN)) 
						* exp(-2 * (dotHTAlphaX * dotHTAlphaX + dotHBAlphaY * dotHBAlphaY)/(1 + dotHN));
				}

				return float4(ambientColor + diffuseRef + specRef, 1.0);
				





			}
			ENDCG
		}
	}
}
