#!/bin/bash

echo "Starting Andar Bahar WebSocket Server..."
echo

cd server

echo "Installing dependencies..."
npm install

echo
echo "Starting server on port 8080..."
echo "Press Ctrl+C to stop the server"
echo

npm start 