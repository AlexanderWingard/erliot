#include <Console.h>

String data;

void setup() {
  Bridge.begin();
  Console.begin();
  while(!Console);
}

void loop() {
  if (Console.available() > 0) {
    uint16_t packlen = (Console.read() << 8) | Console.read();
    data = "00";
    int i = packlen;
    while(i > 0) {
      if(Console.available()) {
        data.concat((char)Console.read());
        i--;
      }
    }
    data[0] = highByte(packlen);
    data[1] = lowByte(packlen);
    Console.print(data);
    Console.flush();
  }
}
