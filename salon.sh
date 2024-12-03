#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

MAIN_MENU(){
  echo -e "\nWelcome to the Salon\n"
  echo -e "\nList of Services:"
  OPTIONS=$( $PSQL "SELECT name FROM services;" | nl -s ') ' -w 1 )
  echo -e "\n$OPTIONS\nWhat service would you like? Please enter a valid service number (1-3) or 4 to quit: "
  read SERVICE_ID_SELECTED  
  while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ || "$SERVICE_ID_SELECTED" -ge 5 ]]
  do
    echo -e "\nInvalid choice.\n"
    echo -e "List of Services:\n$OPTIONS\nPlease enter a valid service number (1-3) or 4 to quit: "
    read SERVICE_ID_SELECTED
  done

  if [[ "$SERVICE_ID_SELECTED" == 4 ]]
  then
    echo "Thanks for Coming"
  else
    SCHEDULER "$SERVICE_ID_SELECTED"
  fi
}

SCHEDULER(){
  SERVICE_ID_SELECTED=$1
  echo -e "\nScheduling appointment for service #$SERVICE_ID_SELECTED\n"
  echo "Provide a phone number: "
  read CUSTOMER_PHONE
  VALID_PHONE=$($PSQL "SELECT COUNT(*) from CUSTOMERS where phone='$CUSTOMER_PHONE';")
  if (( $VALID_PHONE == 0 ))
  then
    echo -e "\nAh. A new customer. What is your name?"
    read CUSTOMER_NAME
    CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
    if [[ $? -eq 0 ]]; then
      echo "Customer inserted successfully!"
    else
      echo "Error inserting customer: $CUSTOMER_RESULT"
    fi
  fi
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE';")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  if [[ $? -eq 0 ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  else
    echo "Error making appointment: $APPOINTMENT_RESULT"
  fi
}

MAIN_MENU
