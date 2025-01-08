using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AsteroidManager : MonoBehaviour
{
    #region Singleton
    // Singleton instance of the AsteroidManager
    public static AsteroidManager Instance;

    private void Awake()
    {
        // Ensure there is only one instance of AsteroidManager
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this); // Destroy this duplicate instance
        }
    }
    #endregion

    // Array of asteroid prefabs (regular asteroids)
    public GameObject[] asteroidPrefabs;

    // Distance at which the asteroids spawn
    public float asteroidSpawnDistance = 150f;

    // Initial spawn time for asteroids (starts slow)
    public float spawnTime = 3f;
    private float timer = 0f;

    // Reference to the InGameManager
    public InGameManager inGameManager;

    // Range for asteroid positions
    [HideInInspector]
    public float minX, maxX, minY, maxY;

    // List of currently alive asteroids
    [HideInInspector]
    public List<GameObject> aliveAsteroids = new List<GameObject>();

    // Timer to track speed increase
    private float speedIncreaseTimer = 0f;

    // Interval and amount for increasing asteroid speed
    private float speedIncreaseInterval = 50f;
    private float speedIncreaseAmount = 200f;

    // Initial speed of the asteroids
    private float currentSpeed = 1500f;

    // Interval and amount for increasing spawn rate (decreasing spawn time)
    private float spawnRateIncreaseInterval = 120f;
    private float spawnRateIncreaseAmount = 0.02f;

    // Start is called before the first frame update
    void Start()
    {
        timer = spawnTime; // Initialize the timer
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        speedIncreaseTimer += Time.deltaTime;

        // Spawn a new asteroid if enough time has passed
        if (timer >= spawnTime)
        {
            SpawnNewAsteroid();
            timer = 0f; // Reset the timer
        }

        // Increase asteroid speed after a certain interval
        if (speedIncreaseTimer >= speedIncreaseInterval)
        {
            IncreaseAsteroidSpeed();
            speedIncreaseTimer = 0f; // Reset the speed increase timer
        }

        // Increase the spawn rate (reduce the spawn time) periodically
        if (timer >= spawnRateIncreaseInterval)
        {
            IncreaseSpawnRate(); // Increase spawn rate
        }
    }

    // Increases the speed of all alive asteroids
    private void IncreaseAsteroidSpeed()
    {
        currentSpeed += speedIncreaseAmount; // Increase speed
        foreach (var asteroid in aliveAsteroids)
        {
            asteroid.GetComponent<AsteroidController>().SetSpeed(currentSpeed); // Update speed for each asteroid
        }
    }

    // Increases the spawn rate by reducing the spawn time
    private void IncreaseSpawnRate()
    {
        spawnTime -= spawnRateIncreaseAmount; // Decrease the spawn time (increase the spawn rate)
        if (spawnTime < 0.1f)  // Ensure spawn time doesn't go below 0.1 seconds
        {
            spawnTime = 0.1f;
        }
    }

    // Called when an asteroid is destroyed to remove it from the alive list
    public void OnAsteroidKill(GameObject asteroid)
    {
        aliveAsteroids.Remove(asteroid);
    }

    // Spawns a new asteroid at a random position within defined ranges
    private void SpawnNewAsteroid()
    {
        float newX = Random.Range(minX, maxX);
        float newY = Random.Range(minX, maxY);

        Vector3 spawnPos = new Vector3(newX, newY, asteroidSpawnDistance);

        // Instantiate a new asteroid prefab
        GameObject GO = Instantiate(asteroidPrefabs[Random.Range(0, asteroidPrefabs.Length)], spawnPos, Quaternion.identity);

        // Add a Rigidbody component if it doesn't already exist
        Rigidbody rb = GO.GetComponent<Rigidbody>();
        if (rb == null)
        {
            rb = GO.AddComponent<Rigidbody>(); // Add Rigidbody if missing
        }

        // Set gravity settings for the asteroid (optional)
        rb.useGravity = true; // Set true for gravity, or false if gravity is not needed

        // Set the speed for the new asteroid
        GO.GetComponent<AsteroidController>().SetSpeed(currentSpeed);

        // Add the new asteroid to the alive list
        aliveAsteroids.Add(GO);
    }

    // Updates materials for targeted asteroids (used for highlighting)
    public void UpdateAsteroids(List<GameObject> targetedAsteroids)
    {
        foreach (GameObject asteroid in aliveAsteroids)
        {
            if (targetedAsteroids.Contains(asteroid))
            {
                // Set material to red for targeted asteroids
                asteroid.GetComponent<AsteroidController>().SetTargetMaterial();
            }
            else
            {
                // Reset material for non-targeted asteroids
                asteroid.GetComponent<AsteroidController>().ResetMaterial();
            }
        }
    }
}
