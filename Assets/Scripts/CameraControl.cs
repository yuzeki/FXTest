using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    public float amplitude = 5;
    public Transform target;
    Quaternion m_InitRot;
    Vector3 m_InitTrans;
    Vector3 m_InitForward;
    float m_InitDis;

    private void Start()
    {
        m_InitTrans = transform.position;
        m_InitRot = transform.rotation;
        m_InitForward = target.position - transform.position;
        m_InitDis = m_InitForward.magnitude;
        Input.gyro.enabled = true;
    }

    void Update()
    {
        //transform.rotation = Quaternion.Slerp(transform.rotation, m_InitRot * Quaternion.Euler(Input.gyro.rotationRate * amplitude), 0.1F);
        Quaternion targetRot = m_InitRot * Quaternion.Euler(Input.gyro.rotationRateUnbiased * amplitude);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, 0.1F);
        //transform.position = Vector3.Lerp(transform.position, m_InitTrans + Input.gyro.gravity * amplitude, 0.1F);
        transform.position = m_InitTrans + m_InitForward - transform.forward * m_InitDis;
    }

   
}
