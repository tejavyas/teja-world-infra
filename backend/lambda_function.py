import json
import requests

def lambda_handler(event, context):
    print("Lambda invoked!")  # ✅ Ensure this shows up in logs
    url = "https://api.coindesk.com/v1/bpi/currentprice/BTC.json"
    
    try:
        response = requests.get(url)
        data = response.json()
        print("Fetched BTC data:", data)  # ✅ Print fetched data
        
        return {
            "statusCode": 200,
            "body": json.dumps({"btc_price": data["bpi"]["USD"]["rate"]})
        }
    except Exception as e:
        print("Error:", str(e))  # ✅ Print any errors
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
}
