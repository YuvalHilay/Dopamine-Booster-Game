using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AsteroidController : MonoBehaviour
{
    public float moveSpeed = 3000f; // Speed of the asteroid
    private Rigidbody rb; // Rigidbody component for physics interactions
    private Vector3 randomRotation; // Random rotation for the asteroid's movement
    private float removePositionZ; // Position where the asteroid will be destroyed when it passes

    public Material targetMaterial; // Material to apply when the asteroid is targeted
    private Material baseMat; // Base material for the asteroid
    private Renderer[] renderers; // Array of renderers for the asteroid's mesh

    public bool isGoldenAsteroid = false; // Flag to check if the asteroid is golden

    // Particle effect to play when the asteroid is destroyed
    public ParticleSystem explosion;

    void Start()
    {
        // Initialize Rigidbody and random rotation values
        rb = GetComponent<Rigidbody>();
        randomRotation = new Vector3(Random.Range(0f, 100f), Random.Range(0f, 100f), Random.Range(0f, 100f));
        removePositionZ = Camera.main.transform.position.z;

        // Get all renderers for the asteroid
        renderers = GetComponentsInChildren<Renderer>();
        baseMat = renderers[0].material; // Set the base material of the asteroid
    }

    // Resets the material of the asteroid to its original state
    public void ResetMaterial()
    {
        if (renderers == null)
            return;

        // Iterate over all the renderers and reset their materials
        foreach (Renderer rend in renderers)
        {
            rend.material = baseMat;
        }
    }

    // Sets the material of the asteroid to the target material (used for highlighting)
    public void SetTargetMaterial()
    {
        if (renderers == null)
            return;

        // Iterate over all the renderers and set their material to the target material
        foreach (Renderer rend in renderers)
        {
            rend.material = targetMaterial;
        }
    }

    void Update()
    {
        // Check if the asteroid has passed the designated position and should be destroyed
        if (transform.position.z < removePositionZ)
        {
            AsteroidManager.Instance.aliveAsteroids.Remove(gameObject); // Remove from the asteroid list
            Destroy(gameObject); // Destroy the asteroid
        }

        // Move the asteroid in the negative Z direction based on the current speed
        Vector3 movementVector = new Vector3(0f, 0f, -moveSpeed * Time.deltaTime);
        rb.velocity = movementVector; // Apply the movement to the Rigidbody

        // Rotate the asteroid randomly
        transform.Rotate(randomRotation * Time.deltaTime);
    }

    // Method to destroy the asteroid
    public void DestroyAsteroid()
    {

        // Remove the asteroid from the alive list in AsteroidManager
        AsteroidManager.Instance.OnAsteroidKill(gameObject);

        // Play the explosion particle effect at the asteroid's position
        Instantiate(explosion, transform.position, Quaternion.identity);

        // Destroy the asteroid object after a delay
        Destroy(gameObject);
    }

    // Collision detection with player
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            // Notify the player of the asteroid impact
            other.gameObject.GetComponent<PlayerController>().OnAsteroidImpact();
            DestroyAsteroid(); // Destroy the asteroid
        }
    }

    // Set the speed of the asteroid
    public void SetSpeed(float speed)
    {
        moveSpeed = speed; // Update the asteroid's speed
    }
}
