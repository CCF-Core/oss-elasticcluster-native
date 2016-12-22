
# Introduction

This repo is for deploying the native 3 node elasticsearch cluster, based on the 5.x code based on a URL for a RPM.

This ansible can be used to 
  1. Provision a OAP ES-cluster from scratch in openstack given openstack credentials
  2. Or deploy OAP ES-cluster from scrach to a set of hosts that can be accessed with ssh keys.

When deploying to Openstack, this automation will try to ***delete*** and recreate the hosts listed in the inventory file.


#### The OAP ES Cluster deploys the following components:
* Consul for DNS services
* Elasticsearch/Logstash/Kibana 5.x
* Nginx for proxying requests.
* Docker 1.12.3 and docker-compose 0.9.
* Ansible 2.x for deployment automation.

The following are the settings that need to be updated to deploy:

Inventory folder: ansible/inventory/us-va

# Deployment

  To create an openstack cluster from scratch, the openstack instructions need to be followed in addition to the regualr deployment instructions.

## Provision openstack hosts

  - The variables that can be edited are located in the `ansible/inventory/us-va/group_vars/all`:

    ```yaml
    #Sample settings for us-va (ansible/inventory/us-va/group_vars/all)
    openstack:
      auth_url: https://us-virginia-1.cloud.cisco.com:5000/v2.0/
      availability_zone: iad10-1-csx
      image: 9e252722-8a63-43a5-bee3-c6a88e543513
      tenant: CCF-OAP-151381
      nodes_flavor: SO3-Large
      key_name: oss20
      auto_ip: no
      network: b1e9c3ec-83c9-4663-a29a-12d0101f3634
      security_groups:
        - default

    environment:
      OS_USERNAME: <username>
      OS_PASSWORD: <password>
      OS_AUTH_URL: "{{ openstack.auth_url }}"
      OS_TENANT_NAME: "{{ openstack.tenant }}"
    ```

 -  Update the inventory file to set the hosts `ansible/inventory/us-va/group_vars/us-va.yml`
    
    **__If these hosts already exist, they will be deleted and recreated__**
    ```yaml
    [consul]
    oap-control-01
    oap-control-02
    oap-control-03

    [dashboard]
    oap-web-01

    [elasticsearch]
    oap-data-01
    oap-data-02
    oap-data-03
    ```
  - Run the openstack playbook once the above two files are updated.
    ```bash
    ansible-playbook -i ansible/inventory/us-va/us-va.yml ansible/openstack.yml
    ```
  
    **This will deploy the openstack hosts.** 
  
    Once the openstack hosts are deployed, continue with the instructions for deploying the ELK cluster.

## Deploy ELK Cluster

  Follow this section to deploy an ELK cluster on a set of hosts.

  - Set inventory at `ansible/inventory/us-va/group_vars/us-va.yml` to reflect your cluster
    ```yaml
    [consul]
    oap-control-01
    oap-control-02
    oap-control-03

    [dashboard]
    oap-web-01

    [elasticsearch]
    oap-data-01
    oap-data-02
    oap-data-03
    ```
  - Deploy consul servers
    ```bash
    ansible-playbook -i ansible/inventory/us-va/us-va.yml ansible/core.yml
    ```

  - Update group_vars/all to set the values for the cluster `ansible/inventory/us-va/group_vars/all`
    ```yaml
    bind_address: "{{ ansible_eth0.ipv4.address }}"
  
    consul_ips: #these are the IPs of the consul hosts provisioned above.
      - 10.0.10.23
      - 10.0.10.24
      - 10.0.10.25
      - 8.8.8.8

    customer_id: iam #Set this to the customer id of the customer.
    ```

  - Deploy ES cluster
    ```bash
    ansible-playbook -i ansible/inventory/us-va/us-va.yml ansible/customer.yml
    ```

### Additional Notes
This Repo uses `git submodules`: 
  - First time cloning the repo: run `git submodule update --init --recursive`
  - To get latest use `git pull --recurse-submodules`
