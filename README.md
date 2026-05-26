# Proyecto 7: Serverless Website

**Sitio web completamente serverless desplegado con S3, CloudFront y Lambda usando Terraform.**

---

## 📋 Descripción General

Este proyecto implementa una **infraestructura serverless para un sitio web estático**. Utiliza Amazon S3 para almacenamiento, CloudFront como CDN global para distribución rápida, y Lambda@Edge para lógica serverless.

**Objetivo:** Aprender a desplegar sitios web sin servidores, con escalado automático y bajo costo.

---

## 🎯 ¿Qué se espera que pase?

Cuando ejecutes `terraform apply`:

1. ✅ **S3 bucket se crea** con versionado habilitado
2. ✅ **Archivos HTML se suben** (index.html, error.html)
3. ✅ **CloudFront Distribution se crea** con Origin Access Identity
4. ✅ **Política S3 se configura** para acceso CloudFront
5. ✅ **Lambda@Edge se crea** (opcional) para funciones serverless
6. ✅ **CloudFront URL se genera** para acceder al sitio
7. ✅ **HTTPS automático** via CloudFront

**Resultado:** Sitio web público, rápido, seguro y escalable automáticamente.

---

## 🏗️ Arquitectura

```
[ Usuarios en todo el mundo ] ── Solicitan: https://proyecto7.example.com
              │
              ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│ AWS CLOUDFRONT (Capa CDN Global - PriceClass_100)                             │
│                                                                               │
│  Ubicaciones Perimetrales (300+ Edge Locations mas cercanas al usuario)       │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │ Cache Layer (Configuracion TTL)                                         │  │
│  │   - TTL Default: 300s (5 min)                                           │  │
│  │   - TTL Max: 3600s (1 hora)                                             │  │
│  │   - Compresion: Habilitada                                              │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │ Lambda@Edge (Habilitada en Edge Locations)                              │  │
│  │   - Ejecucion cercana al usuario | Timeout: 5s                          │  │
│  │   - Logica: Inyeccion de Custom Headers (Seguridad/Personalizacion)     │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │ Error Handling (Manejo de Errores Custom)                               │  │
│  │   - 404 (No Encontrado) ──> Redirige a error.html                       │  │
│  │   - 403 (Acceso Denegado) ──> Redirige a error.html                     │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────┘
              │                                                 ▲
              │ (Si NO esta cacheado - Cache Miss)              │
              │ Autentica mediante OAI                          │ Respuesta HTTPS
              ▼                                                 │ Automatica
┌───────────────────────────────────────────────────────────────┴───────────────┐
│ AMAZON S3 (Origen Protegido - Region: us-east-1)                              │
│                                                                               │
│  Origin Access Identity (OAI):                                                │
│    - Politica de S3 configurada para permitir lectura SOLO a CloudFront       │
│    - Public Access: BLOQUEADO permanentemente al mundo exterior               │
│                                                                               │
│  Bucket Name: proyecto7-website-<account-id> (Versionado: HABILITADO)         │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │ Archivos Estaticos (Default Root Object: index.html)                    │  │
│  │   ├── index.html  (Pagina principal del sitio web)                      │  │
│  │   └── error.html  (Pagina amigable para respuestas 404/403)             │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────┘
```

**Flujo:**
1. Usuario solicita sitio
2. CloudFront intercepta en edge location más cercano
3. Si está cacheado → Responde directamente
4. Si no → Obtiene de S3 origin
5. Lambda@Edge (opcional) agrega headers personalizados

---

## 📦 Estructura del Proyecto

```
proyecto7-serverless-website/
├── providers.tf              # Configuración de AWS Provider
├── variables.tf              # Variables de Terraform
├── main.tf                   # Recursos: S3, CloudFront, Lambda
├── outputs.tf                # Outputs (URLs, IDs, etc)
├── terraform.tfvars          # Valores de variables
├── index.py                  # Función Lambda (opcional)
├── lambda_function.zip       # ZIP compilado de Lambda
├── .gitignore                # Archivos a ignorar
└── README.md                 # Este archivo
```

---

## 🚀 Uso Rápido

### Prerequisitos

