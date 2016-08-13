using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LoadVolumeData : MonoBehaviour {

	public Texture3D volumeData;
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

		volumeData = new Texture3D (256, 256, 128, TextureFormat.ARGB32, false);

		volumeData.SetPixels (allColorsWithPadding);
		volumeData.Apply ();
		GetComponent<Renderer>().material.SetTexture("_Texture", volumeData);
	}

	void addImageColorToList(Texture2D anImage){
		Color[] tempColors = anImage.GetPixels ();
		for (int i = 0; i < tempColors.Length; i++) {
			imageColors.Add (tempColors [i]);
		}
	}
	// Update is called once per frame
	void Update () {
	
	}
}
