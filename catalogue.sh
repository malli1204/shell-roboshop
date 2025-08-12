#!/bin/bash


uid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at : $(date)" | tee -a $LOG_FILE

if [ $uid -ne 0 ] 
then 
    echo -e "$R you are not running with root user $N" | tee -a $LOG_FILE
    exit 1
else 
    echo "you are running with root user" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e "Installing $2 is $G success $N " | tee -a $LOG_FILE
    else 
        echo -e "Installing $2 is $R not succcess $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y
VALIDATE $? "disabling current module.."

dnf module enable nodejs:20 -y
VALIDATE $? "enabling 20 version module.."


dnf install nodejs -y
VALIDATE $? "Installing nodejs.."

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "adding the roboshop user.."
else 
    eche -e "user already exists so skipping"
fi

mkdir /app 
VALIDATE $? "creating app directory.."

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "loading the zip file.."

rm -rf /app/*

cd /app 
npm install 
VALIDATE $? "installing dependencies.."

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying system services.."

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "starting system services.."

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "copying mongodb repo file"

dnf install mongodb-mongosh -y
VALIDATE $? "installing mongodb.."

mongosh --host mongodb.malli12.site </app/db/master-data.js
VALIDATE $? "loading the master data.."

























# #!/bin/bash

# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# LOGS_FOLDER="/var/log/roboshop-logs"
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
# SCRIPT_DIR=$PWD

# mkdir -p $LOGS_FOLDER
# echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# # check the user has root priveleges or not
# if [ $USERID -ne 0 ]
# then
#     echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
#     exit 1 #give other than 0 upto 127
# else
#     echo "You are running with root access" | tee -a $LOG_FILE
# fi

# # validate functions takes input as exit status, what command they tried to install
# VALIDATE(){
#     if [ $1 -eq 0 ]
#     then
#         echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
#     else
#         echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
#         exit 1
#     fi
# }

# dnf module disable nodejs -y &>>$LOG_FILE
# VALIDATE $? "module disable"

# dnf module enable nodejs:20 -y &>>$LOG_FILE
# VALIDATE $? "module enable"

# dnf install nodejs -y &>>$LOG_FILE
# VALIDATE $? "installing nodejs"

# id roboshop
# if [ $? -ne 0 ]
# then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
#     VALIDATE $? "creating user"
# else 
#     echo -e "system user already created $Y SKIPPING $N"
# fi
# mkdir -p /app 
# VALIDATE $? "creating app dir"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
# VALIDATE $? "downloading catalogue"

# rm -rf /app/*
# cd /app 
# unzip /tmp/catalogue.zip &>>$LOG_FILE
# VALIDATE $? "unzipping catalogue"

# npm install &>>$LOG_FILE 
# VALIDATE $? "installing dependencies" &>>$LOG_FILE

# cp $SCRIPT_DIR/catalogue.services /etc/systemd/system/catalogue.service
# VALIDATE $? "creating services"

# systemctl daemon-reload &>>$LOG_FILE 
# systemctl enable catalogue &>>$LOG_FILE
# systemctl start catalogue &>>$LOG_FILE
# VALIDATE $? "starting the catalogue"


# cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongodb.repo

# dnf install mongodb-mongosh -y &>>$LOG_FILE
# VALIDATE $? "installing mongodb"

# STATUS=$(mongosh --host mongodb.malli12.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
# if [ $STATUS -lt 0 ]
# then
#     mongosh --host mongodb.malli12.site </app/db/master-data.js &>>$LOG_FILE
#     VALIDATE $? "Loading data into MongoDB"
# else
#     echo -e "Data is already loaded ... $Y SKIPPING $N"
# fi
