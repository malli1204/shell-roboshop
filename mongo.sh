#!/bin/bash

uid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript.logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executing at : $(date)" | tee -a $LOG_FILE


if [ $uid -ne 0 ] 
then 
    echo -e "$R you are not running with root user $N" | tee -a $LOG_FILE
    exit 1
else 
    echo "you are running with root user" | tee -a $LOG_FILE
fi

validate(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 is $G success $N " | tee -a $LOG_FILE
    else 
        echo -e "$2 is $R not succcess $N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
validate $? "Copying mongodb Repo"

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "mongodb installing server"

systemctl enable mongod &>>$LOG_FILE
validate $? "mongodb enabling"

systemctl start mongod &>>$LOG_FILE
validate $? "mongodb starting"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
validate $? "changing congif to allow remote connections"

systemctl restart mongod &>>$LOG_FILE
validate $? "mongodb restarting"
