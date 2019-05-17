Shader "Hidden/ScanEffectShader"
{
	Properties
	{
		_MainTex	("Texture",		2D)			= "white" {}
		_ScanColor	("Scan Color",	Color)		= (1,1,1,0)
		_ScanTimer	("Scan Timer",	float)		= 0
		_ScanWidth	("Scan Width",	float)		= 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
			};

			struct v2f
			{
				float2 uv		: TEXCOORD0;
				float2 uv_depth	: TEXCOORD1;
				float4 vertex	: SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex	= UnityObjectToClipPos(v.vertex);
				o.uv		= v.uv.xy;
				o.uv_depth	= v.uv.xy;
				return o;
			}
			
			sampler2D	_MainTex;
			sampler2D	_CameraDepthTexture;
			float		_ScanTimer;
			float		_ScanWidth;
			float4		_ScanColor;
			

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col			= tex2D(_MainTex, i.uv);
				float depth			= SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
				float linerDepth	= Linear01Depth(depth);

				if (linerDepth < _ScanTimer && linerDepth > _ScanTimer - _ScanWidth && linerDepth < 1)
				{
					float diff = 1 - (_ScanTimer - linerDepth) / _ScanWidth;
					_ScanColor *= diff;
					return col + _ScanColor;
				}

				
				return col;
			}
			ENDCG
		}
	}
}
