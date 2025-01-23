import json
import boto3
import os

# DynamoDB setup
dynamodb = boto3.client("dynamodb")
DDB_TABLE = os.environ["DDB_TABLE"]

# WebSocket API Management
WEBSOCKET_MANAGEMENT_URL = os.environ["WEBSOCKET_MANAGEMENT_URL"]
apigw_client = boto3.client("apigatewaymanagementapi", endpoint_url=WEBSOCKET_MANAGEMENT_URL)

def lambda_handler(event, context):
    """Handle WebSocket connection events."""
    route_key = event.get("requestContext", {}).get("routeKey", "")

    if route_key == "$connect":
        return on_connect(event)
    elif route_key == "$disconnect":
        return on_disconnect(event)
    elif route_key == "send_message":
        return send_message(event)

def on_connect(event):
    """Store WebSocket connection ID in DynamoDB."""
    connection_id = event["requestContext"]["connectionId"]
    
    dynamodb.put_item(
        TableName=DDB_TABLE,
        Item={"connectionId": {"S": connection_id}}
    )
    
    print(f"🔌 Connected: {connection_id}")
    return {"statusCode": 200}

def on_disconnect(event):
    """Remove WebSocket connection ID from DynamoDB."""
    connection_id = event["requestContext"]["connectionId"]

    dynamodb.delete_item(
        TableName=DDB_TABLE,
        Key={"connectionId": {"S": connection_id}}
    )

    print(f"🔴 Disconnected: {connection_id}")
    return {"statusCode": 200}

def send_message(event):
    """Send a test message to all active WebSocket clients."""
    active_connections = dynamodb.scan(TableName=DDB_TABLE).get("Items", [])
    
    for conn in active_connections:
        connection_id = conn["connectionId"]["S"]
        try:
            apigw_client.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({"message": "Hello from WebSocket!"})
            )
            print(f"📨 Message sent to {connection_id}")
        except Exception as e:
            print(f"⚠️ Failed to send message to {connection_id}: {str(e)}")
    
    return {"statusCode": 200}
