﻿Shader "Hidden/Fire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
		Cull Off Lighting Off ZWrite On
		Blend  SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


			float noise(float3 p) //Thx to Las^Mercury
			{
				float3 i = floor(p);
				float4 a = dot(i, float3(1., 57., 21.)) + float4(0., 57., 21., 78.);
				float3 f = cos((p - i)*acos(-1.))*(-.5) + .5;
				a = lerp(sin(cos(a)*a), sin(cos(1. + a)*(1. + a)), f.x);
				a.xy = lerp(a.xz, a.yw, f.y);
				return lerp(a.x, a.y, f.z);
			}

			float sphere(float3 p, float4 spr)
			{
				return length(spr.xyz - p) - spr.w;
			}

			float flame(float3 p)
			{
				float d = sphere(p*float3(1., .5, 1.), float4(.0, -1., .0, 1.));
				return d + (noise(p + float3(.0, _Time.y *2., .0)) + noise(p*3.)*.5)*.25*(p.y);
			}

			float scene(float3 p)
			{
				return min(100. - length(p), abs(flame(p)));
			}

			float4 raymarch(float3 org, float3 dir)
			{
				float d = 0.0, glow = 0.0, eps = 0.02;
				float3  p = org;
				bool glowed = false;

				for (int i = 0; i < 64; i++)
				{
					d = scene(p) + eps;
					p += d * dir;
					if (d > eps)
					{
						if (flame(p) < .0)
							glowed = true;
						if (glowed)
							glow = float(i) / 64.;
					}
				}
				return float4(p, glow);
			}

			void mainImage(out float4 fragColor, in float2 fragCoord)
			{
				float2 v = -1.5 + 3 * fragCoord.xy/* / iResolution.xy*/;
				//v.x *= iResolution.x / iResolution.y;

				float3 org = float3(0., -2., 3.8);
				float3 dir = normalize(float3(v.x*1.6, -v.y, -1.5));

				float4 p = raymarch(org, dir);
				float glow = p.w;

				float4 col = lerp(float4(1., .5, .1, 1.), float4(0.1, .5, 1., 1.), p.y*.02 + .4);

				fragColor = lerp(float4(.0,.0,.0,.0), col, pow(glow*2., 4.));
				//fragColor = lerp(float4(1.), lerp(float4(1.,.5,.1,1.),float4(0.1,.5,1.,1.),p.y*.02+.4), pow(glow*2.,4.));

			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;
				mainImage(col, i.uv);
                return col;
            }
            ENDCG
        }
    }
}