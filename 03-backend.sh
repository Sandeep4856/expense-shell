#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

useradd expense
VALIDATE $? "Creating expense user"

# if we run this code  for the first time in terminal we will get sucess response
# if we run this code 2nd time will get an error called useradd : user 'expense ' already created  
                                                    # creating user expense  .... failure 

 # i want to check wheather the user is altready exists or not i need to run this command :  id  ec2-user (will get the id info)
 # after that ill check exit status: echo $? ---> 0
 # id expense (will get the id info)
 # echo $? --> 0
 # now i want to change some modifications in the above code particularly in user expense part 


