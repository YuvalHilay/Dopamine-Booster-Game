using UnityEngine;

public class AudioManager : MonoBehaviour
{
    private AudioSource audioSource; // Reference to the AudioSource component

    void Start()
    {
        // Automatically find and assign the AudioSource component
        audioSource = GetComponent<AudioSource>();

        // Check if the AudioSource component is attached to the GameObject
        if (audioSource == null)
        {
            Debug.LogError("No AudioSource component found on this GameObject.");
            return;
        }

        // Set the audio to loop
        audioSource.loop = true; // Ensure that the audio will play in a loop

        // Play the audio
        audioSource.Play(); // Start playing the audio
    }
}
