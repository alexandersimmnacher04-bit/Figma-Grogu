Shader "Phong Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            float3 GetViewDir(float3 worldPos)
            {
                return normalize (worldPos- _WorldSpaceCameraPos);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 normal : NORMAL;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex.xyz);
                o.normal = normalize (mul (unity_ObjectToWorld, v.normal.xyz));
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 viewDir = GetViewDir(i.worldPos);
                float3 lightDirection = _WorldSpaceLightPos0.xyz;
                float3 normal = i.normal;

                //Diffuse light
                float diffuseLight = dot (normal, lightDirection);
                diffuseLight = max(0, diffuseLight);

                //Specular light
                float3 reflectedLightDir = reflect (normal, lightDirection);
                float specularLight = dot (reflectedLightDir, -viewDir);
                specularLight = max(0, specularLight);
                specularLight = pow(specularLight, 20);

                //Final light
                float finalLighting = diffuseLight + specularLight;


                return float4(finalLighting,finalLighting,finalLighting,1);
            }
            ENDCG
        }
    }
}
