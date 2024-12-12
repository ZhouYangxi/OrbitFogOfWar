Shader "CustomRenderTexture/FogHallowPivot"
{
    Properties
    {
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

            float4 frag(v2f_customrendertexture IN) : SV_Target
            {
                float2 uv = IN.localTexcoord.xy;
                float4 color = tex2D(_SelfTexture2D, IN.globalTexcoord.xy);

                // 以LocalPivot为中心
                // Alpha逐渐降低。
                float2 center = float2(0.5, 0.5);
                float distance = length(center - uv) * 2;
                distance = saturate(distance);

                float r = max(1.0 - distance, color.r);
                color.r = r;
                return color;
            }
            ENDCG
        }
    }
}
