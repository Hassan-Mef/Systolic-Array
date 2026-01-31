# High-Performance 2D Convolution Accelerator (Systolic Array)

This repository contains the RTL design and supporting modules for a **hardware-accelerated 2D convolution engine** implemented using a **systolic array architecture**.  
The project was developed as a final-year / semester design project focusing on **throughput-oriented digital design**, **modular RTL development**, and **FSM-driven dataflow control**.

---

## 📌 Project Overview

2D convolution is a core operation in image processing and deep learning workloads.  
This project implements a **streaming 2×2 convolution accelerator** using a **systolic architecture**, enabling:

- Parallel multiply–accumulate (MAC) operations  
- High throughput via pipelining  
- Parameterized and modular RTL design  
- Clear separation of datapath and control logic  

The design is written entirely in **Verilog HDL** and targeted for **FPGA implementation**.

---

## 📂 Repository Structure

```
├── 1DConv   # Contains code for 1d convolution and its implementation on FPGA board
├── 2D-Systloic-Array/ # Core systolic array RTL (main project)
├── Interfacing/ # UART & button interfacing modules (experimental)
└── README.md # This file
```


### 🔹 `2D-Systloic-Array/`
Contains the complete and functional systolic convolution accelerator:
- Processing Elements (PEs)
- Kernel storage
- Datapath
- FSM-based control
- Top-level integration

📄 A **detailed technical README** is provided inside this directory.

### 🔹 `Interfacing/`
Contains UART transmit/receive logic and button debounce modules intended for FPGA-based input/output interfacing.

⚠️ **Note:**  
UART-based data interfacing is **currently not fully functional** and was not integrated into the final evaluation flow.  
The core convolution accelerator operates correctly and can be demonstrated using simulation and direct signal inspection.

---

## 🛠️ Tools & Technologies
- Verilog HDL  
- FPGA-oriented RTL design  
- Finite State Machines (FSM)  
- Pipelined systolic architectures  

---

## 📈 Project Status
- ✅ Core systolic convolution accelerator: **Completed**
- ⚠️ UART-based interfacing: **Partial / Experimental**
- 🔜 FPGA I/O integration: Future work

---

## 📚 References
Relevant references and documentation are included in the project report and inline comments within the RTL modules.

---

## 👨‍💻 Authors
Developed by undergraduate Computer Engineering students as part of an academic design project.


