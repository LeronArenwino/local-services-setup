# Local Development Services Setup

Este repositorio contiene configuraciones Docker Compose para ejecutar servicios de desarrollo local de forma rápida y sencilla.

> 💡 **Recomendación**: Se recomienda usar [Podman](https://podman.io/) como alternativa más segura a Docker. Podman es compatible con Docker Compose y no requiere privilegios de administrador. Todos los comandos `docker-compose` funcionan directamente con `podman-compose`.

## Servicios Disponibles

- **LocalStack** - Simulador de servicios AWS (Puerto: 4566)
- **RabbitMQ** - Message broker con interfaz de gestión (Puertos: 5672, 15672)
- **Redis** - Base de datos en memoria (Puerto: 6379)
- **SonarQube** - Análisis de código con PostgreSQL (Puerto: 9000)

## Guía de Implementación

### 🚀 Despliegue Completo (Recomendado)

Desde la raíz del proyecto:

```bash
# Iniciar todos los servicios
docker-compose up -d
```

```bash
# Detener todos los servicios
docker-compose down
```

#### Servicios Específicos

```bash
# Solo LocalStack
docker-compose up -d localstack

# Solo RabbitMQ y Redis
docker-compose up -d rabbitmq redis

# Solo SonarQube (incluye base de datos)
docker-compose up -d sonarqube sonar-db
```

### 📁 Despliegue Individual

```bash
# LocalStack
cd localstack && docker-compose up -d

# LocalStack Pro
cd localstack-pro && docker-compose up -d

# RabbitMQ
cd rabbitmq && docker-compose up -d

# Redis
cd redis && docker-compose up -d

# SonarQube
cd sonar && docker-compose up -d
```

```bash
# Detener (desde cada carpeta respectiva)
docker-compose down
```

## Configuración de Acceso

| Servicio              | URL/Puerto             | Credenciales      |
| --------------------- | ---------------------- | ----------------- |
| LocalStack            | http://localhost:4566  | test/test         |
| RabbitMQ (Management) | http://localhost:15672 | guest/guest       |
| RabbitMQ (AMQP)       | `localhost:5672`       | guest/guest       |
| Redis                 | `localhost:6379`       | Sin autenticación |
| SonarQube             | http://localhost:9000  | admin/admin       |

## Configuración Avanzada

Puedes personalizar la configuración usando variables de entorno:

```bash
# Archivo .env (opcional)
DEBUG=1
SONAR_IMAGE=sonarqube:developer
LOCALSTACK_VOLUME_DIR=./custom-volume
```

## Consideraciones Técnicas

- **Podman vs Docker**: Los comandos mostrados usan `docker-compose`, pero son totalmente compatibles con `podman-compose`
- **Carpeta volume**: Es necesario crear manualmente la carpeta `volume` en el directorio `localstack` antes de ejecutar el servicio
- **Persistencia**: Los datos se mantienen en volúmenes Docker/Podman nombrados
- **Networking**: Todos los servicios están en la red `local-services`
- **Credenciales**: Las credenciales por defecto son para **DESARROLLO** únicamente
- **Puertos**: Asegúrate de que los puertos no estén ocupados por otros servicios

## Referencias Técnicas

Para configurar y usar los servicios AWS localmente con LocalStack, consulta la documentación oficial:

### Podman (Recomendado)

- **Documentación oficial**: https://podman.io/
- **Guía de instalación**: https://podman.io/getting-started/installation
- **Podman Compose**: https://docs.podman.io/en/latest/markdown/podman-compose.1.html
- **Migración desde Docker**: https://podman.io/whatis.html

### AWS CLI

- **Documentación oficial**: https://aws.amazon.com/es/cli/
- **Guía de instalación**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- **Configuración**: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

### LocalStack

- **Documentación oficial**: https://docs.localstack.cloud/aws/
- **Configuración de servicios**: https://docs.localstack.cloud/references/configuration/
- **Integración con AWS CLI**: https://docs.localstack.cloud/integrations/aws-cli/

### RabbitMQ

- **Documentación oficial**: https://www.rabbitmq.com/documentation.html
- **Tutoriales paso a paso**: https://www.rabbitmq.com/tutorials
- **Guía de administración**: https://www.rabbitmq.com/admin-guide.html
- **Management Plugin**: https://www.rabbitmq.com/management.html


