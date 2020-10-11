Shader "MyShader/lightShader"
{
    Properties
    {
        _Tint("Tint",Color)=(0,1,0,1)
        _MainTex("MainTex",2D)="white"{}
		_Metallic("Metallic",Range(0,1))=0
		_Smoothness("Smoothness",Range(0,1))=0.5
    }
    SubShader
    {
        Pass
        {
			Tags{
				"LightMode"="ForwardBase"
			}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityStandardBRDF.cginc"	
            
            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Metallic;
			float _Smoothness;
            struct VertexData
            {
                float4 localPosition:POSITION;
                float2 uv:TEXCOORD0;
				float3 normal:NORMAL;
            };
            struct Interpolator
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 normal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
            };
           
            Interpolator vert(VertexData v)
            {
                Interpolator i;
                // return float4(0,0,0,0);               
                i.pos=UnityObjectToClipPos(v.localPosition);
                // i.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
                i.uv=TRANSFORM_TEX(v.uv,_MainTex);
				i.normal=UnityObjectToWorldNormal(v.normal);
				i.worldPos=mul(unity_ObjectToWorld,v.localPosition);
                return i;
            }

            float4 frag(Interpolator i):SV_TARGET
            {
				float3 lightDir=_WorldSpaceLightPos0.xyz;
				float3 viewDir=normalize(_WorldSpaceCameraPos-i.worldPos);
				// float3 lightColor=_LightColor0.rgb;
				// float3 albedo=tex2D(_MainTex,i.uv).rgb*_Tint.rgb;
				// float3 diffuse=albedo*lightColor*DotClamped(lightDir,normalize(i.normal));
				//float4 color=float4(diffuse,1);
				float3 reflectionDir=reflect(-lightDir,i.normal);
				float3 color=pow(DotClamped(viewDir,reflectionDir),_Smoothness*100);
				// float3 color=DotClamped(viewDir,reflectionDir);
                return float4(color,1);
            }

            ENDCG
        }
    }
}