#!/bin/sh

# Files used for storing the current balance and transaction history
BALANCE_FILE="balance.txt"
TRANSACTION_LOG="budget_data.txt"

# Color variables for terminal output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
MAGENTA="\033[35m"
RESET="\033[0m"

# Main menu function: Clears the screen and displays options
initialize() {
    clear
    echo -e "${CYAN}==============================="
    echo "   Welcome to Simpler Budget!  "
    echo -e "===============================${RESET}"
    echo ""
    echo -e "${YELLOW}1)${RESET} Add Transaction"
    echo -e "${YELLOW}2)${RESET} View Summary"
    echo -e "${YELLOW}3)${RESET} Filter Transactions"
    echo -e "${YELLOW}4)${RESET} Check Balance"
    echo -e "${YELLOW}5)${RESET} Clear Transactions"
    echo -e "${YELLOW}6)${RESET} Monthly Summary"
    echo -e "${YELLOW}7)${RESET} Reset Balance"
    echo -e "${YELLOW}8)${RESET} Exit"
    echo ""
    echo -e "${MAGENTA}Enter choice:_${RESET}"
    read choice
    case "$choice" in
        1) add_transaction ;;
        2) view_summary ;;
        3) filter_transactions ;;
        4) check_balance ;;
        5) reset_transaction ;;
        6) monthly_summary ;;
        7) clear_balance ;;
        8) exit_func ;;
        *) echo -e "${RED}Invalid choice. Please enter a number between 1 and 7.${RESET}"
           sleep 1.5
           initialize ;;
    esac
}

# File checking using short-circuiting:
# If the file doesn't exist, create it with initial content.
[ ! -f "$BALANCE_FILE" ] && echo "0" > "$BALANCE_FILE"
[ ! -f "$TRANSACTION_LOG" ] && echo "===== Transaction History =====" > "$TRANSACTION_LOG"
[ ! -f "budget_data.txt.bak" ] && echo "===== Transaction History Backlog =====" >> "budget_data.txt.bak"

# Load current balance from the balance file.
balance=$(cat "$BALANCE_FILE")

# Function to add an income or expense transaction
add_transaction() {
    echo -e "${MAGENTA}Enter type of Transaction:${RESET}"
    # Prompt for type: 1 for Income (green) or 2 for Expense (red)
    echo -e "Enter '1' for ${GREEN}INCOME${RESET} or '2' for ${RED}EXPENSE${RESET}"
    read type
    echo -e "${MAGENTA}Enter amount:${RESET}"
    read amount

    if [ "$type" = "1" ]; then
        # For income: update balance, set plain and colored transaction type, then ask for description
        transaction_type="Income"
        transaction_type_colored="${GREEN}Income${RESET}"
        
        echo -e "${MAGENTA}Add a short Description:${RESET}"
        read description
    elif [ "$type" = "2" ]; then
        # For expense: check if balance is sufficient before subtracting amount
        transaction_type="Expense"
        transaction_type_colored="${RED}Expense${RESET}"
        if [ $((balance - amount)) -lt 0 ]; then
            echo -e "${RED}Your balance is $balance. You can't afford this expense!${RESET}"
            sleep 2
            initialize
            return
        else
            echo -e "${MAGENTA}Add a short Description:${RESET}"
            read description
            balance=$((balance - amount))
        fi
    else
        # Handle invalid input for transaction type
        echo -e "${RED}Invalid input. Please enter '1' or '2'.${RESET}"
        sleep 1.5
        add_transaction
        return
    fi

    # Get today's date in YYYY-MM-DD format
    date_today=$(date +'%Y-%m-%d')
    echo ""
    # Display a preview of the transaction with colored details
    echo -e "${CYAN}Preview:${RESET} $description | $transaction_type_colored | ${YELLOW}$amount${RESET} | $date_today"
    echo ""
    echo -e "${MAGENTA}Enter ${GREEN}Y${MAGENTA} to Confirm, ${RED}X${MAGENTA} to Cancel:${RESET}"
    read confirm

    if [ "$confirm" = "Y" ]; then
        balance=$((balance + amount))
        echo -e "${GREEN}Transaction confirmed!${RESET}"
        # Append transaction details (without color codes) to the transaction log file
        echo "$description | $transaction_type | $amount | $date_today" >> "$TRANSACTION_LOG"
        # Save the updated balance to the balance file
        echo "$balance" > "$BALANCE_FILE"
        echo -e "${CYAN}Current Balance: ${YELLOW}$balance${RESET}"
    elif [ "$confirm" = "X" ]; then
        echo -e "${RED}Transaction canceled.${RESET}"
    else
        echo -e "${RED}Invalid input. Transaction canceled.${RESET}"
    fi
    sleep 1.5
    initialize
}

# Function to display the full transaction history and current balance
view_summary() {
    if [ $(wc -w < "$TRANSACTION_LOG") -ne 0 ]; then
        echo -e "${CYAN}Your current balance is: ${YELLOW}$balance${RESET}"
        echo ""
        # Output the contents of the transaction log file
        cat "$TRANSACTION_LOG"
        echo ""
        echo -e "${MAGENTA}Enter any key to return to the main menu.${RESET}"
        read
    else
        echo -e "${RED}No transactions found yet.${RESET}"
        sleep 1.5
    fi
    initialize
}

