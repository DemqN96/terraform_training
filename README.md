# Terraform EKS/VPC Infrastructure — Що зроблено і як запускати

## Що реалізовано
- AWS провайдер з регіоном `us-west-2`.
- VPC інфраструктура: `aws_vpc`, `aws_internet_gateway`, 2 публічні та 2 приватні підмережі, 1 `aws_nat_gateway` з `aws_eip`, маршрутні таблиці та асоціації.
- Безпека: `aws_security_group` для EKS кластера і нод.
- IAM: ролі для кластера і нодгрупи з політиками `AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`.
- EKS: кластер v1.28, нодгрупа (SPOT, `t3.small`, autoscaling), CloudWatch лог-група.
- Outputs: ідентифікатори/ARN/endpoint кластера, VPC ID/CIDR, списки підмереж, параметри нодгрупи.

## Структура
- `main.tf` — провайдер, IAM, SG, EKS кластер і нодгрупа, CloudWatch лог-група.
- `vpc.tf` — VPC, підмережі, IGW, NAT, маршрутні таблиці та асоціації.
- `variables.tf` — змінні (економні значення за замовчуванням).
- `outputs.tf` — корисні вихідні дані після `apply`.

## Передумови
- Встановлено: Terraform ≥ 1.0, AWS CLI, налаштовані креденшіали AWS з доступом до EKS/VPC/EC2/IAM/CloudWatch у `us-west-2`.

## Швидкий старт
```bash
cd /Users/pk/Desktop/terraform_training
terraform -version
terraform init -upgrade
terraform validate
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

Після застосування можна переглянути вихідні дані:
```bash
terraform output
```

## Налаштування kubeconfig (необовʼязково)
```bash
aws eks update-kubeconfig --name $(terraform output -raw cluster_id) --region us-west-2
kubectl get nodes
```

## Змінні (основні)
- `aws_region` (string, default: `us-west-2`)
- `cluster_name` (string, default: `test-eks-cluster`)
- `node_group_name` (string, default: `test-node-group`)
- `node_count` (number, default: `3`)
- `instance_type` (string, default: `t3.small`)
- `capacity_type` (string, default: `SPOT`)
- `project_name` (string, default: `eks-testing`)
- `environment` (string, default: `test`)
- `nat_gateway_count` (number, default: `1`)

## Видалення ресурсів
```bash
terraform destroy -auto-approve
```

## Перевірка, що все знищено
```bash
terraform state list            # має бути порожньо
terraform plan                  # має показати No changes
```
AWS (регіон `us-west-2`): відсутність кластера/нодгруп, VPC-ресурсів (VPC/Subnets/IGW/NAT/RT), SG, EIP/ENI, лог-групи, IAM ролей.

