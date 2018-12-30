Shader "neo/screenSpriteGrow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "True" }
		LOD 100
		Cull Off
		Lighting Off
		ZWrite Off

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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			float4 _Color;
			float _Strength;
			float _Width;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{


				float2 scaledTexelSize = _MainTex_TexelSize.xy * _Width;

				float2 offsetUV = float2(0, 1) * scaledTexelSize;
				float colA = tex2D(_MainTex, i.uv + offsetUV).a * 1;
				offsetUV = float2(-1, 0) * scaledTexelSize;
				colA += tex2D(_MainTex, i.uv + offsetUV).a * 1;
				offsetUV = float2(0, 0) * scaledTexelSize;
				colA += tex2D(_MainTex, i.uv + offsetUV).a * 4;
				offsetUV = float2(1, 0) * scaledTexelSize;
				colA += tex2D(_MainTex, i.uv + offsetUV).a * 1;
				offsetUV = float2(0, -1) * scaledTexelSize;
				colA += tex2D(_MainTex, i.uv + offsetUV).a * 1;

				colA *= 0.125 * _Strength;
				colA = min(colA, 1);

				return fixed4(_Color.xyz, colA);
			}
			ENDCG
		}


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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			sampler2D _BloomTex;
			float4 _BloomTex_ST;

			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 originC = tex2D(_MainTex, i.uv);
				float4 bloomC = tex2D(_BloomTex, i.uv);
				float4 maskC = tex2D(_MaskTex, i.uv);

				int isOriginC = step(0.5, maskC.a);
				float4 mixColor = bloomC.a * bloomC + (1 - bloomC.a) * originC;
				mixColor = lerp(mixColor, originC, isOriginC);

				return mixColor;
			}
			ENDCG
		}
	}
}
