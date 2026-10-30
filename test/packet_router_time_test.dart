import 'package:meshex/data/packet_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('время отправителя без часов заменяется временем приёма', () {
    const rx = 1792000000;
    expect(senderTime(0, rx), rx);
    expect(senderTime(1793, rx), rx); // секунды с загрузки
    expect(senderTime(1791000000, rx), 1791000000);
  });
}
