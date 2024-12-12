using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using Object = UnityEngine.Object;

namespace OrbitGames
{
    public sealed class FogOfWar : MonoBehaviour
    {
        public string fogName = "world_map_0";
        public string saveKey = "world_map_0_fog";
        public float worldSize = 1000;
        public CustomRenderTexture customRenderTexture;

        private CustomRenderTextureUpdateZone[] customRenderTextureUpdateZones;
        private Texture2D savedTexture;
        private int textureSize;

        // Start is called before the first frame update
        private void Start()
        {
            textureSize = PlayerPrefs.GetInt(saveKey + "_size", (int)customRenderTexture.width);
            var bytesStr = PlayerPrefs.GetString(saveKey + "_data", null);
            
            if (!string.IsNullOrEmpty(bytesStr))
            {
                var bytes = Convert.FromBase64String(bytesStr);
                savedTexture = new Texture2D(textureSize, textureSize, customRenderTexture.graphicsFormat, 0,
                    TextureCreationFlags.None);
                savedTexture.LoadImage(bytes);
                customRenderTexture.initializationColor = Color.white;
                customRenderTexture.initializationTexture = savedTexture;
            }
            else
            {
                savedTexture = new Texture2D(textureSize, textureSize, customRenderTexture.graphicsFormat, 0,
                    TextureCreationFlags.None);
                customRenderTexture.initializationColor = Color.black;
                customRenderTexture.initializationTexture = null;
            }

            var temp = new List<CustomRenderTextureUpdateZone>();
            customRenderTexture.GetUpdateZones(temp);
            customRenderTextureUpdateZones = temp.ToArray();
            customRenderTexture.Initialize();
        }

        // Update is called once per frame
        private void LateUpdate()
        {
            foreach (var torcher in FogOfWarTorcher.torchers)
            {
                if (torcher.fogName == fogName && torcher.radius > 0)
                {
                    //把火炬的位置传递到本地坐标。
                    //计算出一个相对偏移。
                    var torcherPos = transform.InverseTransformPoint(torcher.transform.position);
                    var torcherPosXZ = new Vector2(torcherPos.x, -torcherPos.z);
                    var pixelPos = (torcherPosXZ / worldSize) * textureSize;
                    var pixelRadius = (new Vector2(torcher.radius, torcher.radius) / worldSize) * textureSize;

                    //更新位置。
                    ref var zone = ref customRenderTextureUpdateZones[0];
                    zone.updateZoneCenter = pixelPos;
                    zone.updateZoneSize = pixelRadius;
                    customRenderTexture.SetUpdateZones(customRenderTextureUpdateZones);
                    customRenderTexture.Update(1);
                }
            }
        }

        private void OnDestroy()
        {
            if (savedTexture != null)
            {
                Object.Destroy(savedTexture);
                savedTexture = null;
            }
        }

        [ContextMenu("Save Data")]
        public void SaveData()
        {
            if (savedTexture != null && customRenderTexture != null)
            {
                var prev = RenderTexture.active;
                RenderTexture.active = customRenderTexture;
                savedTexture.ReadPixels(new Rect(0, 0, customRenderTexture.width, customRenderTexture.height), 0, 0);
                savedTexture.Apply();
                RenderTexture.active = prev;

                var bytes = savedTexture.EncodeToPNG();
                PlayerPrefs.SetString(saveKey + "_data", Convert.ToBase64String(bytes));
                PlayerPrefs.SetInt(saveKey + "_size", savedTexture.width);
                PlayerPrefs.Save();
                
                Debug.Log("Save ok");
            }
        }

        private void OnDrawGizmos()
        {
            Gizmos.matrix = transform.localToWorldMatrix;
            Gizmos.DrawWireCube(new Vector3(worldSize / 2f, 0, -worldSize / 2f), new Vector3(worldSize, 1, worldSize));
        }
    }
}
