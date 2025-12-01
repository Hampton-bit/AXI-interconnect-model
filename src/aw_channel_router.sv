// ===================== Write Address Channel Router =====================
class aw_channel_router;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)
    addr_decode #(32,4) decoder;
    round_robin_arbiter #(4) arbiters[4];
    bit [3:0] prev_awvalid;
    bit [3:0] prev_awready;

    function new(virtual axi_intf #(.ID_WIDTH(4)) masters[4], virtual axi_intf #(.ID_WIDTH(8)) slaves[4], addr_decode #(32,4) dec);
        for(int i=0; i<4; i++) begin
            m_if[i] = masters[i];
            s_if[i] = slaves[i];
            arbiters[i] = new();
        end
        decoder = dec;
        prev_awvalid = 4'b0;
        prev_awready = 4'b0;
    endfunction

    task run();
        $display("here2");
        fork
            // Reset handler
            begin
                forever begin
                    @(posedge m_if[0].clk);
                    if(!m_if[0].rst_n) begin
                        for(int si=0; si<4; si++) begin
                            arbiters[si].last_grant = -1;
                            slave_connection[si] = -1;
                        end
                    end
                end
            end
            
            // Main routing process - runs all slaves sequentially each clock
            begin
                forever begin
                    @(posedge m_if[0].clk);
                    
                    // Clear all master awready signals first
                    for(int mi=0; mi<4; mi++) begin
                        m_if[mi].awready = 1'b0;
                    end
                    
                    // Route each slave (sequentially to avoid race conditions)
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

        // Default: clear slave awvalid
        s_if[si].awvalid = 1'b0;

        // Build request vector from masters
        requests = 4'b0;
        for(int mi=0; mi<4; mi++) begin
            if(m_if[mi].awvalid) begin
                target = decoder.decode(m_if[mi].awaddr);
                if(target == si) requests[mi] = 1;
            end
        end

        // Arbitrate if there are requests and no active W channel connection
        if(s_if[si].awready && (requests!=0) && (slave_connection[si] < 0)) begin
            grant = arbiters[si].arbitrate(requests);

            if(|grant) begin
                winner = 0;
                for(int k=0; k<4; k++) if(grant[k]) winner = k;
				
                $display("T=%0t: AW Router - m[%0d]->s[%0d]", $time, winner, si);
                
                // Route master signals to slave
                s_if[si].awaddr  = m_if[winner].awaddr;
                s_if[si].awid    = {4'b0, winner[1:0], m_if[winner].awid};
                s_if[si].awlen   = m_if[winner].awlen;
                s_if[si].awsize  = m_if[winner].awsize;
                s_if[si].awburst = m_if[winner].awburst;
                s_if[si].awvalid = m_if[winner].awvalid;
                
                // Route slave ready back to winning master
                m_if[winner].awready = s_if[si].awready;
                
                // Check if handshake occurs this cycle
                if(m_if[winner].awvalid && s_if[si].awready) begin
                    // Establish W channel connection for this master
                    slave_connection[si] = winner;
                    $display("T=%0t: AW Router - Handshake complete: Master %0d -> Slave %0d (W connection established)", 
                             $time, winner, si);
                end
            end
        end
    endtask
endclass
