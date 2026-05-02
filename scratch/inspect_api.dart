import 'package:reflectable/reflectable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.reflectable.dart'; // Import generated code

// Define a reflector with the capabilities you need
class Reflector extends Reflectable {
  const Reflector() : super(invokingCapability, declarationsCapability);
}

// Create a const instance of the reflector
const reflector = Reflector();

// Annotate the class you want to reflect on
@reflector
class ReflectablePlugin extends FlutterLocalNotificationsPlugin {}

void main() {
  initializeReflectable(); // Initialize reflection support

  var plugin = ReflectablePlugin();
  var instanceMirror = reflector.reflect(plugin);
  var classMirror = instanceMirror.type;

  print('Methods of FlutterLocalNotificationsPlugin:');
  classMirror.declarations.forEach((key, value) {
    if (value is MethodMirror) {
      print('${MirrorSystem.getName(key)}: ${value.parameters.length} parameters');
      for (var param in value.parameters) {
        print('  - ${MirrorSystem.getName(param.simpleName)} (isOptional: ${param.isOptional}, isNamed: ${param.isNamed})');
      }
    }
  });
}   