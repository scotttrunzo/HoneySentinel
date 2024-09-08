# HoneySentinel
A script to generate honeyfiles and subsequently monitor and send alerts for unauthorized access to the honeyfiles in Linux systems.  


### Installation
1. Clone the repository:
   git clone https://github.com/scotttrunzo/HoneySentinel.git
   

### Requirements
  Required Tools:  
         - Linux system (tested on Kali Linux)  
         - inotify-tools  
         - Postfix  
         

   Install Required Tools:  
   
   sudo apt-get install inotify-tools mailutils  
   sudo apt-get install postfix  
                  - choose "Internet Site" option upon installation  
               
 
### Usage  
1. Modifications
   
     Modify the script in the commented portions with your desired information.  
       - Modify the email address in the send_email_alert function to the email address where you wish to receive the notifications.  
       - Modify the file directory path where you wish the Honeyfiles to be housed. Directories such as /etc or /var/www is a more convincing location for confidential file baiting.  
       - Modify the allowed IPs to whitelist yourself (your own IP address) and other IP addresses you wish to allow access over the files and to ensure most importantly they are not blacklisted upon accessing the files.  
       - If you wish, modify the log destinations to your desired logs.
   

2.  Ensure postfix is running before running the script
   
       sudo systemctl start postfix  
       sudo systemctl enable postfix

3.  Run script with sudo to ensure proper permissions.
   
       sudo ./HoneySentinel.sh

    

