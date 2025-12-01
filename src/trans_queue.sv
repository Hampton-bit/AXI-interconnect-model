// ===================== Transaction Queue (DEPRECATED) =====================
// This file is kept for compatibility but is no longer used.
// The interconnect now uses ID fields directly for routing instead of queues.
// The master port number is embedded in the ID field (bits [5:4]) and extracted
// by the response routers to determine the destination master.

// Legacy structure - not actively used
typedef struct {
    bit       active;
    bit [1:0] master_idx;
    bit [3:0] trans_id;
} trans_entry_t_legacy;
