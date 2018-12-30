using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class screenSpriteGrow : MonoBehaviour {

    [SerializeField]
    Material bloomMaterial;

    Camera bloomCamera;
    RenderTexture bloomMask;

    [SerializeField]
    [Range(0.1f, 10f)]
    float bloomStrength = 1f;
    [SerializeField]
    [Range(0f,10f)]
    float bloomWidth = 1f;
    [SerializeField]
    Color bloomColor = Color.white;
    [SerializeField]
    [Range(1, 10)]
    int bloomLoop = 1;

    private void Start()
    {
        Camera mainCamera = GetComponent<Camera>();
        GameObject go = new GameObject();
        go.name = "bloomCamera";
        bloomCamera = go.AddComponent<Camera>();
        bloomCamera.clearFlags = CameraClearFlags.Color;
        bloomCamera.allowHDR = true;
        bloomCamera.orthographic = true;
        bloomCamera.cullingMask = 1 << LayerMask.NameToLayer("bloom");
        bloomCamera.orthographicSize = mainCamera.orthographicSize;
        bloomCamera.farClipPlane = mainCamera.farClipPlane;
        bloomCamera.nearClipPlane = mainCamera.nearClipPlane;
        bloomCamera.depth = mainCamera.depth + 1;
        bloomCamera.backgroundColor = new Color(0f,0f,0f,0f);

        bloomCamera.transform.parent = transform;
        bloomCamera.transform.localPosition = Vector3.zero;
        bloomCamera.transform.localScale = Vector3.zero;
        bloomCamera.transform.localEulerAngles = Vector3.zero;

        bloomMask = new RenderTexture(Screen.width,Screen.height, 0, RenderTextureFormat.BGRA32);
        bloomCamera.targetTexture = bloomMask;
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture temp = RenderTexture.GetTemporary(source.width, source.height, 0, source.format, RenderTextureReadWrite.Default);
        RenderTexture temp1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format, RenderTextureReadWrite.Default);

        RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> 1, source.height >> 1, 0, source.format, RenderTextureReadWrite.Default);
        RenderTexture temp4 = RenderTexture.GetTemporary(source.width >> 2, source.height >> 2, 0, source.format, RenderTextureReadWrite.Default);

        RenderTexture temp21 = RenderTexture.GetTemporary(source.width >> 1, source.height >> 1, 0, source.format, RenderTextureReadWrite.Default);
        RenderTexture temp41 = RenderTexture.GetTemporary(source.width >> 2, source.height >> 2, 0, source.format, RenderTextureReadWrite.Default);
        Graphics.Blit(bloomMask, temp2);
        for(int i = 0;i < bloomLoop; i++)
        {
            Graphics.Blit(temp2, temp21, bloomMaterial, 0);
            Graphics.Blit(temp21, temp2, bloomMaterial, 0);
        }
        Graphics.Blit(bloomMask, temp4);
        for (int i = 0; i < bloomLoop; i++)
        {
            Graphics.Blit(temp4, temp41, bloomMaterial, 0);
            Graphics.Blit(temp41, temp4, bloomMaterial, 0);
        }

        bloomMaterial.SetFloat("_Strength", bloomStrength);
        bloomMaterial.SetFloat("_Width", bloomWidth);
        bloomMaterial.SetColor("_Color", bloomColor);
        bloomMaterial.SetTexture("_MaskTex", bloomMask);

        bloomMaterial.SetTexture("_BloomTex", temp2);
        Graphics.Blit(source, temp, bloomMaterial,1 );
        bloomMaterial.SetTexture("_BloomTex", temp4);
        Graphics.Blit(temp, temp1, bloomMaterial, 1);

        Graphics.Blit(temp1, destination);

        RenderTexture.ReleaseTemporary(temp);
        RenderTexture.ReleaseTemporary(temp1);

        RenderTexture.ReleaseTemporary(temp2);
        RenderTexture.ReleaseTemporary(temp4);

        RenderTexture.ReleaseTemporary(temp21);
        RenderTexture.ReleaseTemporary(temp41);
    }

}
