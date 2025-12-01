// ===================== AXI 4x4 Interconnect (Top Level) =====================
class axi_interconnect;
    virtual axi_intf #(.ID_WIDTH(4)) m_if[4];  // Master interfaces (4-bit IDs)
    virtual axi_intf #(.ID_WIDTH(8)) s_if[4];  // Slave interfaces (8-bit IDs)

    // Components
    addr_decode #(32,4) decoder;
    aw_channel_router   aw_router;
    ar_channel_router   ar_router;
    w_channel_router    w_router;
    b_channel_router    b_router;
    r_channel_router    r_router;

    function new(virtual axi_intf #(.ID_WIDTH(4)) m1_if, virtual axi_intf #(.ID_WIDTH(4)) m2_if, 
                 virtual axi_intf #(.ID_WIDTH(4)) m3_if, virtual axi_intf #(.ID_WIDTH(4)) m4_if,
                 virtual axi_intf #(.ID_WIDTH(8)) s1_if, virtual axi_intf #(.ID_WIDTH(8)) s2_if, 
                 virtual axi_intf #(.ID_WIDTH(8)) s3_if, virtual axi_intf #(.ID_WIDTH(8)) s4_if);
        // Assign interfaces
        m_if[0] = m1_if; m_if[1] = m2_if; m_if[2] = m3_if; m_if[3] = m4_if;
        s_if[0] = s1_if; s_if[1] = s2_if; s_if[2] = s3_if; s_if[3] = s4_if;

        // Create decoder
        decoder = new();
        
        // Create channel routers
        aw_router = new(m_if, s_if, decoder);
        ar_router = new(m_if, s_if, decoder);
        w_router  = new(m_if, s_if);
        b_router  = new(m_if, s_if);
        r_router  = new(m_if, s_if);
        for(int i=0; i<4;i++) slave_connection[i]=-1;
    endfunction

    // Start all routing tasks
    task start();
      $display("here");
        fork
            aw_router.run();
             ar_router.run();
             w_router.run();
             b_router.run();
             r_router.run();
        join_none
    endtask
endclass


