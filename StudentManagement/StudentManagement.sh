#!/bin/bash

read -p "Enter your T.C no: " tc
read -sp "Enter your password: " password
echo

user_info=$(grep "^$tc," users.txt)

if [ -z "$user_info" ]; then
    echo "Nou user."
    exit 1
fi

stored_password=$(echo "$user_info" | cut -d ',' -f4)

if [ "$stored_password" == "$password" ]; then
    echo "Login success!"
    user_role=$(echo "$user_info" | cut -d ',' -f5)
    echo "ROLE: $user_role"
else
    echo "Invalid password."
    exit 1
fi

wait_for_keypress() {
    read -n 1 -s -r -p "Press any key to go main menu"
    echo
}

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
                read -p "TC: " new_tc
                existing_student=$(grep "^$new_tc," users.txt)
                if [ -n "$existing_student" ]; then
                  echo "Error: A student with this T.C no already in the system."
                  wait_for_keypress
                  else
                read -p "Name: " new_name
                read -p "Surname: " new_surname
                read -sp "Password: " new_password
                echo
                echo "$new_tc,$new_name,$new_surname,$new_password,normal" >> users.txt
                echo "Student added."
                wait_for_keypress
                fi
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
                    read -sp "Password: " new_password
                    echo
                    sed -i "/^$update_tc,/c\\$update_tc,$new_name,$new_surname,$new_password,normal" users.txt
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

normal_menu() {
    echo "User information:"
    echo "$user_info"
    echo "Logout..."
    exit 0
}

if [ "$user_role" == "admin" ]; then
    admin_menu
else
    normal_menu
fi
