// ===================== Write Data Channel Router =====================
class w_channel_router;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)
    

	
	
    function new(virtual axi_intf #(.ID_WIDTH(4)) masters[4], virtual axi_intf #(.ID_WIDTH(8)) slaves[4]);
        for(int i=0; i<4; i++) begin
            m_if[i] = masters[i];
            s_if[i] = slaves[i];
        end
    endfunction

    task run();
        fork
            // Main routing process - runs all slaves sequentially each clock
            begin
                forever begin
                    @(posedge m_if[0].clk);
                    
                    // Clear all master wready signals first
                    for(int mi=0; mi<4; mi++) begin
                        m_if[mi].wready = 1'b0;
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
        int master_port;

        // Route if there's an active connection
        if(slave_connection[si] >= 0) begin
            master_port = slave_connection[si];
            
            // Route W channel data from the correct master
            s_if[si].wdata  = m_if[master_port].wdata;
            s_if[si].wstrb  = m_if[master_port].wstrb;
            s_if[si].wlast  = m_if[master_port].wlast;
            s_if[si].wvalid = m_if[master_port].wvalid;
            
            // Route wready back to master (this is the critical backpressure signal!)
            m_if[master_port].wready = s_if[si].wready;
            
            // Check if handshake occurred
            if(m_if[master_port].wvalid && s_if[si].wready) begin
                $display("T=%0t: W Router - Slave %0d beat transferred from master %0d (WLAST=%b)", 
                         $time, si, master_port, m_if[master_port].wlast);
                
                if(m_if[master_port].wlast) begin
                    $display("T=%0t: W Router - Slave %0d transaction completed from master %0d - clearing connection", 
                             $time, si, master_port);
                    slave_connection[si] = -1;  // Clear connection after last beat
                end
            end
        end
    endtask
endclass
