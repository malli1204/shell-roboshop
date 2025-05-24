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

echo "please enter root password"
read -s MYSQL_ROOT_PASSWORD

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

dnf install maven -y
VALIDATE $? "Installing maven"

d roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "creating user"
else 
    echo -e "system user already created $Y SKIPPING $N"
fi
mkdir -p /app 
VALIDATE $? "creating app dir"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "downloading shipping"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package 
VALIDATE $? "packaging the shipping application"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving the jar file"

cp $SCRIPT_DIR/shipping.services /etc/systemd/system/shipping.service

systemctl daemon-reload
VALIDATE $? "reloading thee system"

systemctl enable shipping 
systemctl start shipping
VALIDATE $? "startinh the system service"

dnf install mysql -y 
VALIDATE $? "installing the mysql"

mysql -h mysql.malli12.site -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h mysql.malli12.site -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h mysql.malli12.site -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "loading the data"

systemctl restart shipping
VALIDATE $? "restarting the data"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "execution time , $Y time taken: $TOTAL_TIME"