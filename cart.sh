#!/bin/bash
START_TIME=$(date +%s)

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

dnf module disable nodejs -y
VALIDATE $? "disabling module"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling module"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "adding the user"
else
    echo -e "user already added kindly skip"

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "downloading the zip file"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip
VALIDATE $? "unzipping the cart file"

npm install 
VALIDATE $? "installing the dependencies"

sed -i $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "updating the service files"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
VALIDATE $? "starting system services"



















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

# curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
# VALIDATE $? "downloading cart"

# rm -rf /app/*
# cd /app 
# unzip /tmp/cart.zip &>>$LOG_FILE
# VALIDATE $? "unzipping cart"

# npm install &>>$LOG_FILE 
# VALIDATE $? "installing dependencies" &>>$LOG_FILE

# cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
# VALIDATE $? "creating services"

# systemctl daemon-reload &>>$LOG_FILE 
# systemctl enable cart &>>$LOG_FILE
# systemctl start cart &>>$LOG_FILE
# VALIDATE $? "starting the cart"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "execution time , $Y time taken: $TOTAL_TIME"
