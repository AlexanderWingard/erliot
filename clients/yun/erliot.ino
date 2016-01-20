#include <Console.h>

bool toggle = false;
char incomingByte;
uint16_t packlen = 1024;

void setup() {
  pinMode(4, OUTPUT);
  Bridge.begin();
  Console.begin();
  while(!Console);
}

void loop() {
  if (Console.available() > 0) {
    (Console.read() >> 8) | (Console.read() << 8);
    Console.write(highByte(packlen));
    Console.write(lowByte(packlen));
  }
}
