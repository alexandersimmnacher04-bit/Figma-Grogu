// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Phong Shader Ultimativ"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1) //Die Farbe des Objekts
        _Tex ("Pattern", 2D) = "white" {} //Optionale texture

        _Shininess ("Shininess", Float) = 10 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200 //Level of Detail

        Pass
        {
            Tags { "LightMode" = "ForwardBase" } //Fürs erste Licht

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc" //Gibt uns Licht daten, Kamera informationen etc.

            uniform float4 _LightColor0; //Von UnityCG

            sampler2D _Tex; //Wird genutzt für Texturen
            float4 _Tex_ST; //Für Tiling

            uniform float4 _Color; //Benutzte die Variablen von oben hier
            uniform float4 _SpecColor;
            uniform float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Berechnet die Welt position für unseren Punkt
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Brechnet den Normalen
                o.pos = UnityObjectToClipPos(v.vertex); //Und die Position
                o.uv = TRANSFORM_TEX(v.uv, _Tex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalDirection = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                float oneOverDistance = 1.0 /length(vert2LightSource);
                float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); //Optimierung für Spot lights
                float3 lightDirection = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;

                float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb; //Abient component
                float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse Teil
                float3 specularReflection;
                if (dot(i.normal, lightDirection) < 0.0) //Licht auf der falschen Seite - nicht Specular
                {
                    specularReflection = float3(0.0, 0.0, 0.0);
                }
                else
                {
                    //Specular Teil
                    specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
                }

                float3 color = (ambientLighting + diffuseReflection) * tex2D(_Tex, i.uv) + specularReflection; //Textur ist nicht auf der Specular Reflexion
                return float4(color, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd"} //Für zusätzliche Lichter
            Blend One One //Zusätzliches Blenden

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc" //Gibt uns Licht daten, Kamera informationen etc.

            uniform float4 _LightColor0; //Von UnityCG

            sampler2D _Tex; //Benutzt für Texturen
            float4 _Tex_ST; //Für Tiling

            uniform float4 _Color; //Benutzte die Variablen von oben hier
            uniform float4 _SpecColor;
            uniform float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Berechnet die Welt position für unseren Punkt
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Berechnet den Normalen
                o.pos = UnityObjectToClipPos(v.vertex); //Und die Position
                o.uv = TRANSFORM_TEX(v.uv, _Tex);

                return o;
            }

            fixed4 frag (v2f i) : Color
            {
                float3 normalDirection = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                float oneOverDistance = 1.0 /length(vert2LightSource);
                float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); //Optimierung für Spot lights
                float3 lightDirection = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;

                float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb; //Abient component
                float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse Teil
                float3 specularReflection;
                if (dot(i.normal, lightDirection) < 0.0) //Licht auf der falschen Seite - nicht Specular
                {
                    specularReflection = float3(0.0, 0.0, 0.0);
                }
                else
                {
                    //Specular Teil
                    specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
                }

                float3 color = (diffuseReflection) * tex2D(_Tex, i.uv) + specularReflection; //Kein Abient hier
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
