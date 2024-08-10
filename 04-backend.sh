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

# useradd expense
# VALIDATE $? "Creating expense user"

# instead of the above code in the comment which i mentioned i need to replace it with the below code because it is not in idempotent in nature 

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

# lets create an app directory 

# mkdir / app 
# VALIDATE $? "creating app directory"

# for an instance  lets create a  diretory  :: mkdir /tmp/test 
# if we create the same directory will get an error called already exists
# in this case we have a command called -p if we use this -p if directory is not creates a directory. if the directory already exists it  didn't show any error message 
# why im using -p because the mkdir /app is not idempotent in nature    

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip 
VALIDATE $? "Downloading backend code"

cd /app
unzip /tmp/backend.zip 
VALIDATE $? "Extracted backend code"


npm install 
VALIDATE $? "Installing nodejs dependencies"

# vim /etc/systemd/system/backend.service
# shell scripting can't use vim it is only for humans
# so will create a file for backend.service
# in that particular file will copy the content and do some modifications 

# vim /etc/systemd/system/backend.service
# (here we take absolute path of backend.service)
# /home/ec2-user/expense-shell/backend.service



cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service 
VALIDATE $? "Copied backend service"

systemctl daemon-reload 
VALIDATE $? "Daemon Reload"

systemctl start backend 
VALIDATE $? "Starting backend"

systemctl enable backend 
VALIDATE $? "Enabling backend"

dnf install mysql -y 
VALIDATE $? "Installing MySQL Client"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql 
VALIDATE $? "Schema loading"

#here we use this at the top 
#echo "Please enter DB password:"
#read -s mysql_root_password

systemctl restart backend 
VALIDATE $? "Restarting Backend"