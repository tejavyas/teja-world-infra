
2️⃣ Manually Add a Connection ID
Try manually inserting a connection ID to test if DynamoDB works:

aws dynamodb put-item --table-name websocket_connections --item '{"connectionId": {"S": "test-connection-id"}}'

aws dynamodb scan --table-name websocket_connections