**Follow this when you update `backend/lambda_function.py` to reconfigure the `lambda.zip`**

```sh
cd backend
zip lambda.zip lambda_function.py
mv lambda.zip ../
cd ..
terraform apply
curl $(terraform output -raw api_gateway_url)
