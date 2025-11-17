# 📦 Multi-Tier AWS Deployment Using Terraform

This project provisions a complete **3-tier architecture** on AWS using
Terraform.\
It includes a **VPC**, **private & public subnets**, **NAT gateways**,
**EC2 frontend**, **EC2 backend (Flask API)**, and a **MySQL RDS
database**.\
The setup automatically deploys a working full-stack application where:

- The **frontend EC2** (Apache) proxies `/api/` requests to the
  backend
- The **backend EC2** (Flask) connects to the MySQL database
- Everything is deployed inside a fully customized VPC module

---

## 📁 Project Structure

    .
    ├── main.tf
    ├── outputs.tf
    ├── backend.tf
    ├── README.md
    ├── web_app
    │   ├── frontedn
    │   │   ├── frontend.tpl
    │   │   └── index.html
    │   └── backend
    │       ├── backend.tpl
    │       └── app.py
    └── modules
        ├── vpc
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── ec2
            ├── main.tf
            ├── variables.tf
            └── outputs.tf

---

## 🚀 Architecture Overview

### **1. VPC Module**

Creates:

- Custom VPC
- Public + Private Subnets
- Internet Gateway
- NAT Gateway (per AZ optional)
- Route Tables & Associations

### **2. EC2 Module**

Reusable EC2 module supporting:

- AMI filtering
- Dynamic security group rules
- Custom user_data templates
- Tag merging
- Output of public/private IPs

### **3. Frontend Instance**

- Apache HTTPD
- Reverse proxy to backend (`/api → backend:5000`)
- Serves static HTML (`index.html`)

### **4. Backend Instance**

- Flask API
- CORS enabled
- MySQL Connector
- Auto-provisions DB + Demo Data
- Security group allowing frontedn-only access

### **5. RDS Database**

- MySQL 8.0
- Private subnets
- Security group allowing backend-only access

---

## 🧩 How the Components Talk

Component Communication

---

Frontend EC2 Uses `ProxyPass /api/ http://<backend>:5000/`
Backend EC2 Connects to RDS MySQL using private endpoint
Database Only allows access from backend subnet (10.42.3.0/24)

---

## ▶️ Deployment Instructions

### **1. Clone this repository**

```bash
git clone <your-repo-url>
cd project
```

### **2. Initialize Terraform**

```bash
terraform init
```

### **3. Validate**

```bash
terraform validate
```

### **4. Plan the infrastructure**

```bash
terraform plan
```

### **5. Deploy**

```bash
terraform apply -auto-approve
```

---

## 🌐 Accessing the App

After apply, Terraform outputs:

    public_ip = x.x.x.x

Open the app in browser:

    http://<public_ip>

You will see:

- A simple HTML page
- A list of users retrieved from the MySQL database through the backend
  API

---

## 📡 API Endpoints (Backend)

Endpoint Description

---

`/` Health check
`/users` Returns list of users from MySQL

---

## 🧪 Testing Connectivity

### Test Backend API From Frontend EC2:

```bash
curl http://<backend-private-ip>:5000/users
```

### Test DB From Backend EC2:

```bash
mysql -h <db-endpoint> -u root -p
```

---

## 🛠️ Customization

You can modify:

- `index.html` → Frontend UI
- `app.py` → Backend API
- `frontend.tpl` → Apache config
- `backend.tpl` → Database provisioning logic
- `modules/*` → VPC/EC2 infrastructure

---

## 📤 Cleanup

To destroy all resources:

```bash
terraform destroy -auto-approve
```

---

## 🧑‍💻 Author

**Kamal Sabry Mohammed**
