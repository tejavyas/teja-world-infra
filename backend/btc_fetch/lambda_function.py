import json
import os
import urllib.request
import boto3

# Initialize AWS clients
dynamodb = boto3.client("dynamodb")
apigw_client = boto3.client("apigatewaymanagementapi", endpoint_url=os.environ["WEBSOCKET_MANAGEMENT_URL"])

DDB_TABLE = "WebSocketConnections"  # Change this to match your DynamoDB table name

def send_websocket_update():
    """Fetch BTC price and send to all connected WebSocket clients"""
    try:
        # Fetch BTC price
        url = "https://api.coindesk.com/v1/bpi/currentprice/BTC.json"
        response = urllib.request.urlopen(url)
        data = json.loads(response.read().decode())
        btc_price = data["bpi"]["USD"]["rate"]

        # Get all active WebSocket connections
        connections = dynamodb.scan(TableName=DDB_TABLE).get("Items", [])
        
        # Send message to all connected clients
        for connection in connections:
            connection_id = connection["connectionId"]["S"]
            try:
                apigw_client.post_to_connection(
                    ConnectionId=connection_id,
                    Data=json.dumps({"btc_price": btc_price})
                )
                print(f"Sent BTC Price to {connection_id}: {btc_price}")
            except Exception as e:
                print(f"Failed to send to {connection_id}: {str(e)}")

    except Exception as e:
        print(f"Error fetching BTC price: {str(e)}")

def lambda_handler(event, context):
    """Lambda entry point"""
    send_websocket_update()
    return {"statusCode": 200}
