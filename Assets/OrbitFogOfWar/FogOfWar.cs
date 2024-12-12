using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogOfWar : MonoBehaviour
{
    public Vector2 screenPosition;
    
    public CustomRenderTexture customRenderTexture;
    private CustomRenderTextureUpdateZone[] customRenderTextureUpdateZones;
    // Start is called before the first frame update
    void Start()
    {
        var temp = new List<CustomRenderTextureUpdateZone>();
        customRenderTexture.GetUpdateZones(temp);
        customRenderTextureUpdateZones = temp.ToArray();
        customRenderTexture.Initialize();
    }

    // Update is called once per frame
    void LateUpdate()
    {
        ref var zone = ref customRenderTextureUpdateZones[0];
        zone.updateZoneCenter = screenPosition;
        customRenderTexture.SetUpdateZones(customRenderTextureUpdateZones);
        customRenderTexture.Update(1);
    }
}
