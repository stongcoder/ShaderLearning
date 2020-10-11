Shader "Custom/CelEffectsDottedOutline"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_OutlineExtrusion("Outline Extrusion", float) = 0
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineDot("Outline Dot", float) = 0.25
		_OutlineDot2("Outline Dot Distance", float) = 0.5
		_OutlineSpeed("Outline Dot Speed", float) = 50.0
		_SourcePos("Source Position", vector) = (0, 0, 0, 0)
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
			{ 
				"LightMode" = "ForwardBase" // allows shadow rec/cast
			}

			// Write to Stencil buffer (so that outline pass can read)
			Stencil
			{
				Ref 4
				Comp always
				Pass replace
				ZFail keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			// Properties
			sampler2D _MainTex;
			sampler2D _RampTex;
			float4 _Color;
			float4 _LightColor0; // provided by Unity

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
				LIGHTING_COORDS(1,2) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with 4x4 matrix
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				output.texCoord = input.texCoord;

                TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
		
				return 1;
			}

			ENDCG
		}


		// Outline pass
		Pass
		{
			// Won't draw where it sees ref value 4
			Cull OFF
			ZWrite OFF
			ZTest ON
			Stencil
			{
				Ref 4
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			// Properties
			float4 _OutlineColor;
			float  _OutlineSize;
			float  _OutlineExtrusion;
			float  _OutlineDot;
			float  _OutlineDot2;
			float  _OutlineSpeed;
			float4 _SourcePos;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 screenCoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4 newPos = input.vertex;

				// normal extrusion technique
				float3 normal = normalize(input.normal);
				newPos += float4(normal, 0.0) * _OutlineExtrusion;

				// convert to world space
				output.pos = UnityObjectToClipPos(newPos);

				// get screen coordinates
				output.screenCoord = ComputeScreenPos(output.pos);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// dotted line with animation
				// if you want to remove the animation, remove "+ _Time * _OutlineSpeed"
				float2 pos = input.pos.xy + _Time * _OutlineSpeed;
                float skip = sin(_OutlineDot*abs(distance(_SourcePos.xy, pos))) + _OutlineDot2;
				clip(skip); // stops rendering a pixel if 'skip' is negative

                float4 color = _OutlineColor;
				return color;
			}

			ENDCG
		}
	}
}