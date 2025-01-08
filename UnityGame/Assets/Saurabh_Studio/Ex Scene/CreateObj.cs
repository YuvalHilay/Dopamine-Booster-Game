using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class CreateObj : MonoBehaviour
{
    public Image PP;
    public Sprite[] temp;
    public GameObject parent;
    public Color[] colorList;
    public int colorNo;

    // Use this for initialization
    void Start()
    {
        for (int i = 0; i < temp.Length; i++)
        {
            var createImage = Instantiate(PP) as Image;
            createImage.transform.SetParent(parent.transform, false);
            createImage.color = colorList[colorNo];
            createImage.gameObject.SetActive(true);
            Image tempNew = createImage.GetComponentsInChildren<Image>()[1];
            tempNew.sprite = temp[i];
            createImage.gameObject.name = temp[i].name;

            // Uncomment if you want to save as a prefab
            // string localPath = $"Assets/UI button pack 3/Button round color {colorNo + 1}/{createImage.gameObject.name}.prefab";
            // CreateNew(createImage.gameObject, localPath);
        }
    }

    // Create a new prefab at the specified path
    static void CreateNew(GameObject obj, string localPath)
    {
#if UNITY_EDITOR
        // Save the object as a prefab
        PrefabUtility.SaveAsPrefabAsset(obj, localPath);
#endif
    }
}
