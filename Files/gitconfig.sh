#!/bin/bash

echo "Configure Git credentials. You can press Ctrl+C at any time to cancel."
echo ""

# Validate email address format
while true; do
    read -p "Enter your email address: " email
    if [[ "$email" =~ ^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$ ]]; then
        break
    else
        echo "Invalid email format. Please try again."
    fi
done

# Validate first name (only letters)
while true; do
    read -p "Enter your First Name: " fname
    if [[ "$fname" =~ ^[A-Za-z]+$ ]]; then
        break
    else
        echo "Invalid first name. Letters only, please."
    fi
done

# Validate last name (only letters)
while true; do
    read -p "Enter your Last Name: " lname
    if [[ "$lname" =~ ^[A-Za-z]+$ ]]; then
        break
    else
        echo "Invalid last name. Letters only, please."
    fi
done

echo ""
echo "You entered:"
echo "Email:      $email"
echo "First Name: $fname"
echo "Last Name:  $lname"
echo ""

read -p "Are these details correct? (y/n) " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Setting git configuration..."
    git config --global user.email "${email}"
    git config --global user.name "${fname} ${lname}"
    git config --global http.sslVerify "false"
    git config --global credential.helper "store"

    echo -e "\nYour credentials have been set to:"
    echo "git config --global user.email:           $(git config --global user.email)"
    echo "git config --global user.name:            $(git config --global user.name)"
    echo "git config --global http.sslVerify:       $(git config --global http.sslVerify)"
    echo "git config --global credential.helper:    $(git config --global credential.helper)"

    echo ""
    echo "You can rerun this script anytime to reset your credentials."
else
    echo "No changes have been made. Please rerun the script if you want to try again."
fi

exit 0
