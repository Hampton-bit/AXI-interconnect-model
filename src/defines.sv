// AXI ID width parameters (per AXI spec recommendations)
// - Master components use 4-bit transaction IDs
// - Interconnect appends additional bits for master port identification
// - For 4 masters, need 2 additional bits (4 = 2^2)
// - Slave interfaces see 8-bit IDs (4 master + 4 interconnect bits, using only 6 total)
parameter int MASTER_ID_WIDTH = 4;      // Master's original ID width
parameter int INTERCONNECT_ID_BITS = 4; // Additional bits for master port number (using 2 of 4)
parameter int SLAVE_ID_WIDTH = MASTER_ID_WIDTH + INTERCONNECT_ID_BITS; // Total ID at slave = 8 bits

// ID Field Layout at Slave Interface (8 bits total):
// [7:6] - Reserved (0)
// [5:4] - Master port number (0-3)
// [3:0] - Original transaction ID from master (4 bits)

int slave_connection [4] = '{default:-1};
