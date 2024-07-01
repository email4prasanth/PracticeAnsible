#                                       Ansible Part-1
#### Pre-requisites
- Launch server using packer AMI and assign role and install ansible required ansible core version.
- Terraform file that uses data source(AMI) and resources to launch 3 public servers

[doc reference](https://docs.ansible.com/ansible-core/devel/index.html)

1. Launch a server with the custom AMI we have created with packer(`ansibleadmin` as user) and add assume admin role (03:52) to this instance.
    - Install ansible 


2. Install the ansible controller go to docs.ansible.com selecet [ansible core](https://docs.ansible.com/ansible-core/devel/index.html) contine as follows ![ansibleinstall](https://github.com/email4prasanth/Practice/blob/master/Ansible/Images/ansibleinstall1.png) with the following commands
    ```
    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y
    ```

Ansible controller can't able to run on windows natively and we can only use winows as a ansible clinet which means we can configure windows as a client machine, though there is concept called WSL(Windows Subsystem for Linux). All the coonections between controller and client uses `SSH` connection

![Ansible Controller Support](https://github.com/email4prasanth/Practice/blob/master/Ansible/Images/ansible-controller.png)

3. Once the installation is done, validate installation by running `ansible --version` command. It shows the ansible configured paths.
> [!ssh keys]
> Here iam using DevOps key public and pvt key in  `ansible` to pull the code by pasting the public key in git repo else it will throws unauthorized.
> Here iam using same DevOps keys in `root` this will help to connect the establishment between ansible controller and ansible client else step 13 error will occur
> without doing step4 we can deploy server using terraform code and can acess the server using putty but while using ping it will show ![](ansible1)

4. Ansible configuration file is present in this path `/etc/ansible/ansible.cfg`, by default this file has so many parameters and are in disabled state. We need to enable required parameters, but to edit them we need to unlock the ansible.cfg file(by default it is disbaled) run the above command as root user 
```
sudo su -
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

5. Press `ctl+w` to search the terms
    ```
    cat /etc/ansible/ansible.cfg | grep -i host_key
    cat /etc/ansible/ansible.cfg | grep -i remote_user
    ```
    -  `host_key_checking`, when you found it by default it is in commented(;) and its value is 'True'. We need to make its value 'False' and uncomment it by removing semicolon(;) infront of it.
    - `remote_user`, uncomment it and set the value as `ansibleadmin`. By setting this value "Ansible controller" connects with the client with this username.
    - add public and privakte DevOpsKey (confirm these steps should be done in root user)


6. To create inventory file now install `unzip` and [Terraform](https://developer.hashicorp.com/terraform/downloads) binary amd64, unzip it,move the binary to /usr/local/bin and delete the downloaded zip file.
```
apt install -y unzip
cd /usr/local/bin
wget https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
ll 
unzip terraform_1.8.4_linux_amd64.zip
rm -rf terraform_1.8.4_linux_amd64.zip
terraform version
exit 
terraform version
```
7. `ssh-keygen (enter, enter, enter)` copy the pubkey of Deploy keys, allow write permission `
8. In vscode, Create `local_files.tf` and `details.tpl` **${}** is correct I use `$()` files, which we already used them in the terraform provisioners. This creates `invfile` that consists of all the public ip's of the instances.

9. In the 'Ansible controller' we need to use terraform to deploy instances(ansible clients) and connect them to ansible controller.

10. Write the terraform code to deploy 3 instances with the custom AMI ID(which was created for packer) and push to github. Install `git` in ansible controller server

11. Generate rsa_pub key using `ssh-keygen` and add that key in the github keys. Clone the repository in the `Ansible controller server` and run the terraform commands `fmt`, `validate`, `plan`, `apply`. 

12. Once infrastructure is deployed, we can observe that a `invfile` is created locally in the `ansible controller` server, if we read that file we can see the public ip's of all the 3 instances.
{
    [allservers]
    ansibleclient01 ansible_port=22 ansible_host=3.15.2.170
    ansibleclient02 ansible_port=22 ansible_host=18.221.99.135
    ansibleclient03 ansible_port=22 ansible_host=18.224.39.155
}

13. Now `Ansible controller` needs to connect to it either individually or all at time. To do that we run a command 
**`ansible -i invfile allservers -m ping`**. Instead of connecting it throws an error for all 3 instances

------
    ansibleclient01 | UNREACHABLE! => {
        "changed": false,
        "msg": "Failed to connect to the host via ssh: Warning: Permanently added '3.15.2.170' (ED25519) to the list of known hosts.\r\nansibleadmin@3.15.2.170: Permission denied (publickey).",
        "unreachable": true
    }
-----

Refer this link to [Manage Mulple SSH keys](https://www.freecodecamp.org/news/how-to-manage-multiple-ssh-keys/)

git 2.10 or later, to support multiple ssh keys configure git with new key using the following command

    -- eval $(ssh-agent) 
-everytime server reboots this ssh-agent service is stopped, we need to restart it by running this command
    
    -- ssh-add ~/.ssh/gitrsa (your_custom_generated_private_key)
-Add your custom private key to the agent. Now try to run git commands it has to work,otherwise run the following command

    -- git config core.sshCommand 'ssh -i ~/.ssh/id_rsa_corp'

`ansible -i invfile allservers -m ping`
    --To run ping on [allservers] group

`ansible -i invfile webservers -m ping`
    --To run ping on [webservers] group only

`ansible -i invfile dbservers -m ping`
    --To run ping on [dbservers] group only

`ansible -i invfile appservers -m ping`
    --To run ping on [appservers] group only

`ansible -i invfile all -m ping`
    ----To run ping on all servers
### Ansible adhoc commands

`ansible -i invfile webservers -a uptime` (Here -a represents arguments)
--This command gets the `uptime` of the webservers only, similary `free` gets you memory usage details

`ansible -i invfile ansibleclient03 -a "cat /etc/passwd"`
--In the "" we can given shell commands to run on targeted clinet/or group of clients/or on all clients

-----

Ansible supports modules, which are nothing but pre-defined libraries. [Ansible modules reference](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html)

--Lets take an example to create a user in host machines, for that go to ansible modules --> System modules --> User Module. Then type this command 

    --ansible -i invfile allservers -m user -a "name=testuser state=present shell=/bin/bash"

It will throw error that permission denied(admin/sudo access is required). To give sudo permisiions add `--become` at the end of the command(its is like sudo su -)

    --ansible -i invfile allservers -m user -a "name=testuser state=present shell=/bin/bash" --become

Similarly test the user created or not by running the following command

    --ansible -i invfile allservers -a "cat /etc/passwd" --become

Similarly delete the user by running the following command

    --ansible -i invfile allservers -m user -a "name=testuser state=absent shell=/bin/bash" --become

We can install packages using package module or you use shell module. The following command installs nginx server in all hosts.

    -- ansible -i invfile allservers -m shell -a "apt install -y nginx" --become
-----

But to install softwares, running multiple commands at a time in the hosts we need to use a concept called `ansible-playbooks`. This is a file in which we use commands/keywords to execute the required scripts or functionality. This file extension may be in ``.ini`` or ``.yaml`` formats. Majority are using `.yaml` format, beacuse it is easy to read and write keywords. Also supports many features just like json.

[Read this article once to get started with `YAML`](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)

-- `ansible-playbook -i invfile nginx_playbook.yaml --syntax-check` 
    checks the syntax

-- `ansible-playbook -i invfile nginx_playbook.yaml --check` 
    Dry run

-- `ansible-playbook -i invfile nginx_playbook.yaml` 
    Runs the playbook

You can also add `tags` to the individual plays or tasks. The advantage is that we can run playbook with specific tags only, it means only the code associated with the tag only will run.

-- `ansible-playbook -i invfile nginx_playbook.yaml --list-tags`
  It lists all the tags

-- `ansible-playbook -i invfile nginx_playbook.yaml --tags install,service`
  It runs the playbook code under which these tags `install` and `service` is associated

Added tags 
 -- syntx : git tag -a <tag> <commit-hash> -m <message>
 -- command: `git tag -a 1.0.0 5514579 -m "Added Tags to End Ansible part 1"; git push origin 1.0.0` (or  for multiple tags `git push origin --tags`)

 ansible
       ssh-keygen
   29  nano /root/.ssh/id_rsa
   30  nano /root/.ssh/id_rsa.pub
   31  ll
   32  cat id_rsa
   33  cat id_rsa.pub (copy this in git repo)
    2  git clone url
    3  cd Practice/
    4  LL
    5  ll
    6  cd Practice-Terraform/
    7  LL
    8  ll
    9  terraform init
   10  terraform validate
   11  terraform plan
   12  terraform apply --auto-approve
   13  ll
   14  cat invfile
   15  ansible -i invfile allservers -m ping
   16  terraform destroy --auto-approve
   17  git status
   18  git branch
   19  git pull AnsibleComplex
   20  git merge AnsibleComplex
   21  git stash
   22  ll
   23  git pull origin AnsibleComplex
   24  AnsibleComplex
   25  ll
   26  cat local_files.tf
   27  cat details.tpl
   28  terraformplan
   29  terraform plan
   30  terraform apply --auto-approve
   31  cat invfile
   32  ansible -i invfile allservers -m ping
   33  history
**root**
       sudo su -
    1  sudo apt update
    2  sudo apt install software-properties-common
    3  sudo add-apt-repository --yes --update ppa:ansible/ansible
    4  sudo apt install ansible -y
    7  ansible --version
   42  ansible-config init --disabled > /etc/ansible/ansible.cfg
   43  cat /etc/ansible/ansible.cfg | grep -i host_key
   44  cat /etc/ansible/ansible.cfg | grep -i remote_user
   45  nano /etc/ansible/ansible.cfg
   46  cat /etc/ansible/ansible.cfg | grep -i remote_user
   47  cat /etc/ansible/ansible.cfg | grep -i host_key
    8  apt install -y unzip
    9  cd /usr/local/bin
   10  wget https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
   11  unzip terraform_1.8.4_linux_amd64.zip
   12  cd
   13  terraform --version
   28  ssh-keygen
   29  nano /root/.ssh/id_rsa
   30  nano /root/.ssh/id_rsa.pub
   31  ll
   32  cat id_rsa
   33  cat id_rsa.pub
   55  terraform version
   56  ansible --version
   57  exit

