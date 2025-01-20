using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;  // Import TextMesh Pro

public class InGameManager : MonoBehaviour
{
    public Image healthBarFill; // HEALTH IMAGE
    public float healthBarChangeTime = 0.5f; // TIME FOR CHANGE THE HEALTH
    private bool isExerciseMessageActive = false; // IF THERE IS EXERCISE MESSAGE
    //GAMEOBJECTS EVENTS
    public GameObject pauseMenu;
    public GameObject deathMenu;
    public GameObject levelCompleteMenu;
    private Coroutine gameTimerCoroutine;
    public PlayerManager playerManager;

    public Text asteroidKillText;
    public float popupInterval = 3f; // Time interval between popups
    private GameObject popupMessageUI; // The popup message UI object
    private TextMeshProUGUI popupMessageText; // The TextMesh Pro UI component inside the popup
    private TextMeshProUGUI countdownText; // The countdown text to show the timer above the message
    public float gameDuration = 240f; // משך זמן המשחק (240 sec)
    private float remainingTime; // Time left for the timer
    private bool gameEnded = false;
    // רשימות הודעות בעברית ובאנגלית
    private List<string> exerciseMessagesEnglish = new List<string>
    {
        "ready ?",
        "Sport exercise:       Now run in place",
        "Sport exercise:       Now jump in place",
        "Breathing exercise:       Inhale for four, hold for four, exhale for four, and hold for four"
    };

    private List<string> exerciseMessagesHebrew = new List<string>
    {
        "? ןכומ",
        "טרופס לוגרת          םוקמב ץור וישכע",
        "טרופס לוגרת          םוקמב ץופק וישכע",
        "היצטידמ תוליעפ         תוינש עברא םושנ         תוינש עברא ףושנו",
    };

    // רשימה של ההודעות שתוצג לפי השפה
    private List<string> exerciseMessages;
    public List<float> messageDurations = new List<float> { 30f, 30f, 60f }; // Durations for each message in seconds
    private float countdownTime; // Remaining countdown time
    public TMP_FontAsset popupFont;  // Reference to a TextMesh Pro font (drag in the Inspector)

    private void Start()
    {
        remainingTime = gameDuration; // rebuild the remain time
        CreatePopupUI();
        gameTimerCoroutine = StartCoroutine(GameTimer()); // start the timer of the game
        StartCoroutine(DisplayExerciseMessages());
    }
    private IEnumerator GameTimer()
    {
        // Loop until the remaining time is greater than 0 and the game has not ended
        while (remainingTime > 0 && !gameEnded)
        {
            // Check if the game is paused (time scale is 0)
            while (Time.timeScale == 0f)
            {
                yield return null; // Wait until the time resumes
            }

            // Update the time display (e.g., show remaining time)
            ChangeAsteroidKillCount(remainingTime);

            // Wait for one second
            yield return new WaitForSeconds(1f);

            // Decrease one second from the remaining time
            remainingTime--;
        }

        // End the game if time is up and the game hasn't ended yet
        if (!gameEnded && remainingTime <= 0)
        {
            EndGame();
        }
    }




    private void CreatePopupUI()
    {
        // Create the UI Panel (popupMessageUI)
        popupMessageUI = new GameObject("PopupMessageUI");
        RectTransform rectTransform = popupMessageUI.AddComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(600, 100); // Adjust size
        popupMessageUI.AddComponent<CanvasRenderer>();

        // Add a Canvas component if needed (optional, depends on your scene setup)
        Canvas canvas = popupMessageUI.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;

        // Add Image or Background for the panel
        Image panelImage = popupMessageUI.AddComponent<Image>();
        panelImage.color = new Color(1f, 1f, 0f, 0.7f); // Yellow background with transparency

        // Create the TextMesh Pro UI component for the message
        GameObject messageTextObj = new GameObject("PopupMessageText");
        messageTextObj.transform.SetParent(popupMessageUI.transform);

        popupMessageText = messageTextObj.AddComponent<TextMeshProUGUI>();  // Use TextMeshProUGUI instead of TMP_Text
        popupMessageText.font = popupFont;  // Assign the font through the Inspector
        popupMessageText.fontSize = 90;
        popupMessageText.alignment = TextAlignmentOptions.Center;  // Align text to the center
        popupMessageText.color = Color.black; // Change text color to black
        popupMessageText.rectTransform.sizeDelta = new Vector2(950, 100); // Match size with panel
        popupMessageText.rectTransform.anchoredPosition = Vector2.zero; // Center the text

        // Create the countdown text UI component
        GameObject countdownTextObj = new GameObject("CountdownText");
        countdownTextObj.transform.SetParent(popupMessageUI.transform);

        countdownText = countdownTextObj.AddComponent<TextMeshProUGUI>();  // Use TextMeshProUGUI instead of TMP_Text
        countdownText.font = popupFont;  // Assign the font through the Inspector
        countdownText.fontSize = 90;
        countdownText.alignment = TextAlignmentOptions.Center;  // Align text to the center
        countdownText.color = Color.black; // Change text color to black
        countdownText.rectTransform.sizeDelta = new Vector2(700, 100); // Match size with panel
        countdownText.rectTransform.anchoredPosition = new Vector2(0, 250); // Position above the message

        // Initially hide the popup
        popupMessageUI.SetActive(false);
    }

