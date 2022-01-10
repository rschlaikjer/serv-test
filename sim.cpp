#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <Vtest_top.h>

struct TestData {
  Vtest_top *can;
  VerilatedVcdC *trace;
  uint64_t time_ns = 0;
  void eval() {
    can->eval();
    trace->dump(time_ns++);
  }
  TestData(const char *trace_name) {
    Verilated::traceEverOn(true);
    can = new Vtest_top;
    trace = new VerilatedVcdC();
    can->trace(trace, 99);
    trace->open(trace_name);
  }
  ~TestData() {
    if (can != nullptr) {
      free(can);
    }
    if (trace != nullptr) {
      trace->flush();
      trace->close();
    }
  }
};

int main() {
  TestData td("serv.vcd");

  // Reset for a couple cycles
  td.can->i_reset = 1;
  while (td.time_ns++ < 16) {
    td.can->i_clk = td.can->i_clk ? 0 : 1;
    td.eval();
  }
  td.can->i_reset = 0;

  // Free run for a while
  while (td.time_ns++ < 100'000) {
    td.can->i_clk = td.can->i_clk ? 0 : 1;
    td.eval();
  }
}
