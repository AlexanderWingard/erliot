#include <Console.h>

String data;
int point;
uint8_t pins[] = {2, 3, 4, 5, 6, 7, 8, 9 };

void setup() {
  for (int i = 0; i < sizeof(pins); i++) {
    pinMode(pins[i], OUTPUT);
  }
  Bridge.begin();
  Console.begin();
  while (!Console);
}

void loop() {
  if (Console.available() > 0) {
    uint16_t packlen = (Console.read() << 8) | Console.read();
    data = "";
    int i = packlen;
    char count = 0;
    while (i > 0) {
      if (Console.available()) {
        data.concat((char)Console.read());
        i--;
      }
    }

    point = 0;
    if (data[point] == (char)131) {
      if (data[++point] == (char)108) {
        uint32_t listl = read32();
        for (uint32_t i = 0; i < listl; i++) {
          uint8_t pin = 0;
          uint8_t mode = 0;
          if (data[++point] == (char)116) {
            uint32_t mapl = read32();
            for (uint32_t j = 0; j < mapl; j++) {
              String s = "";
              uint8_t p = 0;
              if (data[++point] == (char)109) {
                uint32_t strl = read32();
                for (uint32_t k = 0; k < strl; k++) {
                  s.concat((char)data[++point]);
                }
              }
              if (data[++point] == (char)97) {
                p = (char)data[++point];
              }
              if (s == "pin") {
                pin = p;
              } else if (s == "state") {
                mode = p;
              }
            }
          }
          digitalWrite(pin, mode);
        }
      }
    }
  }
}

uint32_t read32() {
  return data[++point] << 24 | data[++point] << 16 | data[++point] << 8 | data[++point];
}

