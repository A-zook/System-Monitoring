#The script sets up and manages an AWS S3 bucket using the AWS CLI.

#Check AWS CLI Version
aws --version

#Configure AWS Credentials
aws configure

#List Existing S3 Buckets
aws s3 ls

#Create New S3 Bucket
aws s3api create-bucket --bucket azi.first.bucket --region us-east-1

#Set Public Access Block for the Bucket
aws s3api put-public-access-block --bucket azi.first.bucket --public-access-block-configuration 
BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

#Upload a File to S3
aws s3 cp "C:\Users\UserName\test-file.txt" s3://azi.first.bucket/

#Generate a Pre-Signed URL
aws s3 presign s3://azi.first.bucket/test-file.txt --expires-in 10800


