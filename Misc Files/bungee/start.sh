#!/bin/bash
java -XX:+UseG1GC -Xmx$1m -jar BungeeCord.jar
