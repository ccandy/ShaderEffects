Shader "Andy/ParallaxMap"
{
	Properties
	{
		_BumpMap	("Normal Map",	   2D)		= "bump"{}
		_ParallaxMap("Heightmap(in A)",2D)		= "black"{}
		_Color		("Diffuse Color", Color)	= (1,1,1,1)
		_SpecColor	("Spec Color",	  Color)	= (1,1,1,1)
		_Shininess	("Shiniess",	  Float)	= 10
		_Parallax	("Max Height",	  Float)	= 0.01
		_MaxTexCoordOffset("Max Texture Coordinate Offset", Float) =
		 0.01
	}


	CGINCLUDE
		#include "UnityCG.cginc"
		uniform float4		_LightColor0;
		
		uniform sampler2D	_BumpMap;
		uniform float4		_BumpMap_ST;
		
		uniform float4		_Color;
		uniform float4		_SpecColor;
		uniform float		_Shininess;

		uniform sampler2D	_ParallaxMap;
		uniform float		_Parallax;
		uniform float4		_ParallaxMap_ST;
		uniform float		_MaxTexCoordOffset;

		struct vertexInput 
		{
			float4 vertex	:POSITION;
			float3 normal	:NORMAL;
			float4 tangent : TANGENT;
			float4 texcoord :TEXCOORD0;
			
		};

		struct vertexOutput
		{
			float4 pos			:SV_POSITION;
			float4 posWorld		:TEXCOORD0;
			float4 tex			:TEXCOORD1;
			float3 tangentWorld	:TEXCOORD2;
			float3 normalWorld	:TEXCOORD3;
			float3 binormalWorld:TEXCOORD4;
			float3 viewDirWorld :TEXCOORD5;
			float3 viewDirInSurfaceCoords : TEXCOORD6;
		};

		vertexOutput vert(vertexInput input) 
		{
			vertexOutput output;

			float4x4 modelMatrix		= unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;

			output.tangentWorld			= normalize(mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
			output.normalWorld			= normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
			output.binormalWorld		= normalize(cross(output.normalWorld, output.tangentWorld) * input.tangent.w);

			float3 binormal				= cross(input.normal, input.tangent.xyz) * input.tangent.w;
			
			float3 viewDirInObjCoord	= mul(modelMatrixInverse, float4(_WorldSpaceCameraPos,1.0)) - input.vertex.xyz;
			
			float3x3 localSurfaceMatrix   = float3x3(input.tangent.xyz, binormal, input.normal);
			output.viewDirInSurfaceCoords = mul(localSurfaceMatrix, viewDirInObjCoord);

			output.posWorld		= mul(modelMatrix, input.vertex);
			output.tex			= input.texcoord;
			output.pos			= UnityObjectToClipPos(input.vertex);
			output.viewDirWorld = normalize(_WorldSpaceCameraPos - output.posWorld);


			return output;
		}

		float4 fragWithAmbient(vertexOutput input) :COLOR
		{
			float	height			= _Parallax * (-0.5 + tex2D(_ParallaxMap, _ParallaxMap_ST.xy * input.tex.xy + _ParallaxMap_ST.zw).x);
			float2	texCoordOffsets	= clamp(height * input.viewDirInSurfaceCoords.xy
				/ input.viewDirInSurfaceCoords.z,
				-_MaxTexCoordOffset, +_MaxTexCoordOffset);
			
			
			float4 encodeNormal		= tex2D(_BumpMap, _BumpMap_ST.xy * (input.tex.xy + texCoordOffsets) + _BumpMap_ST.zw);
			float3 localCoords		= float3(2.0*encodeNormal.a - 1, 2* encodeNormal.g - 1,0);
			localCoords.z			= sqrt(1 - dot(localCoords, localCoords));

			float3x3 local2World	= float3x3(input.tangentWorld, input.binormalWorld, input.normalWorld);
			float3 normalDir		= normalize(mul(localCoords, local2World));

			float3 lightDir;
			float atten;

			if (_WorldSpaceLightPos0.w == 0) 
			{
				atten		= 1;
				lightDir	= normalize(_WorldSpaceLightPos0.xyz);
			}
			else 
			{
				float3 viewToSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
				float distance		= length(viewToSource);
				atten				= 1/distance;
				lightDir			= normalize(viewToSource);
			}

			float3 ambientLight		= UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
			float3 diffuseRef		= _LightColor0.rgb *  _Color.rgb * atten * dot(max(normalDir, lightDir), 0);

			float3 specRef;

			if (dot(normalDir, lightDir) < 0) 
			{
				specRef = float3(0, 0, 0);
			}
			else 
			{
				specRef = atten * _LightColor0.rgb
					* _SpecColor.rgb * pow(max(0.0, dot(
						reflect(-lightDir, normalDir),
						input.viewDirWorld)), _Shininess);
			}


			return float4(ambientLight + diffuseRef + specRef,1);



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
