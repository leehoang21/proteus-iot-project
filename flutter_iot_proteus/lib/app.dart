import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_proteus/data.dart';
import 'package:flutter_iot_proteus/images.dart';
import 'package:firebase_database/firebase_database.dart';

import 'card_custom.dart';
import 'firebase_options.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final FirebaseDatabase database;
  bool isLoading = true;
  late final FirebaseApp app;
  late final DatabaseReference ref;
  String fan = ImagesContants.fan;
  String led1 = ImagesContants.lampOff;
  String led2 = ImagesContants.lampOff;
  Data data = Data(temp: 0, humi: 0, fan: 0, led1: 0, led2: 0, fanLevel: 0);
  bool autoFan = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    database = FirebaseDatabase.instance;
    isLoading = false;
    ref = database.ref('ROOM01');
    ref.onValue.listen((event) {
      final data0 = event.snapshot.value;
      data = Data(
        temp: int.tryParse((data0 as dynamic)['temp']) ?? 0,
        humi: int.tryParse((data0 as dynamic)['humi']) ?? 0,
        fan: int.tryParse((data0 as dynamic)['fan']) ?? 0,
        led1: int.tryParse((data0 as dynamic)['led01']) ?? 0,
        led2: int.tryParse((data0 as dynamic)['led02']) ?? 0,
        fanLevel: int.tryParse((data0 as dynamic)['fanlevel']) ?? 0,
      );
      autoFan = data.fanLevel == 0 ? false : true;
      if (autoFan) {
        fan = data.fanLevel <= data.temp
            ? ImagesContants.fanGif
            : ImagesContants.fan;
      } else {
        fan = data.fan == 1 ? ImagesContants.fanGif : ImagesContants.fan;
      }
      led1 = data.led1 == 1 ? ImagesContants.lampOn : ImagesContants.lampOff;
      led2 = data.led2 == 1 ? ImagesContants.lampOn : ImagesContants.lampOff;
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    CardCustom(
                      height: 150,
                      width: double.infinity,
                      backgroundColor: Colors.blue[100]!,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'nhiệt độ : ${data.temp}°C',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                              ),
                            ),
                            //độ ẩm
                            Text(
                              'độ ẩm  ${data.humi}%',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CardCustom(
                              backgroundColor: Colors.green[100]!,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    Image.asset(fan),
                                    const Text('Quạt'),
                                    Row(
                                      children: [
                                        Text(
                                          'auto',
                                          style: TextStyle(
                                            color: autoFan
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Switch(
                                          value: autoFan,
                                          onChanged: (value) {
                                            autoFan = value;
                                            if (!autoFan) {
                                              ref.update({
                                                'fanlevel': '0',
                                                'fan': '0'
                                              });
                                              fan = data.fan == 1
                                                  ? ImagesContants.fanGif
                                                  : ImagesContants.fan;
                                            } else {
                                              ref.update({
                                                'fan': '0',
                                              });
                                              fan = data.fanLevel <= data.temp
                                                  ? ImagesContants.fanGif
                                                  : ImagesContants.fan;
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    autoFan
                                        ? TextField(
                                            controller: TextEditingController(),
                                            decoration: const InputDecoration(
                                              hintText: 'Nhập nhiệt độ',
                                            ),
                                            onSubmitted: (value) {
                                              print(value);
                                              try {
                                                ref.update({
                                                  'fanlevel': value,
                                                });
                                              } on Exception catch (e) {
                                                log(e.toString());
                                              }
                                              setState(() {});
                                            },
                                          )
                                        : Row(
                                            children: [
                                              const Text(
                                                'on/off',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Switch(
                                                value: data.fan == 1
                                                    ? true
                                                    : false,
                                                onChanged: (value) {
                                                  try {
                                                    ref.update({
                                                      'fan': value ? '1' : '0',
                                                    });
                                                    fan = value
                                                        ? ImagesContants.fanGif
                                                        : ImagesContants.fan;
                                                  } on Exception catch (e) {
                                                    log(e.toString());
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: CardCustom(
                              backgroundColor: Colors.yellow[100]!,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(led1),
                                    const Text('Đèn 1'),
                                    Switch(
                                      value: data.led1 == 1 ? true : false,
                                      onChanged: (value) {
                                        try {
                                          ref.update({
                                            'led01': value ? '1' : '0',
                                          });
                                          led1 = value
                                              ? ImagesContants.lampOn
                                              : ImagesContants.lampOff;
                                        } on Exception catch (e) {
                                          log(e.toString());
                                        }
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: CardCustom(
                              backgroundColor: Colors.red[100]!,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    kIsWeb
                                        ? const SizedBox()
                                        : const SizedBox(
                                            height: 220,
                                          ),
                                    Image.asset(led2),
                                    const Text('Đèn 2'),
                                    Switch(
                                      value: data.led2 == 1 ? true : false,
                                      onChanged: (value) {
                                        try {
                                          ref.update({
                                            'led02': value ? '1' : '0',
                                          });
                                          led2 = value
                                              ? ImagesContants.lampOn
                                              : ImagesContants.lampOff;
                                        } on Exception catch (e) {
                                          log(e.toString());
                                        }
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
