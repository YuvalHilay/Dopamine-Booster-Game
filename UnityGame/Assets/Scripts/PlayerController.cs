using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Joystick input;                  // Joystick input for controlling player movement
    public float moveSpeed = 10f;           // Player movement speed
    public float maxRotation = 25f;         // Maximum rotation of the player

    private Rigidbody rb;                   // Rigidbody component for physics-based movement
    private float minX, maxX, minY, maxY;   // Boundary values for the player's movement

    public int maxHealth = 10;              // Maximum health of the player
    private int currentHealth;              // Current health of the player
    public InGameManager inGameManager;     // Reference to the in-game manager for health updates

    public Transform[] missleSpawnPoints;   // Missile spawn points for firing rockets
    public GameObject rocketPrefab;         // The rocket prefab to be instantiated
    public float fireInterval = 2f;         // Time interval between consecutive rocket fires
    private bool canFire = true;            // Boolean to control whether the player can fire a rocket

    private Vector3 raycastDirection = new Vector3(0f, 0f, 1f);  // Direction for raycasting (forward)
    public float raycastDst = 100f;         // Distance for raycasting
    int layerMask;                          // Layer mask to identify targets in raycasting

    private List<GameObject> previousTargets = new List<GameObject>();  // List to store previously detected targets

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();        // Get the Rigidbody component attached to the player
        SetUpBoundries();                      // Set up the movement boundaries for the player
        currentHealth = maxHealth;             // Initialize the player's health
        layerMask = LayerMask.GetMask("EnemyRaycastLayer");  // Define the layer mask for enemy raycasting
    }

    // Update is called once per frame
    void Update()
    {
        MovePlayer();                          // Move the player based on input
        RotatePlayer();                        // Rotate the player based on its position

        CalculateBoundries();                  // Ensure the player stays within the boundaries

        RaycastForAsteroids();                 // Perform raycasting to detect asteroids
    }

    // Perform raycasting to detect asteroids and update the targets
    private void RaycastForAsteroids()
    {
        List<GameObject> currentTargets = new List<GameObject>();  // List to store currently detected targets

        // Iterate through each missile spawn point
        foreach (Transform missleSpawnPoint in missleSpawnPoints)
        {
            RaycastHit hit;
            Ray ray = new Ray(missleSpawnPoint.position, raycastDirection);  // Create a ray from the missile spawn point
            if (Physics.Raycast(ray, out hit, raycastDst, layerMask))  // Cast the ray and check if it hits an object in the layer mask
            {
                GameObject target = hit.transform.gameObject;  // Get the target (object hit by the ray)
                currentTargets.Add(target);  // Add the target to the list
            }
        }

        bool listsChanged = false;  // Flag to determine if the target list has changed

        // Compare current targets with previous targets to detect changes
        if (currentTargets.Count != previousTargets.Count)
        {
            listsChanged = true;
        }
        else
        {
            for (int i = 0; i < currentTargets.Count; ++i)
            {
                if (currentTargets[i] != previousTargets[i])
                {
                    listsChanged = true;
                }
            }
        }

        if (listsChanged == true)
        {
            // Update asteroids in the AsteroidManager
            AsteroidManager.Instance.UpdateAsteroids(currentTargets);

            // Store the current targets as previous targets for future comparison
            previousTargets = currentTargets;
        }
    }

    // Fire rockets from all missile spawn points
    public void FireRockets()
    {
        if (canFire)
        {
            // Fire rockets from each spawn point
            foreach (Transform t in missleSpawnPoints)
            {
                Instantiate(rocketPrefab, t.position, Quaternion.identity);  // Instantiate a rocket at the spawn point
            }

            canFire = false;  // Prevent firing until reload is complete

            StartCoroutine(ReloadDelay());  // Start the reload coroutine
        }
    }

    // Coroutine to delay the reloading of rockets
    private IEnumerator ReloadDelay()
    {
        // Play reload sound (if implemented)
        yield return new WaitForSeconds(fireInterval);  // Wait for the fire interval before allowing another shot

        canFire = true;  // Allow firing again
    }

    // Rotate the player based on its horizontal position
    private void RotatePlayer()
    {
        float currentX = transform.position.x;  // Get the current x position of the player
        float newRotatinZ;

        // Rotate the player based on whether it's on the left or right side of the screen
        if (currentX < 0)
        {
            newRotatinZ = Mathf.Lerp(0f, -maxRotation, currentX / minX);  // Rotate negatively if on the left
        }
        else
        {
            newRotatinZ = Mathf.Lerp(0f, maxRotation, currentX / maxX);  // Rotate positively if on the right
        }

        // Apply the rotation to the player
        Vector3 currentRotationVector3 = new Vector3(0f, 0f, newRotatinZ);
        Quaternion newRotation = Quaternion.Euler(currentRotationVector3);
        transform.localRotation = newRotation;
    }

    // Ensure the player stays within the boundaries of the game area
    private void CalculateBoundries()
    {
        Vector3 currentPosition = transform.position;

        // Clamp the player's position to stay within the defined boundaries
        currentPosition.x = Mathf.Clamp(currentPosition.x, minX, maxX);
        currentPosition.y = Mathf.Clamp(currentPosition.y, minY, maxY);

        transform.position = currentPosition;  // Apply the clamped position to the player
    }

    // Set up the boundaries based on the camera's viewport and the player's size
    private void SetUpBoundries()
    {
        float camDistance = Vector3.Distance(transform.position, Camera.main.transform.position);  // Get the camera's distance from the player
        Vector2 bottomCorners = Camera.main.ViewportToWorldPoint(new Vector3(0f, 0f, camDistance));  // Get the world position of the bottom-left corner of the camera's viewport
        Vector2 topCorners = Camera.main.ViewportToWorldPoint(new Vector3(1f, 1f, camDistance));  // Get the world position of the top-right corner of the camera's viewport

        // Calculate the size of the player's collider
        Bounds gameObjectBouds = GetComponent<Collider>().bounds;
        float objectWidth = gameObjectBouds.size.x;
        float objectHeight = gameObjectBouds.size.y;

        // Set the boundaries based on the camera's corners and the player's size
        minX = bottomCorners.x + objectWidth;
        maxX = topCorners.x - objectWidth;
        minY = bottomCorners.y + objectHeight;
        maxY = topCorners.y - objectHeight;

        // Set the asteroid manager's boundaries
        AsteroidManager.Instance.maxX = maxX;
        AsteroidManager.Instance.minX = minX;
        AsteroidManager.Instance.minY = minY;
        AsteroidManager.Instance.maxY = maxY;
    }

    // Move the player based on joystick input
    private void MovePlayer()
    {
        float horizontalMovement = input.Horizontal;  // Get the horizontal movement from the joystick
        float verticalMovement = input.Vertical;      // Get the vertical movement from the joystick

        Vector3 movementVector = new Vector3(horizontalMovement, verticalMovement, 0f);  // Create a movement vector based on the input

        rb.velocity = movementVector * moveSpeed;  // Apply the movement to the Rigidbody
    }

    // Called when the player collides with an asteroid
    public void OnAsteroidImpact()
    {
        currentHealth--;  // Decrease the player's health

        // Update the health bar in the in-game manager
        inGameManager.ChangeHealthbar(maxHealth, currentHealth);

        if (currentHealth == 0)  // If the player's health reaches 0
        {
            OnPlayerDeath();  // Call the death method
        }
    }

    // Handle the player's death (e.g., play animation)
    private void OnPlayerDeath()
    {
        // Play death animation or effects here

        Debug.Log("Player Died");  // Output message for player death (can be replaced with actual death logic)
    }
}
