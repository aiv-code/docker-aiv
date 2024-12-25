#!/bin/bash

java -Xms512m -Xmx8192m --add-opens=java.base/java.nio=ALL-UNNAMED --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED -Dspring.config.location=file:./config/application.yml -Dloader.path=./config/drivers -cp ./config/:./application/aiv.jar org.springframework.boot.loader.PropertiesLauncher