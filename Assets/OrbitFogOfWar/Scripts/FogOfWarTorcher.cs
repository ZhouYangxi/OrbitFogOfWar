using System;
using System.Collections.Generic;
using UnityEngine;

namespace OrbitGames
{
    public sealed class FogOfWarTorcher : MonoBehaviour
    {
        public string fogName = "world_map_0";
        //实际世界坐标的米数
        public float radius = 10.0f;
        
        internal static List<FogOfWarTorcher> torchers = new List<FogOfWarTorcher>();

        private void OnEnable()
        {
            torchers.Add(this);
        }

        private void OnDisable()
        {
            torchers.Remove(this);
        }
    }
}