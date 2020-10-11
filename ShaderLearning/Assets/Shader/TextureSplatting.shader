Shader "MyShader/TextureSplatting"
{
    Properties
    {
        
        _MainTex("MainTex",2D)="white"{}
        [NoScaleOffset] _Texture1("Texture1",2D)="white"{}
        [NoScaleOffset]_Texture2("Texture2",2D)="white"{}
        [NoScaleOffset]_Texture3("Texture3",2D)="white"{}
        [NoScaleOffset]_Texture4("Texture4",2D)="white"{}


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
            sampler _Texture1;
            sampler _Texture2;
            sampler _Texture3; 
            sampler _Texture4;
            struct VertexData
            {
                float4 localPosition:POSITION;
                float2 uv:TEXCOORD0;
            };
            struct Interpolator
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float2 uvSplat:texcoord1;
            };
           
            Interpolator vert(VertexData v)
            {
                Interpolator i;
                // return float4(0,0,0,0);
               
                i.pos=UnityObjectToClipPos(v.localPosition);
                // i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
                i.uv=TRANSFORM_TEX(v.uv,_MainTex);
                i.uvSplat=v.uv;
                return i;
            }

            float4 frag(Interpolator i):SV_TARGET
            {
                float4 splat=tex2D(_MainTex,i.uvSplat);
                return tex2D(_Texture1,i.uv)*splat.r+tex2D(_Texture2,i.uv)*(splat.g)+tex2D(_Texture3,i.uv)*(splat.b)+tex2D(_Texture4,i.uv)*(1-splat.r-splat.g-splat.b);
            }

            ENDCG
        }
    }
}