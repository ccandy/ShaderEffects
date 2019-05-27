using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode, RequireComponent(typeof(LineRenderer))]
public class Bezier_Spline : MonoBehaviour {

    // Use this for initialization

    public List<GameObject> controlPts  = new List<GameObject>();
    public Color color                  = Color.white;
    public float width                  = 0.2f;
    public int numberOfPoints           = 20;
    LineRenderer lineRender;

    void Start()
    {
        lineRender                  = gameObject.GetComponent<LineRenderer>();
        lineRender.useWorldSpace    = true;
        lineRender.material         = new Material(Shader.Find("Particles/Additive"));
    }

    // Update is called once per frame
    void Update()
    {
        if (null == lineRender || controlPts == null || numberOfPoints < 3)
        {
            return;
        }

        lineRender.startColor   = color;
        lineRender.endColor     = color;
        lineRender.startWidth   = width;
        lineRender.endWidth     = width;

        if(numberOfPoints < 2)
        {
            numberOfPoints = 2;
        }

        lineRender.positionCount    = numberOfPoints * (controlPts.Count - 2);

        Vector3 p0, p1, p2;
        for (int j = 0; j < controlPts.Count - 2; j++){
            if (controlPts[j] == null || controlPts[j + 1] == null || controlPts[j+2] == null)
            {
                return;
            }
            p0 = 0.5f * (controlPts[j].transform.position + controlPts[j + 1].transform.position);
            p1 = controlPts[j + 1].transform.position;
            p2 = 0.5f * (controlPts[j + 1].transform.position + controlPts[j + 2].transform.position);

            Vector3 position;
            float t;
            float pointStep = 1.0f / numberOfPoints;

            if(j == controlPts.Count - 3)
            {
                pointStep = 1.0f / (numberOfPoints - 1);
            }

            for (int i = 0; i < numberOfPoints; i++)
            {
                t        = i * pointStep;
                position = (1.0f - t) * (1.0f - t) * p0 + 2.0f * (1.0f - t) * t * p1 + t * t * p2;
                lineRender.SetPosition(i + j * numberOfPoints, position);
            }


        }

        



    }
}
