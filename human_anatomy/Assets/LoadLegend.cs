#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LoadLegend : MonoBehaviour
{

    //public Texture3D volumeData;
    public List<Color> imageColors;
    //cadaver/5
    private const int numImages = 400;
    private const int startNumber = 60;
    // Use this for initialization
    void Start()
    {

        for (int i = startNumber; i < numImages+startNumber; i+=5)
        {
            Texture2D anImage = Resources.Load("Legend/"+i.ToString().PadLeft(4, '0')) as Texture2D;
            addImageColorToList(anImage);
        }

        Color[] allColors = imageColors.ToArray();

        int texSize = 512 * 512 * 512;

        Color[] allColorsWithPadding = new Color[texSize];

        allColors.CopyTo(allColorsWithPadding, 0);
        for (int i = allColors.Length; i < allColorsWithPadding.Length; i++)
        {
            allColorsWithPadding[i] = new Color(0, 0, 0, 0);
        }

        Texture3D volumeData = new Texture3D(512, 512, 512, TextureFormat.ARGB32, false);

        volumeData.SetPixels(allColorsWithPadding);
        volumeData.Apply();

        // assign it to the material of the parent object
        GetComponent<Renderer>().material.SetTexture("Legend_Data", volumeData);
    }

    void addImageColorToList(Texture2D anImage)
    {
        Color[] tempColors = anImage.GetPixels();
        for (int i = 0; i < tempColors.Length; i++)
        {
            imageColors.Add(tempColors[i]);
        }
    }

}
