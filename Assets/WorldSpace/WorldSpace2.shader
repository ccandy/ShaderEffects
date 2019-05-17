// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Andy/WorldSpace"
{
	Properties
	{
		_Point			("a point in world space", Vector)	= (0,0,0,1)
		_DistanceNear	("threshold distance",	Float)		= 5
		_ColorNear		("Color near to point", Color)		= (0,1.0,0,1)
		_ColorFar		("Color far from point", Color)		= (0.3,0.3,0.3,1)
	}


	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag
			// make fog work
			
			#include "UnityCG.cginc"
				

			struct vertexInput
			{
				float4 vertex : POSITION;
			};

			struct vertexOutput
			{
				float4 pos			:	SV_POSITION;
				float4 pos_in_world	:	TEXCOORD0;
			};

			uniform float4	_Point;
			uniform float	_DistanceNear;
			uniform float4  _ColorNear;
			uniform float4  _ColorFar;

			
			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;
				o.pos			= UnityObjectToClipPos(v.vertex);
				o.pos_in_world	= mul(unity_ObjectToWorld, v.vertex);

				return o;
			}
			
			fixed4 frag (vertexOutput i) : SV_Target
			{
				float dis = distance(i.pos_in_world, _Point);

			if (dis < _DistanceNear)
			{
				return _ColorNear;
				
			}
			else 
			{
				return _ColorFar;
			}


			}
			ENDCG
		}
	}
}
