# Terraform EKS Infrastructure - Документація

## Огляд

Цей проект містить Terraform конфігурацію для створення повноцінної EKS (Elastic Kubernetes Service) інфраструктури в AWS. Інфраструктура розділена на модулі для кращої організації та повторного використання коду.

## Архітектура

### Модулі

1. **VPC Module** (`modules/vpc/`)
   - Створює VPC з публічними та приватними підмережами
   - Налаштовує Internet Gateway та NAT Gateway
   - Конфігурує маршрутні таблиці

2. **IAM Module** (`modules/iam/`)
   - Створює IAM ролі для EKS кластера
   - Створює IAM ролі для вузлів (node groups)
   - Прикріплює необхідні політики

3. **EKS Module** (`modules/eks/`)
   - Створює EKS кластер
   - Налаштовує node groups
   - Конфігурує security groups
   - Створює CloudWatch log group

### Структура файлів

```
terraform_training/
├── main.tf                 # Основна конфігурація з модулями
├── variables.tf            # Змінні для конфігурації
├── outputs.tf              # Вихідні значення
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── terraform.tfstate       # Стан Terraform
└── terraform.tfstate.backup
```

## Економні налаштування

Для тестування використовуються економні налаштування:

- **Instance Type**: `t3.small` (найменший доступний)
- **Capacity Type**: `SPOT` (значна економія)
- **Node Count**: 3 (мінімальна кількість для високої доступності)
- **NAT Gateway**: 1 (замість 2 для економії)
- **Log Retention**: 7 днів

## Передумови

1. **AWS CLI** встановлений та налаштований
2. **Terraform** версії >= 1.0
3. **AWS аккаунт** з необхідними правами
4. **kubectl** (опціонально, для роботи з кластером)

### Налаштування AWS CLI

```bash
aws configure
```

Введіть ваші AWS credentials:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (наприклад: us-west-2)

## Як запустити

### 1. Ініціалізація Terraform

```bash
terraform init
```

Ця команда завантажує необхідні провайдери та модулі.

### 2. Перевірка плану

```bash
terraform plan
```

Перегляньте план створення ресурсів. Має бути створено 26 ресурсів.

### 3. Застосування конфігурації

```bash
terraform apply
```

Підтвердіть виконання командою `yes`. Процес займе приблизно 10-15 хвилин.

### 4. Перевірка статусу

```bash
terraform show
```

Подивіться створені ресурси та їх конфігурацію.

## Налаштування kubectl

Після створення кластера налаштуйте kubectl:

```bash
# Отримайте конфігурацію кластера
aws eks update-kubeconfig --region us-west-2 --name test-eks-cluster

# Перевірте підключення
kubectl get nodes
```

## Вихідні дані (Outputs)

Після успішного створення інфраструктури будуть доступні наступні виходи:

- `cluster_id` - ID EKS кластера
- `cluster_endpoint` - Endpoint кластера
- `cluster_certificate_authority_data` - Сертифікат для підключення
- `vpc_id` - ID VPC
- `subnet_ids` - ID підмереж
- `node_groups` - Інформація про node groups

## Видалення інфраструктури

⚠️ **УВАГА**: Ця команда видалить всі створені ресурси!

```bash
terraform destroy
```

Підтвердіть видалення командою `yes`.

## Структура VPC

```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── 10.0.1.0/24 (us-west-2a)
│   └── 10.0.2.0/24 (us-west-2b)
└── Private Subnets
    ├── 10.0.10.0/24 (us-west-2a)
    └── 10.0.20.0/24 (us-west-2b)
```

## Security Groups

1. **EKS Cluster Security Group** - дозволяє комунікацію між кластером та вузлами
2. **EKS Nodes Security Group** - дозволяє вхідний трафік на вузли

## Моніторинг та логи

- CloudWatch Log Group: `/aws/eks/test-eks-cluster/cluster`
- Retention: 7 днів
- Логи EKS кластера автоматично надсилаються в CloudWatch

## Вартість

Приблизна вартість для тестування (за місяць):
- EKS кластер: ~$73
- EC2 instances (t3.small SPOT): ~$15-20
- NAT Gateway: ~$32
- **Загальна вартість**: ~$120-125/місяць

## Поширені проблеми та рішення

### 1. Помилка "Reference to undeclared resource"
**Проблема**: Outputs посилаються на ресурси, які не існують в root модулі.
**Рішення**: Переконайтеся, що outputs посилаються на модулі (наприклад, `module.eks.cluster_id`).

### 2. Помилка "Insufficient permissions"
**Проблема**: AWS користувач не має необхідних прав.
**Рішення**: Перевірте IAM політики користувача.

### 3. Помилка "Subnet not found"
**Проблема**: VPC та підмережі не створені.
**Рішення**: Переконайтеся, що модуль VPC виконується перед модулем EKS.

## Корисні команди

```bash
# Переглянути стан
terraform state list

# Переглянути конкретний ресурс
terraform state show module.eks.aws_eks_cluster.main

# Переглянути outputs
terraform output

# Валідація конфігурації
terraform validate

# Форматування коду
terraform fmt -recursive
```

## Додаткові ресурси

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

---

**Примітка**: Ця конфігурація створена для навчальних цілей. Для production середовища додатково налаштуйте backup, monitoring, та security політики.

