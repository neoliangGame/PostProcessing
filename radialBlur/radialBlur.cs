using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class radialBlur : MonoBehaviour {
    //径向模糊效果基础设置
    [SerializeField]
    Material ratialBlurMaterial;
    [SerializeField]
    [Range(0,10)]
    float strength = 1;
    [SerializeField]
    Vector2 center = Vector2.zero;
    [SerializeField]
    Texture2D maskTex;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        ratialBlurMaterial.SetVector("_Center", new Vector4(center.x, center.y, 0, 0));
        ratialBlurMaterial.SetFloat("_Strength", strength);
        ratialBlurMaterial.SetTexture("_MaskTex", maskTex);
        Graphics.Blit(source, destination, ratialBlurMaterial, 0);
    }
}
