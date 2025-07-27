package com.example.my_app;

import android.app.Notification;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

import com.google.firebase.FirebaseApp;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.HashMap;
import java.util.Map;

public class NotificationListener extends NotificationListenerService {

    private static final String TAG = "NotificationListener";
    private static String currentUserId = null; // Static field to hold the current user ID

    // Method to set the user ID from Flutter
    public static void setUserId(String userId) {
        currentUserId = userId;
        Log.d(TAG, "User ID set to: " + (userId != null ? userId : "null"));
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "NotificationListenerService created.");
        // Ensure Firebase is initialized if it hasn't been already
        if (FirebaseApp.getApps(this).isEmpty()) {
            FirebaseApp.initializeApp(this);
            Log.d(TAG, "FirebaseApp initialized in NotificationListenerService.");
        }
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        Log.d(TAG, "Notification Posted: " + sbn.getPackageName());

        if (currentUserId == null) {
            Log.w(TAG, "No user logged in. Skipping notification sync.");
            return;
        }

        Notification notification = sbn.getNotification();
        if (notification == null) {
            Log.w(TAG, "Notification is null for package: " + sbn.getPackageName());
            return;
        }

        String packageName = sbn.getPackageName();
        String title = notification.extras.getString(Notification.EXTRA_TITLE);
        CharSequence textCs = notification.extras.getCharSequence(Notification.EXTRA_TEXT);
        String text = textCs != null ? textCs.toString() : null;
        long postTime = sbn.getPostTime(); // Timestamp in milliseconds

        Log.d(TAG, "Captured Notification: " +
                "Package: " + packageName +
                ", Title: " + title +
                ", Text: " + text +
                ", Timestamp: " + postTime);

        // Store notification in Firestore
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        Map<String, Object> notificationData = new HashMap<>();
        notificationData.put("packageName", packageName);
        notificationData.put("title", title);
        notificationData.put("text", text);
        notificationData.put("timestamp", new com.google.firebase.Timestamp(new java.util.Date(postTime))); // Convert long to Timestamp

        db.collection("users")
                .document(currentUserId)
                .collection("notifications")
                .add(notificationData)
                .addOnSuccessListener(documentReference -> Log.d(TAG, "Notification added with ID: " + documentReference.getId()))
                .addOnFailureListener(e -> Log.e(TAG, "Error adding notification", e));
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        Log.d(TAG, "Notification Removed: " + sbn.getPackageName());
        // You can add logic here to remove from Firestore if needed
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "NotificationListenerService destroyed.");
    }
}
