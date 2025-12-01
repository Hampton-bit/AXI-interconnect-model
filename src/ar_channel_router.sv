// ===================== Read Address Channel Router =====================
class ar_channel_router;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)
    addr_decode #(32,4) decoder;
    round_robin_arbiter #(4) arbiters[4];

    function new(virtual axi_intf #(.ID_WIDTH(4)) masters[4], virtual axi_intf #(.ID_WIDTH(8)) slaves[4], addr_decode #(32,4) dec);
        for(int i=0; i<4; i++) begin
            m_if[i] = masters[i];
            s_if[i] = slaves[i];
            arbiters[i] = new();
        end
        decoder = dec;
    endfunction

    task run();
        fork
            // Reset handler
            begin
                forever begin
                    @(posedge m_if[0].clk);
                    if(!m_if[0].rst_n) begin
                        for(int si=0; si<4; si++) begin
                            arbiters[si].last_grant = -1;
                        end
                    end
                end
            end

            // Sequential router for all slaves
            begin
                forever begin
                    @(posedge m_if[0].clk);
                    
                    // Debug: Show master arvalid states for Slave 1 targets
                    if(m_if[0].arvalid && decoder.decode(m_if[0].araddr) == 1 || 
                       m_if[1].arvalid && decoder.decode(m_if[1].araddr) == 1) begin
                        $display("T=%0t ROUTER START: M0.arvalid=%b M1.arvalid=%b", $time, m_if[0].arvalid, m_if[1].arvalid);
                    end
                    
                    // Clear all master arready signals once at start of clock cycle
                    for(int mi=0; mi<4; mi++) begin
                        m_if[mi].arready = 1'b0;
                    end
                    
                    // Route each slave sequentially
                    route_to_slave(0);
                    route_to_slave(1);
                    route_to_slave(2);
                    route_to_slave(3);
                end
            end
        join_none
    endtask

    task route_to_slave(int si);
        bit [3:0] requests;
        bit [3:0] grant;
        int target;
        int winner;

        // Default: disconnect slave
        s_if[si].arvalid = 1'b0;

        // Build request vector from masters
        requests = 4'b0;
        for(int mi=0; mi<4; mi++) begin
            if(m_if[mi].arvalid) begin
                target = decoder.decode(m_if[mi].araddr);
                if(target == si) begin
                    requests[mi] = 1;
                    if(si == 1) $display("T=%0t AR: M%0d arvalid=1 addr=%h -> S%0d", $time, mi, m_if[mi].araddr, si);
                end
            end
        end

        // Arbitrate only if slave is ready
        if(s_if[si].arready) begin
            grant = arbiters[si].arbitrate(requests);
            
            if(si == 1 && (requests != 0)) begin
                $display("T=%0t AR: S1 req=%b grant=%b last=%0d", $time, requests, grant, arbiters[si].last_grant);
            end

            if(|grant) begin
                winner = 0;
                for(int k=0; k<4; k++) if(grant[k]) winner = k;

                if(si == 1) $display("T=%0t AR: S1 winner=%0d, setting m_if[%0d].arready=%b", $time, winner, winner, s_if[si].arready);

                // Route master signals to slave
                s_if[si].araddr  = m_if[winner].araddr;
                s_if[si].arid    = {4'b0, winner[1:0], m_if[winner].arid};
                s_if[si].arlen   = m_if[winner].arlen;
                s_if[si].arsize  = m_if[winner].arsize;
                s_if[si].arburst = m_if[winner].arburst;
                s_if[si].arvalid = m_if[winner].arvalid;
                
                // Route slave ready back to winning master
                m_if[winner].arready = s_if[si].arready;
            end
        end
    endtask
endclass
