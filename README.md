# 🏦 Banking Management System (8086 Assembly Language)

A menu-driven **Banking Management System** developed in **x86 Assembly Language (8086 Architecture)** as part of the **Computer Organization and Architecture (COA)** curriculum. 

The program simulates core retail banking operations using low-level DOS interrupts (`INT 21H`), memory segmentation, stack manipulation, and modular assembly procedures.

---

## 📋 Table of Contents
- [Features](#-features)
- [Technical Specifications](#-technical-specifications)
- [System Architecture & Memory Layout](#-system-architecture--memory-layout)
- [DOS Interrupts Used](#-dos-interrupts-used)
- [Detailed Module Walkthrough](#-detailed-module-walkthrough)
  - [1. Main Menu & Navigation](#1-main-menu--navigation)
  - [2. Account Creation](#2-account-creation)
  - [3. Authentication & Login](#3-authentication--login)
  - [4. Customer Dashboard Operations](#4-customer-dashboard-operations)
  - [5. Utility Procedures (Subroutines)](#5-utility-procedures-subroutines)
- [How to Run (Execution Guide)](#-how-to-run-execution-guide)
  - [Using DOSBox with MASM / TASM](#option-a-using-dosbox-with-masm--tasm)
  - [Using EMU8086](#option-b-using-emu8086)
- [Known Limitations & Design Notes](#-known-limitations--design-notes)

---

## ✨ Features

- **Account Opening**:
  - Full Name entry (buffered string).
  - Age input (numeric validation).
  - Mobile number input (10-digit support).
  - 4-Digit Security PIN creation with strict length and character checks (`'0'`-`'9'`).
  - Initial deposit and automatic account number generation (default: `1001`).
- **Secure Authentication**:
  - Account number and 4-digit PIN verification.
  - Prevents login if no account has been registered yet.
- **Banking Operations**:
  - 💰 **Check Balance**: Displays current available funds in rupees.
  - 📥 **Deposit Money**: Accepts amount and updates balance in real time.
  - 📤 **Withdraw Money**: Validates requested amount against available balance to prevent overdrafts.
  - 🔑 **Change PIN**: Updates PIN securely with 4-digit validation.
  - 📄 **Account Details**: Displays account holder's name, age, mobile number, and account number.
  - 🚪 **Logout**: Logs out safely and redirects back to the main menu.

---

## ⚙️ Technical Specifications

| Parameter | Specification |
| :--- | :--- |
| **Target Architecture** | Intel 8086 (16-bit real mode) |
| **Memory Model** | `.MODEL SMALL` (64 KB Code segment, 64 KB Data segment) |
| **Stack Size** | `.STACK 100H` (256 bytes) |
| **Assemblers Supported** | MASM, TASM, EMU8086 |
| **Runtime Environment** | MS-DOS / DOSBox emulator |
| **Number System** | 16-bit unsigned integers (Range: `0` to `65,535`) |

---

## 🧠 System Architecture & Memory Layout

### Data Segment (`.DATA`)

The data segment holds UI strings, buffered input structures, and account state variables:

#### 1. Input Buffers (DOS Function `0AH` Format)
Buffered input requires a specific memory structure:
- Byte 0: Maximum allowed characters.
- Byte 1: Actual number of characters read (set by DOS).
- Byte 2+: The ASCII character string entered by the user.

```assembly
NAME_BUF    DB 30, 0, 31 DUP(0)     ; Buffer for Full Name (Max 30 chars)
MOBILE_BUF  DB 11, 0, 12 DUP(0)     ; Buffer for Mobile No. (Max 11 chars)
PIN_BUF     DB 5,  0, 6 DUP(0)      ; Buffer for 4-digit PIN (Max 5 chars)
NEW_PIN_BUF DB 5,  0, 6 DUP(0)      ; Buffer for New PIN
```

#### 2. Persistent Storage (Session Variables)
```assembly
NAME_DATA       DB 32 DUP('$')      ; '$'-terminated string for DOS 09H display
MOBILE_DATA     DB 12 DUP('$')      ; '$'-terminated mobile string
PIN_DATA        DB '0000'           ; 4 ASCII bytes storing active PIN
AGE             DW 0                ; 16-bit word for age
ACCOUNT_NO      DW 1001             ; Default account number
BALANCE         DW 0                ; 16-bit word for balance
ACCOUNT_CREATED DB 0                ; Flag: 0 = No account, 1 = Account created
CHOICE          DB ?                ; Menu selection temporary storage
```

---

## ⚡ DOS Interrupts Used

All I/O operations are driven via software interrupt `INT 21H`:

| Function (`AH`) | Purpose | Description in this Project |
| :---: | :--- | :--- |
| `01H` | Character Input with Echo | Reads single character choices (menu selection) into `AL`. |
| `02H` | Character Output | Prints a single character placed in `DL` (used for digit output). |
| `09H` | String Output | Displays `$`-terminated strings pointed to by `DS:DX`. |
| `0AH` | Buffered Keyboard Input | Reads full lines into structured memory buffers (Name, Mobile, PIN). |
| `4CH` | Terminate Process | Returns control back to DOS safely upon exit. |

---

## 🔍 Detailed Module Walkthrough

```
                 +-------------------+
                 |    Main Menu      |
                 | (1.Create 2.Login)|
                 +---------+---------+
                           |
            +--------------+--------------+
            |                             |
      [1. Create]                   [2. Login]
            |                             |
    * Enter Name                    * Verify Account No
    * Enter Age                     * Verify 4-digit PIN
    * Enter Mobile                        |
    * Enter 4-digit PIN           [Success]
    * Initial Deposit                     v
            |                   +-------------------+
            +------------------>|  Bank Dashboard   |
                                +---------+---------+
                                          |
        +-------------+-------------+-----+-------+-------------+
        |             |             |             |             |
   [1.Balance]   [2.Deposit]  [3.Withdraw]   [4.New PIN]   [5.Details]
```

### 1. Main Menu & Navigation
- Initializes `DS` with `@DATA`.
- Shows `TITLE_MSG` and `WELCOME` prompt.
- Reads menu option via `AH=01H`. Handles carriage return / newline flushing.
- Jumps conditionally (`JE`) to `CREATE_ACCOUNT`, `LOGIN`, or `EXIT_SYSTEM`.

### 2. Account Creation (`CREATE_ACCOUNT`)
1. **Account Existence Check**: Checks if `ACCOUNT_CREATED == 1`. If yes, returns to menu.
2. **Name & Mobile**: Reads using buffered input `AH=0AH`, then copies characters into `NAME_DATA` and `MOBILE_DATA` followed by `$` for printing.
3. **Age & Deposit**: Uses the `READ_NUMBER` procedure to convert ASCII keystrokes into 16-bit integers stored in `AGE` and `BALANCE`.
4. **PIN Validation**:
   - Enforces length == 4 characters (`CMP BYTE PTR PIN_BUF+1, 4`).
   - Validates that every character is a decimal digit (`'0'` <= char <= `'9'`).
   - If invalid, redirects to `PIN_ERROR` and prompts again.
5. **Finalization**: Sets `ACCOUNT_CREATED = 1`, prints assigned account number (`1001`), and redirects to `MAIN_MENU`.

### 3. Authentication & Login (`LOGIN`)
1. Checks `ACCOUNT_CREATED`. If `0`, displays error `"Please Create Account First!"`.
2. Asks for Account Number via `READ_NUMBER` and compares with `ACCOUNT_NO`.
3. Reads 4-digit PIN and executes a byte-by-byte comparison (`CHECK_LOGIN_PIN`) with `PIN_DATA`.
4. If match succeeds, shows `"Login Successful!"` and opens `BANK_MENU`. Otherwise jumps to `LOGIN_ERROR`.

### 4. Customer Dashboard Operations (`BANK_MENU`)
- **Check Balance (`CHECK_BALANCE`)**:
  Loads `BALANCE` into `AX` and calls `DISPLAY_NUMBER`.
- **Deposit Money (`DEPOSIT_MONEY`)**:
  Calls `READ_NUMBER`, performs `ADD BALANCE, AX`, and confirms success.
- **Withdraw Money (`WITHDRAW_MONEY`)**:
  Calls `READ_NUMBER`. Compares `CMP AX, BALANCE`.
  - If requested amount > balance (`JA`), jumps to `INSUFFICIENT_BALANCE`.
  - Otherwise subtracts `SUB BALANCE, AX` and confirms.
- **Change PIN (`CHANGE_PIN`)**:
  Prompts for a new 4-digit PIN, performs length and digit validation, copies into `PIN_DATA`, and updates credentials.
- **Account Details (`ACCOUNT_DETAILS`)**:
  Prints Name, Age, Mobile Number, and Account Number using string printing and numeric display.
- **Logout (`LOGOUT`)**:
  Clears session view and returns to the initial main menu.

### 5. Utility Procedures (Subroutines)

#### A. `READ_NUMBER` (String to 16-bit Unsigned Integer)
Converts multi-digit keyboard inputs into a single binary integer in `AX`:
- Clears `BX` (accumulator).
- Loops reading characters (`AH=01H`):
  - If Enter (`ASCII 13`), finishes conversion.
  - Ignores non-numeric characters (`< '0'` or `> '9'`).
  - Converts ASCII to integer: `AL = AL - '0'`.
  - Multiplies previous sum by 10: `AX = BX * 10`.
  - Adds new digit: `AX = AX + Digit`.
  - Saves running total back to `BX`.
- Returns result in `AX`.

#### B. `DISPLAY_NUMBER` (16-bit Unsigned Integer to ASCII)
Converts 16-bit value in `AX` to decimal representation on screen:
- Handles zero check explicitly (`CMP AX, 0`).
- Repeatedly divides by 10 (`DIV BX` where `BX = 10`):
  - Remainder in `DX` is pushed onto the stack.
  - Quotient in `AX` continues the loop until `AX == 0`.
- Pops digits from stack in reverse order, adds `'0'`, and prints each character using DOS function `AH=02H`.

---

## 🚀 How to Run (Execution Guide)

### Option A: Using DOSBox with MASM / TASM

1. **Install DOSBox** and create a working directory (e.g., `C:\dos\coa_project`).
2. Copy `bank.asm` along with the assembler tools (`MASM.EXE`, `LINK.EXE` or `TASM.EXE`, `TLINK.EXE`) into that directory.
3. Launch DOSBox and mount the directory:
   ```dos
   Z:\> mount c c:\dos\coa_project
   Z:\> c:
   ```
4. **Assemble and Link**:
   - **Using MASM**:
     ```dos
     C:\> masm bank.asm;
     C:\> link bank.obj;
     C:\> bank.exe
     ```
   - **Using TASM**:
     ```dos
     C:\> tasm bank.asm
     C:\> tlink bank.obj
     C:\> bank.exe
     ```

### Option B: Using EMU8086

1. Open **EMU8086** IDE.
2. Click **File -> Open** and select `bank.asm`.
3. Click the **Emulate** button (or press `F5`).
4. In the emulator window, click **Run** to execute the interactive banking console.

---

## 📌 Known Limitations & Design Notes

1. **In-Memory Volatile Storage**:
   Data resides in RAM during runtime. Exiting the program clears account records (no disk/file persistence).
2. **Single User Account**:
   Designed for single-account demonstration at a time (`ACCOUNT_NO = 1001`).
3. **16-Bit Word Boundary**:
   Balances and amounts are stored as 16-bit unsigned words (`DW`), limiting the maximum deposit or balance to **Rs. 65,535**.
4. **Buffer Flushing**:
   Enter key / Carriage return bytes are consumed cleanly before next menu transitions to prevent trailing newline skips.

---

### 👨‍💻 Project Context
- **Course**: Computer Organization and Architecture (COA) / Microprocessors Lab
- **Platform**: 16-bit Real Mode x86 Assembly
- **Author**: Sajal

