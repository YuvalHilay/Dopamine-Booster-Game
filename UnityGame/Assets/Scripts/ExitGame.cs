using UnityEngine;

public class ExitGame : MonoBehaviour
{
    // זמן המתנה לפני יציאה מהמשחק (במילישניות)
    public float exitTime = 400f;

    void Start()
    {
        // מתחיל את הספירה לאחור עם הזמן שהגדרת
        Invoke("Exit", exitTime);
    }

    void Exit()
    {
        // סוגר את המשחק
        Application.Quit();

        // אם אתה עובד על Unity Editor, להפסיק את המשחק גם בתוך העורך
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }
}