# Function to filter transactions by type and sort them by date
filter_transactions() {
    echo -e "${MAGENTA}Select filter type:${RESET}"
    echo -e "Enter '1' for ${GREEN}INCOME${RESET} or '2' for ${RED}EXPENSE${RESET}"
    read filter_choice

    case "$filter_choice" in
        1) 
            echo -e "${CYAN}Filtering ${GREEN}Income${CYAN} transactions...${RESET}"
            sleep 1
            echo ""
            # Filter lines containing "Income" and sort by the date field (4th field)
            grep -i "Income" "$TRANSACTION_LOG" | sort -t '|' -k4
            ;;
        2) 
            echo -e "${CYAN}Filtering ${RED}Expense${CYAN} transactions...${RESET}"
            sleep 1
            echo ""
            # Filter lines containing "Expense" and sort by the date field (4th field)
            grep -i "Expense" "$TRANSACTION_LOG" | sort -t '|' -k4
            ;;
        *)
            echo -e "${RED}Invalid input. Please enter '1' or '2'.${RESET}"
            sleep 2
            filter_transactions
            return
            ;;
    esac

    echo ""
    echo -e "${MAGENTA}Enter any key to return to the main menu.${RESET}"
    read
    initialize
}

# Function to display the current balance
check_balance() {
    echo -e "${CYAN}Your Balance is: ${YELLOW}$balance${RESET}"
    sleep 2.5
    initialize
}

# Function to reset all transactions after user confirmation,
# and back up the existing transaction history.
reset_transaction() {
    echo -e "${MAGENTA}Are you sure? Enter ${RED}1${MAGENTA} for 'YES' or ${GREEN}2${MAGENTA} for 'NO'${RESET}"
    read input
    if [ "$input" = "1" ]; then
        echo -e "${YELLOW}Resetting Transactions...${RESET}"
        sleep 1
        # Backup the transaction log (excluding header) to a backup file
        grep -v "===== Transaction History =====" "$TRANSACTION_LOG" >> "budget_data.txt.bak"
        # Remove the balance and transaction log files, then reset balance to 0
        [ -f "$BALANCE_FILE" ] && rm "$BALANCE_FILE" 
        rm "$TRANSACTION_LOG"
        balance=0
        echo -e "${GREEN}Transactions have been reset.${RESET}"
        echo "0" > "$BALANCE_FILE"
    elif [ "$input" = "2" ]; then
        echo -e "${CYAN}Canceled.${RESET}"
    else 
        echo -e "${RED}Invalid Input, please try again later.${RESET}"
    fi
    sleep 2
}

# Function to generate a monthly summary of transactions using awk.
# It aggregates income and expense totals for each Month-Year.
monthly_summary() {
    # Print an empty line for spacing
    echo ""
    # Print the "Monthly Summary" header in CYAN color
    echo -e "${CYAN}====== Monthly Summary ======${RESET}"
    
    # Use awk to process the transaction log:
    # - Field separator is "|" 
    # - Pass color variables to awk for formatting the output
    awk -F"|" -v green="$GREEN" -v red="$RED" -v reset="$RESET" '
    BEGIN {
        # Set the output field separator to "|"
        OFS = "|"
        # Print header row with column titles: Month-Year, Income, Expense
        printf "%-12s %-20s %-20s\n", "Month-Year", "Income", "Expense"
    }
    {
        # Remove leading and trailing spaces from fields 2, 3, and 4
        gsub(/^ +| +$/, "", $2)
        gsub(/^ +| +$/, "", $3)
        gsub(/^ +| +$/, "", $4)
        
        # Split the date (field 4) using "-" as the delimiter and form Month-Year
        split($4, dateParts, "-")
        monthYear = dateParts[1] "-" dateParts[2]

        # Aggregate amounts based on transaction type
        if (tolower($2) == "income") {
            income[monthYear] += $3
        } else if (tolower($2) == "expense") {
            expense[monthYear] += $3
        }
    }
    END {
        # Loop through each month and print the totals with color formatting
        for (month in income) {
            printf "%-12s %s%-20.2f%s %s%-20.2f%s\n", month, green, income[month], reset, red, expense[month], reset
        }
    }' "$TRANSACTION_LOG"
    
    # Print a blank line for spacing after the summary table
    echo ""
    # Prompt the user to press any key to return to the main menu
    echo -e "${MAGENTA}Enter any key to return to the main menu.${RESET}"
    # Wait for user input
    read
    # Return to the main menu by calling the initialize function
    initialize
}

# Function to clear the balance
clear_balance() {
    rm balance.txt
    echo -e "${YELLOW}resetting balance...${RESET}"
    sleep 1.5
    [ ! -f "$BALANCE_FILE" ] && echo "0" > "$BALANCE_FILE"
    echo -e "${YELLOW}Balance reset successful!${RESET}"
    sleep 1.5
    initialize
}

# Function to exit the script 
exit_func() {
    echo -e "${CYAN}Goodbye!${RESET}"
    sleep 2
    exit 0
}

# Start the script by calling the initialize function
initialize
