#!/bin/sh

# Files
BALANCE_FILE="balance.txt"
TRANSACTION_LOG="budget_data.txt"

# Color variables
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
MAGENTA="\033[35m"
RESET="\033[0m"

# Initialize menu
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
    echo -e "${YELLOW}7)${RESET} Exit"
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
        7) exit_func ;;
        *) echo -e "${RED}Invalid choice. Please enter a number between 1 and 7.${RESET}"
           sleep 1.5
           initialize ;;
    esac
}

# file checking (i used short circuting instead of if statements)
[ ! -f "$BALANCE_FILE" ] && echo "0" > "$BALANCE_FILE"
[ ! -f "$TRANSACTION_LOG" ] && echo "===== Transaction History =====" > "$TRANSACTION_LOG"
[ ! -f "budget_data.txt.bak" ] && echo "===== Transaction History Backlog =====" >> "budget_data.txt.bak"

balance=$(cat "$BALANCE_FILE")

# Add income or expense
add_transaction() {
    echo -e "${MAGENTA}Enter type of Transaction:${RESET}"
    echo -e "Enter '1' for ${GREEN}INCOME${RESET} or '2' for ${RED}EXPENSE${RESET}"
    read type
    echo -e "${MAGENTA}Enter amount:${RESET}"
    read amount

    if [ "$type" = "1" ]; then
        transaction_type="Income"
        transaction_type_colored="${GREEN}Income${RESET}"
        balance=$((balance + amount))
        echo -e "${MAGENTA}Add a short Description:${RESET}"
        read description
    elif [ "$type" = "2" ]; then
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
        echo -e "${RED}Invalid input. Please enter '1' or '2'.${RESET}"
        sleep 1.5
        add_transaction
        return
    fi

    date_today=$(date +'%Y-%m-%d')
    echo ""
    echo -e "${CYAN}Preview:${RESET} $description | $transaction_type_colored | ${YELLOW}$amount${RESET} | $date_today"
    echo ""
    echo -e "${MAGENTA}Enter ${GREEN}Y${MAGENTA} to Confirm, ${RED}X${MAGENTA} to Cancel:${RESET}"
    read confirm

    if [ "$confirm" = "Y" ]; then
        echo -e "${GREEN}Transaction confirmed!${RESET}"
        echo "$description | $transaction_type | $amount | $date_today" >> "$TRANSACTION_LOG"
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

# View transaction history
view_summary() {
    if [ $(wc -w < "$TRANSACTION_LOG") -ne 0 ]; then
        echo -e "${CYAN}Your current balance is: ${YELLOW}$balance${RESET}"
        echo ""
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

# Filter by transaction type
filter_transactions() {
    echo -e "${MAGENTA}Select filter type:${RESET}"
    echo -e "Enter '1' for ${GREEN}INCOME${RESET} or '2' for ${RED}EXPENSE${RESET}"
    read filter_choice

    case "$filter_choice" in
        1) 
            echo -e "${CYAN}Filtering ${GREEN}Income${CYAN} transactions...${RESET}"
            sleep 1
            echo ""
            grep -i "Income" "$TRANSACTION_LOG" | sort -t '|' -k4
            ;;
        2) 
            echo -e "${CYAN}Filtering ${RED}Expense${CYAN} transactions...${RESET}"
            sleep 1
            echo ""
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

# Show balance
check_balance() {
    echo -e "${CYAN}Your Balance is: ${YELLOW}$balance${RESET}"
    sleep 2.5
    initialize
}

# Reset transactions and backup
reset_transaction() {
    echo -e "${MAGENTA}Are you sure? Enter ${RED}1${MAGENTA} for 'YES' or ${GREEN}2${MAGENTA} for 'NO'${RESET}"
    read input
    if [ "$input" = "1" ]; then
        echo -e "${YELLOW}Resetting Transactions...${RESET}"
        sleep 1
        grep -v "===== Transaction History =====" "$TRANSACTION_LOG" >> "budget_data.txt.bak"
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

# Monthly summary
monthly_summary() {
    echo ""
    echo -e "${CYAN}====== Monthly Summary ======${RESET}"
    awk -F"|" -v green="$GREEN" -v red="$RED" -v reset="$RESET" '
    BEGIN {
        OFS = "|"
        printf "%-12s %-20s %-20s\n", "Month-Year", "Income", "Expense"
    }
    {
        gsub(/^ +| +$/, "", $2)
        gsub(/^ +| +$/, "", $3)
        gsub(/^ +| +$/, "", $4)
        split($4, dateParts, "-")
        monthYear = dateParts[1] "-" dateParts[2]

        if (tolower($2) == "income") {
            income[monthYear] += $3
        } else if (tolower($2) == "expense") {
            expense[monthYear] += $3
        }
    }
    END {
        for (month in income) {
            printf "%-12s %s%-20.2f%s %s%-20.2f%s\n", month, green, income[month], reset, red, expense[month], reset
        }
    }' "$TRANSACTION_LOG"
    echo ""
    echo -e "${MAGENTA}Enter any key to return to the main menu.${RESET}"
    read
    initialize
}

# Exit function
exit_func() {
    echo -e "${CYAN}Goodbye!${RESET}"
    sleep 2
    exit 0
}

# Start the script
initialize
