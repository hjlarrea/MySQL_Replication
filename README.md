# MySQL Replication

The ARM templates included in this repository provide a solution to replicate a MySQL Server. Two options are avaibale:

1. Implement PaaS MySQL servers. Microsoft has enabled replication between MySQL PaaS instances, but all of them must be deployed in the same location.
2. Implement a Hybrid solution, where the master server is a Linux VM running MySQL and the slave nodes are MySQL PaaS instances.

Both implementations have their parameters fully documented and are accompanied by the parameters file as exmaples.

## Full PaaS solution (paas.azuredeploy.json)

This ARM template will deploy only MySQL PaaS instances. Depending on the information provided it might deploy from 1 to 6 instances. In the case of deploying only 1 (a master and 0 copies) and SQL Instance will be created and no read only copies will be deployed. Any other combination will deploy a master MySQL PaaS instance and between 1 to 5 read only replicas.

![image](/docs/img01.png)

This implementation is based on what is described in [Read replicas in Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/concepts-read-replicas)

## Hybrid solution (iaas.azuredeploy.json)

This ARM template will deploy:
- A MySQL PaaS instance
- A Network Security Group
- A Public IP
- A VNet (depends on the NSG) with a Subnet whithin (using the whole address space). The NSG is attached to the subnet.
- An Ubuntu 16.04-LTS VM (depends on the Public IP, the MySQL and the Vnet).

![image](/docs/img02.png)

The VM as part of the deployment will execute a custom script extension which will execute the install_mysql.sh script (see the scripts directory). This script will configure the VM for MySQL, install MySQL and set up replication against the MySQL PaaS component. 

All the components (PIP, NSG, VNET and VM) will be deployed in the same location as the resource group. While the MySQL PaaS server will be deployed in the indicated location (preferably a different one than the RG's), but whithin the same RG.

This implementation is based on what is described in [How to configure Azure Database for MySQL Data-in Replication](https://docs.microsoft.com/en-us/azure/mysql/howto-data-in-replication)

**IMPORTANT:** This configuration has been created as a POC, it has been written with a security-focused mindset. If you are planning to deploy this on a production environment I recommend you to:
- Change ports for internet exposed services and review NSG configuration.
- Use certificates for MySQL Replication
- Review the Linux configuration script and the IP Tables and App Armor configurations
- MySQL Allows all Azure Resource to connect to it but you might want to replace if with the Public IP address assigned to the Linux VM.