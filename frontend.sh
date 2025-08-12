#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nginx -y
VALIDATE $? "disabling current module.."

dnf module enable nginx:1.24 -y
VALIDATE $? "enabling 1.24 version module.."

dnf install nginx -y
VALIDATE $? "installing nginx.."

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "starting the system services.."

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing all the data in html file.."

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading the zip file.."

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzipping the file.."

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "removing data in conf file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "changing the configuration"

systemctl restart nginx 
VALIDATE $? "restarting the nginx service"





















# dnf module disable nginx -y &>>$LOG_FILE
# VALIDATE $? "module disable"

# dnf module enable nginx:1.24 -y &>>$LOG_FILE
# VALIDATE $? "module enable"

# dnf install nginx -y &>>$LOG_FILE
# VALIDATE $? "installing nginx"

# systemctl enable nginx &>>$LOG_FILE
# systemctl start nginx &>>$LOG_FILE
# VALIDATE $? "starting system services"

# rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
# VALIDATE $? "removing the content in html file"

# curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
# VALIDATE $? "downloading the zip file"

# cd /usr/share/nginx/html 
# unzip /tmp/frontend.zip &>>$LOG_FILE
# VALIDATE $? "unzipping the file"

# rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
# VALIDATE $? "removing data in conf file"

# cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
# VALIDATE $? "changing the configuration"

# systemctl restart nginx &>>$LOG_FILE
# VALIDATE $? "restarting system services"
