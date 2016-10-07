# swarm-cluster

This repo can be used to deploy a `docker swarm cluster` in us-va.

To deploy a cluster, 
 1. Clone this repo in us-va, 
 2. Update the inventory `environments\us-va\inventory.yml` and 
 3. Run the following command.
    ```
    ansible-playbook site.yml -i environments/us-va/inventory.yml
    ```
