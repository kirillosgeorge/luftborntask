#!/bin/bash

sudo apt-get update -y
sudo apt-get install nginx -y
nginx -v  
sudo systemctl start nginx
sudo systemctl enable nginx 
sudo ufw allow 'nginx full'
sudo ufw reload