Shader "Andy/ToonShading"
{
	Properties
	{
		_Color("Diffuse Color", Color) = (1,1,1,1)
		_UnlitColor("Unlit Color", Color) = (1,1,1,1)
		_DiffuseThreshold("Threshold for Diffuse Colors", Range(0,1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_LitOutlinetThickness("Lit Outline Thickness", Float) = 0.1
		_UnLitOutlinetThickness("UnLit Outline Thickness", Float) = 0.4
		_SpecColor("Spec Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
	}
		SubShader
	{

		LOD 100

		Pass
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex		vert
			#pragma fragment	frag

			#include "UnityCG.cginc"

			uniform float4	_LightColor0;

			uniform float4	_Color;
			uniform float4	_UnlitColor;
			uniform float	_DiffuseThreshold;
			uniform float4	_OutlineColor;
			uniform float	_LitOutlineThickness;
			uniform float	_UnLitOutlinetThickness;
			uniform float4  _SpecColor;
			uniform float	_Shininess;

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
				
				float4x4 modeMatrix			= unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				output.pos					= UnityObjectToClipPos(input.vertex);
				output.posWorld				= mul(modeMatrix, input.vertex);
				output.normalDir			= normalize(mul(float4(input.normal,0.0), modelMatrixInverse).xyz);

				return output;
			}
			
			float4 frag (vertexOutput input) : COLOR
			{
				// sample the texture
				float3 normalDir			= normalize(input.normalDir);
				float3 viewDir				= normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDir;
				float atten;

				if (_WorldSpaceLightPos0.w == 0) 
				{
					atten		= 1;
					lightDir	= normalize(_WorldSpaceLightPos0.xyz);
				}
				else 
				{
					float3 viewToSource = _WorldSpaceLightPos0.xyz - input.posWorld;
					float distance		= length(viewToSource);
					atten				= 1/distance;
					lightDir			= normalize(viewToSource);
				}

				float3 fragmentColor	= _UnlitColor.rgb;
				if (atten * max(0, dot(normalDir, lightDir)) >= _DiffuseThreshold) 
				{
					fragmentColor		= _LightColor0.rgb * _Color.rgb;
				}


				if (dot(viewDir, normalDir) < lerp(_UnLitOutlinetThickness, _LitOutlineThickness, max(0.0, dot(normalDir, lightDir))))
				{
					fragmentColor = _LightColor0.rgb * _OutlineColor.rgb;
				}

				if (dot(normalDir, lightDir) > 0 && atten * pow(max(0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess) > 0.5) 
				{
					fragmentColor = _SpecColor.a * _LightColor0.rgb * _SpecColor.rgb + (1.0 - _SpecColor.a) * fragmentColor;
				}
				return float4(fragmentColor,1);


				
			
			}
			ENDCG
		}
	}
}
