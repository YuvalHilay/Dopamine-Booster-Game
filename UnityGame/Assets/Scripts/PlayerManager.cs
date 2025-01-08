using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// The PlayerManager class is responsible for managing the active player in the game.
/// </summary>
public class PlayerManager : MonoBehaviour
{
    /// <summary>
    /// A private variable that holds the currently active player controller.
    /// </summary>
    private PlayerController activePlayerController;

    /// <summary>
    /// This method is called when the object is initialized. 
    /// It determines the active player controller based on the game's state.
    /// </summary>
    private void Awake()
    {
        // Check if GameManager is null (used for debugging or testing purposes)
        if (GameManager.Instance == null)
        {
            // Debugging scenario
            Debug.Log("Debugging or testing");
            // Initialize the first active player controller
            GetFirstActiveController();
        }
        else
        {
            // In a real game scenario
            // Set the current spaceship
            SetCurrentSpaceship();
        }
    }

    /// <summary>
    /// This method sets the current spaceship based on the GameManager's index.
    /// It activates the spaceship at the current index and deactivates others.
    /// </summary>
    private void SetCurrentSpaceship()
    {
        // Get the index of the current spaceship from the GameManager
        int currentSpaceshipIdx = GameManager.Instance.CurrentSpaceshipIdx;

        int i = 0;
        // Loop through each spaceship in the PlayerManager's transform
        foreach (Transform spaceship in this.transform)
        {
            int currentIdx = i;
            // Check if the current index matches the current spaceship index
            if (currentIdx == currentSpaceshipIdx)
            {
                // Activate the spaceship at the current index
                spaceship.gameObject.SetActive(true);
                // Get the PlayerController component from the spaceship
                activePlayerController = spaceship.GetComponent<PlayerController>();
            }
            else
            {
                // Deactivate the spaceship if it's not the current one
                spaceship.gameObject.SetActive(false);
            }
            i++;
        }
    }

    /// <summary>
    /// This method calls the FireRockets method on the active player controller.
    /// It triggers the firing of rockets from the active spaceship.
    /// </summary>
    public void FireRockets()
    {
        // Fire rockets using the active player's controller
        activePlayerController.FireRockets();
    }

    /// <summary>
    /// This method gets the first active player controller from the list of spaceships.
    /// It sets the activePlayerController to the first active spaceship it finds.
    /// </summary>
    private void GetFirstActiveController()
    {
        // Loop through each spaceship in the PlayerManager's transform
        foreach (Transform spaceship in this.transform)
        {
            // Check if the spaceship is active
            if (spaceship.gameObject.activeSelf)
            {
                // Set the active player controller to this spaceship's controller
                activePlayerController = spaceship.GetComponent<PlayerController>();
                return; // Return as soon as the first active controller is found
            }
        }
    }
}