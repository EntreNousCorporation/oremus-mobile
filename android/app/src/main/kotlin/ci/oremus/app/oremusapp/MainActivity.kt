package ci.oremus.app.oremusapp

import android.view.WindowManager.LayoutParams
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        //window.addFlags(LayoutParams.FLAG_SECURE); //Empêche la capture d'écran dans l'app
        //AudioServicePlugin.setup(this, flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flavor").setMethodCallHandler {
                call, result -> result.success(BuildConfig.FLAVOR)
        }
    }
}
