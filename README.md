# RISC-V RV32I CPU 설계 및 시뮬레이션

> SystemVerilog로 구현한 32비트 RISC-V 기본 정수 명령어(RV32I) 단일 사이클 프로세서

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [RISC-V 소개](#risc-v-소개)
3. [아키텍처 설계](#아키텍처-설계)
4. [모듈 구조](#모듈-구조)
5. [명령어 지원 목록](#명령어-지원-목록)
6. [파일 구조](#파일-구조)
7. [시뮬레이션 결과](#시뮬레이션-결과)
8. [Troubleshooting](#troubleshooting)

---

## 프로젝트 개요

본 프로젝트는 RISC-V RV32I ISA를 기반으로 한 **단일 사이클(Single-Cycle) 32비트 프로세서**를 SystemVerilog로 설계하고 Vivado 시뮬레이터로 검증한 결과물입니다.

| 항목 | 내용 |
|------|------|
| **구현 언어** | SystemVerilog |
| **대상 ISA** | RISC-V RV32I |
| **구현 방식** | Single-Cycle |
| **지원 명령어 타입** | R / I / S / B / U / J |
| **레지스터 파일** | 32개 범용 레지스터 (x0 ~ x31) |
| **데이터 폭** | 32bit |

---

## RISC-V 소개

RISC-V는 2010년 UC Berkeley에서 개발한 **오픈소스 ISA(Instruction Set Architecture)** 입니다.

### 타 ISA와의 비교

| 항목 | RISC-V | ARM | x86 |
|------|--------|-----|-----|
| 라이선스 | 무료 ✅ | 유료 ❌ | 유료 ❌ |
| 명령어 수 | 적음 | 중간 | 매우 많음 |
| 구조 | RISC | RISC | CISC |
| 오픈소스 | ✅ | ❌ | ❌ |
| 커스터마이징 | 자유 ✅ | 제한적 | 불가 |

### RV32I 핵심 특징

- **32개 범용 레지스터** (x0 ~ x31, 각 32비트 폭)
- **x0 레지스터** : 항상 0 고정 (하드와이어드)
- **고정폭 명령어** : 모든 명령어 32비트 → 디코딩 단순화
- **Load/Store 구조** : 메모리 접근은 LW/SW 명령어만 담당
- **Little-Endian** : 낮은 주소에 하위 바이트 저장

---

## 아키텍처 설계

### Block Diagram

```
         ┌──────────────────────────────────────────────────────┐
         │                   RV32I_cpu                          │
         │                                                      │
         │  ┌──────────────┐    ┌─────────────────────────────┐ │
instr ──►│  │ control_unit │    │      RV32I_datapath         │ │
_data    │  │              │    │  ┌──────────┐  ┌─────────┐  │ │
         │  │  rf_we  ────►│───►│  │register_ │  │  imm_   │  │ │
         │  │  jal    ────►│    │  │  file    │  │extender │  │ │
         │  │  jalr   ────►│    │  └──────────┘  └─────────┘  │ │
         │  │  alusrc ────►│    │  ┌──────────┐  ┌─────────┐  │ │
         │  │  branch ────►│    │  │   alu    │  │   pc    │  │ │
         │  │  alu_   ────►│    │  └──────────┘  └─────────┘  │ │
         │  │  control     │    │  ┌──────────┐               │ │
         │  │  dwe    ────►│───►│  │ mux_5x1  │               │ │
         │  └──────────────┘    │  └──────────┘               │ │
         │                      └─────────────────────────────┘ │
         └──────────────────────────────────────────────────────┘
              │                              │
              ▼                              ▼
         instr_mem                       data_mem
```

### 서브 모듈 역할

| 모듈 | 역할 |
|------|------|
| `program_counter` | PC 관리 및 주소 계산 |
| `register_file` | x0 ~ x31 레지스터 읽기/쓰기 |
| `imm_extender` | 명령어 타입별 즉시값 부호 확장 |
| `alu` | 산술·논리·분기 연산 |
| `data_mem` | 데이터 메모리 R/W (바이트/하프워드/워드) |
| `control_unit` | 명령어 디코딩 및 제어신호 생성 |

---

## 모듈 구조

### 명령어 타입별 비트 필드

| 비트 필드 | 역할 |
|-----------|------|
| `opcode [6:0]` | 명령어 타입 구분 (R/I/S/B/U/J) |
| `funct3 [14:12]` | 세부 연산 종류 구분 |
| `funct7 [31:25]` | R-type 추가 구분 (ADD/SUB 분리) |
| `rs1 [19:15]` | 첫 번째 소스 레지스터 번호 |
| `rs2 [24:20]` | 두 번째 소스 레지스터 번호 |
| `rd [11:7]` | 목적지 레지스터 번호 |

### Control Unit Truth Table

| opcode | rf_we | jal | jalr | alusrc | branch | alu_control | rfwdsrc_sel | dwe |
|--------|-------|-----|------|--------|--------|-------------|-------------|-----|
| R_TYPE | 1 | 0 | 0 | 0 | 0 | {0,funct7[5],funct3} | 3'b000 | 0 |
| S_TYPE | 0 | 0 | 0 | 1 | 0 | ADD | - | 1 |
| IL_TYPE | 1 | 0 | 0 | 1 | 0 | ADD | 3'b001 | 0 |
| II_TYPE | 1 | 0 | 0 | 1 | 0 | {0,funct3} | 3'b000 | 0 |
| B_TYPE | 0 | 0 | 0 | 0 | 1 | {10,funct3} | - | 0 |
| LUI_TYPE | 1 | 0 | 0 | - | 0 | - | 3'b010 | 0 |
| AUIPC_TYPE | 1 | 0 | 0 | - | 0 | - | 3'b011 | 0 |
| JAL_TYPE | 1 | 1 | 0 | - | 1 | - | 3'b100 | 0 |
| JALR_TYPE | 1 | 1 | 1 | - | 1 | - | 3'b100 | 0 |

---

## 명령어 지원 목록

### R-type (레지스터 ↔ 레지스터 연산)

| 명령어 | 동작 | funct3 | funct7 |
|--------|------|--------|--------|
| ADD | rd = rs1 + rs2 | 000 | 0000000 |
| SUB | rd = rs1 - rs2 | 000 | 0100000 |
| AND | rd = rs1 & rs2 | 111 | 0000000 |
| OR  | rd = rs1 \| rs2 | 110 | 0000000 |
| XOR | rd = rs1 ^ rs2 | 100 | 0000000 |
| SLL | rd = rs1 << rs2[4:0] | 001 | 0000000 |
| SRL | rd = rs1 >> rs2[4:0] | 101 | 0000000 |
| SRA | rd = rs1 >>> rs2[4:0] | 101 | 0100000 |
| SLT | rd = (rs1 < rs2) ? 1:0 (signed) | 010 | 0000000 |
| SLTU | rd = (rs1 < rs2) ? 1:0 (unsigned) | 011 | 0000000 |

### I-type (즉시값 연산 / 메모리 로드)

**II_TYPE (즉시값 연산)**

| 명령어 | 동작 |
|--------|------|
| ADDI | rd = rs1 + imm |
| SLTI | rd = (rs1 < imm) ? 1:0 (signed) |
| SLTIU | rd = (rs1 < imm) ? 1:0 (unsigned) |
| XORI | rd = rs1 ^ imm |
| ORI | rd = rs1 \| imm |
| ANDI | rd = rs1 & imm |
| SLLI | rd = rs1 << imm[4:0] |
| SRLI | rd = rs1 >> imm[4:0] |
| SRAI | rd = rs1 >>> imm[4:0] |

**IL_TYPE (메모리 로드)**

| 명령어 | 동작 | 타입 |
|--------|------|------|
| LW | rd = M[rs1+imm][31:0] | - |
| LH | rd = M[rs1+imm][15:0] | signed |
| LHU | rd = M[rs1+imm][15:0] | unsigned |
| LB | rd = M[rs1+imm][7:0] | signed |
| LBU | rd = M[rs1+imm][7:0] | unsigned |

### S-type (메모리 저장)

| 명령어 | 저장 크기 | 동작 |
|--------|-----------|------|
| SW | 32bit (4byte) | M[rs1+imm] = rs2[31:0] |
| SH | 16bit (2byte) | M[rs1+imm] = rs2[15:0] |
| SB | 8bit (1byte) | M[rs1+imm] = rs2[7:0] |

### B-type (조건부 분기)

| 명령어 | 조건 | 타입 |
|--------|------|------|
| BEQ | rs1 == rs2 | - |
| BNE | rs1 != rs2 | - |
| BLT | rs1 < rs2 | signed |
| BGE | rs1 >= rs2 | signed |
| BLTU | rs1 < rs2 | unsigned |
| BGEU | rs1 >= rs2 | unsigned |

> 조건 참 → PC = PC + imm / 조건 거짓 → PC = PC + 4

### U-type (상위 20비트 즉시값)

| 명령어 | 동작 |
|--------|------|
| LUI | rd = imm (상위 20bit에 적재) |
| AUIPC | rd = PC + imm |

### J-type (무조건 점프)

| 명령어 | 점프 기준 | 점프 범위 | 주요 용도 |
|--------|-----------|-----------|-----------|
| JAL | PC = PC + imm / rd = PC+4 | ±1MB | 함수 호출 |
| JALR | PC = rs1 + imm / rd = PC+4 | 레지스터 기반, 범위자유 | 함수 복귀 |

---

## 파일 구조

```
.
├── define.vh              # opcode, funct3/7, alu_control 매크로 정의
├── RV32I_top.sv           # 최상위 모듈 (cpu + instr_mem + data_mem 연결)
├── RV32I_cpu.sv           # CPU 최상위 (control_unit + datapath)
│   ├── control_unit       # 명령어 디코딩, 제어신호 생성
├── RV32I_datapath.sv      # 데이터패스 (PC, RF, IMM, ALU, MUX 등)
│   ├── program_counter    # PC 관리 및 분기/점프 주소 계산
│   ├── register_file      # 32개 범용 레지스터
│   ├── imm_extender       # 즉시값 부호 확장
│   ├── alu                # 산술/논리/분기 연산
│   ├── mux_2x1            # 2:1 멀티플렉서
│   ├── mux_5x1            # 5:1 멀티플렉서 (writeback 선택)
│   ├── branch_and         # branch & btaken → branch_sel
│   └── or_gate            # jal | branch_sel
└── data_mem.sv            # 데이터 메모리 (SB/SH/SW, LB/LH/LW/LBU/LHU)
```

---

## 시뮬레이션 결과

### R-type 검증 (초기값: x15=-1, x16=-16)

| 명령어 | 계산식 | 예상값 → 결과값 |
|--------|--------|----------------|
| ADD | 1 + 2 = 3 | 3 ✅ |
| SUB | 5 - 3 = 2 | 2 ✅ |
| SLL | 00011 → 01100 = 12 | 12 ✅ |
| SLT | -1 < 5 성립 → 1 | 1 ✅ |
| SLTU | 0xFFFF_FFFF < 5 불성립 → 0 | 0 ✅ |
| XOR | 0111 ^ 0101 = 0010 | 2 ✅ |
| SRL | 1111…1111_0000 >> 2 (논리) | 536870910 ✅ |
| SRA | 1111…1111_0000 >> 2 (산술) | -2 ✅ |
| OR  | 1001 \| 0110 = 1111 | 15 ✅ |
| AND | 1100 & 1010 = 1000 | 8 ✅ |

### C언어 통합 시뮬레이션 (sum program)

```c
int adder(int a, int b);
void main(void) {
    int i = 0;
    int sum = 0;
    while(i < 11) {
        sum = adder(i, sum);
        i = i + 1;
    }
    return;
}
int adder(int a, int b) {
    return a + b;
}
```

- **예상 결과** : 0 + 1 + 2 + ... + 10 = **55**
- **최종 검증** : `reg[10] = 55` ✅
- SP 초기화(400) → 함수 호출마다 프레임 확보(368 ↔ 336) → 루프 탈출 후 SP 복원(400) 확인

---

## Troubleshooting

### SB/SH 명령어 저장 위치 오류

**문제**  
기존 코드는 `daddr[31:2]`(word 주소)만 사용하여 항상 같은 하위 8bit에만 저장됨.  
→ `daddr[1:0]` (세부 주소값) 무시

**해결**  
- SB → `daddr[1:0]`으로 저장 위치 결정 (4가지 바이트 위치)
- SH → `daddr[1]`로 저장 위치 결정 (상위/하위 16bit 선택)

```verilog
// Before (잘못된 코드)
`SB: data_mem[daddr[31:2]] <= {data_mem[daddr[31:2]][31:8], dwdata[7:0]};

// After (수정된 코드)
`SB: begin
    case (daddr[1:0])
        2'b00: data_mem[daddr[31:2]] <= {data_mem[daddr[31:2]][31:8],  dwdata[7:0]};
        2'b01: data_mem[daddr[31:2]] <= {data_mem[daddr[31:2]][31:16], dwdata[15:8],  data_mem[daddr[31:2]][7:0]};
        2'b10: data_mem[daddr[31:2]] <= {data_mem[daddr[31:2]][31:24], dwdata[23:16], data_mem[daddr[31:2]][15:0]};
        2'b11: data_mem[daddr[31:2]] <= {dwdata[31:24], data_mem[daddr[31:2]][23:0]};
    endcase
end
```

---

## 참고

- RISC-V 공식 스펙: [https://riscv.org/technical/specifications/](https://riscv.org/technical/specifications/)
- 작성일: 2026.03.17
- 작성자: 윤지원
