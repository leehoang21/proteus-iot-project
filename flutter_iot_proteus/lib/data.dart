class Data {
  final int temp;
  final int humi;
  final int fan;
  final int led1;
  final int led2;
  final int fanLevel;

  Data({
    required this.temp,
    required this.humi,
    required this.fan,
    required this.led1,
    required this.led2,
    required this.fanLevel,
  });

  @override
  String toString() {
    return 'Data{temp: $temp, humi: $humi, fan: $fan, led1: $led1, led2: $led2}';
  }
}
