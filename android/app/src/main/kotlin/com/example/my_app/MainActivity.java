package com.example.my_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Intent;
import android.provider.Settings;
import android.text.TextUtils;
import android.content.ComponentName;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.my_app/notification_sync";
    private static final String TAG = "MainActivity";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("setUserId")) {
                                String userId = call.argument("userId");
                                NotificationListener.setUserId(userId);
                                result.success(null);
                            } else if (call.method.equals("openNotificationSettings")) {
                                openNotificationAccessSettings();
                                result.success(null);
                            } else if (call.method.equals("isNotificationServiceEnabled")) {
                                result.success(isNotificationServiceEnabled());
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void openNotificationAccessSettings() {
        Intent intent = new Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS);
        startActivity(intent);
    }

    private boolean isNotificationServiceEnabled() {
        String pkgName = getPackageName();
        final String flat = Settings.Secure.getString(getContentResolver(),
                "enabled_notification_listeners");
        if (!TextUtils.isEmpty(flat)) {
            final String[] names = flat.split(":");
            for (int i = 0; i < names.length; i++) {
                final ComponentName cn = ComponentName.unflattenFromString(names[i]);
                if (cn != null && TextUtils.equals(pkgName, cn.getPackageName())) {
                    return true;
                }
            }
        }
        return false;
    }
}
