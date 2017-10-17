Shader "NoxWings/Dissolve" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_BumpMap ("Normal map", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		
		_NoiseTex ("Noise", 2D) = "white" {}
		_Dissolved ("Dissolved", Range(0,1)) = 0.0
		_DissolvedTint ("Dissolved Edge Color", Color) = (1,0,0,1)
		_DissolvedEmission ("Dissolved Edge Emission", Range(0, 1)) = 1.0
		_DissolvedSmooth ("Dissolve Edge Smooth", Range(0, 1)) = 0.15

		[Enum(Off,0,Back,2)] _Culling ("Culling", Int) = 0
	}
	SubShader {
	
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull [_Culling]
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _NoiseTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_NoiseTex;
			float3 viewDir;
		};

		fixed4 _Color;
		half _Metallic;
		half _Glossiness;
		
		fixed4 _DissolvedTint;
		half _Dissolved;
		half _DissolvedEmission;
		half _DissolvedSmooth;
		

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Compute texture disolved
			half noise = 1-tex2D (_NoiseTex, IN.uv_NoiseTex).r;
			half dissolve = noise - _Dissolved * 1.01;
			
			// Clip disolved
			clip (dissolve); 
			
			// Compute main color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			
			// Compute the ammount of disolved border
			// Note: The saturated dissolved part allows for a smooth border appearance
			half dissolvedBorder = _DissolvedSmooth * saturate(_Dissolved * 10);
			
			// Disolve border
			if (dissolve < dissolvedBorder) {
				// **************************
				// COMPUTE DISOLVING BORDER
				// **************************
				
				// Color and borderColor contribution
				half cp = saturate(dissolve / dissolvedBorder); // color percentage
				half bp = 1-cp; // border percentage
				
				// Compute color
				c =  (c * cp) + (_DissolvedTint * bp);
				
				// Compute emission
				if (_DissolvedEmission) {
					o.Emission = saturate(_DissolvedTint.rgb * _DissolvedEmission * pow(bp, 3));
				}
			}
			
			// Flip the normals if the pixel is backfacing (inner object pixel)
			// This is required for metallic and smooth back surfaces to render correct lighting
			float3 n = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			o.Normal = dot(IN.viewDir, float3(0, 0, 1)) > 0 ? n : -n;
			
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1.0;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
