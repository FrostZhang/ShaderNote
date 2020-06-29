// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Surf/Ice" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap("Normalmap", 2D) = "bump" {}
	_Ice("Ice", 2D) = "white" {}
	_Y("_Y", Range(-1.5,1)) = 0.5
}

SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300

CGPROGRAM
#pragma surface surf Lambert

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _Ice;
float _Y;
fixed4 _Color;

struct Input {
    float2 uv_MainTex;
    float2 uv_BumpMap;
	float high;
};

void vert(inout appdata_base v,inout Input o)
{
	o.high = step(v.vertex.y, _Y);
}

void surf (Input IN, inout SurfaceOutput o) {
	float4 col = tex2D(_MainTex, IN.uv_MainTex)*(1 - IN.high);
	float4 col2 = tex2D(_Ice, IN.uv_MainTex)* IN.high;
	col = (col + col2)* _Color;
	o.Albedo = col.rgb;
    o.Alpha = col.a;
    o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG
}

FallBack "Legacy Shaders/Diffuse"
}
