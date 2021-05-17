// This shader draws a texture on the mesh.
Shader "Yuzeki/ICE"
{
    // The _BaseMap variable is visible in the Material's Inspector, as a field
    // called Base Map.
    Properties
    {
        _BaseMap("Base Map", 2D) = "white"
        _ParallaxMap("Parallax Map", 2D) = "black" {}
        _ParallaxScale("Parallax Scale", float) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "ParallaxMapping.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 uv           : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 viewDirectionTS : TEXCOORD3;
            };

            // This macro declares _BaseMap as a Texture2D object.
            TEXTURE2D(_BaseMap);
            // This macro declares the sampler for the _BaseMap texture.
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_ParallaxMap);        
            SAMPLER(sampler_ParallaxMap);

            CBUFFER_START(UnityPerMaterial)
                // The following line declares the _BaseMap_ST variable, so that you
                // can use the _BaseMap variable in the fragment shader. The _ST
                // suffix is necessary for the tiling and offset function to work.
                float4 _BaseMap_ST;
                float _ParallaxScale;
            CBUFFER_END

            bool IsPerspectiveProjection()
            {
                return (unity_OrthoParams.w == 0);
            }

            float3 GetViewForwardDir()
            {
                float4x4 viewMat = GetWorldToViewMatrix();
                return -viewMat[2].xyz;
            }

            float3 GetWorldSpaceViewDir(float3 positionWS)
            {
                if (IsPerspectiveProjection())
                {
                    // Perspective
                    return _WorldSpaceCameraPos - positionWS;
                }
                else
                {
                    // Orthographic
                    return -GetViewForwardDir();
                }
            }

            Varyings vert(Attributes input)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                // The TRANSFORM_TEX macro performs the tiling and offset
                // transformation.
                OUT.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                OUT.normalWS = TransformObjectToWorldNormal(input.normalOS);
                OUT.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                float3 viewDirectionWS = GetWorldSpaceViewDir(positionWS);
                OUT.viewDirectionTS = GetViewDirectionTangentSpace(OUT.tangentWS, OUT.normalWS, viewDirectionWS);
                return OUT;
            }

            half4 frag(Varyings input) : SV_Target
            {                
                //float dotValue = lerp(1, 0, abs(dot(float3(0.0, 0.0, 1.0), normalize(input.viewDirectionTS)))); 
                //return float4(dotValue, 0, 0, 1);
                float3 viewDirTS = input.viewDirectionTS;
                float2 texCoord = ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _ParallaxScale, input.uv);
                //if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0.0)
                //    clip(-1);
                //return float4(texCoord.x, texCoord.y, 0, 1);
                //return float4(viewDirTS,1);
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, texCoord);
                return color;
            }
            ENDHLSL
        }
    }
}