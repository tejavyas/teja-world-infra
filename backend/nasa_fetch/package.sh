#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

# Remove any previous zip file
rm -f lambda.zip

# Install dependencies (if any) inside the current directory
pip install -r requirements.txt --target .

# Create a zip file with all dependencies and Lambda function
zip -r lambda.zip . -x "package.sh" "*.pyc" "__pycache__/*"

echo "NASA Lambda package lambda.zip is ready."
