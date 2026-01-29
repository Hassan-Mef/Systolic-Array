# 2D Systolic Array – Convolution Accelerator (RTL Design)

This directory contains the **complete RTL implementation** of a **2×2 systolic array–based 2D convolution accelerator**.  
The design emphasizes **modularity**, **pipelining**, and **clear datapath–control separation**.

---

## 🧠 Architectural Overview

The accelerator is based on a **systolic array architecture**, where data flows rhythmically through an array of **Processing Elements (PEs)**.  
Each PE performs a **multiply–accumulate (MAC)** operation and passes intermediate results forward every clock cycle.

### Key Architectural Goals:
- High throughput via spatial and temporal parallelism  
- Deterministic and FSM-controlled data movement  
- Parameterized design for scalability  
- Clean RTL hierarchy suitable for FPGA synthesis  

---

## 🔁 Dataflow Summary

1. Input image pixels are streamed into the systolic datapath
2. Kernel values are preloaded and distributed to PEs
3. Each PE performs MAC operations synchronously
4. Partial sums propagate through the array
5. Final convolution output is produced after pipeline latency
6. Valid signals ensure correct output timing

---

## 🧱 Module-Level Description

### 🔹 `PE.v` – Processing Element
- Core computational unit of the systolic array
- Performs:
  - Multiplication of input data and kernel weight
  - Accumulation with incoming partial sum
- Fully synchronous design
- Passes data and partial sums to neighboring PEs

---

### 🔹 `Kernal_2by2.v`
- Stores the 2×2 convolution kernel
- Provides kernel coefficients to corresponding PEs
- Designed as a lightweight, deterministic kernel source

---

### 🔹 `Conv_2by_2.v`
- Implements the logical grouping of PEs required for a single 2×2 convolution window
- Acts as a local datapath block
- Abstracts PE-level wiring and MAC coordination

---

### 🔹 `Systolic_Datapath.v`
- Integrates multiple convolution blocks
- Manages:
  - Data shifting
  - Partial sum propagation
  - Pipeline alignment
- Designed independently of control logic for clarity and reuse

---

### 🔹 `Systolic_FSM.v`
- Finite State Machine responsible for:
  - Window scheduling
  - Data-valid generation
  - Synchronization with pipeline latency
- Ensures correct sequencing between:
  - Input streaming
  - Computation
  - Output validation

---

### 🔹 `Systolic_Top.v`
- Top-level integration module
- Connects:
  - Datapath
  - FSM controller
- Parameterized for:
  - Image dimensions
  - Kernel size
  - Pipeline latency
- Exposes clean input/output interface for simulation and FPGA integration

---

## ⏱️ Latency vs Throughput Trade-off

The design intentionally increases **pipeline latency** to achieve **higher throughput**:

- Initial outputs appear after pipeline fill time
- Once filled, outputs are produced at a steady rate
- This trade-off is ideal for streaming and image-processing workloads

---

## 🧪 Verification & Testing

- Functional verification performed via simulation
- Outputs validated against software-based convolution results
- Valid-signal timing verified relative to pipeline depth

---

## 🚧 Known Limitations
- Currently supports fixed 2×2 kernel
- UART-based input/output handled externally (not integrated here)
- Expansion to larger kernels requires additional PEs and control logic

---

## 🔮 Future Improvements
- Support for larger kernel sizes (e.g., 3×3)
- Dynamic kernel loading
- Full FPGA I/O integration
- Performance benchmarking on hardware

---

## 📌 Notes
This design prioritizes **clarity, correctness, and architectural soundness** over aggressive optimization, making it suitable for academic evaluation and future extensions.

