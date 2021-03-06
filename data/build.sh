#!/bin/bash 

# set Host system username and password, for SSH access
HOST_USER="apolloclark" # INSERT YOUR HOST USERNAME
HOST_PASS="jenkins" #INSERT YOUR HOST PASSWORD
export HOST_USER
export HOST_PASS

# set the Workspace path
export WORKSPACE_PATH="/var/lib/jenkins/jobs/discover-flask-vagrant/workspace/"

# set folder permissions, remove old test files
sudo chmod -R 777 $WORKSPACE_PATH
cd $WORKSPACE_PATH
rm -rf $WORKSPACE_PATH/*

# connect to Host Machine
sshpass -p $HOST_PASS ssh $HOST_USER@10.0.2.2 -o StrictHostKeyChecking=no -t -t <<EOF

# cd ~/Sites/discover-flask-test/vagrant-test
# delete old files, copy over new Git data
cd ~/Sites
rm -rf discover-flask-test
git clone https://github.com/apolloclark/discover-flask-vagrant discover-flask-test

# startup Vagrant, takes a while...
cd discover-flask-test/vagrant-test
vagrant up

# save out ssh key, ssh into new VM, run tests
vagrant ssh-config > vagrant-ssh
ssh -F vagrant-ssh default 'sh' < ../www/run_tests.sh

# MAY WORK
# ssh -F vagrant-ssh default 'bash -s' < /vagrant/run_tests.sh
# cat your_script.sh | ssh your_host bash

# DOES NOT WORK
# ssh -F vagrant-ssh default -t -t 'sh' < ../www/run_tests.sh

exit 0
EOF




# perform cURL test, ensure we are able to access server
curl 192.168.1.4/login?next=%2F

# run JMeter tests
jmeter -n -t /vagrant/jmeter.jmx -l $WORKSPACE_PATH/jmeter.jtl




# connect to Host Machine
sshpass -p $HOST_PASS ssh $HOST_USER@10.0.2.2 -o StrictHostKeyChecking=no -t -t <<EO3

# destroy VM, delete folder
cd ~/Sites/discover-flask-test/vagrant-test
vagrant destroy -f
rm -rf ~/Sites/discover-flask-test/
echo "  Destroyed VM image..."
exit 0
EO3
