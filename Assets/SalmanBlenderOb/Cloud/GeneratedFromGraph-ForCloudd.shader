Shader "Shader Graphs/ForCloud"
{
    Properties
    {
        _Rotate("Rotate", Vector, 4) = (1, 0, 0, 0)
        _Noise_Scale("Noise Scale", Float) = 0
        _Cloud_speed("Cloud speed", Float) = 10
        _HightOfTheCoud("HightOfTheCoud", Float) = 30
        _test("test", Vector, 4) = (0, 1, -1, 1)
        _ColorOfTheLevel1("ColorOfTheLevel1", Color) = (0, 0, 0, 1)
        _ColorOfTheLevel2("ColorOfTheLevel2", Color) = (0, 0, 0, 1)
        _Noise_Edge1("Noise Edge1", Float) = 0
        _Noise_Edge2("Noise Edge2", Float) = 0
        _Cloud_strong("Cloud strong", Float) = 0
        _Base_scale("Base scale", Float) = 0
        _Base_Time_Speed("Base Time Speed", Float) = 0.2
        _Base_strength("Base strength", Float) = 0
        _fresnel_Power("fresnel Power", Float) = 1
        _Opacity("Opacity", Float) = 0
        _Fade_depth("Fade depth", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4 = _ColorOfTheLevel1;
            float4 _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4 = _ColorOfTheLevel2;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float4 _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4;
            Unity_Lerp_float4(_Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4, _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxxx), _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4);
            float _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float = _fresnel_Power;
            float _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float);
            float _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float;
            Unity_Multiply_float_float(_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float, _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float);
            float _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float = _Opacity;
            float _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float, _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float, _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float);
            float4 _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4;
            Unity_Add_float4(_Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4, (_Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float.xxxx), _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4);
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.BaseColor = (_Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP1;
            #endif
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4 = _ColorOfTheLevel1;
            float4 _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4 = _ColorOfTheLevel2;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float4 _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4;
            Unity_Lerp_float4(_Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4, _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxxx), _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4);
            float _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float = _fresnel_Power;
            float _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float);
            float _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float;
            Unity_Multiply_float_float(_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float, _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float);
            float _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float = _Opacity;
            float _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float, _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float, _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float);
            float4 _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4;
            Unity_Add_float4(_Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4, (_Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float.xxxx), _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4);
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.BaseColor = (_Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_speed;
        float _HightOfTheCoud;
        float4 _test;
        float4 _ColorOfTheLevel2;
        float4 _ColorOfTheLevel1;
        float _Noise_Edge2;
        float _Noise_Edge1;
        float _Cloud_strong;
        float _Base_scale;
        float _Base_Time_Speed;
        float _Base_strength;
        float _fresnel_Power;
        float _Opacity;
        float _Fade_depth;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
            float s, c;
            sincos(Rotation, s, c);
            Axis = normalize(Axis);
            Out = In * c + cross(Axis, In) * s + Axis * dot(Axis, In) * (1 - c);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), ViewDir))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float3 _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxx), _Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3);
            float _Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float = _HightOfTheCoud;
            float3 _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d7359fde82824d71bda7141834f502c2_Out_2_Vector3, (_Property_a40bfa0cac814abab4c510a2e2ce29d2_Out_0_Float.xxx), _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3);
            float3 _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_5126e80fa7304a3c9165d94404a87034_Out_2_Vector3, _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3);
            description.Position = _Add_4cc8ee5bcc50446fa149a48104ad1e60_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4 = _ColorOfTheLevel1;
            float4 _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4 = _ColorOfTheLevel2;
            float _Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float = _Noise_Edge1;
            float _Property_51146804728342109ba2283c310b3603_Out_0_Float = _Noise_Edge2;
            float4 _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4 = _Rotate;
            float _Split_87da0d4590654ed592568803b2fbf681_R_1_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[0];
            float _Split_87da0d4590654ed592568803b2fbf681_G_2_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[1];
            float _Split_87da0d4590654ed592568803b2fbf681_B_3_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[2];
            float _Split_87da0d4590654ed592568803b2fbf681_A_4_Float = _Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4[3];
            float3 _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_34b4d394754b4c3a891f95cd3fe55c19_Out_0_Vector4.xyz), _Split_87da0d4590654ed592568803b2fbf681_A_4_Float, _RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3);
            float _Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float = _Cloud_speed;
            float _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float;
            Unity_Multiply_float_float(_Property_311fd8b42bd548e5bb6307a510622d9a_Out_0_Float, IN.TimeParameters.x, _Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float);
            float2 _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_f1b0e680bfb94d459995d823946082a1_Out_2_Float.xx), _TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2);
            float _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float = _Noise_Scale;
            float _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_38f454f4bcaa4323b8fca15bc72d0db6_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float);
            float2 _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2);
            float _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_7dcd27b6cf064aec929c593234ad04dd_Out_3_Vector2, _Property_e584592e155748cd9ee619fe48487bc9_Out_0_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float);
            float _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float;
            Unity_Add_float(_GradientNoise_b75aaf22b83c4440815d19b7b86fe070_Out_2_Float, _GradientNoise_c5abf6fe994b4b3ea5d6e22a1771bc43_Out_2_Float, _Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float);
            float _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float;
            Unity_Divide_float(_Add_9ec9102fc42a4087b9791f97c0a3ec1f_Out_2_Float, float(2), _Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float);
            float _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float = _Cloud_strong;
            float _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float;
            Unity_Power_float(_Divide_55da3c73162b45d282421c0d9124d235_Out_2_Float, _Property_bbdcc66697014f039d985e044697f9d0_Out_0_Float, _Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float);
            float _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float;
            Unity_Saturate_float(_Power_f1fa690431b8412082eb11d3765a9367_Out_2_Float, _Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float);
            float4 _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4 = _test;
            float _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[0];
            float _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[1];
            float _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[2];
            float _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float = _Property_05cccf805a52419486fb0da325f6cecf_Out_0_Vector4[3];
            float2 _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_R_1_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_G_2_Float.x );
            float2 _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2 = float2( _Split_05afd47e1af84cac832dc36057fa998a_B_3_Float.x, _Split_05afd47e1af84cac832dc36057fa998a_A_4_Float.x );
            float _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float;
            Unity_Remap_float(_Saturate_85008cdcd3c9448c91a9bc2c8384a9ee_Out_1_Float, _Append_47bad7c799c74f16a9392839089aa36b_Out_2_Vector2, _Append_fb13b5c6404542b785b39d144208d624_Out_2_Vector2, _Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float);
            float _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float;
            Unity_Absolute_float(_Remap_12334410de0a46c2ab8c54494186d3b0_Out_3_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float);
            float _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float;
            Unity_Smoothstep_float(_Property_3ffd6dd040024a4aa98f0f4f099e5e77_Out_0_Float, _Property_51146804728342109ba2283c310b3603_Out_0_Float, _Absolute_9df96f707ea64e7fa6710fb565ecae69_Out_1_Float, _Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float);
            float _Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float = _Base_Time_Speed;
            float _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float;
            Unity_Multiply_float_float(_Property_4a896917854f4bfeade8fb83b91d5e4b_Out_0_Float, IN.TimeParameters.x, _Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float);
            float2 _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2;
            Unity_TilingAndOffset_float((_RotateAboutAxis_e5bba965c58b403cbc01b84b8ba522ce_Out_3_Vector3.xy), float2 (1, 1), (_Multiply_6ca157e28e58448b98b4cc3fd6665f88_Out_2_Float.xx), _TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2);
            float _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float = _Base_scale;
            float _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_69efc1eb60cc4c1e8000db7c39e9a7d4_Out_3_Vector2, _Property_1de8308df9ca46a18e59f76769b8224c_Out_0_Float, _GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float);
            float _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float = _Base_strength;
            float _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_93d116cee5e64db4b9ec73b3b99feb08_Out_2_Float, _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float);
            float _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float;
            Unity_Add_float(_Smoothstep_acb4e8ada8064fab829e19968d221bd5_Out_3_Float, _Multiply_4cd92f3c41a440aab106223c065604b6_Out_2_Float, _Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float);
            float _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float;
            Unity_Add_float(float(1), _Property_5fd11130c9754348b4d69615f1d24e50_Out_0_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float);
            float _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float;
            Unity_Divide_float(_Add_99005f1f2aa94f5b88b9119ca377bc50_Out_2_Float, _Add_ffbfee879d0f46b283c5bb0b1eff712e_Out_2_Float, _Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float);
            float4 _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4;
            Unity_Lerp_float4(_Property_2d1458c631db44868f17812bc84cd08a_Out_0_Vector4, _Property_5941d55a0cf143ab9db0c9c063ed9efa_Out_0_Vector4, (_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float.xxxx), _Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4);
            float _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float = _fresnel_Power;
            float _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_e9183814035b4c68b866fd2266f9ee36_Out_0_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float);
            float _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float;
            Unity_Multiply_float_float(_Divide_1cb350a7b73d4c2fb72565de7cee150a_Out_2_Float, _FresnelEffect_33d82f43cced43cdbc630594f95306a7_Out_3_Float, _Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float);
            float _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float = _Opacity;
            float _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_657e7fb4ffe94d288452aa2d5f6d3e20_Out_2_Float, _Property_0d474d58c3104ac79c589dda31c68a06_Out_0_Float, _Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float);
            float4 _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4;
            Unity_Add_float4(_Lerp_34c441db479e4b79b28414b6c02d6a5e_Out_3_Vector4, (_Multiply_f6c551a73932449fa1be9382563c1163_Out_2_Float.xxxx), _Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4);
            float _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float);
            float4 _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_2d793b49a715442da1cd8b0180892a9f_R_1_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[0];
            float _Split_2d793b49a715442da1cd8b0180892a9f_G_2_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[1];
            float _Split_2d793b49a715442da1cd8b0180892a9f_B_3_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[2];
            float _Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float = _ScreenPosition_0d6f0badfecb4ce9804eb0856b1ddf62_Out_0_Vector4[3];
            float _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float;
            Unity_Subtract_float(_Split_2d793b49a715442da1cd8b0180892a9f_A_4_Float, float(1), _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float);
            float _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float;
            Unity_Subtract_float(_SceneDepth_203e046d05e5469c8c59ef9c4ddb03a3_Out_1_Float, _Subtract_1a748c4864b34224959d198db2b32dfd_Out_2_Float, _Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float);
            float _Property_358fbc350e8348d0805911667826590b_Out_0_Float = _Fade_depth;
            float _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float;
            Unity_Divide_float(_Subtract_1d85b5156adb43b9b1a705e9c59c3ef7_Out_2_Float, _Property_358fbc350e8348d0805911667826590b_Out_0_Float, _Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float);
            float _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            Unity_Saturate_float(_Divide_e5dc263606834d8c98035bd7844a9a1a_Out_2_Float, _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float);
            surface.BaseColor = (_Add_722350ee2af2406bb9620b799d6ef841_Out_2_Vector4.xyz);
            surface.Alpha = _Saturate_46d53702e3214098b99a36d68fa081e1_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}