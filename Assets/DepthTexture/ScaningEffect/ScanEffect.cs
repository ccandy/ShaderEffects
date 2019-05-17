using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanEffect : MonoBehaviour {

    // Use this for initialization



    public  float           ScanSpeed = 5;
    public  Shader          CurShader;
    private float           ScanTimer;
    private bool            StartScan;
    private Material        _curMat;
    public  Material        CurMat
    {
        get
        {
            if(_curMat == null)
            {
                _curMat = new Material(CurShader);
            }

            return _curMat;
        }
    }




	void Start () {

        ScanTimer = 0;
        StartScan = false;
        Camera.main.depthTextureMode = DepthTextureMode.Depth;

    }
	
	// Update is called once per frame
	void Update () {

        if (StartScan)
        {
            ScanTimer += Time.deltaTime * ScanSpeed;
        }

        if (Input.GetButtonDown("Fire1"))
        {
            StartScan = true;
            ScanTimer = 0;
        }
	}


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(CurShader != null)
        {
            CurMat.SetFloat("_ScanTimer", ScanTimer);
            Graphics.Blit(source, destination, CurMat);
        }
    }

}
