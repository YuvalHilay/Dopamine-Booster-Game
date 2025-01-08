﻿using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    // References to UI elements
    public Transform levelContainer; // Container for level buttons
    public RectTransform menuContainer; // Main menu container
    public float transitionTime = 1f; // Time for menu transition
    private int screenWidth; // Screen width for menu animations

    private GameObject currentSpaceshipPreview = null; // Current spaceship preview object
    public float rotationSpeed = 10f; // Rotation speed of spaceship preview

    private Vector3 randomDirection; // Random direction for spaceship movement
    private float moveSpeed = 5f; // Speed of spaceship movement
    private float directionChangeInterval = 2f; // Time interval for changing direction
    private Camera mainCamera; // Reference to the main camera

    // Start is called before the first frame update
    private void Start()
    {
        InitLevelButtons(); // Initialize level buttons
        screenWidth = Screen.width; // Get the screen width

        UpdateSpaceshipPreview(); // Update the spaceship preview

        mainCamera = Camera.main; // Get the main camera

        // Initialize random direction for spaceship movement
        randomDirection = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0f).normalized;
        InvokeRepeating("ChangeRandomDirection", directionChangeInterval, directionChangeInterval); // Repeatedly change direction
    }

    // Update is called once per frame
    private void Update()
    {
        if (currentSpaceshipPreview != null)
        {
            // Rotate spaceship preview
            currentSpaceshipPreview.transform.Rotate(0f, rotationSpeed * Time.deltaTime, 0f);

            // Move spaceship in random direction
            currentSpaceshipPreview.transform.Translate(randomDirection * moveSpeed * Time.deltaTime);

            // Check if spaceship has gone out of screen bounds
            Vector3 position = currentSpaceshipPreview.transform.position;
            Vector3 screenPos = mainCamera.WorldToScreenPoint(position);

            // If spaceship is out of screen bounds, change direction
            if (screenPos.x < 0 || screenPos.x > Screen.width || screenPos.y < 0 || screenPos.y > Screen.height)
            {
                ChangeRandomDirection(); // Change direction when off-screen
            }
        }
    }

    // Quit the application
    public void OnQuitButtonClicked()
    {
        Debug.Log("Quit App");
        Application.Quit(); // Exit the app
    }

    // Change the random direction of the spaceship
    private void ChangeRandomDirection()
    {
        randomDirection = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0f).normalized;
    }

    // Update the spaceship preview
    private void UpdateSpaceshipPreview()
    {
        if (currentSpaceshipPreview != null)
        {
            Destroy(currentSpaceshipPreview); // Destroy the previous preview
        }

        // Instantiate a new spaceship preview
        GameObject newSpaceshipPrefab = GameManager.Instance.currentSpaceship;
        Vector3 startRotationVector = new Vector3(0f, 180f, 0f); // Initial rotation
        currentSpaceshipPreview = Instantiate(newSpaceshipPrefab, Vector3.zero, Quaternion.Euler(startRotationVector));
    }

    // Initialize level buttons based on completed levels
    private void InitLevelButtons()
    {
        if (menuContainer == null) return; // Early exit if menuContainer is null

        int lastLevelCompleted = SaveManager.Instance.GetLevelsCompleted(); // Get the last completed level

        int i = 0;
        foreach (Transform t in levelContainer)
        {
            int currentIdx = i;
            Button button = t.GetComponent<Button>();
            if (currentIdx <= lastLevelCompleted)
            {
                // Completed level
                button.onClick.AddListener(() => OnLevelSelect(currentIdx));
                button.image.color = Color.white;
            }
            else if (currentIdx == lastLevelCompleted + 1)
            {
                // The next level to be completed
                button.onClick.AddListener(() => OnLevelSelect(currentIdx));
                button.image.color = Color.green;
            }
            else
            {
                // Not completed
                button.interactable = false;
                button.image.color = Color.gray;
            }

            i++;
        }
    }

    // Change the menu view with a sliding animation
    private void ChangeMenu(MenuType menuType)
    {
        Vector3 newPos;
        if (menuType == MenuType.Map1Menu)
        {
            newPos = new Vector3(-screenWidth, 0f, 0f); // Off-screen position for Map1Menu
        }
        else
        {
            newPos = Vector3.zero; // Default position for MainMenu
        }

        StopAllCoroutines();
        StartCoroutine(ChangeMenuAnimation(newPos)); // Start menu transition animation
    }

    // Coroutine for the menu transition animation
    private IEnumerator ChangeMenuAnimation(Vector3 newPos)
    {
        if (menuContainer == null) yield break; // Early exit if the menuContainer is null

        float elapsed = 0f;
        Vector3 oldPos = menuContainer.anchoredPosition3D;

        while (elapsed <= transitionTime)
        {
            if (menuContainer == null) yield break; // Exit if menuContainer is destroyed during the coroutine

            elapsed += Time.deltaTime;
            Vector3 currentPos = Vector3.Lerp(oldPos, newPos, elapsed / transitionTime);
            menuContainer.anchoredPosition3D = currentPos;
            yield return null;
        }
    }

    // Handle level selection
    private void OnLevelSelect(int idx)
    {
        GameManager.Instance.currentLevelIdx = idx;

        int levelIdx = idx + 1;
        string sceneName = "Level" + levelIdx.ToString();
        SceneManager.LoadScene(sceneName); // Load the selected level scene
    }

    // Start the game and change to the map menu
    public void OnPlayButtonClicked()
    {
        Debug.Log("Play Button Clicked");
        ChangeMenu(MenuType.Map1Menu); // Switch to map menu
    }

    // Go back to the main menu
    public void OnMainMenuButtonClicked()
    {
        Debug.Log("Clicked main button");
        ChangeMenu(MenuType.MainMenu); // Switch to main menu
    }

    // Handle the "Next Map" button click (currently not implemented)
    public void OnNextMapButtonClicked()
    {
        Debug.Log("Next map clicked");
    }

    // Load the menu scene in Hebrew
    public void LoadSceneHebrew()
    {
        LanguageManager.SelectedLanguage = "Hebrew";
        SceneManager.LoadScene("MenuSceneHebrew"); // Load the Hebrew menu scene
    }

    // Load the menu scene in English
    public void LoadSceneEnglish()
    {
        LanguageManager.SelectedLanguage = "English";
        SceneManager.LoadScene("MenuScene"); // Load the English menu scene
    }

    // Enum for menu types
    private enum MenuType
    {
        MainMenu,
        Map1Menu
    }
}