    private bool isMessageActive = false;  // Flag to track if the message is active


    private IEnumerator DisplayExerciseMessages()
    {
        // Choose the messages based on the selected language
        if (LanguageManager.SelectedLanguage == "Hebrew")
        {
            exerciseMessages = exerciseMessagesHebrew;
        }
        else
        {
            exerciseMessages = exerciseMessagesEnglish;
        }

        // Loop until the game ends
        while (!gameEnded)
        {
            // Loop through the list of exercise messages
            for (int i = 0; i < exerciseMessages.Count; i++)
            {
                // Pause the game time before displaying the message
                Time.timeScale = 0f;

                // Display the current message
                ShowPopupMessage(exerciseMessages[i]);

                // Start a countdown timer for the message duration
                float countdownTime = messageDurations[i];
                while (countdownTime > 0)
                {
                    // Update the countdown text with the remaining time
                    countdownText.text = Mathf.Ceil(countdownTime).ToString();

                    // Wait for one second before updating the countdown
                    yield return new WaitForSecondsRealtime(1f);
                    countdownTime--;
                }

                // Hide the message after the countdown finishes
                HidePopupMessage();

                // Resume the game time
                Time.timeScale = 1f;

                // Wait for the duration of the current message
                yield return new WaitForSecondsRealtime(messageDurations[i]);

                // Wait between exercise messages (if needed)
                yield return new WaitForSecondsRealtime(18f); // Example break between messages
            }
        }
    }






    private void ShowPopupMessage(string message)
    {
        // Check if the popup UI and message text are assigned, no message is currently active, and the game has not ended
        if (popupMessageUI != null && popupMessageText != null && !isMessageActive && !gameEnded)
        {
            // Set the text of the popup message
            popupMessageText.text = message;

            // If the message is related to a sport exercise, pause the game time
            if (message.Contains("Sport exercise"))
            {
                isExerciseMessageActive = true;
                Time.timeScale = 0f; // Pause the game time
            }

            // Show the popup message
            popupMessageUI.SetActive(true);
            isMessageActive = true;  // Mark the message as active
        }
    }

    private void HidePopupMessage()
    {
        // Check if the popup UI is assigned
        if (popupMessageUI != null)
        {
            // Hide the popup message
            popupMessageUI.SetActive(false);

            // Resume the game time
            Time.timeScale = 1f;  // Resume the game time
            isMessageActive = false;  // Mark the message as inactive

            // If the message was related to an exercise, reset the exercise flag
            isExerciseMessageActive = false;
        }
    }

    public void ChangeHealthbar(int maxHealth, int currentHealth)
    {
        // Ensure the health is not negative
        if (currentHealth < 0)
            return;

        // If health reaches zero, trigger the death menu
        if (currentHealth == 0)
        {
            Invoke("OpenDeathMenu", healthBarChangeTime);
        }

        // Calculate the health percentage
        float healthPct = currentHealth / (float)maxHealth;
        StartCoroutine(SmootheHealthbarChange(healthPct)); // Smooth the health bar transition
    }

    private IEnumerator SmootheHealthbarChange(float newFillAmt)
    {
        float elapsed = 0f;
        float oldFillAmt = healthBarFill.fillAmount;
        while (elapsed <= healthBarChangeTime)
        {
            elapsed += Time.deltaTime;
            float currentFillAmt = Mathf.Lerp(oldFillAmt, newFillAmt, elapsed / healthBarChangeTime);
            healthBarFill.fillAmount = currentFillAmt;  // Update the health bar fill amount
            yield return null;
        }
    }

    public void OnFireButtonClicked()
    {
        // Check if the game is paused or if a message is active
        if (Time.timeScale == 0f || isExerciseMessageActive || isMessageActive)
        {
            Debug.Log("Cannot fire rockets while the game is paused or a message is active.");
            return;  // Prevent firing rockets if game is paused or a message is active
        }

        // Allow firing rockets if the game is not paused and no message is active
        playerManager.FireRockets();
    }

