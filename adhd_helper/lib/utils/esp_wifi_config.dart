import 'dart:async';

import 'package:esp_smartconfig/esp_smartconfig.dart';

void connectEspToWifi({
  required String ssid,
  required String bssid,
  required String password,
}) async {
  final provisioner = Provisioner.espTouch();

  provisioner.listen((response) {
    print("Device ${response.bssidText} connected to WiFi!");
  });

  try {
    await provisioner.start(ProvisioningRequest.fromStrings(
      ssid: ssid,
      bssid: bssid,
      password: password,
    ));

    // If you are going to use this library in Flutter
    // this is good place to show some Dialog and wait for exit
    //
    // Or simply you can delay with Future.delayed function
    await Future.delayed(const Duration(seconds: 80));
  } catch (e, s) {
    print(e);
  }

// Provisioning does not have any timeout so it needs to be
// stopped manually
  provisioner.stop();

//   const ESPTouchTask task = ESPTouchTask(
//     ssid: 'ICST',
//     bssid: '48:4a:e9:1b:91:66',
//     password: 'arduino123',
//   );
//   final Stream<ESPTouchResult> stream = task.execute();
// //   final printResult = (ESPTouchResult result) {
// //     print('IP: ${result.ip} MAC: ${result.bssid}');
// //   };
// //   StreamSubscription<ESPTouchResult> streamSubscription =
// //       stream.listen(printResult);

// // // Don't forget to cancel your stream subscription.
// // // You might cancel after the UDP wait+send time has passed (default 1 min)
// // // or you could cancel when the user asked to cancel
// // // for example, either via X button, or popping a route off the stack.
// //   streamSubscription.cancel();
}
