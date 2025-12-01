interface axi_intf #(
    parameter int ID_WIDTH = 4  // Master interfaces use 4 bits, slave interfaces use 8 bits
)(input logic clk, input logic rst_n);
    // Write Address Channel
    logic                  awvalid;
    logic                  awready;
    logic [ID_WIDTH-1:0]   awid;      // 4 bits for master, 8 bits for slave
    logic [31:0]           awaddr;
    logic [7:0]            awlen;      // Burst length
    logic [2:0]            awsize;     // Burst size
    logic [1:0]            awburst;    // Burst type

    // Write Data Channel
    logic        wvalid;
    logic        wready;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wlast;

    // Write Response Channel
    logic                  bvalid;
    logic                  bready;
    logic [ID_WIDTH-1:0]   bid;        // 4 bits for master, 8 bits for slave
    logic [1:0]            bresp;

    // Read Address Channel
    logic                  arvalid;
    logic                  arready;
    logic [ID_WIDTH-1:0]   arid;       // 4 bits for master, 8 bits for slave
    logic [31:0]           araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;

    // Read Data Channel
    logic                  rvalid;
    logic                  rready;
    logic [31:0]           rdata;
    logic [1:0]            rresp;
    logic [ID_WIDTH-1:0]   rid;        // 4 bits for master, 8 bits for slave
    logic                  rlast;

    task reset_signals();
        awvalid=0; awready=0; awid=0; awaddr=0; awlen=0; awsize=0; awburst=0;
        wvalid=0; wready=0; wdata=0; wstrb=0; wlast=0;
        bvalid=0; bready=0; bid=0; bresp=0;
        arvalid=0; arready=0; arid=0; araddr=0; arlen=0; arsize=0; arburst=0;
        rvalid=0; rready=0; rdata=0; rresp=0; rid=0; rlast=0;
    endtask
endinterface

