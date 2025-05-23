#!/bin/bash

# AMI_ID="ami-09c813fb71547fc4f"
# SG_ID="sg-00d233e7d20a6b130"
# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "frontend")
# ZONE_ID="Z0839647F7C8RDZW5D3P"
# DOMAIN_NAME="malli12.site"

# for instance in $@
# do
#     INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-00d233e7d20a6b130 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
#      if [ $instance != "frontend" ]
#     then
#         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
#     else
#         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
     
#     fi
#     echo "$instance IP address: $IP"
# done


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-00d233e7d20a6b130" # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0839647F7C8RDZW5D3P" # replace with your ZONE ID
DOMAIN_NAME="malli12.site" # replace with your domain
#for instance in ${INSTANCES[@]}
for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-00d233e7d20a6b130 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=test}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
 
    fi
    echo "$instance IP address: $IP"
done