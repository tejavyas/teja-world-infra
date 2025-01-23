import os
import json
import urllib.request
import boto3

# Retrieve WebSocket Management URL from environment variable
WEBSOCKET_URL = os.environ["WEBSOCKET_MANAGEMENT_URL"]
apigw_client = boto3.client("apigatewaymanagementapi", endpoint_url=WEBSOCKET_URL)

def send_websocket_update(message):
    """Send a message to connected WebSocket clients."""
    try:
        apigw_client.post_to_connection(
            ConnectionId="YOUR-CONNECTION-ID",  # Retrieve this dynamically
            Data=json.dumps(message)
        )
        print("WebSocket update sent:", message)
    except Exception as e:
        print("WebSocket Error:", str(e))

def lambda_handler(event, context):
    # NASA API Key (replace "DEMO_KEY" with your real key if needed)
    nasa_api_key = "DEMO_KEY"
    url = f"https://api.nasa.gov/DONKI/notifications?api_key={nasa_api_key}"

    try:
        response = urllib.request.urlopen(url)
        data = json.loads(response.read())

        # Get latest NASA space weather event, or empty object if none
        latest_event = data[0] if data else {}

        send_websocket_update({"nasa_data": latest_event})

        return {
            "statusCode": 200,
            "body": json.dumps({"nasa_data": latest_event})
        }
    except Exception as e:
        print("Error fetching NASA data:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
