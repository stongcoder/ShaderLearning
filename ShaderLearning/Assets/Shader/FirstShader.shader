Shader "MyShader/FirstShader"
{
    Properties
    {
        _Tint("Tint",Color)=(0,1,0,1)
        _MainTex("MainTex",2D)="white"{}
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
            struct VertexData
            {
                float4 localPosition:POSITION;
                float2 uv:TEXCOORD0;
            };
            struct Interpolator
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                
            };
           
            Interpolator vert(VertexData v)
            {
                Interpolator i;
                // return float4(0,0,0,0);
               
                i.pos=UnityObjectToClipPos(v.localPosition);
                // i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
                i.uv=TRANSFORM_TEX(v.uv,_MainTex);
                return i;
            }

            float4 frag(Interpolator i):SV_TARGET
            {
                return tex2D(_MainTex,i.uv)*_Tint;
            }

            ENDCG
        }
    }
}