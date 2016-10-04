#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LoadVolumeData : MonoBehaviour {

	//public Texture3D volumeData;
	public List<Color> imageColors;

	private const int numImages = 120;
	// Use this for initialization
	void Start () {
		string head = "head-";
		for (int i = 0; i < numImages; i++) {
			Texture2D anImage = Resources.Load("head-images/" + head + i.ToString().PadLeft(3, '0')) as Texture2D;
			addImageColorToList (anImage);
		}

		Color[] allColors = imageColors.ToArray ();

		int texSize = 256 * 256 * 128;

		Color[] allColorsWithPadding = new Color[texSize];

		allColors.CopyTo (allColorsWithPadding, 0);
		for (int i = allColors.Length; i < allColorsWithPadding.Length; i++) {
			allColorsWithPadding [i] = new Color (0, 0, 0, 0);
		}

		Texture3D volumeData = new Texture3D (256, 256, 128, TextureFormat.ARGB32, false);

		volumeData.SetPixels (allColorsWithPadding);
		volumeData.Apply ();

        // assign it to the material of the parent object
        GetComponent<Renderer>().material.SetTexture("_Data", volumeData);
        // save it as an asset for re-use
        #if UNITY_EDITOR
        AssetDatabase.CreateAsset(volumeData, @"Assets/" + "skull" + ".asset");
        #endif
    }

    void addImageColorToList(Texture2D anImage){
		Color[] tempColors = anImage.GetPixels ();
		for (int i = 0; i < tempColors.Length; i++) {
			imageColors.Add (tempColors [i]);
		}
	}

}
