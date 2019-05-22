using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class BasicImageEffect : MonoBehaviour {

    // Use this for initialization

    public Material material;

    
	void Start ()
    {
        if (!material.shader.isSupported)
        {
            enabled = false;
            return;
        }	
	}

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
