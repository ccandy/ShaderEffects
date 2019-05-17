Shader "Andy/SeeThoughWall"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ThoughColor("See Tough Color",Color) = (1,0,0,1)
	}
		SubShader
		{
		

			Tags { "RenderType" = "Opaque" }

			Pass
			{


				ZTest   Greater
				//Blend	One One
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				sampler2D	_MainTex;
				fixed4		_ThoughColor;
				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = _ThoughColor;
					return col;
				}
				ENDCG
			}

			Pass
			{

				ZTest   Less

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				sampler2D	_MainTex;
				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					return col;
				}
				ENDCG
			}

		}

}
