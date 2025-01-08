using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.IO;
using System.Xml.Serialization;
/// <summary>
/// The SaveManager class handles saving, loading, and updating the game state.
/// It manages player data such as  levels completed, and spaceships.
/// </summary>
public class SaveManager : MonoBehaviour
{
    /// <summary>
    /// A static instance of the SaveManager class to ensure only one instance exists (Singleton pattern).
    /// </summary>
    public static SaveManager Instance;

    /// <summary>
    /// This method is called when the object is initialized.
    /// It ensures that only one instance of SaveManager exists and loads the saved game data.
    /// </summary>
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            Load();
            //ResetValues();
        }
    }

    /// <summary>
    /// A private instance of SaveClass that holds the player's saved data.
    /// </summary>
    private SaveClass saveClass;

    /// <summary>
    /// This method resets the player's data to default values.
    /// </summary>
    private void ResetValues()
    {
        
        saveClass.levelsCompleted = -1;
        saveClass.ownedSpacesips = new int[] { 1, 0, 0, 0, 0, 0, 0, 0, 0 };
        Save();
    }

    /// <summary>
    /// Checks if the player has purchased the spaceship at the given index.
    /// </summary>
    /// <param name="idx">The index of the spaceship to check.</param>
    /// <returns>True if the spaceship is owned, otherwise false.</returns>
    public bool IsSpaceshipowned(int idx)
    {
        if (saveClass.ownedSpacesips[idx] == 1)
        {
            return true;
        }
        else
        {
            return false;
        }

        //return saveClass.ownedSpacesips[idx] == 1;
    }

    /// <summary>
    /// Purchases the spaceship at the given index by marking it as owned.
    /// </summary>
    /// <param name="idx">The index of the spaceship to purchase.</param>
    public void PurchaseSpaceship(int idx)
    {
        saveClass.ownedSpacesips[idx] = 1;
        Save();
    }



    /// <summary>
    /// Increments the number of completed levels by 1 and saves the updated data.
    /// </summary>
    public void CompletedNextLevel()
    {
        saveClass.levelsCompleted++;
        Save();
    }

    /// <summary>
    /// Gets the total number of completed levels.
    /// </summary>
    /// <returns>The number of levels completed.</returns>
    public int GetLevelsCompleted()
    {
        return saveClass.levelsCompleted;
    }





    /// <summary>
    /// Saves the current game data to PlayerPrefs.
    /// </summary>
    public void Save()
    {
        string serializedObject = Serialize(saveClass);
        PlayerPrefs.SetString("saveFile", serializedObject);
    }

    /// <summary>
    /// Loads the saved game data from PlayerPrefs.
    /// If no data exists, it creates a new save file with default values.
    /// </summary>
    private void Load()
    {
        if (PlayerPrefs.HasKey("saveFile"))
        {
            // Load and deserialize the saved data
            saveClass = Deserialize(PlayerPrefs.GetString("saveFile"));
        }
        else
        {
            // Create a new save file if none exists
            Debug.Log("Creating new file");
            saveClass = new SaveClass();
            Save();
        }
    }

    /// <summary>
    /// Serializes a SaveClass object to an XML string.
    /// </summary>
    /// <param name="toBeSerialized">The SaveClass object to serialize.</param>
    /// <returns>The XML string representation of the SaveClass object.</returns>
    private string Serialize(SaveClass toBeSerialized)
    {
        XmlSerializer xml = new XmlSerializer(typeof(SaveClass));
        StringWriter writer = new StringWriter();
        xml.Serialize(writer, toBeSerialized);
        return writer.ToString();
    }

    /// <summary>
    /// Deserializes an XML string to a SaveClass object.
    /// </summary>
    /// <param name="xmlSerialized">The XML string to deserialize.</param>
    /// <returns>The deserialized SaveClass object.</returns>
    private SaveClass Deserialize(string xmlSerialized)
    {
        XmlSerializer xml = new XmlSerializer(typeof(SaveClass));
        StringReader reader = new StringReader(xmlSerialized);
        return xml.Deserialize(reader) as SaveClass;
    }
}