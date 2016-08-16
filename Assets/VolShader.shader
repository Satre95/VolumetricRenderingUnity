Shader "Unlit/VolShader"
{
	Properties
	{
		_VolTex ("_VolTex", 3D) = "" {}
		_VolDimensions( "The width, height, and depth of the cube", Vector) = (0,0,0)
		_VolDimensionsPOT( "Width, height, and depth of cube where size is power of two", Vector) = (0,0,0)
		_ZTexOffset( "ZTexOffset", Float) = 0
		_Quality( "Quality", Float) = 1.0
		_Density( "Voxel Density", Float) = 0.75
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
				float3 uvw : TEXCOORD0;
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
				o.uvw = v.vertex.xyz * 0.5f + 0.5f;
				UNITY_TRANSFER_FOG(o,o.vertex);
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

				//TODO: Add raymarching vol sampling here.
				float3 minVolume = 1.0f/_VolDimensionsPOT;
				float3 maxVolume = 1.0f - minVolume;
				float3 volDimension = (maxVolume - minVolume) * _VolDimensions;
				float volLength = length(volDimension);

				float4 finalColor = float4(0,0,0,0);
				float3 zOffsetVector = float3(0,0,0);
				float3 backPos = i.vertex.xyz * 0.5f + 0.5f;
				float3 lookVec = normalize(backPos - _WorldSpaceCameraPos);

				Ray eye;
				eye.Origin = _WorldSpaceCameraPos;
				eye.Direction = lookVec;


				BoundingBox box;
				box.Min = float3(0,0,0);
				box.Max = float3(1,1,1);

				float tnear, tfar;
				IntersectBox(eye, box, tnear, tfar);
				if(tnear < 0.15f){
					tnear = 0.15f;
				}
				if(tnear > tfar){
					discard;
				}

				float3 rayStart = (eye.Origin + eye.Direction * tnear) * (maxVolume - minVolume) + minVolume;
				float3 rayStop = (eye.Origin + eye.Direction * tfar) * (maxVolume - minVolume) + minVolume;

				float3 dir = rayStop - rayStart;
				float3 vec = rayStart;

				float dirLength = length(dir);
				if(dirLength == clamp(dirLength, 0, volLength)){
					int steps = int(floor(length(volDimension * dir) * _Quality));
					float3 deltaDir = dir/float(steps);
					float4 colorSample;
					float alphaScale = _Density/_Quality;

					float random = frac(sin( i.uvw.x * 12.9898 + i.uvw.y * 78.233) * 43758.5453);
					vec += deltaDir * random;

					//RayCast!!
					[unroll(2000)] for( int i = 0; i < steps; i++) {
						float3 vecZ = vec + zOffsetVector;

						if(vecZ.z > maxVolume.z) {
							vecZ.z -= maxVolume.z;
						}

						colorSample = tex3D(_VolTex, vecZ);

						float oneMinusAlpha = 1.0f - finalColor.a;
						colorSample.a *= alphaScale;

						finalColor.rgb = lerp(finalColor.rgb, colorSample.rgb * colorSample.a, oneMinusAlpha);
						finalColor.a += finalColor.a * oneMinusAlpha;
						finalColor.rgb /= finalColor.a;

						if( finalColor.a >= 1.0f) {
							break;
						}

						vec += deltaDir;
					}
				}

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				return finalColor;
			}
			ENDCG
		}
	}
}
