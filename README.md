# Amazon EKS Terraform Configuration

Ця конфігурація Terraform розгортає Amazon Elastic Kubernetes Service (EKS) кластер з 3 робочими вузлами без використання модулів та хард-коду.

## Архітектура

- **VPC**: Створюється з публічними та приватними підмережами в 2 AZ
- **EKS Cluster**: Розгортається з версією Kubernetes 1.28
- **Node Group**: 3 віртуальні машини типу t3.medium
- **Networking**: NAT Gateways для приватних підмереж, Internet Gateway для публічних

## Передумови

1. **AWS CLI** встановлений та налаштований
2. **Terraform** версії >= 1.0
3. **kubectl** для роботи з кластером
4. **AWS credentials** налаштовані (aws configure або environment variables)

## Файли конфігурації

- `main.tf` - Основна конфігурація провайдера AWS
- `variables.tf` - Змінні для налаштування
- `vpc.tf` - Мережева інфраструктура (VPC, підмережі, маршрути)
- `eks.tf` - EKS кластер та необхідні IAM ролі
- `node-group.tf` - Група робочих вузлів
- `outputs.tf` - Вивід важливої інформації

## Налаштування змінних

Всі параметри налаштовуються через змінні у файлі `variables.tf`:

```hcl
variable "aws_region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "node_count" {
  default = 3
}

variable "instance_type" {
  default = "t3.medium"
}
```

## Розгортання

1. **Ініціалізація Terraform:**
```bash
terraform init
```

2. **Перегляд плану розгортання:**
```bash
terraform plan
```

3. **Застосування конфігурації:**
```bash
terraform apply
```

4. **Підтвердження:** Введіть `yes` для підтвердження розгортання

## Налаштування kubectl

Після успішного розгортання налаштуйте kubectl:

```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

Або використайте output з Terraform:
```bash
aws eks update-kubeconfig --region $(terraform output -raw aws_region) --name $(terraform output -raw cluster_name)
```

## Перевірка кластера

```bash
# Перевірка вузлів
kubectl get nodes

# Перевірка системних подів
kubectl get pods -n kube-system

# Детальна інформація про кластер
kubectl cluster-info
```

## Видалення ресурсів

```bash
terraform destroy
```

## Важливі виходи (Outputs)

Після розгортання ви отримаєте:

- `cluster_endpoint` - Endpoint кластера
- `cluster_certificate_authority_data` - Сертифікат для підключення
- `vpc_id` - ID VPC
- `subnet_ids` - ID підмереж

## Вартість

Орієнтовна вартість на місяць:
- EKS Control Plane: ~$73
- 3x t3.medium instances: ~$90
- NAT Gateways: ~$90
- Storage: ~$10

**Загальна вартість: ~$263/місяць**

## Безпека

- Всі робочі вузли розгортаються в приватних підмережах
- Публічний доступ до API сервера обмежений
- Використовуються Security Groups для контролю трафіку
- IAM ролі з мінімальними необхідними правами

## Масштабування

Для зміни кількості вузлів:
1. Змініть значення `node_count` у `variables.tf`
2. Запустіть `terraform apply`

Для зміни типу інстансу:
1. Змініть значення `instance_type` у `variables.tf`
2. Запустіть `terraform apply`

## Troubleshooting

### Проблеми з підключенням
```bash
# Перевірте статус кластера
aws eks describe-cluster --name <cluster-name> --region <region>

# Перевірте конфігурацію kubectl
kubectl config current-context
```

### Проблеми з вузлами
```bash
# Перевірте статус node group
aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name>

# Перевірте логи вузлів
kubectl describe node <node-name>
```
