using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode, RequireComponent(typeof(LineRenderer))]
public class Spline_Curve : MonoBehaviour {

    // Use this for initialization

    public List<GameObject> controlPoints   = new List<GameObject>();
    public Color color                      = Color.white;
    public float width                      = 0.02f;
    public int numberOfPts                  = 20;
    LineRenderer lineRenderer;

    void Start ()
    {
        lineRenderer                = gameObject.GetComponent<LineRenderer>();
        lineRenderer.useWorldSpace  = false;
        lineRenderer.material       = new Material(Shader.Find("Particles/Additive"));

    }
	
	// Update is called once per frame
	void Update ()
    {
		if(lineRenderer == null || controlPoints == null || controlPoints.Count < 2)
        {
            return;
        }

        lineRenderer.startColor = color;
        lineRenderer.endColor   = color;
        lineRenderer.startWidth = width;
        lineRenderer.endWidth   = width;

        if(numberOfPts < 2)
        {
            numberOfPts = 2;
        }
        lineRenderer.positionCount = numberOfPts * (controlPoints.Count - 1);
        Vector3 p0, p1, m0, m1;

        for(int j = 0; j < controlPoints.Count - 1; j++)
        {
            
            if(controlPoints[j] == null || controlPoints[j + 1] == null || (j > 0 && controlPoints[j -1] == null) || (j < controlPoints.Count -2 && controlPoints[j + 2] == null))
            {
                    return;
            }


            p0 = controlPoints[j].transform.position;
            p1 = controlPoints[j + 1].transform.position;

            if(j > 0)
            {
                m0 = 0.5f * (controlPoints[j + 1].transform.position - controlPoints[j - 1].transform.position);
            }
            else
            {
                m0 = controlPoints[j + 1].transform.position - controlPoints[j].transform.position;
            }
            if(j < controlPoints.Count - 2)
            {
                m1 = 0.5f * (controlPoints[j + 2].transform.position - controlPoints[j].transform.position);
            }
            else
            {
                m1 = controlPoints[j + 1].transform.position - controlPoints[j].transform.position;
            }

            Vector3 position;
            float t;
            float pointStep = 1.0f / numberOfPts;

            if(j == controlPoints.Count - 2)
            {
                pointStep = 1.0f / (numberOfPts - 1);
            }

            for(int i = 0; i < numberOfPts; i++)
            {
                t = i * pointStep;
                position = (2.0f * t * t * t - 3.0f * t * t + 1.0f) * p0
                         + (t * t * t - 2.0f * t * t + t) * m0
                         + (-2.0f * t * t * t + 3.0f * t * t) * p1
                         + (t * t * t - t * t) * m1;
                lineRenderer.SetPosition(i + j * numberOfPts, position);


            }


            
        }









	}
}
