// ===================== Extended Testbench with Comprehensive Tests =====================
module tb;
    logic clk, rst_n;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        #25 rst_n = 1;
    end

    axi_intf #(.ID_WIDTH(4)) m_if0(clk, rst_n);
    axi_intf #(.ID_WIDTH(4)) m_if1(clk, rst_n);
    axi_intf #(.ID_WIDTH(4)) m_if2(clk, rst_n);
    axi_intf #(.ID_WIDTH(4)) m_if3(clk, rst_n);

    axi_intf #(.ID_WIDTH(8)) s_if0(clk, rst_n);
    axi_intf #(.ID_WIDTH(8)) s_if1(clk, rst_n);
    axi_intf #(.ID_WIDTH(8)) s_if2(clk, rst_n);
    axi_intf #(.ID_WIDTH(8)) s_if3(clk, rst_n);

    logic [7:0] awid_s0, awid_s1, awid_s2, awid_s3;
    logic [7:0] arid_s0, arid_s1, arid_s2, arid_s3;

    always @(posedge clk) begin
        if(s_if0.awvalid && s_if0.awready) awid_s0 <= s_if0.awid;
        if(s_if1.awvalid && s_if1.awready) awid_s1 <= s_if1.awid;
        if(s_if2.awvalid && s_if2.awready) awid_s2 <= s_if2.awid;
        if(s_if3.awvalid && s_if3.awready) awid_s3 <= s_if3.awid;
        
        if(s_if0.arvalid && s_if0.arready) arid_s0 <= s_if0.arid;
        if(s_if1.arvalid && s_if1.arready) arid_s1 <= s_if1.arid;
        if(s_if2.arvalid && s_if2.arready) arid_s2 <= s_if2.arid;
        if(s_if3.arvalid && s_if3.arready) arid_s3 <= s_if3.arid;
    end

    axi_interconnect intercon;
    initial begin 
        m_if0.reset_signals(); m_if1.reset_signals(); 
        m_if2.reset_signals(); m_if3.reset_signals();
        s_if0.reset_signals(); s_if1.reset_signals(); 
        s_if2.reset_signals(); s_if3.reset_signals();

        intercon = new(m_if0, m_if1, m_if2, m_if3,
                      s_if0, s_if1, s_if2, s_if3);
    
        fork
            intercon.start();
        join_none
    end

    // Test counter
    int test_count = 0;
    int pass_count = 0;

    initial begin
        $display("T=%0t: Before Test Start", $time);

        @(posedge rst_n);
        repeat(5) @(posedge clk);
      	
        $display("T=%0t: Test Start", $time);
		
        // ===== Test Case 1: Single Write Transaction =====
        test_count++;
        fork
            begin
                $display("\n[TEST 1] T=%0t: Master 0 writes to Slave 1 (addr=0x10000000)", test_count, $time);
                
                s_if1.awready = 1'b1;
                
                @(posedge clk);
                m_if0.awaddr  <= 32'h1000_0000;
                m_if0.awid    <= 4'd1;
                m_if0.awlen   <= 8'd0;
                m_if0.awsize  <= 3'd2;
                m_if0.awburst <= 2'b01;
                m_if0.awvalid <= 1'b1;
                $display("[%1t ] here before m0 awready", $time);
                $monitor("monitor m_if0.awready: %1d", m_if0.awready);
                wait(m_if0.awready);
                
                $display("here after m0 awready");
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                s_if1.awready = 1'b0;
                
                s_if1.wready = 1'b1;
                
                @(posedge clk);
                m_if0.wdata  <= 32'hDEADBEEF;
                m_if0.wstrb  <= 4'hF;
                m_if0.wlast  <= 1'b1;
                m_if0.wvalid <= 1'b1;
                
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                s_if1.wready = 1'b0;

                // B response
                m_if0.bready = 1'b1;
                
                @(posedge clk);  
                s_if1.bid    <= awid_s1;
                s_if1.bresp  <= 2'b00;
                s_if1.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                $display("[TEST %0d] T=%0t: PASSED - Write transaction completed", test_count, $time);
                pass_count++;
                
                @(posedge clk);
                s_if1.bvalid <= 1'b0;
                m_if0.bready = 1'b0;
            end
            
            begin
                repeat(200) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);

        // ===== Test Case 2: Single Read Transaction =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 reads from Slave 1 (addr=0x10000000)", test_count, $time);
                
                s_if1.arready = 1'b1;
                
                @(posedge clk);
                m_if0.araddr  <= 32'h1000_0000;
                m_if0.arid    <= 4'd2;
                m_if0.arlen   <= 8'd0;
                m_if0.arsize  <= 3'd2;
                m_if0.arburst <= 2'b01;
                m_if0.arvalid <= 1'b1;
                
                wait(m_if0.arready);
                @(posedge clk);
                m_if0.arvalid <= 1'b0;
                s_if1.arready = 1'b0;
                
                // R response
                m_if0.rready = 1'b1;
                
                @(posedge clk);
                s_if1.rid    <= arid_s1;
                s_if1.rdata  <= 32'hCAFEBABE;
                s_if1.rresp  <= 2'b00;
                s_if1.rlast  <= 1'b1;
                s_if1.rvalid <= 1'b1;
                
                wait(m_if0.rvalid);
                $display("[TEST %0d] T=%0t: PASSED - Read transaction completed, data=0x%h", test_count, $time, m_if0.rdata);
                pass_count++;
                
                @(posedge clk);
                s_if1.rvalid <= 1'b0;
                m_if0.rready = 1'b0;
            end
            
            begin
                repeat(200) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);
	
        // ===== Test Case 3: Write to Different Slaves =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 writes to all 4 slaves", test_count, $time);
                
                // Write to Slave 0
                s_if0.awready = 1'b1;
                s_if0.wready = 1'b1;
                
                @(posedge clk);
                m_if0.awaddr  <= 32'h0000_0000;
                m_if0.awid    <= 4'd3;
                m_if0.awlen   <= 8'd0;
                m_if0.awsize  <= 3'd2;
                m_if0.awburst <= 2'b01;
                m_if0.awvalid <= 1'b1;
                
                wait(m_if0.awready);
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                
                m_if0.wdata  <= 32'h0000_0000;
                m_if0.wstrb  <= 4'hF;
                m_if0.wlast  <= 1'b1;
                m_if0.wvalid <= 1'b1;
                
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                
                m_if0.bready = 1'b1;
                s_if0.bid    <= awid_s0;
                s_if0.bresp  <= 2'b00;
                s_if0.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                @(posedge clk);
                s_if0.bvalid <= 1'b0;
                s_if0.awready = 1'b0;
                s_if0.wready = 1'b0;
                
                repeat(3) @(posedge clk);
                
                // Write to Slave 2
                s_if2.awready = 1'b1;
                s_if2.wready = 1'b1;
                
                @(posedge clk);
                m_if0.awaddr  <= 32'h2000_0000;
                m_if0.awid    <= 4'd4;
                m_if0.awvalid <= 1'b1;
                
                wait(m_if0.awready);
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                
                m_if0.wdata  <= 32'h2222_2222;
                m_if0.wvalid <= 1'b1;
                
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                
                s_if2.bid    <= awid_s2;
                s_if2.bresp  <= 2'b00;
                s_if2.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                @(posedge clk);
                s_if2.bvalid <= 1'b0;
                m_if0.bready = 1'b0;
                s_if2.awready = 1'b0;
                s_if2.wready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Write to multiple slaves completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(400) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);
        
		
        // ===== Test Case 4: Multiple Masters to Same Slave (Arbitration) =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Masters 0 and 1 both write to Slave 1 (Arbitration test)", test_count, $time);
                
                s_if1.awready = 1'b1;
                s_if1.wready = 1'b1;
                
                fork
                    // Master 0 transaction
                    begin
                        @(posedge clk);
                        m_if0.awaddr  <= 32'h1000_0010;
                        m_if0.awid    <= 4'd5;
                        m_if0.awlen   <= 8'd0;
                        m_if0.awsize  <= 3'd2;
                        m_if0.awburst <= 2'b01;
                        m_if0.awvalid <= 1'b1;
                        
                        wait(m_if0.awready);
                        @(posedge clk);
                        m_if0.awvalid <= 1'b0;
                        
                        @(posedge clk);
                        m_if0.wdata  <= 32'hAAAAAAAA;
                        m_if0.wstrb  <= 4'hF;
                        m_if0.wlast  <= 1'b1;
                        m_if0.wvalid <= 1'b1;
                        
                        wait(m_if0.wready);
                        @(posedge clk);
                        m_if0.wvalid <= 1'b0;
                        
                        m_if0.bready = 1'b1;
                        wait(m_if0.bvalid);
                        @(posedge clk);
                        m_if0.bready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 0 transaction completed", test_count, $time);
                    end
                    
                    // Master 1 transaction
                    begin
                        @(posedge clk);
                        m_if1.awaddr  <= 32'h1000_0020;
                        m_if1.awid    <= 4'd6;
                        m_if1.awlen   <= 8'd0;
                        m_if1.awsize  <= 3'd2;
                        m_if1.awburst <= 2'b01;
                        m_if1.awvalid <= 1'b1;
                        
                        wait(m_if1.awready);
                        @(posedge clk);
                        m_if1.awvalid <= 1'b0;
                        
                        @(posedge clk);
                        m_if1.wdata  <= 32'hBBBBBBBB;
                        m_if1.wstrb  <= 4'hF;
                        m_if1.wlast  <= 1'b1;
                        m_if1.wvalid <= 1'b1;
                        
                        wait(m_if1.wready);
                        @(posedge clk);
                        m_if1.wvalid <= 1'b0;
                        
                        m_if1.bready = 1'b1;
                        wait(m_if1.bvalid);
                        @(posedge clk);
                        m_if1.bready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 1 transaction completed", test_count, $time);
                    end
                    
                    // Slave response handler
                    begin
                        logic [7:0] saved_awid1, saved_awid2;
                        
                        // Capture both AWIDs in parallel
                        fork
                            begin
                                @(posedge clk iff (s_if1.awvalid && s_if1.awready));
                                saved_awid1 = s_if1.awid;
                                $display("[TEST %0d] T=%0t: Slave captured first AWID=%h", test_count, $time, saved_awid1);
                            end
                            begin
                                // Wait for first AW to pass
                                @(posedge clk iff (s_if1.awvalid && s_if1.awready));
                                // Wait for second AW
                                @(posedge clk iff (s_if1.awvalid && s_if1.awready));
                                saved_awid2 = s_if1.awid;
                                $display("[TEST %0d] T=%0t: Slave captured second AWID=%h", test_count, $time, saved_awid2);
                            end
                        join
                        
                        // Now process W and B channels sequentially for each transaction
                        
                        // First transaction: wait for W, send B
                        @(posedge clk iff (s_if1.wvalid && s_if1.wready && s_if1.wlast));
                        @(posedge clk);
                        @(posedge clk);
                        s_if1.bid    <= saved_awid1;
                        s_if1.bresp  <= 2'b00;
                        s_if1.bvalid <= 1'b1;
                        $display("[TEST %0d] T=%0t: Slave sending B response with BID=%h", test_count, $time, saved_awid1);
                        @(posedge clk iff (s_if1.bready && s_if1.bvalid));
                        @(posedge clk);
                        s_if1.bvalid <= 1'b0;
                        
                        // Second transaction: wait for W, send B
                        @(posedge clk iff (s_if1.wvalid && s_if1.wready && s_if1.wlast));
                        @(posedge clk);
                        @(posedge clk);
                        s_if1.bid    <= saved_awid2;
                        s_if1.bresp  <= 2'b00;
                        s_if1.bvalid <= 1'b1;
                        $display("[TEST %0d] T=%0t: Slave sending B response with BID=%h", test_count, $time, saved_awid2);
                        @(posedge clk iff (s_if1.bready && s_if1.bvalid));
                        @(posedge clk);
                        s_if1.bvalid <= 1'b0;
                    end
                join
                
                s_if1.awready = 1'b0;
                s_if1.wready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Arbitration test completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(500) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end

        join_any
        disable fork;

        repeat(5) @(posedge clk);

        // ===== Test Case 5: Burst Write Transaction =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 burst write to Slave 1 (4 beats)", test_count, $time);
                
                s_if1.awready = 1'b1;
                s_if1.wready = 1'b1;
                
                @(posedge clk);
                m_if0.awaddr  <= 32'h1000_0100;
                m_if0.awid    <= 4'd7;
                m_if0.awlen   <= 8'd3;  // 4 beats
                m_if0.awsize  <= 3'd2;
                m_if0.awburst <= 2'b01;
                m_if0.awvalid <= 1'b1;
                
                wait(m_if0.awready);
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                s_if1.awready = 1'b0;
                
                // Beat 1
                m_if0.wdata  <= 32'h0000_0001;
                m_if0.wstrb  <= 4'hF;
                m_if0.wlast  <= 1'b0;
                m_if0.wvalid <= 1'b1;
                wait(m_if0.wready);
                @(posedge clk);
                
                // Beat 2
                m_if0.wdata  <= 32'h0000_0002;
                wait(m_if0.wready);
                @(posedge clk);
                
                // Beat 3
                m_if0.wdata  <= 32'h0000_0003;
                wait(m_if0.wready);
                @(posedge clk);
                
                // Beat 4 (last)
                m_if0.wdata  <= 32'h0000_0004;
                m_if0.wlast  <= 1'b1;
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                s_if1.wready = 1'b0;
                
                // B response
                m_if0.bready = 1'b1;
                @(posedge clk);
                s_if1.bid    <= awid_s1;
                s_if1.bresp  <= 2'b00;
                s_if1.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                @(posedge clk);
                s_if1.bvalid <= 1'b0;
                m_if0.bready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Burst write completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(300) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);

        // ===== Test Case 6: Burst Read Transaction =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 burst read from Slave 1 (4 beats)", test_count, $time);
                
                s_if1.arready = 1'b1;
                
                @(posedge clk);
                m_if0.araddr  <= 32'h1000_0100;
                m_if0.arid    <= 4'd8;
                m_if0.arlen   <= 8'd3;  // 4 beats
                m_if0.arsize  <= 3'd2;
                m_if0.arburst <= 2'b01;
                m_if0.arvalid <= 1'b1;
                
                wait(m_if0.arready);
                @(posedge clk);
                m_if0.arvalid <= 1'b0;
                s_if1.arready = 1'b0;
                
                m_if0.rready = 1'b1;
                
                // Beat 1
                @(posedge clk);
                s_if1.rid    <= arid_s1;
                s_if1.rdata  <= 32'h1111_1111;
                s_if1.rresp  <= 2'b00;
                s_if1.rlast  <= 1'b0;
                s_if1.rvalid <= 1'b1;
                wait(s_if1.rready);
                @(posedge clk);
                
                // Beat 2
                s_if1.rdata  <= 32'h2222_2222;
                wait(s_if1.rready);
                @(posedge clk);
                
                // Beat 3
                s_if1.rdata  <= 32'h3333_3333;
                wait(s_if1.rready);
                @(posedge clk);
                
                // Beat 4 (last)
                s_if1.rdata  <= 32'h4444_4444;
                s_if1.rlast  <= 1'b1;
                wait(s_if1.rready);
                @(posedge clk);
                s_if1.rvalid <= 1'b0;
                m_if0.rready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Burst read completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(300) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;
        

        repeat(5) @(posedge clk);

        // ===== Test Case 6: Multiple Masters Read from Same Slave (Read Arbitration) =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Masters 0 and 1 both read from Slave 1 (Read Arbitration test)", test_count, $time);
                
                s_if1.arready = 1'b1;
                
                fork
                    // Master 0 read transaction
                    begin
                        @(posedge clk);
                        m_if0.araddr  <= 32'h1000_0200;
                        m_if0.arid    <= 4'd10;
                        m_if0.arlen   <= 8'd0;
                        m_if0.arsize  <= 3'd2;
                        m_if0.arburst <= 2'b01;
                        m_if0.arvalid <= 1'b1;
                        $display("[TEST %0d] T=%0t: Master 0 asserted arvalid", test_count, $time);
                        
                        wait(m_if0.arready);
                        $display("[TEST %0d] T=%0t: Master 0 got arready", test_count, $time);
                        @(posedge clk);
                        m_if0.arvalid <= 1'b0;
                        
                        m_if0.rready = 1'b1;
                        wait(m_if0.rvalid && m_if0.rlast);
                        @(posedge clk);
                        m_if0.rready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 0 read completed", test_count, $time);
                    end
                    
                    // Master 1 read transaction
                    begin
                        @(posedge clk);
                        m_if1.araddr  <= 32'h1000_0300;
                        m_if1.arid    <= 4'd11;
                        m_if1.arlen   <= 8'd0;
                        m_if1.arsize  <= 3'd2;
                        m_if1.arburst <= 2'b01;
                        m_if1.arvalid <= 1'b1;
                        $display("[TEST %0d] T=%0t: Master 1 asserted arvalid", test_count, $time);
                        
                        wait(m_if1.arready);
                        $display("[TEST %0d] T=%0t: Master 1 got arready", test_count, $time);
                        @(posedge clk);
                        m_if1.arvalid <= 1'b0;
                        
                        m_if1.rready = 1'b1;
                        wait(m_if1.rvalid && m_if1.rlast);
                        @(posedge clk);
                        m_if1.rready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 1 read completed", test_count, $time);
                    end
                    
                    // Slave response handler
                    begin
                        logic [7:0] saved_arid1, saved_arid2;
                        
                        // Capture ARIDs when each master completes handshake
                        fork
                            begin
                                wait(m_if0.arvalid && m_if0.arready);
                                // Reconstruct the slave-side ID
                                saved_arid1 = {4'b0, 2'b00, m_if0.arid};  // Master 0 = port bits 00
                                @(posedge clk);  // Synchronize to clock edge
                                $display("[TEST %0d] T=%0t: Captured M0 handshake, ARID=%h", test_count, $time, saved_arid1);
                            end
                            begin
                                wait(m_if1.arvalid && m_if1.arready);
                                // Reconstruct the slave-side ID
                                saved_arid2 = {4'b0, 2'b01, m_if1.arid};  // Master 1 = port bits 01
                                @(posedge clk);  // Synchronize to clock edge
                                $display("[TEST %0d] T=%0t: Captured M1 handshake, ARID=%h", test_count, $time, saved_arid2);
                            end
                        join
                        
                        // Process first R response
                        @(posedge clk);
                        s_if1.rid    <= saved_arid1;
                        s_if1.rdata  <= 32'hDEAD_BEEF;
                        s_if1.rresp  <= 2'b00;
                        s_if1.rlast  <= 1'b1;
                        s_if1.rvalid <= 1'b1;
                        
                        wait(s_if1.rready);
                        @(posedge clk);
                        s_if1.rvalid <= 1'b0;
                        
                        // Process second R response
                        @(posedge clk);
                        s_if1.rid    <= saved_arid2;
                        s_if1.rdata  <= 32'hCAFE_BABE;
                        s_if1.rlast  <= 1'b1;
                        s_if1.rvalid <= 1'b1;
                        
                        wait(s_if1.rready);
                        @(posedge clk);
                        s_if1.rvalid <= 1'b0;
                        s_if1.arready = 1'b0;
                    end
                join
                
                $display("[TEST %0d] T=%0t: PASSED - Read arbitration completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(300) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);

        // ===== Test Case 8: Simultaneous Read and Write =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 writes while Master 1 reads from different slaves", test_count, $time);
                
                s_if0.awready = 1'b1;
                s_if0.wready = 1'b1;
                s_if2.arready = 1'b1;
                
                fork
                    // Master 0 writes to Slave 0
                    begin
                        @(posedge clk);
                        m_if0.awaddr  <= 32'h0000_0000;
                        m_if0.awid    <= 4'd9;
                        m_if0.awlen   <= 8'd0;
                        m_if0.awsize  <= 3'd2;
                        m_if0.awburst <= 2'b01;
                        m_if0.awvalid <= 1'b1;
                        
                        wait(m_if0.awready);
                        @(posedge clk);
                        m_if0.awvalid <= 1'b0;
                        
                        m_if0.wdata  <= 32'hFFFF_FFFF;
                        m_if0.wstrb  <= 4'hF;
                        m_if0.wlast  <= 1'b1;
                        m_if0.wvalid <= 1'b1;
                        
                        wait(m_if0.wready);
                        @(posedge clk);
                        m_if0.wvalid <= 1'b0;
                        
                        m_if0.bready = 1'b1;
                        s_if0.bid    <= awid_s0;
                        s_if0.bresp  <= 2'b00;
                        s_if0.bvalid <= 1'b1;
                        
                        wait(m_if0.bvalid);
                        @(posedge clk);
                        s_if0.bvalid <= 1'b0;
                        m_if0.bready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 0 write completed", test_count, $time);
                    end
                    
                    // Master 1 reads from Slave 2
                    begin
                        @(posedge clk);
                        m_if1.araddr  <= 32'h2000_0000;
                        m_if1.arid    <= 4'd10;
                        m_if1.arlen   <= 8'd0;
                        m_if1.arsize  <= 3'd2;
                        m_if1.arburst <= 2'b01;
                        m_if1.arvalid <= 1'b1;
                        
                        wait(m_if1.arready);
                        @(posedge clk);
                        m_if1.arvalid <= 1'b0;
                        
                        m_if1.rready = 1'b1;
                        s_if2.rid    <= arid_s2;
                        s_if2.rdata  <= 32'h5555_5555;
                        s_if2.rresp  <= 2'b00;
                        s_if2.rlast  <= 1'b1;
                        s_if2.rvalid <= 1'b1;
                        
                        wait(m_if1.rvalid);
                        @(posedge clk);
                        s_if2.rvalid <= 1'b0;
                        m_if1.rready = 1'b0;
                        $display("[TEST %0d] T=%0t: Master 1 read completed", test_count, $time);
                    end
                join
                
                s_if0.awready = 1'b0;
                s_if0.wready = 1'b0;
                s_if2.arready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Simultaneous read/write completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(300) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(5) @(posedge clk);

        // ===== Test Case 9: Back-to-Back Transactions =====
        test_count++;
        fork
            begin
                $display("\n[TEST %0d] T=%0t: Master 0 back-to-back writes to Slave 1", test_count, $time);
                
                s_if1.awready = 1'b1;
                s_if1.wready = 1'b1;
                
                // Transaction 1: AW
                @(posedge clk);
                m_if0.awaddr  <= 32'h1000_1000;
                m_if0.awid    <= 4'd11;
                m_if0.awlen   <= 8'd0;
                m_if0.awsize  <= 3'd2;
                m_if0.awburst <= 2'b01;
                m_if0.awvalid <= 1'b1;
                
                wait(m_if0.awready);
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                
                // Transaction 1: W
                m_if0.wdata  <= 32'h1111_1111;
                m_if0.wstrb  <= 4'hF;
                m_if0.wlast  <= 1'b1;
                m_if0.wvalid <= 1'b1;
                
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                
                // Transaction 1: B response
                m_if0.bready = 1'b1;
                s_if1.bid    <= 8'h0b;  // First transaction (master 0, id 11)
                s_if1.bresp  <= 2'b00;
                s_if1.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                @(posedge clk);
                s_if1.bvalid <= 1'b0;
                
                // Small delay before second transaction
                @(posedge clk);
                
                // Transaction 2: AW
                m_if0.awaddr  <= 32'h1000_2000;
                m_if0.awid    <= 4'd12;
                m_if0.awlen   <= 8'd0;
                m_if0.awsize  <= 3'd2;
                m_if0.awburst <= 2'b01;
                m_if0.awvalid <= 1'b1;
                
                wait(m_if0.awready);
                @(posedge clk);
                m_if0.awvalid <= 1'b0;
                
                // Transaction 2: W
                m_if0.wdata  <= 32'h2222_2222;
                m_if0.wstrb  <= 4'hF;
                m_if0.wlast  <= 1'b1;
                m_if0.wvalid <= 1'b1;
                
                wait(m_if0.wready);
                @(posedge clk);
                m_if0.wvalid <= 1'b0;
                
                // Transaction 2: B response
                s_if1.bid    <= 8'h0c;  // Second transaction (master 0, id 12)
                s_if1.bresp  <= 2'b00;
                s_if1.bvalid <= 1'b1;
                
                wait(m_if0.bvalid);
                @(posedge clk);
                s_if1.bvalid <= 1'b0;
                m_if0.bready = 1'b0;
                
                s_if1.awready = 1'b0;
                s_if1.wready = 1'b0;
                
                $display("[TEST %0d] T=%0t: PASSED - Back-to-back transactions completed", test_count, $time);
                pass_count++;
            end
            
            begin
                repeat(400) @(posedge clk);
                $display("[TEST %0d] ERROR: Timeout!", test_count);
                $finish;
            end
        join_any
        disable fork;

        repeat(10) @(posedge clk);
        
        // Test Summary
        $display("\n========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", test_count - pass_count);
        if (pass_count == test_count)
            $display("  Result:      ALL TESTS PASSED!");
        else
            $display("  Result:      SOME TESTS FAILED!");
        $display("========================================");
        $display("T=%0t: All tests completed!", $time);
        $finish;
    end

    initial begin
        $display("\n========== AXI 4x4 Interconnect Extended Testbench ==========");
        $display("Address Map:");
        $display("  Slave 0: 0x00000000 - 0x0FFFFFFF");
        $display("  Slave 1: 0x10000000 - 0x1FFFFFFF");
        $display("  Slave 2: 0x20000000 - 0x2FFFFFFF");
        $display("  Slave 3: 0x30000000 - 0x3FFFFFFF");
        $display("\nTest Coverage:");
        $display("  1. Single Write Transaction");
        $display("  2. Single Read Transaction");
        $display("  3. Write to Multiple Slaves");
        $display("  4. Multiple Masters to Same Slave (Arbitration)");
        $display("  5. Burst Write Transaction");
        $display("  6. Burst Read Transaction");
        $display("  7. Simultaneous Read and Write");
        $display("  8. Back-to-Back Transactions");
        $display("=============================================================\n");
    end
    
    initial begin 
    	$dumpvars();
    	$dumpfile("svip.vcd");
    end 

endmodule

