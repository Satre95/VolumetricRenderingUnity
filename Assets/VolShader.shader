﻿Shader "Unlit/VolShader"
{
	Properties
	{
		_VolTex ("_VolTex", 3D) = "" {}
		_VolDimensions( "The width, height, and depth of the cube", Vector) = (0,0,0)
		_VolDimensionsPOT( "Width, height, and depth of cube where size is power of two", Vector) = (0,0,0)
		_ZTexOffset( "Don't know what this is for", Float) = 0
		_Quality( "Don't know what this is for", Float) = 0
		_Density( "Density of voxels", Float) = 0.75
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler3D _VolTex;
			float4 _VolTex_ST; 

			//Custom uniforms for volumetric rendering.
			float3 _VolDimensions;
			float3 _VolDimensionsPOT;
			float _ZTexOffset;
			float _Quality;
			float _Density;

			//----------------------------------------
			//VERTEX SHADER
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.vertex.xyz * 0.5f + 0.5f;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


			//----------------------------------------
			//FRAGMENT SHADER
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex3D(_VolTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
