[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/CiscoDevNet/appd-machine-agent-installation)

|Technology|Category|Product|Languages|
|----------|--------|-------|---------|
|Cloud|Data Center,Open Source|AppDynamics|Hashicorp Configuration Language (HCL)|

# Automate deployment of virtual machines and AppDynamics Machine Agent
 This solution is an example of how to get started with monitoring and observability using AppDynamics's Machine Agent. The example details how to:
 * Use Terraform to deploy five virtual machines in vSphere followed by the installation of Apache and the AppDynamics Machine Agent using Ansible.
 * Once Terraform provisions the virtual machines, a provisioner within Terraform calls the Ansible playbook that installs Apache, Docker, and the AppDynamics Machine Agent.

The main objective is to get started with monitoring your infrastructure by showing an automated way of getting the AppDynamics agent installed, so that you have observability baked into an environment from the onset. We first start with the use case of monitoring virtual machines with follow-on use cases showing how Kubernetes clusters, databases, and applications are brought into the fold to ultimately provide a full-stack view of your operations in real time.

## Requirements

Here is a list of dependencies to make this work in your environment:

- vSphere 6.7 or higher
- Terraform v0.15.2 or higher
- Ansible 2.10.2
- AppDynamics controller instance along with its credentials
- A virtual machine template with CentOS 8.2 installed as the guest OS

## Credentials

We purposely did not add credentials and other sensitive information to the repo by including them in the `.gitignore` file. As such, if you clone this repo, you must create two files. 
- first file named `secret.tfvars` contains sensitive Terraform variables. 
- second file named `variables.yml` is used by Ansible. 
In this scenario, we encrypted `variables.yml` using the command `ansible-vault` command and decrypt it as needed locally. You could take the same approach or leave the file unencrypted if you are confident it will not be shared or inadvertently uploaded to a repo.

Here is a list of variables you must include and define for each file.

- `secret.tfvars` in HCL format (file is in the same directory as the `terraform.tfvars` file):
  - vsphere_user
  - vsphere_password
  - vsphere_server (the IP address or FQDN)
  - vsphere_vm_firmware (default is `vsphere_vm_firmware = bios`)
  - ssh-pub-key (an SSH key used with a service account that allows Ansible to connect over SSH)
  - service_account_username
  - service_account_password
- `variables.yml` (written in YAML) file:
  - CONTROLLER_HOST (the URI of the AppDynamics Controller)
  - CONTROLLER_PORT (typically 443)
  - ACCOUNT_NAME (AppDynamics Account Name)
  - MACHINE_PATH (a hierarchy that is separated with a | For example: San Jose|Rack1|)
  - ACCOUNT_ACCESS_KEY (this value is available in the AppDynamics Controller)
  - APPD_BEARER_TOKEN (is the token that is derived from the available image download via cURL)


## What Terraform Provisions

In this example, Terraform uses the `vsphere` provider and a `vsphere_virtual_machine` resource to:

- Create five virtual machines from virtual machine template.
- Add the SSH key of a service account to each host.
- Run an Ansible playbook that performs the steps in the next section.

## What Ansible Installs and Configures

After Terraform creates five virtual machines, the Ansible playbook installs and configures:

- Apache Web Server
- Firewall with port 80 opened
- Docker
- DNS (resolv.conf is configured)
- AppDynamics Machine Agent

Each Apache Web Server is configured with a custom (using a Jinja template) `index.html` page that displays the hostname.

The same approach is taken with the AppDynamics Machine Agent. In other words, a Jinja template creates a custom file for each containing the hostname.

## Creating and Applying the Terraform Plan

Here are the steps that guide you to run Terraform along with examples of each:

1. Initialize Terraform:
    
`terraform init  -var-file="secret.tfvars"`

2. Create a Terraform Plan:

`terraform plan -out appd-machine-agent-installation.tfplan -var-file="secret.tfvars"`

3. Apply the Terraform Plan:

`terraform apply -var-file="secret.tfvars"`

Each of these commands includes the `secret.tfvars` containing the sensitive variables that are needed to connect to the different resources as described in the previous section.

## Results

### Virtual Machines

You see five virtual machines that are created with static IP addresses in vSphere.

<img src="images/vsphere-virtual-machines.png" alt="Virtual Machines screenshot of the vSphere client">

### Apache Web Servers

Each Apache server has a custom `index.html` file that includes the hostname of the machine.

<img src="images/apache-server-result.png" alt="Apache Server Result">

### AppDynamics Controller

The five virtual machines appear in the AppDynamics controller, each running an Apache Web Server, and all five appearing in the AppDynamics controller.

<img src="images/appd-machine-agents.png" alt="List of Machine Agents in AppDynamics screenshot">

Click any of the check box available just before the `OS` column; then click `View Details` to see that the data reported by the Machine Agent to the AppDynamics Controller. 

You can see the data that is reported by the Machine Agent on `apache-webserver-1`.

<img src="images/appd-web-server-1.png" alt="Data reported with Load Average, CPU, Availability, and Memory">


###  Monitor HTTP as a service for extra credit

Now that you have an Apache Web Server running and you have a Machine Agent onboarded your newly created hosts, you can monitor HTTP as a service. Here's how:

1. Click `Servers` on the top navigation bar followed by `Service Availability` on the left-hand side of the AppDynamics controller user interface.
2. Click `Add`.
3. Enter a name for the service availability check (see the values we used in the example below).
4. Enter a target address (a FQDN is needed to an A record in DNS is needed).
5. Select the server that runs the check.  
   In this case, `apache-web-server-2` is used to run a check against the HTTP service running on `apache-web-server-1`.

<img src="images/add-service-monitoring-page-1.png" alt="Select the server for an AppDynamics configuration for an HTTP Check">

6. Next, click the `Response Validtor` tab followed by selecting `Add Response Validator`.
7. Keep `Status Code` and select `Equals` for the condition followed by entering a value of `200`. 
8. Explore the other options to see how many other Response Validators you can come up with.
   We chose an HTTP response of 200 to keep things simple but there are so many others to choose from. See the example below.
9. Click Save.

<img src="images/add-service-monitoring-page-2.png" alt="Select the Response Validator for an AppDynamics configuration for an HTTP Check">

After saving the configuration, you are returned to the Service Availability page where you will see your newly created Service Availability check displayed. After a few minutes, you will data about the service reported back by the machine agent as it periodically checks the health of the HTTP service running on `apache-webserver-1`. 

The server running the check is listed under the `Server` column and the monitored service is listed in the `Monitored Service` column.

<img src="images/appd-service-availability.png" alt="AppDynamics Service Availability panel screenshot">

10. To see details about the service, click the service and click `Details`.

<img src="images/appd-service-availability-details.png" alt="AppDynamics Service Availability details screenshot">

## Related Repos

Now that you are collecting metrics for machines hosting applications and their infrastructure, check out how to integrate agents into applications with a hands-on sample.

[Cloud Native Sample Bookinfo App Observability](https://developer.cisco.com/codeexchange/github/repo/CiscoDevNet/bookinfo-cloudnative-sample)

## Related DevNet Sandbox

[Cisco AppDynamics Sandbox](https://devnetsandbox.cisco.com/RM/Diagram/Index/9e056219-ab84-4741-9485-de3d3446caf2?diagramType=Topology)

## Links to DevNet Learning Labs

[AppDynamics Fundamentals](https://developer.cisco.com/learning/modules/appdynamics-fundamentals)
