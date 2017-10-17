Shader "NoxWings/Outline/Standard scaled" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline Width", Range (0.0, 0.1)) = .005
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
		LOD 200
		
		// Prepass to create an object outline with the given color
		Pass {
			Name "OUTLINE_SCALED"
			Tags { "LightMode" = "Always" }
			Cull Off
			ZWrite Off		
			//ZTest Always	// Uncomment this to let outline pass through objects
			ColorMask RGB	// alpha not used
			
			CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
 
                struct v2f {
                    float4 pos    : POSITION;
                };
 
 				half _Outline;
                v2f vert (appdata_full v)
                {
	                v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				 
					float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
					float2 offset = TransformViewToProjection(norm.xy);

					float viewDistance = length(ObjSpaceViewDir(v.vertex));
					o.pos.xy += offset * o.pos.z * _Outline / viewDistance;
					return o;
                }
                
 				fixed4 _OutlineColor;
                half4 frag( v2f i ) : COLOR
                {
                	return _OutlineColor;
                }
            ENDCG          
		}
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
