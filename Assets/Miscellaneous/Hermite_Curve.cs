using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hermite_Curve : MonoBehaviour {

    // Use this for initialization

    public GameObject StartPt, StartTangentPt, EndPt, EndTangentPt;
    public Color color          = Color.white;
    public float width          = 0.2f;
    public int numberOfPoints   = 20;
    LineRenderer lineRender;


	void Start ()
    {
        lineRender                  = gameObject.GetComponent<LineRenderer>();
        lineRender.useLightProbes   = true;
        lineRender.material         = new Material(Shader.Find("Particles / Additive"));
	}

    private void Update()
    {
        if (null == lineRender || StartPt == null || StartTangentPt == null || EndPt == null || EndTangentPt == null)
        {
            return;
        }

        lineRender.startColor   = color;
        lineRender.endColor     = color;
        lineRender.startWidth   = width;
        lineRender.endWidth     = width;

        if(numberOfPoints > 0)
        {
            lineRender.positionCount = numberOfPoints;
        }

        Vector3 p0      = StartPt.transform.position;
        Vector3 p1      = EndPt.transform.position;
        Vector3 m0      = StartTangentPt.transform.position - StartPt.transform.position;
        Vector3 m1      = EndTangentPt.transform.position - EndPt.transform.position;

        float t;
        Vector3 position;

        for(int n = 0; n < numberOfPoints; n++)
        {
            t           = n / (numberOfPoints - 1.0f);
            position    = (2.0f * t * t * t - 3.0f * t * t + 1.0f) * p0
                        + (t * t * t - 2.0f * t * t + t) * m0
                        + (-2.0f * t * t * t + 3.0f * t * t) * p1
                        + (t * t * t - t * t) * m1;
            lineRender.SetPosition(n, position);

        }






    }

}
