using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class blur : MonoBehaviour {

    [SerializeField]
    Material blurMaterial;
    [SerializeField]
    [Range(0, 10)]
    float strength = 1f;
    [SerializeField]
    [Range(0, 10)]
    float loopTimes = 1;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture temp = RenderTexture.GetTemporary(source.width >> 1, source.height >> 1, 0, RenderTextureFormat.ARGB32);
        RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> 1, source.height >> 1, 0, RenderTextureFormat.ARGB32);
        blurMaterial.SetFloat("_Strength", strength);
        Graphics.Blit(source, temp, blurMaterial, 0);
        for(int i = 0;i < loopTimes; i++)
        {
            Graphics.Blit(temp, temp1, blurMaterial, 0);
            Graphics.Blit(temp1, temp, blurMaterial, 0);
        }
        Graphics.Blit(temp, destination, blurMaterial, 0);
        RenderTexture.ReleaseTemporary(temp);
        RenderTexture.ReleaseTemporary(temp1);
    }
}
