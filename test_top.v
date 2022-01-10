`default_nettype none
`define EXTEND(width, value) {{width-$bits(value){1'b0}}, value}

module test_top (
    input wire i_clk,
    input wire i_reset
);

wire [31:0] serv_ibus_adr;
wire [ 0:0] serv_ibus_cyc;
reg  [31:0] serv_ibus_rdt;
reg [ 0:0] serv_ibus_ack;

wire [31:0] serv_dbus_adr;
wire [31:0] serv_dbus_dat;
wire [ 3:0] serv_dbus_sel;
wire [ 0:0] serv_dbus_we;
wire [ 0:0] serv_dbus_cyc;
reg  [31:0] serv_dbus_rdt;
reg  [ 0:0] serv_dbus_ack;

`ifdef RISCV_FORMAL
wire serv_rvfi_valid;
wire [63:0] serv_rvfi_order;
wire [31:0] serv_rvfi_insn;
wire        serv_rvfi_trap;
wire        serv_rvfi_halt;
wire        serv_rvfi_intr;
wire [1:0]  serv_rvfi_mode;
wire [1:0]  serv_rvfi_ixl;
wire [4:0]  serv_rvfi_rs1_addr;
wire [4:0]  serv_rvfi_rs2_addr;
wire [31:0] serv_rvfi_rs1_rdata;
wire [31:0] serv_rvfi_rs2_rdata;
wire [4:0]  serv_rvfi_rd_addr;
wire [31:0] serv_rvfi_rd_wdata;
wire [31:0] serv_rvfi_pc_rdata;
wire [31:0] serv_rvfi_pc_wdata;
wire [31:0] serv_rvfi_mem_addr;
wire [3:0]  serv_rvfi_mem_rmask;
wire [3:0]  serv_rvfi_mem_wmask;
wire [31:0] serv_rvfi_mem_rdata;
wire [31:0] serv_rvfi_mem_wdata;

reg  [63:0] r_rvfi_order;
reg  [31:0] r_rvfi_insn;
reg         r_rvfi_trap;
reg         r_rvfi_halt;
reg         r_rvfi_intr;
reg  [1:0]  r_rvfi_mode;
reg  [1:0]  r_rvfi_ixl;
reg  [4:0]  r_rvfi_rs1_addr;
reg  [4:0]  r_rvfi_rs2_addr;
reg  [31:0] r_rvfi_rs1_rdata;
reg  [31:0] r_rvfi_rs2_rdata;
reg  [4:0]  r_rvfi_rd_addr;
reg  [31:0] r_rvfi_rd_wdata;
reg  [31:0] r_rvfi_pc_rdata;
reg  [31:0] r_rvfi_pc_wdata;
reg  [31:0] r_rvfi_mem_addr;
reg  [3:0]  r_rvfi_mem_rmask;
reg  [3:0]  r_rvfi_mem_wmask;
reg  [31:0] r_rvfi_mem_rdata;
reg  [31:0] r_rvfi_mem_wdata;

always @(posedge i_clk) begin
    if (serv_rvfi_valid) begin
        r_rvfi_order        <= serv_rvfi_order;
        r_rvfi_insn         <= serv_rvfi_insn;
        r_rvfi_trap         <= serv_rvfi_trap;
        r_rvfi_halt         <= serv_rvfi_halt;
        r_rvfi_intr         <= serv_rvfi_intr;
        r_rvfi_mode         <= serv_rvfi_mode;
        r_rvfi_ixl          <= serv_rvfi_ixl;
        r_rvfi_rs1_addr     <= serv_rvfi_rs1_addr;
        r_rvfi_rs2_addr     <= serv_rvfi_rs2_addr;
        r_rvfi_rs1_rdata    <= serv_rvfi_rs1_rdata;
        r_rvfi_rs2_rdata    <= serv_rvfi_rs2_rdata;
        r_rvfi_rd_addr      <= serv_rvfi_rd_addr;
        r_rvfi_rd_wdata     <= serv_rvfi_rd_wdata;
        r_rvfi_pc_rdata     <= serv_rvfi_pc_rdata;
        r_rvfi_pc_wdata     <= serv_rvfi_pc_wdata;
        r_rvfi_mem_addr     <= serv_rvfi_mem_addr;
        r_rvfi_mem_rmask    <= serv_rvfi_mem_rmask;
        r_rvfi_mem_wmask    <= serv_rvfi_mem_wmask;
        r_rvfi_mem_rdata    <= serv_rvfi_mem_rdata;
        r_rvfi_mem_wdata    <= serv_rvfi_mem_wdata;
    end
end
`endif

serv_rf_top #(
    .RESET_PC(32'h01_00_00_00),
    .MDU(0), // No mul/div
    .RESET_STRATEGY("MINI"),
    .WITH_CSR(0)
) serv_core (
   .clk         (i_clk),
   .i_rst       (i_reset),
   .i_timer_irq (1'b0),

   .o_ibus_adr  (serv_ibus_adr),
   .o_ibus_cyc  (serv_ibus_cyc),
   .i_ibus_rdt  (serv_ibus_rdt),
   .i_ibus_ack  (serv_ibus_ack),

   .o_dbus_adr  (serv_dbus_adr),
   .o_dbus_dat  (serv_dbus_dat),
   .o_dbus_sel  (serv_dbus_sel),
   .o_dbus_we   (serv_dbus_we ),
   .o_dbus_cyc  (serv_dbus_cyc),
   .i_dbus_rdt  (serv_dbus_rdt),
   .i_dbus_ack  (serv_dbus_ack),

   // Extension
   .o_ext_rs1       (),
   .o_ext_rs2       (),
   .o_ext_funct3    (),
   .i_ext_rd        (32'd0),
   .i_ext_ready     (1'd0),

   // Formal
`ifdef RISCV_FORMAL
    .rvfi_valid     (serv_rvfi_valid    ),
    .rvfi_order     (serv_rvfi_order    ),
    .rvfi_insn      (serv_rvfi_insn     ),
    .rvfi_trap      (serv_rvfi_trap     ),
    .rvfi_halt      (serv_rvfi_halt     ),
    .rvfi_intr      (serv_rvfi_intr     ),
    .rvfi_mode      (serv_rvfi_mode     ),
    .rvfi_ixl       (serv_rvfi_ixl      ),
    .rvfi_rs1_addr  (serv_rvfi_rs1_addr ),
    .rvfi_rs2_addr  (serv_rvfi_rs2_addr ),
    .rvfi_rs1_rdata (serv_rvfi_rs1_rdata),
    .rvfi_rs2_rdata (serv_rvfi_rs2_rdata),
    .rvfi_rd_addr   (serv_rvfi_rd_addr  ),
    .rvfi_rd_wdata  (serv_rvfi_rd_wdata ),
    .rvfi_pc_rdata  (serv_rvfi_pc_rdata ),
    .rvfi_pc_wdata  (serv_rvfi_pc_wdata ),
    .rvfi_mem_addr  (serv_rvfi_mem_addr ),
    .rvfi_mem_rmask (serv_rvfi_mem_rmask),
    .rvfi_mem_wmask (serv_rvfi_mem_wmask),
    .rvfi_mem_rdata (serv_rvfi_mem_rdata),
    .rvfi_mem_wdata (serv_rvfi_mem_wdata),
   `endif

   // MDU (unused)
   .o_mdu_valid()
);

// Combined ROM/RAM for the SERV core
reg [31:0] serv_rom [512];
parameter SERV_ROM_HEX = "serv_test.hex";
initial $readmemh(SERV_ROM_HEX, serv_rom);
always @(posedge i_clk) begin
end

// Handle bus accesses
integer i;
always @(posedge i_clk) begin
    // Serv IBus
    serv_ibus_ack <= 0;
    if (serv_ibus_cyc) begin
        serv_ibus_rdt <= serv_rom[serv_ibus_adr[$clog2(512)-1+2:2]];
        serv_ibus_ack <= 1;
    end

    // Serv DBus
    serv_dbus_ack <= 1'b0;
    if (serv_dbus_cyc) begin
        serv_dbus_ack <= 1'b1;

        // Handle reads
        case (serv_dbus_adr[31:24])
            // General system mem
            8'h01: serv_dbus_rdt <= serv_rom[serv_dbus_adr[$clog2(512)-1+2:2]];

            /* other mapped regions... */
            8'h02: ;

            // Stall the CPU on invalid read
            default: serv_dbus_ack <= 1'b0; // Unmapped, force ack low.
        endcase

        // Writes
        if (serv_dbus_we) begin
            case (serv_dbus_adr[31:24])
                // System mem
                8'h01: begin
                    for (i = 0; i < 4; i++)
                        if (serv_dbus_sel[i])
                            serv_rom[serv_dbus_adr[$clog2(512)-1+2:2]][i*8 +: 8] <= serv_dbus_dat[i*8 +: 8];
                end

                /* other mapped regions... */
                8'h02: ;

                // Stall the CPU on invalid write
                default: serv_dbus_ack <= 1'b0; // Unmapped, force ack low.
            endcase
        end
    end
end

endmodule
`undef EXTEND
