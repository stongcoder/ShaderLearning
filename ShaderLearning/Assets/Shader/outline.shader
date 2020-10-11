// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Outline Shader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" { }
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline width", Range (0.0, 1.0)) = .005
        _DotFactor("DotFactor",float)=0
        _SourcePos("Source Position", vector) = (0, 0, 0, 0)
    }
      
    SubShader
    {
        Pass
        {
            Cull front
              
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
              
            #include "UnityCG.cginc"
              
            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
              
            struct v2f
            {
                float4 pos : POSITION;
                float skip:TEXCOORD0;
            };
              
            uniform float _OutlineWidth;
            uniform float4 _OutlineColor;
            float _DotFactor;
            float4 _SourcePos;
            v2f vert(appdata v)
            {
                v2f o;                 
               
                v.vertex.xyz +=normalize( v.normal) * _OutlineWidth;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.skip=sin(_DotFactor*distance(_SourcePos,v.vertex));
                return o;
            }
              
            half4 frag(v2f i) : COLOR
            {
                
                clip(i.skip);
                return _OutlineColor;
            }
            ENDCG
        }
          
        Pass
        {
            
        }
    }
}