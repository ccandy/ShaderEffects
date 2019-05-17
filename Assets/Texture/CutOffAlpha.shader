Shader "Andy/LayerOfTexture"
{
	Properties
	{
		_MainTex	("Texture", 2D)				= "white" {}
		_DecalTex	("Decal Texture", 2D)		= "white" {}
		_Color		("Main RGB Color", Color)   = (1,1,1,1)
	}
	SubShader
	{
		Tags { "LightMode" = "ForwardBase" }
		LOD 100

		Pass
		{
			

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
		 
			uniform sampler2D	_MainTex;
			uniform sampler2D	_DecalTex;
			uniform float4		_Color;
			uniform float4		_LightColor0;

			#include "UnityCG.cginc"
			
			struct vertexInput 
			{
				float4 vertex	:POSITION;
				float3 normal	:NORMAL;
				float4 texcoord	:TEXCOORD0;
			};
			
			struct vertexOutput
			{
				float4 pos				:SV_POSITION;
				float4 tex				:TEXCOORD0;
				float levelOfLighting	:TEXCOORD1;
			};

			
			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix		= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				float4	 normalTemp			= mul(float4(input.normal,0), modelMatrixInverse);
				float3   normalDir			= normalize(normalTemp.xyz);
				float3   lightDir			= normalize(_WorldSpaceLightPos0.xyz);


				output.levelOfLighting		= max(0,dot(normalDir, lightDir));
				output.tex					= input.texcoord;
				output.pos					= UnityObjectToClipPos(input.vertex);
				return output;
			}
			
			fixed4 frag (vertexOutput input) : SV_Target
			{
				float4 mainColor			= tex2D(_MainTex, input.tex.xy) * _Color;
				float4 decalColor			= tex2D(_DecalTex, input.tex.xy) * _LightColor0;


				return lerp(decalColor, mainColor, input.levelOfLighting);
			}
			ENDCG
		}
	}
}
