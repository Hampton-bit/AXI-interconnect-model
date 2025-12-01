
<div align="center">

# 🚀 AXI4 Interconnect

### High-Performance SystemVerilog Implementation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE%201800-blue.svg)](https://ieeexplore.ieee.org/document/8299595)
[![VCS Compatible](https://img.shields.io/badge/VCS-Compatible-green.svg)](https://www.synopsys.com/verification/simulation/vcs.html)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

*A AXI4 interconnect model for multi-master, multi-slave systems with ID-based routing and round-robin arbitration*

[Features](#-features) •
[Quick Start](#-quick-start) •
[Architecture](#-architecture) •
[Documentation](#-documentation) •
[Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-features)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration Guide](#%EF%B8%8F-configuration-guide)
- [Design Details](#-design-details)
- [Simulation & Verification](#-simulation--verification)
- [Use Cases](#-use-cases)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## 🎯 Overview

The **AXI4 Interconnect** is a professional-grade, AMBA AXI4 interconnect fabric designed for complex SoC architectures. It provides efficient, low-latency communication between multiple bus masters and memory-mapped slaves while maintaining protocol compliance and offering exceptional configurability.

### Why This Interconnect?

- 🎨 **Clean Architecture**: Modular, interface-based design for easy integration
- ⚡ **High Performance**: Optimized for throughput with minimal latency overhead
- 🔧 **Highly Configurable**: Adapt to your specific system requirements
- ✅ **Protocol Compliant**: Adherence to AMBA AXI4 specification
- 🧪 **Well Tested**: Comprehensive testbench with coverage-driven verification
- 🔍 **Smart ID Routing**: Uses upper ID bits for efficient response routing

---

## ✨ Features

### Core Capabilities

| Feature | Description |
|---------|-------------|
| **Full AXI4 Support** | Complete implementation of all 5 AXI4 channels (AW, W, B, AR, R) |
| **Multi-Master/Slave** | 4x4 crossbar topology |
| **Address Decoding** | Flexible, programmable address map for slave selection |
| **Round-Robin Arbitration** | Fair, predictable arbitration with starvation prevention |
| **ID-Based Routing** | Uses upper ID bits to route responses back to correct master |
| **Configurable Widths** | Parameterizable data, address, and ID bus widths |

### Design Characteristics

- ✅ ID-based response routing (no transaction queue overhead)
- ✅ Parallel address decoding for slave selection
- ✅ Deadlock prevention mechanisms
- ✅ Configurable pipeline stages for timing closure
- ✅ Clean SystemVerilog interface-based design

---
### ID-Based Response Routing

The interconnect uses the **upper bits of the AXI ID field** to identify the originating master:

```
┌─────────────────────────────────────────┐
│        AXI Transaction ID               │
├──────────────────┬──────────────────────┤
│  Master ID Bits  │  Transaction ID Bits │
│  (Upper bits)    │  (Lower bits)        │
└──────────────────┴──────────────────────┘
       ↓
    Used for routing
    responses back
    to correct master
```

**Benefits:**
- ✅ No transaction queue overhead
- ✅ Reduced latency
- ✅ Lower resource utilization
- ✅ Simpler design

### Module Hierarchy

```
axi_interconnect (Top)
├── axi_intf (Interface Definition)
├── addr_decode (Address Decoder)
│   └── Address Range Comparators
├── aw_channel_router (Write Address Router)
│   ├── Master Multiplexer
│   ├── Slave Demultiplexer
│   └── ID Management
├── w_channel_router (Write Data Router)
│   └── Data Path Switching
├── b_channel_router (Write Response Router)
│   └── ID-Based Response Routing
├── ar_channel_router (Read Address Router)
│   ├── Master Multiplexer
│   ├── Slave Demultiplexer
│   └── ID Management
├── r_channel_router (Read Data Router)
│   └── ID-Based Response Routing
└── round_robin_arbiter (Arbitration Logic)
    ├── Priority Encoder
    └── Grant Logic
```

---

## 🚀 Quick Start

### Prerequisites

#### Required Tools
- **VCS** (Synopsys VCS 2020.03 or later)
- **Make** (GNU Make 4.0+)
- **Git** (for version control)

#### Optional Tools
- **DVE** - Design Vision Environment (for waveform debugging)
- **GTKWave** - Alternative open-source waveform viewer
- **Verdi** - Advanced debug platform

### Installation

```bash
# Clone the repository
git clone https://github.com/Hampton-bit/AXI-interconnect-model.git
cd axi-interconnect

# Verify VCS installation
vcs -ID

# Quick simulation
cd sim
make
```

### Running Your First Simulation

```bash
# Navigate to simulation directory
cd sim

# Compile and run simulation
make

# View waveforms (DVE)
dve -vpd svip.vcd &

# Or with GTKWave
gtkwave svip.vcd &

# Clean build artifacts
make clean
```

---

## 📁 Project Structure

```
axi-interconnect/
│
├── 📄 README.md                    # This file
├── 📄 LICENSE                      # MIT License
├── 📄 .gitignore                   # Git ignore rules
│
├── 📂 src/                         # RTL Source Files
│   ├── axi_interconnect.sv         # 🔝 Top-level interconnect
│   ├── axi_intf.sv                 # 🔌 AXI4 interface definition
│   ├── addr_decode.sv              # 🎯 Address decoder
│   ├── aw_channel_router.sv        # ✍️  Write address router
│   ├── w_channel_router.sv         # ✍️  Write data router
│   ├── b_channel_router.sv         # ↩️  Write response router
│   ├── ar_channel_router.sv        # 📖 Read address router
│   ├── r_channel_router.sv         # 📖 Read data router
│   ├── round_robin_arbiter.sv      # ⚖️  Round-robin arbiter
│   └── defines.sv                  # 🔧 Common definitions
│
├── 📂 tb/                          # Testbench Files
│   ├── tb.sv                       # 🧪 Main testbench
│   └── compile.f                   # 📜 File compilation list
│
├── 📂 sim/                         # Simulation Environment
│   ├── Makefile                    # 🔨 Build automation
│   ├── simv                        # 💻 Compiled executable
│   ├── svip.vcd                    # 📊 Waveform dump
│   ├── vc_hdrs.h                   # VCS headers
│   ├── csrc/                       # VCS compilation artifacts
│   └── simv.daidir/                # VCS database
│
└── 📂 docs/                        # Documentation (Future)
    ├── architecture.md             # Detailed architecture
    ├── timing_diagrams.md          # Timing specifications
    └── api_reference.md            # Module interfaces
```

---

## ⚙️ Configuration Guide

### Basic Configuration

The interconnect is configured through SystemVerilog parameters. Edit [`src/axi_interconnect.sv`](src/axi_interconnect.sv):

```systemverilog
module axi_interconnect #(
    // Topology Configuration
    parameter int NUM_MASTERS = 4,        // Number of AXI masters (1-16)
    parameter int NUM_SLAVES  = 4,        // Number of AXI slaves (1-16)
    
    // Bus Width Configuration
    parameter int DATA_WIDTH  = 64,       // 32, 64, 128, 256, 512, 1024
    parameter int ADDR_WIDTH  = 32,       // Address bus width (12-64)
    parameter int ID_WIDTH    = 8,        // Transaction ID width (4-16)
    
    // Protocol Configuration
    parameter int STRB_WIDTH  = DATA_WIDTH/8,  // Byte strobe width
    parameter int USER_WIDTH  = 1              // User signal width
) (
    // Port declarations...
);
```

### ID Width Calculation

**Important:** The ID width must accommodate master identification:

```systemverilog
// ID_WIDTH = MASTER_ID_BITS + TRANSACTION_ID_BITS
// MASTER_ID_BITS = $clog2(NUM_MASTERS)

// Example: 4 masters, want 4-bit transaction IDs
// MASTER_ID_BITS = 2 (for 4 masters)
// ID_WIDTH = 2 + 4 = 6 bits minimum
```

### Advanced Configuration

#### Address Map Configuration

Define slave address ranges in [`src/addr_decode.sv`](src/addr_decode.sv):

```systemverilog
// Example: 4GB address space divided among 4 slaves
localparam logic [ADDR_WIDTH-1:0] SLAVE_BASE_ADDR [NUM_SLAVES] = {
    32'h0000_0000,  // Slave 0: 0x0000_0000 - 0x3FFF_FFFF (1GB)
    32'h4000_0000,  // Slave 1: 0x4000_0000 - 0x7FFF_FFFF (1GB)
    32'h8000_0000,  // Slave 2: 0x8000_0000 - 0xBFFF_FFFF (1GB)
    32'hC000_0000   // Slave 3: 0xC000_0000 - 0xFFFF_FFFF (1GB)
};

localparam logic [ADDR_WIDTH-1:0] SLAVE_MASK [NUM_SLAVES] = {
    32'hC000_0000,  // 1GB mask
    32'hC000_0000,
    32'hC000_0000,
    32'hC000_0000
};
```

#### Arbitration Policy

Configure arbitration in [`src/round_robin_arbiter.sv`](src/round_robin_arbiter.sv):

```systemverilog
// Round-robin provides fair access
// No starvation of any master
// Predictable arbitration behavior
```


## 🔬 Design Details

### 1. Address Decoder ([`addr_decode.sv`](src/addr_decode.sv))

**Purpose**: Decodes transaction addresses to determine target slave

**Key Features**:
- Configurable address ranges per slave
- Parallel decode logic for low latency
- Error detection for unmapped addresses
- Support for overlapping address ranges with priority

**Interface**:
```systemverilog
input  logic [ADDR_WIDTH-1:0] addr_i,
output logic [NUM_SLAVES-1:0] slave_select_o,
output logic                  decode_error_o
```

**Operation**:
- Compares incoming address against all slave ranges
- Generates one-hot slave select signal
- Single-cycle decode operation

---

### 2. Channel Routers

Each AXI4 channel has a dedicated router optimized for its specific requirements:

#### Write Address Channel ([`aw_channel_router.sv`](src/aw_channel_router.sv))
- Multiplexes write address requests from masters
- Routes to appropriate slave based on address decode
- **Appends master ID to upper bits of AWID**
- Handles AxSIZE, AxLEN, AxBURST attributes

#### Write Data Channel ([`w_channel_router.sv`](src/w_channel_router.sv))
- Routes write data following address channel
- Manages WLAST signaling
- Handles byte strobes for partial writes
- No ID modification (follows address channel)

#### Write Response Channel ([`b_channel_router.sv`](src/b_channel_router.sv))
- **Extracts master ID from upper bits of BID**
- Routes responses back to originating master
- Preserves transaction IDs
- Handles error propagation (OKAY, SLVERR, DECERR)

#### Read Address Channel ([`ar_channel_router.sv`](src/ar_channel_router.sv))
- Multiplexes read address requests from masters
- Routes to appropriate slave based on address decode
- **Appends master ID to upper bits of ARID**
- Manages read attributes

#### Read Data Channel ([`r_channel_router.sv`](src/r_channel_router.sv))
- **Extracts master ID from upper bits of RID**
- Routes read data back to requesting master
- Manages RLAST signaling
- Preserves response ordering per master

---

### 3. Round-Robin Arbiter ([`round_robin_arbiter.sv`](src/round_robin_arbiter.sv))

**Arbitration Algorithm**:
1. Maintains rotating priority pointer
2. Scans requests starting from last grant position
3. Awards grant to first requesting master in rotation
4. Updates priority pointer on grant
5. Prevents starvation through fair rotation

**Performance**:
- Single-cycle arbitration decision
- Zero-latency grant for single requester
- Starvation-free operation



### 4. ID-Based Response Routing

**How It Works**:

1. **Address Phase (Master → Slave)**:
   ```
   Master generates transaction with ID[3:0] = 0x5
   Interconnect appends Master ID[5:4] = 2'b10
   Slave receives ID[5:0] = 6'b10_0101
   ```

2. **Response Phase (Slave → Master)**:
   ```
   Slave responds with ID[5:0] = 6'b10_0101
   Interconnect extracts Master ID[5:4] = 2'b10 → Master 2
   Routes response to Master 2 with ID[3:0] = 4'b0101
   ```

**Advantages**:
- ✅ No transaction tracking queue required
- ✅ Constant-time routing decision
- ✅ Lower resource utilization
- ✅ Reduced latency
- ✅ Simplified design and verification

**Limitations**:
- Masters must allocate sufficient ID bits
- ID width must accommodate master encoding

---

## 🧪 Simulation & Verification


### Running Simulations

#### Basic Simulation
```bash
cd sim
make              # Compile and run with default settings
```

#### View Waveforms
```bash
# Using DVE
dve -vpd svip.vcd &

# Using GTKWave
gtkwave svip.vcd &
```

#### Clean Artifacts
```bash
make clean        # Remove all build artifacts
```

### Debug Tips

#### Key Signals to Monitor
- `axi_interconnect.aw_valid/aw_ready` - Write address handshake
- `axi_interconnect.ar_valid/ar_ready` - Read address handshake
- `axi_interconnect.awid/arid` - Transaction IDs (with master encoding)
- `axi_interconnect.bid/rid` - Response IDs (with master encoding)
- `axi_interconnect.arbiter.grant` - Arbitration grants
- `axi_interconnect.addr_decode.slave_select` - Slave selection

#### Common Issues
1. **ID Width Too Small**: Ensure ID_WIDTH ≥ $clog2(NUM_MASTERS) + desired transaction ID bits
2. **Address Decode Errors**: Check slave address ranges don't overlap incorrectly
3. **Response Routing**: Verify master ID extraction from upper ID bits

---

## 💼 Use Cases

### 1. Multi-Core Processor SoC
```
CPU Core 0 ────┐
CPU Core 1 ────┤
GPU        ────┼──► AXI Interconnect ──► ├── DDR Controller
DMA Engine ────┤                          ├── ROM
DSP        ────┘                          ├── Peripheral Bus Bridge
                                          └── Cache Controller
```


## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Contribution Guidelines

#### Code Style
- Follow SystemVerilog best practices (IEEE 1800-2017)
- Use consistent naming conventions:
  - `snake_case` for signals and variables
  - `UPPER_CASE` for parameters and constants
  - `PascalCase` for module names
- Add comprehensive comments for complex logic
- Include module headers with description and interface documentation

#### Testing Requirements
- All new features must include test cases in [`tb/tb.sv`](tb/tb.sv)
- Existing tests must pass
- Include waveform analysis for complex features
- Document test scenarios in pull request

#### Documentation
- Update [readme.md](readme.md) for user-facing changes
- Add inline documentation for new modules
- Update architecture diagrams if applicable

### Reporting Issues

Found a bug? Please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- System information (VCS version, OS)
- Relevant code snippets or waveforms

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 AXI Interconnect Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 🙏 Acknowledgments

### Standards & Specifications
- **ARM AMBA AXI Protocol Specification v2.0** - Foundation for AXI4 implementation
- **IEEE 1800-2017** - SystemVerilog Language Reference Manual

### Tools & Frameworks
- **Synopsys VCS** - Simulation and verification platform
- **Verdi** - Debug and analysis environment

### Design Techniques
- ID-based routing approach for efficient response handling
- Round-robin arbitration for fair resource allocation

---

## 📞 Contact & Support

### Getting Help
- 📖 **Documentation**: Check this README and inline code comments
- 💬 **Discussions**: Open discussions for questions
- 🐛 **Issues**: Report bugs via issue tracker
- 📧 **Email**: mnaeem.bee20seecs@seecs.edu.pk

---

<div align="center">

### ⭐ Star this repository if you find it useful!

Made with ❤️ by the AXI Interconnect Team

[⬆ Back to Top](#-axi4-interconnect)

</div>
````


