Shader "CustomRenderTexture/FogHallowPivot"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
     }

     SubShader
     {
        Blend One Zero

        Pass
        {
            Name "FogHallowPivot"

            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

            float4      _Color;
            sampler2D   _MainTex;

            float4 frag(v2f_customrendertexture IN) : SV_Target
            {
                float2 uv = IN.localTexcoord.xy;
                float4 color = tex2D(_MainTex, uv) * _Color;

                // 以LocalPivot为中心
                // Alpha逐渐降低。
                float2 center = float2(0.5, 0.5);
                float distance = length(center - uv) * 2;
                distance = 1.0 - saturate(distance);

                return lerp(float4(0, 0, 0, 0), color, distance);
            }
            ENDCG
        }
    }
}
