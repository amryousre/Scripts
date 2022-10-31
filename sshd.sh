#!/bin/bash

echo "Please enter new ssh port number :"
read SSHPORTNUM

if [[ ( $SSHPORTNUM -gt 1023 ) && ( $SSHPORTNUM -lt 65535 ) ]]
then
	echo
	echo "Changing The SSH Port Number..."
	sudo sed -i "s/#Port 22/Port $SSHPORTNUM/" /etc/ssh/sshd_config
	echo 
	sleep 3
	echo "Installing Packages..."
	sudo yum install policycoreutils-python -y > /dev/null
	echo
	sleep 3
	echo "Adding New Ports To Services..."
	sudo sed -i "s/22\/tcp/$SSHPORTNUM\/tcp/" /etc/services
	sudo sed -i "s/22\/udp/$SSHPORTNUM\/udp/" /etc/services
	semanage port -a -t ssh_port_t -p tcp $SSHPORTNUM
	semanage port -m -t ssh_port_t -p tcp $SSHPORTNUM
	semanage port -a -t ssh_port_t -p udp $SSHPORTNUM
	echo
	sleep 3
	echo "Enable Password Authentication..."
	sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
	echo
	sleep 3
	echo "Restarting SSH Service"
	sudo systemctl restart sshd
	sleep 10
	
	echo
	echo "Checking The New SSH Port Number :"
	sudo cat  /etc/services | grep "The Secure Shell (SSH) Protocol"
	sleep 3
	echo "Installing Firewall And Adding Rules For New SSH Port..."
	sudo yum install ufw -y > /dev/null
	sudo systemctl enable ufw
   	sudo systemctl start ufw
   	sudo ufw enable
   	sudo ufw allow ssh
   	sleep 10
   	echo "SSH port has been changed successfully..."
else
	echo "PLease Enter Port Number In Range 1023:65535"
fi
	echo
	
while true; do
	read -p "Want To Continue For Adding New User? yes|no  " ANSWER
case $ANSWER in
	[yes]* )
	echo "Enter The Name Of New User:"
	read USR
	echo "Adding User $USR"
	sudo useradd $USR
	echo "Enter The Password Of User $USR"
	read -s PASS
	sudo echo "$USR:$PASS" |sudo chpasswd
	sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
	sudo systemctl restart sshd
	sudo touch /etc/sudoers.d/$USR
	sudo echo "$USR    ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/$USR
	break;;
	[no]* ) echo "Done...";;
	* ) echo "Please answer yes or no.";;
	esac
done





