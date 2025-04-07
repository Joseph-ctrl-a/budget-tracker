# Simpler Budget – A Shell-Based Budget Tracker

## Overview

**Simpler Budget** is a command-line tool designed to help users manage their personal finances by logging income and expenses, tracking the current balance, and providing useful summaries. This project was developed by **Group AA Enterprise Computer Systems** as a final project, showcasing a comprehensive use of shell scripting.

## Features

- **Add Transaction:** Log income or expense transactions with an amount, description, and date. The script validates that expenses do not exceed the available balance.
- **View Summary:** Display the complete transaction history along with the current balance.
- **Filter Transactions:** Filter the transaction log by income or expense, with the results sorted by date.
- **Check Balance:** Quickly view your current balance.
- **Clear Transactions:** Reset the transaction history (with automatic backup) after user confirmation.
- **Monthly Summary:** Aggregate and display transactions by month and year.
- **Exit:** Close the application gracefully.

## Installation & Setup

### Prerequisites

- **Bash 5.1.4** or later (tested with Git Bash on VS Code).
- A full-featured terminal (Git Bash on Windows, Linux, or macOS; Windows Subsystem for Linux is also an option).

### Steps

1. **Change Directory**
   set your current directory to budget-tracker
2. **Optional: Make it executable**
   enter the command: "chmod +x budget.sh" (no quotes) into git bash
3. **Run the Script**
   If you made the file executable (**step 2**): _./budget.sh_
   If you skipped step 2: _sh budget.sh_
4. **Using the Script**
   After running the script follow the instructions and enter a number between 1-7 and continue following instructions

# If faced with problems please contact Simpler Budget: Simpler.Budget@mail.ie

**Note: Color and Prompt Issues:**

# If you experience issues with color formatting or user prompts, verify that you are using Git Bash, WSL, or another full Bash environment.
