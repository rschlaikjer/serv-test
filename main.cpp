#include <stdint.h>

void main();

__asm__(".section .init\n"
        "start:\n"
        ".option push\n"
        ".option norelax\n"
        "la gp, __global_pointer$\n"
        ".option pop\n"
        "la x2, _stack\n"
        "call main\n");

int __attribute__((noinline)) other_function(uint32_t a, uint32_t b) {
  *reinterpret_cast<volatile uint32_t *>(0x02'00'00'00) = a & b;
}

void main() {
  while (true) {
    for (int i = 0; i < 32; i++) {
      other_function(*reinterpret_cast<volatile uint32_t *>(0x01'00'00'00),
                     *reinterpret_cast<volatile uint32_t *>(0x01'00'00'04));
    }
  }
}
