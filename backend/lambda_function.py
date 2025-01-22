import json
import urllib.request

def lambda_handler(event, context):
    print("Lambda invoked!")  
    url = "https://api.coindesk.com/v1/bpi/currentprice/BTC.json"
    
    try:
        response = urllib.request.urlopen(url)
        data = json.loads(response.read().decode())
        print("Fetched BTC data:", data)
        
        return {
            "statusCode": 200,
            "body": json.dumps({"btc_price": data["bpi"]["USD"]["rate"]})
        }
    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
