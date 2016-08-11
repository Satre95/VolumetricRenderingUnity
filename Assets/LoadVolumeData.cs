using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LoadVolumeData : MonoBehaviour {

	public Texture3D volumeData;
	private Texture2D[] images;

	private const int numImages = 120;
	// Use this for initialization
	void Start () {




		images = new Texture2D[numImages];
		string head = "head-";
		for (int i = 0; i < numImages; i++) {
			Texture2D anImage = Resources.Load("head-images/" + head + i.ToString().PadLeft(3, '0')) as Texture2D;
			print (anImage.GetPixel(128, 128));
			images [i] = anImage;
		}


	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
