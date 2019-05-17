Shader "Andy/BasicNormalMap"
{
	Properties
	{
		_MainTex("Main Tex",2D)						= "White" {}
		_DisplacementTex("Displacement tex", 2D)	= "White" {}
		_MaxDisplacement("Max Displacement",Float)  = 1.0
	}

	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
		}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			
			uniform sampler2D	_MainTex;
			uniform sampler2D	_DisplacementTex;
			uniform float		_MaxDisplacement;

			struct vertexInput 
			{
				float4 vertex	:POSITION;
				float3 normal	:NORMAL;
				float4 texcoord	:TEXCOORD0;
			};

			struct vertexOutput 
			{
				float4 position :POSITION;
				float4 texcoord :TEXCOORD0;
			};

			vertexOutput vert(vertexInput i) 
			{
				float4 dispTexColor = tex2Dlod(_DisplacementTex, float4(i.texcoord.xy, 0, 0));
				float displacemnet	= dot(float3(0.21,0.72,0.07), dispTexColor.rgb) * _MaxDisplacement;;

				float4 newVertexPos = i.vertex + float4(i.normal * displacemnet, 0.0);

				vertexOutput o;
				o.position			= UnityObjectToClipPos(newVertexPos);
				o.texcoord			= i.texcoord;

				return o;
			}

			float frag(vertexOutput i) : COLOR
			{
				return tex2D(_MainTex, i.texcoord.xy);
			}

			ENDCG
			
		}
	}
}
