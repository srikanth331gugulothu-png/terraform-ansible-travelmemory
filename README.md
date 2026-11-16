# Deploying a MERN Application Using Terraform and Ansible

## 1. Project Overview

This project demonstrates the deployment of a MERN application on AWS using Infrastructure as Code (IaC) and configuration management.

Terraform provisions AWS infrastructure, while Ansible automates server configuration, MongoDB installation and security, backend configuration, React frontend deployment and Nginx setup.

## 2. Technology Stack

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Configuration Management | Ansible |
| Frontend | React.js |
| Backend | Node.js, Express.js |
| Database | MongoDB |
| Web Server | Nginx |
| Operating System | Ubuntu 24.04 LTS |
| Version Control | Git, GitHub |

## 3. AWS Architecture

**AWS Region:** Mumbai (`ap-south-1`)

### Network Design

- VPC: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Internet Gateway for public internet access.
- NAT Gateway for private subnet outbound connectivity.

### EC2 Instances

| Instance | Type | Subnet | Purpose |
|---|---|---|---|
| Web Server | t3.small | Public | React, Node.js, Nginx |
| Database Server | t3.micro | Private | MongoDB |

Both instances use Ubuntu 24.04 LTS.

### Architecture Flow

```text
                  Internet Users
                        |
                        v
                 Internet Gateway
                        |
                        v
                Public Subnet
                  10.0.1.0/24
                        |
                        v
                 Web EC2 (t3.small)
                        |
                 +------+------+
                 |             |
                 v             v
              Nginx         React UI
                 |
                 v
           Node.js / Express
              Port 3001
                 |
                 | MongoDB Port 27017
                 v
              Private Subnet
               10.0.2.0/24
                 |
                 v
           Database EC2
             (t3.micro)
                 |
                 v
               MongoDB

Private Subnet --> NAT Gateway --> Internet Gateway
```

## 4. Terraform Infrastructure

Terraform manages the following AWS resources:

- VPC and subnets
- Internet Gateway
- NAT Gateway and Elastic IP
- Public and private route tables
- Security groups
- Web and database EC2 instances
- IAM role and instance profile
- Systems Manager permissions

### Terraform File Structure

```text
terraform/
├── provider.tf
├── variables.tf
├── main.tf
├── vpc.tf
├── subnets.tf
├── internet_gateway.tf
├── nat_gateway.tf
├── route_tables.tf
├── security_groups.tf
├── ec2.tf
├── iam.tf
├── http.tf
├── outputs.tf
└── .terraform.lock.hcl
```

### Terraform Commands

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

## 5. Ansible Automation

Ansible configures the web and database EC2 instances.

### Playbook Responsibilities

| Playbook | Description |
|---|---|
| `web_setup.yaml` | Install and configure Nginx |
| `nodejs_upgrade.yml` | Install Node.js 22 |
| `clone_app.yaml` | Clone TravelMemory application |
| `mongodb_install.yml` | Install MongoDB |
| `mongodb_security.yml` | Configure MongoDB authentication and users |
| `backend_configure.yml` | Configure backend environment |
| `backend_service.yml` | Configure backend systemd service |
| `frontend_deploy.yml` | Install dependencies and build React frontend |
| `nginx_deploy.yml` | Deploy Nginx configuration |
| `site.yml` | Master deployment playbook |

### Ansible Deployment

```bash
cd ansible

ansible-playbook -i inventory/hosts.ini site.yml --syntax-check --ask-vault-pass

ansible-playbook -i inventory/hosts.ini site.yml --ask-vault-pass
```

The database credentials are protected using Ansible Vault.

## 6. Application Deployment

### Frontend

The React application is built using:

```bash
npm ci
npm run build
```

The production build is deployed to:

`/var/www/travelmemory`

### Backend

The Express backend runs as a systemd service:

`travelmemory-backend.service`

Backend port: `3001`

The application listens on `127.0.0.1:3001`, with Nginx acting as the reverse proxy.

### Database

MongoDB runs on the private database EC2 instance.

- MongoDB port: `27017`
- Authentication enabled
- Application database: `travelmemory`
- Application user has `readWrite` access to its database.

## 7. Security Implementation

- Web SSH access restricted to the current public IP using `/32`.
- Database EC2 has no public IP address.
- MongoDB access permitted only from the web security group.
- Database SSH permitted only from the web security group.
- MongoDB authentication enabled.
- Express backend bound to localhost.
- Ansible Vault used for database credentials.
- EC2 IAM role configured with Systems Manager permissions.

**Note:** The deployed Nginx configuration currently serves HTTP on port 80. HTTPS configuration and TLS certificate installation are not included in this deployment.

## 8. Application Testing

The following tests were completed successfully:

| Test | Result |
|---|---|
| React frontend | HTTP 200 |
| Backend health endpoint | HTTP 200 |
| MongoDB connection | Connected |
| Add trip | Passed |
| View saved trip | Passed |
| Image upload | Passed |
| Persistence after refresh | Passed |

### Health Check

```bash
curl http://YOUR_WEB_PUBLIC_IP/health
```

Expected response:

```json
{
  "status": "ok",
  "db": "connected"
}
```

### Frontend Check

```bash
curl -I http://YOUR_WEB_PUBLIC_IP/
```

Expected response: `HTTP/1.1 200 OK`.

## 9. Ansible Execution Results

The master Ansible playbook completed successfully.

| Host | Tasks OK | Changed | Failed | Unreachable |
|---|---:|---:|---:|---:|
| Web Server | 32 | 6 | 0 | 0 |
| Database Server | 13 | 3 | 0 | 0 |

The initial frontend deployment had a directory-permission issue, which was corrected and incorporated into the Ansible playbook.

## 10. Project Structure

```text
terraform_ansible_travelmemory/
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── vpc.tf
│   ├── subnets.tf
│   ├── internet_gateway.tf
│   ├── nat_gateway.tf
│   ├── route_tables.tf
│   ├── security_groups.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── http.tf
│   └── outputs.tf
│
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini.example
│   ├── playbooks/
│   ├── nginx-travelmemory.conf
│   └── site.yml
│
├── .gitignore
└── README.md
```

## 11. Cost Management

AWS resources, especially NAT Gateway and Elastic IP, can incur ongoing charges.

Review AWS resources and costs after testing. Destroy infrastructure when it is no longer required and after preserving any project data you need.

```bash
cd terraform
terraform plan -destroy
terraform destroy
```

Do not destroy resources while the application or its data are still required.

## 12. Learning Outcomes

- AWS VPC networking and subnet design.
- Public and private EC2 deployment.
- Terraform infrastructure provisioning.
- Ansible configuration management.
- MongoDB installation and security.
- Node.js and React deployment.
- Nginx reverse proxy configuration.
- IAM roles and security groups.
- Infrastructure as Code and automation.
