#!/bin/bash

# simple student management system, 2 different user type, secure login system, hashing mechanism, exception handling.
# admin can perform CRUD operation over student users.
# application will configure directory to run properly, text file will be created by application to store data if not exist.
# application will create admin user in first run.
# application will check uniqueness and format of T.C no.
# application will check format of password for secure hashing.

# Function to check T.C. format and uniqueness
# Admin and student create operations are using this function.
validate_tc() {
    local tc=$1
    if [[ ${#tc} -eq 11 && "$tc" =~ ^[0-9]+$ ]]; then
        existing_user=$(grep "^$tc," users.txt 2>/dev/null)
        if [ -n "$existing_user" ]; then
            echo "Error: A user with this T.C. no already exists in the system."
            return 1
        else
            return 0
        fi
    else
        echo "Invalid T.C. number. It must be 11 digits long and contain only numbers."
        return 1
    fi
}

# Function to check new password's format.
# Update student, create student and create admin are using this function.
validate_password() {
    local password=$1
    if [[ ${#password} -ge 8 && "$password" == *[A-Z]* && "$password" == *[a-z]* && "$password" == *[0-9]*  ]]; then
        return 0
    else
        echo "Password must be at least 8 characters long, contain at least one uppercase and lowercase letter, and one number."
        return 1
    fi
}

# If no users.txt file, create one and get the admin information from user.
if [ ! -f users.txt ]; then
  echo "Welcome to student management system. System did not find any user information file. Please set the admin information for first login."

  while true; do
    read -p "Enter admin T.C no: " admin_tc
    validate_tc "$admin_tc" && break
  done

  read -p "Enter admin name: " admin_name
  read -p "Enter admin surname: " admin_surname

  while true; do
    read -sp "Enter admin password: " admin_password
    echo
    validate_password "$admin_password" && break
  done

  # Hash admin password
  hashed_password=$(echo -n "$admin_password" | sha256sum | awk '{print $1}')
  echo "$admin_tc,$admin_name,$admin_surname,$hashed_password,admin" > users.txt
  echo "Admin created."
fi

# Take TC no and password, encrypt the password and find the user if exist, else raise error.
read -p "Enter your T.C no: " tc
read -sp "Enter your password: " password
echo
hashed_input_password=$(echo -n "$password" | sha256sum | awk '{print $1}')

user_info=$(grep "^$tc," users.txt)

if [ -z "$user_info" ]; then
    echo "No user."
    exit 1
fi

# Compare the hashed input password and hashed stored password to perform login operation.
stored_password=$(echo "$user_info" | cut -d ',' -f4)

if [ "$stored_password" == "$hashed_input_password" ]; then
    echo "Login success!"
    user_role=$(echo "$user_info" | cut -d ',' -f5)
    echo "ROLE: $user_role"
else
    echo "Invalid password."
    exit 1
fi

# Simple helper function to detect key press and direct to main menu.
wait_for_keypress() {
    read -n 1 -s -r -p "Press any key to go main menu"
    echo
}

# Admin panel to perform several actions (CRUD over student users.).
admin_menu() {
    while true; do
        echo "1) Add student"
        echo "2) List students"
        echo "3) View student info"
        echo "4) Update student info"
        echo "5) Delete student"
        echo "6) Exit"
        read -p "What do you want to do ?: " choice

        case $choice in
            1)
                while true; do
                    read -p "TC: " new_tc
                    # User already exist exception and invalid T.C format exception.
                    validate_tc "$new_tc" && break
                done

                read -p "Name: " new_name
                read -p "Surname: " new_surname
                while true; do
                    read -sp "Password: " new_password
                    echo
                    validate_password "$new_password" && break
                done
                hashed_password=$(echo -n "$new_password" | sha256sum | awk '{print $1}')
                echo "$new_tc,$new_name,$new_surname,$hashed_password,normal" >> users.txt
                echo "Student added."
                wait_for_keypress
                ;;

            2)
                echo "Student List:"
                cat users.txt
                wait_for_keypress
                ;;
            3)
                read -p "Enter student T.C no: " search_tc
                student_info=$(grep "^$search_tc," users.txt)
                if [ -z "$student_info" ]; then
                    echo "No student for given T.C no."
                else
                    echo "Student info: $student_info"
                fi
                wait_for_keypress
                ;;
            4)
                read -p "Enter student T.C to update info: " update_tc
                student_info=$(grep "^$update_tc," users.txt)
                if [ -z "$student_info" ]; then
                    echo "No student."
                else
                    read -p "Name: " new_name
                    read -p "Surname: " new_surname
                    while true; do
                        read -sp "Password: " new_password
                        echo
                        validate_password "$new_password" && break
                    done
                    hashed_password=$(echo -n "$new_password" | sha256sum | awk '{print $1}')
                    sed -i "/^$update_tc,/c\\$update_tc,$new_name,$new_surname,$hashed_password,normal" users.txt
                    echo "Update success."
                fi
                wait_for_keypress
                ;;

            5)
                read -p "Enter T.C no to delete student from system: " delete_tc
                sed -i "/^$delete_tc,/d" users.txt
                echo "Student deleted."
                wait_for_keypress
                ;;
            6)
                echo "Logout..."
                exit 0
                ;;
            *)
                echo "Invalid option."
                wait_for_keypress
                ;;
        esac
    done
}

# Simple student screen.
normal_menu() {
    echo "User information:"
    echo "$user_info"
    echo "Logout..."
    exit 0
}

# If session owner is "admin", go to admin panel.
if [ "$user_role" == "admin" ]; then
    admin_menu
else
    normal_menu
fi
