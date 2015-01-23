#!/bin/bash
java -Dlog4j.configurationFile=log4j2.xml -XX:+UseG1GC -Xmx$1m -jar spigot.jar
