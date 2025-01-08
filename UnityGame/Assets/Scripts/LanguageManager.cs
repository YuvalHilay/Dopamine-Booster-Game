using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// The LanguageManager class is responsible for managing and storing the selected language for the application.
/// It holds a static string representing the currently selected language, which can be used throughout the application
/// to adjust language settings, such as translating text or adjusting UI elements to the desired language.
/// </summary>
public static class LanguageManager
{
    /// <summary>
    /// The SelectedLanguage variable holds the currently selected language. The default language is set to "English".
    /// This value can be changed dynamically depending on the user's choice or system settings.
    /// </summary>
    public static string SelectedLanguage = "English"; // Default language
}
