Shader "Andy/OutlinedObject"
{
	Properties
	{
		_Thickness("Thickness",Float) = 0.1
	}
		SubShader
	{

		LOD 100

		Pass
		{
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
			}

			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			uniform float _Thickness;

			
			float4 vert (float4 vertex:POSITION):SV_POSITION
			{
				return UnityObjectToClipPos(vertex);
			}
			
			float4 frag (void) : COLOR
			{
				return float4(0,0,0,1);
			}
			ENDCG
		}


		Pass
		{
			Cull Off
			Stencil
			{
				Ref 1
				Comp NotEqual
				Pass Keep
			}
			
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			uniform float _Thickness;

			float4 vert(float4 vertex : POSITION, float3 normal : NORMAL) : SV_POSITION
			{

				float4 normalDir = float4(normal, 0) * _Thickness;

				return UnityObjectToClipPos(vertex + normalDir);
			}

			float4 frag(void) : COLOR
			{
				return float4(0,1,0,1);
			}
			ENDCG

		}
	}
}
