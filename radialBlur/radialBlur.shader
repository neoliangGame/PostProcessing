//径向模糊
//添加径向模糊效果遮罩
//添加RGB径向差异化
Shader "neo/ratialBlur"
{
	//material中不显示，避免多处设置
	Properties
	{
		[HideInInspector]_MainTex("Texture", 2D) = "white" {}
		[HideInInspector]_Center("Center", Vector) = (0.5,0.5,0.5,0.5)	//只有前两个有用，后两个浪费了
		[HideInInspector]_MaskTex("Mask", 2D) = "black" {}
		[HideInInspector]_Strength("Strength",Range(0,5)) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
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

			float4 _Center;

			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float4 _MaskTex_TexelSize;

			float _Strength;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			//计算center与uv方向采样模糊颜色
			float4 ratialColor(float2 uv, float stren) {
				
				float2 uvDir = uv - _Center.xy;
				//计算uv与center的长度，相离越远，其分离度越大
				float uvLength = 1 + length(uvDir) * 3;
				uvDir = normalize(float3(uvDir.xy, 0)).xy;
				
				float2 strengSize = stren * _MainTex_TexelSize.xy * uvLength;
				//在径向上采样9层进行叠加
				//层数可以增减，看效果而定
				float2 offsetUV = uv - uvDir * _MainTex_TexelSize.xy;
				float4 blurCol = tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 2;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 3;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 4;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 5;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 6;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 7;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 8;
				blurCol += tex2D(_MainTex, offsetUV);
				offsetUV = uv - uvDir * strengSize * 9;
				blurCol += tex2D(_MainTex, offsetUV);

				blurCol /= 9;
				return blurCol;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				//进行三次不同强度的径向采样，分别赋值到RGB通道
				//达到RGB径向差异化效果
				fixed4 blurColR = ratialColor(i.uv, _Strength);
				fixed4 blurColG = ratialColor(i.uv, _Strength * 0.7);
				fixed4 blurColB = ratialColor(i.uv, _Strength * 1.5);
				//径向模糊遮罩，控制屏幕中哪些部分需要径向模糊
				fixed4 maskCol = tex2D(_MaskTex, i.uv);
				float blurRate = 9 * (1 - maskCol.a);
				blurRate = blurRate / (1 + blurRate);
				col = (1 - blurRate) * col + blurRate * float4(blurColR.r, blurColG.g, blurColB.b,1) ;
				return col;
			}
			ENDCG
		}
	}
}
