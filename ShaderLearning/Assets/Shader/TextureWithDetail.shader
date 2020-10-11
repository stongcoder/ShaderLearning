Shader "MyShader/TetureWithDetail"
{
    Properties
    {
        _Tint("Tint",Color)=(0,1,0,1)
        _MainTex("MainTex",2D)="white"{}
        _DetailTex("DetailTex",2D)="white"{}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            
            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            struct VertexData
            {
                float4 localPosition:POSITION ;
                float2 uv:TEXCOORD0;
            };
            struct Interpolator
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float2 uv1:TEXCOORD1;   
                float2 uv2:TEXCOORD2;                

            };
           
            Interpolator vert(VertexData v)
            {
                Interpolator i;
                // return float4(0,0,0,0);
               
                i.pos=UnityObjectToClipPos(v.localPosition);
                // i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
                i.uv=TRANSFORM_TEX(v.uv,_MainTex);
                i.uv1=TRANSFORM_TEX(v.uv,_DetailTex);
                i.uv2=TRANSFORM_TEX(v.uv,_DetailTex);

                return i;
            }

            float4 frag(Interpolator i):SV_TARGET
            {
                float4 color=tex2D(_MainTex,i.uv)*_Tint;
                return color*tex2D(_DetailTex,i.uv1)*2;
            }

            ENDCG
        }
    }
}