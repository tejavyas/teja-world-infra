import json
import requests

def lambda_handler(event, context):
    url = "https://api.coindesk.com/v1/bpi/currentprice/BTC.json"
    response = requests.get(url)
    data = response.json()

    return {
        "statusCode": 200,
        "body": json.dumps({
            "btc_price": data["bpi"]["USD"]["rate"]
        })
    }