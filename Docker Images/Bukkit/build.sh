#!/bin/bash

echo "Building Bukkit Image"
docker rmi minestack/bukkit
docker build -t="minestack/bukkit" .
echo "Finished building Bukkit Image"