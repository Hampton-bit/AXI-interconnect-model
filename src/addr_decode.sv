class addr_decode #(int ADDR_WIDTH=32, int NREG=4);
    bit [ADDR_WIDTH-1:0] addr_base[NREG];
    bit [ADDR_WIDTH-1:0] addr_size[NREG];

    function new(
        bit [ADDR_WIDTH-1:0] addr_base_init[] = '{32'h0000_0000, 32'h1000_0000, 32'h2000_0000, 32'h3000_0000},
        bit [ADDR_WIDTH-1:0] addr_size_init[] = '{32'h0FFF_FFFF, 32'h0FFF_FFFF, 32'h0FFF_FFFF, 32'h0FFF_FFFF}
    );
        for(int i=0; i<NREG; i++) begin
            this.addr_base[i] = addr_base_init[i];
            this.addr_size[i] = addr_size_init[i];
        end
    endfunction

    // Returns slave index (0-3) or -1 if no match
    function int decode(bit [ADDR_WIDTH-1:0] addr);
        for(int i=0; i<NREG; i++) begin
            if(addr >= addr_base[i] && addr < (addr_base[i] + addr_size[i]))
                return i;
        end
        return -1; // No slave matches
    endfunction
endclass
