// ===================== Read Data Channel Router =====================
class r_channel_router;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)

    function new(virtual axi_intf #(.ID_WIDTH(4)) masters[4], virtual axi_intf #(.ID_WIDTH(8)) slaves[4]);
        for(int i=0; i<4; i++) begin
            m_if[i] = masters[i];
            s_if[i] = slaves[i];
        end
    endfunction

    task run();
        forever begin
            @(posedge m_if[0].clk);
            
            // Clear all master R channel signals first
            for(int mi=0; mi<4; mi++) begin
                m_if[mi].rid = 'b0;
                m_if[mi].rdata = 'b0;
                m_if[mi].rresp = 'b0;
                m_if[mi].rlast = 1'b0;
                m_if[mi].rvalid = 1'b0;
            end
            
            // Clear all slave rready signals
            for(int si=0; si<4; si++) begin
                s_if[si].rready = 1'b0;
            end
            
            // Route from each slave to appropriate master
            for(int si=0; si<4; si++) begin
                if(s_if[si].rvalid) begin
                    // Extract master port from RID[5:4]
                    int master_port = s_if[si].rid[5:4];
                    
                    // Route read data to correct master
                    m_if[master_port].rid    = s_if[si].rid[3:0];  // Strip master port bits
                    m_if[master_port].rdata  = s_if[si].rdata;
                    m_if[master_port].rresp  = s_if[si].rresp;
                    m_if[master_port].rlast  = s_if[si].rlast;
                    m_if[master_port].rvalid = 1'b1;
                    s_if[si].rready = m_if[master_port].rready;
                end
            end
        end
    endtask
endclass
