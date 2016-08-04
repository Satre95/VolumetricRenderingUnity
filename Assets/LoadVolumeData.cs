using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LoadVolumeData : MonoBehaviour {

	public Texture3D volumeData;

	private int numImages;
	// Use this for initialization
	void Start () {
		string dataPath = Application.dataPath;
		List<byte> imageData3D = loadAllImagesInFolder (dataPath + "/head-png");

		Color[] colors = convertByteDataToColors (imageData3D);

		volumeData.SetPixels (colors);
		volumeData.Apply ();

        GetComponent<Renderer>().material.SetTexture("_Texture", volumeData);
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	List<byte> loadAllImagesInFolder( string path) {
		List <byte> imageData = new List<byte>();

		if (System.IO.Directory.Exists(path)) {
			string[] imageFilePaths = System.IO.Directory.GetFiles(path);
			numImages = imageFilePaths.Length;

			foreach (string aPath in imageFilePaths) {
				byte[] data = loadImageAtPath (aPath);
				foreach (byte aByte in data) {
					imageData.Add (aByte);
				}
			}
		}

		return imageData;
	}

	byte[] loadImageAtPath( string path ) {
		byte[] imageData = File.ReadAllBytes (path);
		return imageData;
	}

	Color[] convertByteDataToColors( List<byte> byteData) {
		Color[] colors = new Color[256 * 256 * numImages];
		for (int i = 0; i < byteData.Count; i += 3) {
			byte red = byteData [i];
			byte green = byteData [i + 1];
			byte blue = byteData [i + 2];
			colors [i] = new Color (byteData[i], byteData[i+1], byteData[i+2], 1);

			if (colors [i].r < 0.32 && colors [i].g < 0.32 && colors [i].b < 0.32) {
				colors [i].a = 0;
			}
		}

		return colors;
	}
}
