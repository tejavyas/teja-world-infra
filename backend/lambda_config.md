**Follow this when you update `backend/lambda_function.py` to reconfigure the `lambda.zip`**


```sh
# just to figure out what lambda function aws is familiar with, I ran:
terraform state list | grep aws_lambda function
# recieved aws_lambda_function.teja_world_lambda
### then I forced the kill of the aforementioned with
terraform taint aws_lambda_function.teja_world_lambda
terraform apply
# this got rid of the lambda function in aws lambda and now posits a server error


cd backend
zip lambda.zip lambda_function.py
mv lambda.zip ../
cd ..
terraform apply
curl $(terraform output -raw api_gateway_url)
