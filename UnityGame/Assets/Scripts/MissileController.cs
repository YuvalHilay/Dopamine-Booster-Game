using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MissileController : MonoBehaviour
{
    // Speed at which the missile will move
    public float moveSpeed = 3000f;

    // Rigidbody component attached to the missile
    private Rigidbody rb;

    // Start is called before the first frame update
    void Start()
    {
        // Initialize the Rigidbody component
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        // If the missile has passed the asteroid spawn distance, destroy it
        if (transform.position.z > AsteroidManager.Instance.asteroidSpawnDistance)
        {
            Destroy(gameObject);
        }

        // Move the missile in the z direction at the specified speed
        rb.velocity = new Vector3(0f, 0f, moveSpeed * Time.deltaTime);
    }

    // Called when the missile collides with another collider
    private void OnTriggerEnter(Collider other)
    {
        // If the missile collides with an asteroid
        if (other.CompareTag("Asteroid"))
        {
            // Call the DestroyAsteroid method on the asteroid controller to destroy the asteroid
            other.gameObject.GetComponent<AsteroidController>().DestroyAsteroid();

            // Destroy the missile after impact
            Destroy(gameObject);
        }
    }
}