- **Terraform** 1.0+ ([Descargar](https://www.terraform.io/downloads))
- **AWS CLI** configurado
- **Cuenta AWS** activa

### Instalación y Despliegue

```bash
# 1. Clona el repositorio
git clone https://github.com/Ferdev49/proyecto7-serverless-website.git
cd proyecto7-serverless-website

# 2. Crea el ZIP de Lambda
python -m zipfile -c lambda_function.zip index.py

# 3. Inicializa Terraform
terraform init

# 4. Revisa qué se va a crear
terraform plan

# 5. Crea la infraestructura
terraform apply

# 6. Ve los outputs
terraform output

# 7. Accede al sitio
echo "https://$(terraform output -raw cloudfront_domain_name)"

# 8. Destruye (para evitar costos)
terraform destroy
```

---

## 📊 Componentes Creados

### S3 Bucket

```
Nombre: proyecto7-website-<account-id>
Versionado: Habilitado
Public Access: Bloqueado
Archivos:
  - index.html (página principal)
  - error.html (página de error)
```

**Propósito:** Almacenar archivos estáticos de forma durables y económica.

---

### CloudFront Distribution

```
Type: Web Distribution
Origin: S3 Bucket
Default Root Object: index.html
HTTPS: Automático
Cache:
  - TTL Default: 300s
  - TTL Max: 3600s
Compression: Habilitado
Price Class: PriceClass_100
```

**Propósito:**
- **Velocidad:** Cache global en 300+ ubicaciones
- **Seguridad:** HTTPS automático, protección DDoS
- **Costo:** Reductor significativo de transferencia de datos

---

### Origin Access Identity (OAI)

```
Función: Autorizar CloudFront a acceder S3
Sin OAI: S3 sería público
Con OAI: Solo CloudFront puede leer
```

**Propósito:** Seguridad - evitar acceso directo a S3.

---

### Error Handling

```
404 (No encontrado) → error.html
403 (Acceso denegado) → error.html
```

**Propósito:** User experience - mostrar página amigable en errores.

---

### Lambda@Edge (Opcional)

```
Ubicación: CloudFront Edge Locations
Función: Agregar headers personalizados
Ejecución: Cerca del usuario
```

**Ejemplo:**
```python
# Añade headers personalizados
X-Powered-By: Terraform + Serverless
X-Custom-Header: Proyecto7
```

---

## 🔧 Variables Configurables

Edita `terraform.tfvars`:

```hcl
aws_region = "us-east-1"              # Región AWS (CloudFront es global)

# Website
project_name = "proyecto7"
domain_name = "proyecto7.example.com"
bucket_name = "proyecto7-website"

# CloudFront
cloudfront_price_class = "PriceClass_100"  # PriceClass_All, _200, _100
cache_ttl_default = 300                    # segundos (5 min)
cache_ttl_max = 3600                       # segundos (1 hora)

# Lambda@Edge
enable_lambda = true                       # Habilitar funciones
lambda_timeout = 5                         # segundos
```

---

## 📤 Outputs

Después de `terraform apply`:

```bash
$ terraform output

s3_bucket_name = "proyecto7-website-123456789"
s3_bucket_arn = "arn:aws:s3:::proyecto7-website-123456789"

cloudfront_domain_name = "d11gjgip9x8d8d.cloudfront.net"
cloudfront_distribution_id = "E2J2LW9NUYS87L"
cloudfront_arn = "arn:aws:cloudfront::123456789:distribution/E2J2LW9NUYS87L"

website_url = "https://d11gjgip9x8d8d.cloudfront.net"

lambda_function_arn = "arn:aws:lambda:us-east-1:123456789:function:proyecto7-viewer-request"

serverless_summary = {
  "cache_ttl_default" = 300
  "cloudfront_dist_id" = "E2J2LW9NUYS87L"
  "cloudfront_domain" = "d11gjgip9x8d8d.cloudfront.net"
  "lambda_enabled" = true
  "price_class" = "PriceClass_100"
  "region" = "us-east-1"
  "s3_bucket" = "proyecto7-website-123456789"
  "website_url" = "https://d11gjgip9x8d8d.cloudfront.net"
}
```

---

## 🌐 Acceder al Sitio

```bash
# Obtén la URL
terraform output -raw website_url

# Abre en navegador
https://d11gjgip9x8d8d.cloudfront.net
```

Deberías ver:
- Página principal con título "Proyecto 7"
- Estilos morados y grises
- Información sobre el stack tecnológico

---

## 📝 Modificar Contenido

### Actualizar index.html

```hcl
# En main.tf, busca "UPLOAD INDEX.HTML"
# Modifica el contenido en la sección "content = <<-EOT"

terraform plan
terraform apply
```

### Invalidar CloudFront Cache

```bash
# CloudFront puede servir versiones cacheadas
# Para forzar actualización:

DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

---

## 💰 Costos Estimados

**Por mes (aprox):**
- S3 Storage (100 MB): **$0.23**
- CloudFront Data Transfer: **~$0.085 per GB** (varía por región)
- Lambda@Edge: **$0.60 per 1M requests**
- **Total: $1-5/mes** (muy bajo)

**Sin tráfico:** ~$0.30/mes

**Recomendación:** Siempre destruye después de pruebas.

---

## 🔍 Debugging

### CloudFront devuelve 403 Access Denied

```bash
# Verifica la política S3
aws s3api get-bucket-policy --bucket <bucket-name>

# Solución: Invalida cache
aws cloudfront create-invalidation --distribution-id <dist-id> --paths "/*"
```

### CloudFront lento

```bash
# Verifica edge locations
terraform output cloudfront_distribution_id

# Ver en consola AWS:
# CloudFront → Distributions → Monitoring
```

### Lambda no se ejecuta

```bash
# Verifica estado
aws lambda get-function --function-name proyecto7-viewer-request

# Ver logs
aws logs tail /aws/lambda/us-east-1.proyecto7-viewer-request
```

---

## 🚀 Mejoras Futuras

- Agregar dominio personalizado (ACM + Route53)
- Web Application Firewall (WAF)
- Monitoreo con CloudWatch
- CI/CD para actualizar contenido
- CORS headers personalizados
- Compresión Brotli

---

## 📚 Recursos Adicionales

- [S3 Documentation](https://docs.aws.amazon.com/s3/)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Lambda@Edge Guide](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html)
- [CloudFront Best Practices](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/best-practices.html)
- [Terraform AWS S3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

---

**Última actualización:** Mayo 24, 2026
**Versión:** 1.0.0
**Estado:** ✅ Completado y Testeado