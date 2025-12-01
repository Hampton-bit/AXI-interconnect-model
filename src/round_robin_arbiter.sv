// ===================== Round-Robin Arbiter =====================
class round_robin_arbiter #(int N=4);
    int last_grant;

    function new();
        last_grant = -1;
    endfunction

    // Returns one-hot grant vector
    function bit [N-1:0] arbitrate(bit [N-1:0] requests);
        bit [N-1:0] grant = '0;
        
        if (requests == 0) return grant;

        // Round-robin: start from next position after last grant
        for(int i=1; i<=N; i++) begin
            int idx = (last_grant + i) % N;
            if(requests[idx]) begin
                grant[idx] = 1'b1;
                last_grant = idx;
                return grant;
            end
        end
        
        return grant;
    endfunction
endclass