    public void OnMenuBtnClicked()
    {
        Time.timeScale = 1f;  // Resume the game time when exiting to the menu
        SceneManager.LoadScene("MenuScene");  // Load the default menu scene

        // Load a specific menu scene based on the selected language
        if (LanguageManager.SelectedLanguage == "Hebrew")
        {
            SceneManager.LoadScene("MenuSceneHebrew");  // Load the Hebrew version of the menu scene
        }
        else
        {
            SceneManager.LoadScene("MenuScene");  // Load the English version of the menu scene
        }
    }

    public void OnPauseBtnClicked()
    {
        // Check if an exercise message or any other message is active
        if (isExerciseMessageActive || isMessageActive)
        {
            Debug.Log("Pause is disabled while a message is active.");
            return; // Do not allow pausing if a message is active
        }

        // Pause the game when the pause button is clicked
        Time.timeScale = 0f;
        pauseMenu.SetActive(true);  // Show the pause menu

        // Stop the game timer coroutine and save the remaining time
        if (gameTimerCoroutine != null)
        {
            StopCoroutine(gameTimerCoroutine);  // Stop the timer coroutine
        }

        // Even if a message is active, stop all message display coroutines
        StopAllCoroutines();
    }

    public void OnContinueBtnClicked()
    {
        // Resume the game when the continue button is clicked
        Time.timeScale = 1f;
        pauseMenu.SetActive(false);  // Hide the pause menu

        // Restart the game timer coroutine
        gameTimerCoroutine = StartCoroutine(GameTimer());

        // Restart the message display coroutine
        StartCoroutine(DisplayExerciseMessages());
    }

    public void OnRestartBtnClicked()
    {
        // Set the game as ended
        gameEnded = true;

        // Save the game state if necessary (not implemented in this snippet)
        Time.timeScale = 1f;  // Ensure the game is running at normal speed
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);  // Reload the current scene to restart the game
    }

    public void OpenDeathMenu()
    {
        // Set the game as ended when the player dies
        gameEnded = true;

        // Pause the game
        Time.timeScale = 0f;

        // Open the death menu
        deathMenu.SetActive(true);
    }


    public void ChangeAsteroidKillCount(float remainingTime)
    {
        // If the exercise message is active or if the time is paused, do not update the survival time
        if (isExerciseMessageActive || Time.timeScale == 0f)
            return;  // Do not update survival time if an exercise message is active or the game is paused

        // Round the remaining time to the nearest whole number and convert it to a string
        string formattedTime = Mathf.Ceil(remainingTime).ToString(); // Rounds the remaining time to an integer value

        string timeMessage = "";  // Variable to store the message

        // Select the message based on the selected language

        if (LanguageManager.SelectedLanguage == "Hebrew")
        {
            timeMessage = $"תוינש {formattedTime} :דורשל הרטמה";

        }
        else
        {
            timeMessage = $"Goal: To Survive {formattedTime} seconds";
        }

        // Update the text to display the time message
        asteroidKillText.text = timeMessage;

        // Set the font size to 30
        asteroidKillText.fontSize = 30;

        // Make the font bold
        asteroidKillText.fontStyle = FontStyle.Bold;

        // Set the text color to a bold color (e.g., red)
        asteroidKillText.color = Color.red;

        // Remove any shadow effect if it exists on the text
        if (asteroidKillText.GetComponent<Shadow>() != null)
        {
            Destroy(asteroidKillText.GetComponent<Shadow>());
        }

        // Set a fixed width of 700 for the RectTransform of the text
        RectTransform rectTransform = asteroidKillText.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(700, rectTransform.sizeDelta.y);

        // Move the TextMeshPro element to the top of the screen
        rectTransform.anchorMin = new Vector2(0.5f, 1);
        rectTransform.anchorMax = new Vector2(0.5f, 1);
        rectTransform.pivot = new Vector2(0.5f, 1);
        rectTransform.anchoredPosition = new Vector2(0, -10);
    }



    public void OpenLevelCompleteMenu()
    {
        // Pause the game when the level is complete
        Time.timeScale = 0f;

        // Activate the level complete menu
        levelCompleteMenu.SetActive(true);
    }
    // Coroutine that exits the game after a specified delay
    private IEnumerator ExitAfterDelay(float delay)
    {
        yield return new WaitForSecondsRealtime(delay); // Wait for the specified time, using WaitForSecondsRealtime to ignore time scale

        Debug.Log("5 seconds have passed! Exiting the application.");
        Application.Quit(); // This will close the application

        // If you are running in the editor, use this to simulate quitting
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }
    private void EndGame()
    {
        // Mark the game as ended
        gameEnded = true;

        // Pause the game
        Time.timeScale = 0f;

        // Open the level complete menu to show the player they have completed the level
        OpenLevelCompleteMenu();
    }
}

