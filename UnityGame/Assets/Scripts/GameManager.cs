using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class GameManager : MonoBehaviour
{
    // Arrays for spaceship prefabs and textures
    public GameObject[] spaceshipPrefabs;
    public Texture2D[] spaceshipTextures;

    // Static instance of GameManager (Singleton pattern)
    public static GameManager Instance;

    // Variable to store the index of the current spaceship
    private int currentSpaceshipIdx = 0;

    // Read-only property to access the index of the current spaceship
    public int CurrentSpaceshipIdx => currentSpaceshipIdx;

    // Read-only property to access the current spaceship prefab
    public GameObject currentSpaceship => spaceshipPrefabs[currentSpaceshipIdx];

    // Index of the current level
    public int currentLevelIdx = 0;

    // Called when the object is loaded into the scene
    private void Awake()
    {
        // If the GameManager instance does not exist, assign it
        if (Instance == null)
        {
            Instance = this;
        }

        // Initialize the spaceship textures array with the same length as the spaceship prefabs array
        spaceshipTextures = new Texture2D[spaceshipPrefabs.Length];

#if UNITY_EDITOR
        // Loop through all spaceship prefabs, convert them to asset previews, and store them in the textures array
        for (int i = 0; i < spaceshipPrefabs.Length; ++i)
        {
            GameObject prefab = spaceshipPrefabs[i];
            Texture2D texture = AssetPreview.GetAssetPreview(prefab);
            spaceshipTextures[i] = texture;
        }
#endif

        // Prevent this GameManager from being destroyed when loading new scenes
        DontDestroyOnLoad(gameObject);
    }

    // Method to change the current spaceship by its index
    public void ChangeCurrentSpaceship(int idx)
    {
        currentSpaceshipIdx = idx;
    }
}
