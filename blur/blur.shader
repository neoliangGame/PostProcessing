Shader "neo/blur"
{
	Properties
	{
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		[HideInInspector]_Strength("Strength",Range(0,5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			float _Strength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//					  ( 0, 2)
				//			 (-1, 1), ( 0, 1), ( 1, 1)
				//	(-2, 0), (-1, 0), ( 0, 0), ( 1, 0), ( 2, 0)
				//			 (-1,-1), ( 0,-1), ( 1,-1)
				//					  ( 0,-2)
				//fixed4 col = tex2D(_MainTex, i.uv) * 8;

				float2 strengSize = _Strength * _MainTex_TexelSize.xy;

				float2 offsetUV = i.uv + fixed2(0,2) * strengSize;
				float4 col = tex2D(_MainTex, offsetUV);//1

				offsetUV = i.uv + fixed2(-1, 1) * strengSize;//9
				col += tex2D(_MainTex, offsetUV) * 2.5;
				offsetUV = i.uv + fixed2(0, 1) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 4;
				offsetUV = i.uv + fixed2(1, 1) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 2.5;

				offsetUV = i.uv + fixed2(-2, 0) * strengSize;//18
				col += tex2D(_MainTex, offsetUV);
				offsetUV = i.uv + fixed2(-1, 0) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 4;
				offsetUV = i.uv + fixed2(0, 0) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 8;
				offsetUV = i.uv + fixed2(1, 0) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 4;
				offsetUV = i.uv + fixed2(2, 0) * strengSize;
				col += tex2D(_MainTex, offsetUV);

				offsetUV = i.uv + fixed2(-1, -1) * strengSize;//9
				col += tex2D(_MainTex, offsetUV) * 2.5;
				offsetUV = i.uv + fixed2(0, -1) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 4;
				offsetUV = i.uv + fixed2(1, -1) * strengSize;
				col += tex2D(_MainTex, offsetUV) * 2.5;

				offsetUV = i.uv + fixed2(0, -2) * strengSize;//1
				col += tex2D(_MainTex, offsetUV);

				col /= 38;
				return col;
			}
			ENDCG
		}
	}
}
