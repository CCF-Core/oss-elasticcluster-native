**OSS Native Elasticsearch Cluster deployment ansible**

This repo is for deploying the native 3 node elasticsearch cluster, based on the 5.x code in the elastic repos.  

Running this ansible will deploy to an environment (based on your inventory flag).  This code will also **delete** any existing nodes that are listed in that inventory file.  This could result in data loss.  

This code will:

* Create/Destory compute nodes in the environment you select
* Update the hosts file on the localhost to point to the new ip addresses
* Update the hosts file on each of the nodes themselves
* Deploy docker on the hosts.  (for future use)
* Install Elasticsearch 5.x based on the yum repos from elastic.co

The variables that can be edited are located in the group_vars/all:

> environment_name: us-virginia-1
> 
> openstack_auth_url: https://us-virginia-1.cloud.cisco.com:5000/v2.0/
> openstack_availability_zone: iad10-1-csx openstack_image:
> 9e252722-8a63-43a5-bee3-c6a88e543513 openstack_tenant:
> OSS-20-Testing-64156 openstack_nodes_flavor: CO3-Large
> openstack_key_name: oss20 openstack_auto_ip: no
> openstack_security_groups:
>   - default
> 
> remote_user: "cloud-user"
> 
> envionment:   OS_USERNAME: oss-service.gen   OS_PASSWORD: <"Password">
> OS_AUTH_URL: "{{ openstack_auth_url }}"   OS_TENANT_NAME: "{{
> openstack_tenant }}"
> 
> 

