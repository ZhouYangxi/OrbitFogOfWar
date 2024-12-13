Shader "OrbitGames/UI/Mask Blend" {
    
    Properties {
        _MaskTex ("MaskTexture", 2D) = "black" {}
        _MainTexTile ("Main Texture Tile", Float) = 1
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        
        // --- Mask support ---
        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
        [HideInInspector] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }
    
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent" 
        }
        
        // --- Mask support ---
        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }    
        Cull Off
        Lighting Off
        ZTest [unity_GUIZTestMode]
        ColorMask [_ColorMask]
        // ---
        
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZWrite Off

        Pass {
            CGPROGRAM
            
            #include "UnityCG.cginc"
            #include "UnityUI.cginc" 
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _MainTexTile;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;  // set from Image component property
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            int _UIVertexColorAlwaysGammaSpace;

            v2f vert (appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                if (_UIVertexColorAlwaysGammaSpace)
                    if(!IsGammaSpace())
                        o.color = float4(UIGammaToLinear(o.color.xyz), o.color.w);
                return o;
            }
                        
            fixed4 frag (v2f i) : SV_Target {
                half4 color = (tex2D(_MainTex, i.uv * _MainTexTile)) * i.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif

                half mask = (tex2D(_MaskTex, i.uv)).r;
                color.a *= (1.0 - mask);
                
                #ifdef UNITY_UI_ALPHACLIP
                clip(color.a - 0.001);
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                clip(alpha - 0.001);
                #endif

                return color;
            }
            
            ENDCG
        }
    }
}