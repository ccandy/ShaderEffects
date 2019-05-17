Shader "Andy/BasicNormalMap"
{
	Properties
	{
		_BumpMap	("Normal Map",	  2D)		= "bump"{}
		_Color		("Diffuse Color", Color)	= (1,1,1,1)
		_SpecColor	("Spec Color",	  Color)	= (1,1,1,1)
		_Shininess	("Shiniess",	  Float)	= 10	
	}


	CGINCLUDE
		#include "UnityCG.cginc"
		uniform float4		_LightColor0;
		
		uniform sampler2D	_BumpMap;
		uniform float4		_BumpMap_ST;
		
		uniform float4		_Color;
		uniform float4		_SpecColor;
		uniform float		_Shininess;

		struct vertexInput 
		{
			float4 vertex	:POSITION;
			float3 normal	:NORMAL;
			float4 texcoord :TEXCOORD0;
			float4 tangent	:TANGENT;
		};

		struct vertexOutput
		{
			float4 pos			:SV_POSITION;
			float4 posWorld		:TEXCOORD0;
			float4 tex			:TEXCOORD1;
			float3 tangentWorld	:TEXCOORD2;
			float3 normalWorld	:TEXCOORD3;
			float3 binormalWorld:TEXCOORD4;
		};

		vertexOutput vert(vertexInput input) 
		{
			vertexOutput output;

			float4x4	modelMatrix			= unity_ObjectToWorld;
			float4x4	modelMatrixInverse	= unity_WorldToObject;

			output.tangentWorld				= normalize(mul(modelMatrix,		float4(input.tangent.xyz, 0)).xyz);
			output.normalWorld				= normalize(mul(float4(input.normal.xyz, 0), modelMatrixInverse).xyz);
			output.binormalWorld			= normalize(cross(output.normalWorld, output.tangentWorld) * input.tangent.w);

			output.posWorld					= mul(modelMatrix, input.vertex);
			output.tex						= input.texcoord;
			output.pos						= UnityObjectToClipPos(input.vertex);

			return output;
		}

		float4 fragWithAmbient(vertexOutput input) :COLOR
		{
			float4 encodeNormal = tex2D(_BumpMap, input.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
			float3 localCoords	= float3(2 * encodeNormal.a - 1.0, 2 * encodeNormal.g, 0.0);
			localCoords.z		= sqrt(1.0 - dot(localCoords, localCoords));

			float3x3 local2WorldTranspose = float3x3(
				input.tangentWorld,
				input.binormalWorld,
				input.normalWorld);

			float3 normalDir	= normalize(mul(localCoords, local2WorldTranspose));
			float3 viewDir		= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);

			float3 lightDir;
			float atten;

			if (_WorldSpaceLightPos0.w = 0.0) 
			{
				atten			= 1.0;
				lightDir		= normalize(_WorldSpaceLightPos0.xyz);
			}
			else 
			{
				float3 viewSource	= _WorldSpaceCameraPos - input.posWorld.xyz;
				float distance		= length(viewSource);
				atten				= 1 / distance;
				lightDir			= normalize(viewSource);
			}


			float3 ambientLight		= UNITY_LIGHTMODEL_AMBIENT * _Color.rgb;
			float3 diffuseRef		= _Color.rgb * _LightColor0.rgb * max(0, dot(lightDir, normalDir)) * atten;

			float3 specRef;

			if (dot(normalDir,lightDir) < 0)
			{
				specRef = float3(0, 0, 0);
			}
			else 
			{
				specRef = atten * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(
						reflect(-lightDir, normalDir),
						viewDir)), _Shininess);
			}


			return float4(ambientLight + diffuseRef + specRef, 1.0);

		}




	ENDCG

	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
			"LightMode" = "ForwardBase"
		}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	fragWithAmbient
			
			ENDCG
			
		}
	}
}
