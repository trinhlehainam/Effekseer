#version 200 es

struct VS_Input
{
    vec3 Pos;
    vec4 Color;
    vec4 Normal;
    vec4 Tangent;
    vec2 UV1;
    vec2 UV2;
};

struct VS_Output
{
    vec4 PosVS;
    vec4 Color;
    vec2 UV;
    vec4 PosP;
    vec4 PosU;
    vec4 PosR;
};

struct VS_ConstantBuffer
{
    mat4 mCamera;
    mat4 mProj;
    vec4 mUVInversed;
    vec4 mflipbookParameter;
};

uniform VS_ConstantBuffer CBVS0;

attribute vec3 Input_Pos;
attribute vec4 Input_Color;
attribute vec4 Input_Normal;
attribute vec4 Input_Tangent;
attribute vec2 Input_UV1;
attribute vec2 Input_UV2;
centroid varying vec4 _VSPS_Color;
centroid varying vec2 _VSPS_UV;
varying vec4 _VSPS_PosP;
varying vec4 _VSPS_PosU;
varying vec4 _VSPS_PosR;

VS_Output _main(VS_Input Input)
{
    VS_Output Output = VS_Output(vec4(0.0), vec4(0.0), vec2(0.0), vec4(0.0), vec4(0.0), vec4(0.0));
    vec4 pos4 = vec4(Input.Pos.x, Input.Pos.y, Input.Pos.z, 1.0);
    vec3 worldNormal = (Input.Normal.xyz - vec3(0.5)) * 2.0;
    vec3 worldTangent = (Input.Tangent.xyz - vec3(0.5)) * 2.0;
    vec3 worldBinormal = cross(worldNormal, worldTangent);
    vec4 localBinormal = vec4(Input.Pos.x + worldBinormal.x, Input.Pos.y + worldBinormal.y, Input.Pos.z + worldBinormal.z, 1.0);
    vec4 localTangent = vec4(Input.Pos.x + worldTangent.x, Input.Pos.y + worldTangent.y, Input.Pos.z + worldTangent.z, 1.0);
    localBinormal = CBVS0.mCamera * localBinormal;
    localTangent = CBVS0.mCamera * localTangent;
    vec4 cameraPos = CBVS0.mCamera * pos4;
    cameraPos /= vec4(cameraPos.w);
    localBinormal /= vec4(localBinormal.w);
    localTangent /= vec4(localTangent.w);
    localBinormal = cameraPos + normalize(localBinormal - cameraPos);
    localTangent = cameraPos + normalize(localTangent - cameraPos);
    Output.PosVS = CBVS0.mProj * cameraPos;
    Output.PosP = Output.PosVS;
    Output.PosU = CBVS0.mProj * localBinormal;
    Output.PosR = CBVS0.mProj * localTangent;
    Output.PosU /= vec4(Output.PosU.w);
    Output.PosR /= vec4(Output.PosR.w);
    Output.PosP /= vec4(Output.PosP.w);
    Output.Color = Input.Color;
    Output.UV = Input.UV1;
    Output.UV.y = CBVS0.mUVInversed.x + (CBVS0.mUVInversed.y * Input.UV1.y);
    return Output;
}

void main()
{
    VS_Input Input;
    Input.Pos = Input_Pos;
    Input.Color = Input_Color;
    Input.Normal = Input_Normal;
    Input.Tangent = Input_Tangent;
    Input.UV1 = Input_UV1;
    Input.UV2 = Input_UV2;
    VS_Output flattenTemp = _main(Input);
    gl_Position = flattenTemp.PosVS;
    _VSPS_Color = flattenTemp.Color;
    _VSPS_UV = flattenTemp.UV;
    _VSPS_PosP = flattenTemp.PosP;
    _VSPS_PosU = flattenTemp.PosU;
    _VSPS_PosR = flattenTemp.PosR;
}

