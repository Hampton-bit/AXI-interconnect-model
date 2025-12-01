// ===================== Write Response Channel Router =====================
class b_channel_router;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)

    function new(virtual axi_intf #(.ID_WIDTH(4)) masters[4], virtual axi_intf #(.ID_WIDTH(8)) slaves[4]);
        for(int i=0; i<4; i++) begin
            m_if[i] = masters[i];
            s_if[i] = slaves[i];
        end
    endfunction

    task run();
        $display("T=%0t: B Router started", $time);
        forever begin
            @(posedge m_if[0].clk);
 
            // Route from each slave to appropriate master
            for(int si=0; si<4; si++) begin
                if(s_if[si].bvalid) begin
                    // Extract master port from BID[5:4]
                    int master_port = s_if[si].bid[5:4];
                    
                    $display("T=%0t: B Router - Slave %0d routing response to master %0d (BID=%h)", 
                             $time, si, master_port, s_if[si].bid);
                    
                    // Route response to correct master
                    m_if[master_port].bid    = s_if[si].bid[3:0];  // Strip master port bits
                    m_if[master_port].bresp  = s_if[si].bresp;
                    m_if[master_port].bvalid = 1'b1;
                    s_if[si].bready = m_if[master_port].bready;
                    
                    // Check if handshake completed
                    if(m_if[master_port].bready && s_if[si].bvalid) begin
                        $display("T=%0t: B Router - Handshake complete for master %0d from slave %0d", 
                                 $time, master_port, si);
                    end
                end
            end
        end
    endtask
endclass
