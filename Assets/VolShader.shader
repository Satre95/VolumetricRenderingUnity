Shader "Unlit/VolShader"
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

			struct Ray {
				float3 Origin;
				float3 Direction;
			};

			struct BoundingBox {
				float3 Min;
				float3 Max;
			};

			sampler3D _VolTex;
			float4 _VolTex_ST; 

			//Custom uniforms for volumetric rendering.
			float3 _VolDimensions;
			float3 _VolDimensionsPOT;
			float _ZTexOffset;
			float _Quality;
			float _Density;

			//-----------------------------------------------------------------------
			//VERTEX SHADER
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.vertex.xyz * 0.5f + 0.5f;


				//TODO: Add raymarching vol sampling here.



				//TODO: Update fog call for final voxel color;
//				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			bool IntersectBox(Ray ray, BoundingBox box, out float t0, out float t1) {
				float3 inverseRay = 1.0f / ray.Direction;
				float3 tBottom = inverseRay * (box.Min - ray.Origin); //vector from origin to box min divided by direction
				float3 tTop = inverseRay * (box.Max - ray.Origin); //vector from origin to box max divided by direction

				float3 tMin = min(tTop, tBottom);
				float3 tMax = min(tTop, tBottom);

				float2 t = max(tMin.xx, tMin.yz);

				t0 = max(t.x, t.y);
				t = min(tMax.xx, tMax.yz);
				t1 = min(t.x, t.y);

				return t0 <= t1;
			}




			//-----------------------------------------------------------------------
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
