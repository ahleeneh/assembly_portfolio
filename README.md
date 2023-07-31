# 🖥️  Portfolio Project: Strings and Macros
This portfolio project was created by Aline Murillo during the Fall 2022 term as part of Oregon State University's Computer Architecture and Assembly Language.

## 📄 Project Overview
This project written in x86 assembly language was designed to interact with the user, accept 10 signed integers in the form of strings, validate the inputs, and display the list of entered integers along with their sum and truncated average. 


## 📸 Screenshot
![Project6-Screenshot](https://github.com/ahleeneh/assembly_portfolio/assets/107948221/c425a8c3-5c32-4595-b0fc-523a804673c8)


## 📑 Project Guidelines

This project followed the course's guidelines for modularization and implements two strings for string processing.
- `mGetString`: A macro that displays a prompt, gets the user's keyboard input, and stores it into a memory location.
- `mDisplayString`: A macro that prints the string stored in a specified memory location.

Additionally, the project implements two procedures for handling signed integers using string primite instructions.
- `ReadVal`: A procedure that converts a string of ASCII digits to its numeric value representation and validates the user's input as a valid number.
- `WriteVal`: A procedure that converts a numeric SWORD value to a string of ASCII digits and prints it.

The project also adhered to strict requirements, including:
- Validating the user's numeric input the hard way by converting the string to numeric form and handling various error cases.
- Using LODSB and/or STOSB operators for dealing with strings.
- Passing all procedure parameters on the runtime stack using the STDCall calling convention.
- Passing prompts, identifying strings, and other memory locations by address to the macros.
- Saving and restoring registers by the called procedures and macros.
- Cleaning up the stack frame by the called procedure.
- Using Register Indirect addressing or string primitives for integer array elements and Base+Offset addressing for accessing parameters on the runtime stack.

## 👏 Feedback
By TA: 
>Absolutely perfect work Aline! Clear comments, solid logic, and some very smart choices in the code, especially in WriteVal. All edge cases accounted for, excellent work! Possibly the most compact WriteVal I've seen, really well done!
