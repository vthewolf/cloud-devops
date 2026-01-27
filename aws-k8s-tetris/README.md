# **📘 Documentación de Proyecto: Despliegue de Tetris en AWS EKS**

## **1. Introducción y Objetivos**

El objetivo de este proyecto es desplegar una aplicación contenerizada (Tetris) en un entorno de nube escalable (AWS) utilizando prácticas modernas de **Infrastructure as Code (IaC)** y **Orquestación de Contenedores**.

Se ha dividido el trabajo en dos fases claras:

1. **Provisionamiento:** Creación de la infraestructura física (Redes y Servidores) usando **Terraform**.
2. **Despliegue:** Instalación y exposición de la aplicación usando **Kubernetes (Helm & Manifests)**.

---

## **2. Fase de Infraestructura (Terraform)**

En esta fase construimos los cimientos. Hemos modularizado el código para cumplir con estándares empresariales (`main`, `variables`, `tfvars`).

### **A. Módulo S3 (El Almacén de Estado)**

- **Analogía:** Es la caja fuerte de la obra. Antes de poner ladrillos, necesitamos un lugar seguro donde guardar los planos actualizados (`.tfstate`) para no perder el control de lo construido.
- **Técnico:** Bucket S3 con **Versionado** activado (para recuperación de desastres) y ACL privada. Garantiza la integridad del estado de Terraform.

### **B. Módulo VPC (La Red)**

- **Analogía:** Es la parcela vallada, las carreteras y la puerta de entrada.
- **Técnico:** Despliegue de una VPC con rango `10.0.0.0/16`.
- **Decisión de Diseño:** Se han usado **Subnets Públicas** conectadas a un **Internet Gateway**.
- *Por qué:* En entornos productivos usaríamos Subnets Privadas + NAT Gateway, pero para optimizar costes en este entorno de desarrollo, usamos acceso público directo protegido por Security Groups.

### **C. Módulo EKS (El Cluster)**

- **Analogía:** Es el edificio de oficinas y los trabajadores.
- **Técnico:** Cluster de Kubernetes gestionado (Control Plane v1.30).
- **Nodos:** Grupo de Autoescalado con instancias `t3.small`.
- **IAM Roles:** Se han configurado roles específicos para que los nodos puedan descargar imágenes y configurar la red (CNI) de forma autónoma.

### **Ejecución del Despliegue de Infraestructura**

bash

```bash
# 1. Inicializar descargas de proveedores
terraform init

# 2. Planificar (Ver qué se va a crear con las variables de Preproducción)
terraform plan -var-file="pre.tfvars"

# 3. Aplicar (Construir la infraestructura)
terraform apply -var-file="pre.tfvars"
```

---

## **3. Fase de Configuración Post-Despliegue**

Una vez Terraform termina, tenemos el "hardware" encendido, pero desconectado de nuestro ordenador.

### **Paso 1: Conexión (El Handshake)**

Configuramos nuestra herramienta local (`kubectl`) para que tenga permiso de hablar con el cluster en AWS.

bash

```bash
aws eks update-kubeconfig --region eu-west-1 --name tetris-pre-cluster-01
```

### **Paso 2: Instalación del Ingress Controller (El Portero)**

En lugar de usar balanceadores básicos antiguos, instalamos un controlador moderno (**NGINX**) usando **Helm** (el gestor de paquetes de K8s).

- **Por qué:** Nos permite tener un único Load Balancer físico de AWS para múltiples aplicaciones, ahorrando costes y ganando control sobre el enrutamiento.

bash

```bash
# Añadir repo y desplegar NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install mi-portero ingress-nginx/ingress-nginx
```

---

## **4. Fase de Despliegue de Aplicación (Kubernetes)**

Ahora instalamos el software (el juego). Definimos todo en un único fichero maestro: `tetris.yaml`.

### **Estructura del Manifiesto (`tetris.yaml`)**

Este archivo define 3 objetos que trabajan en cadena:

1. **Deployment:** *"Ejecuta esto"*.
- Descarga la imagen `bsord/tetris` y mantiene 2 réplicas vivas (Alta Disponibilidad).
1. **Service (ClusterIP):** *"Conecta esto internamente"*.
- Crea una IP interna privada para que los pods se comuniquen. No es accesible desde fuera.
1. **Ingress:** *"Publica esto"*.
- Es la regla de tráfico. Dice: "Si alguien llega a la raíz (`/`), envíalo al servicio Tetris". Usa la clase `nginx` instalada en el paso anterior.

yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
name: tetris
labels:
  app: tetris
spec:
replicas: 2
selector:
  matchLabels:
    app: tetris
template:
  metadata:
    labels:
      app: tetris
  spec:
    containers:
    - name: tetris
      image: bsord/tetris
      ports:
      - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
name: tetris
spec:
type: ClusterIP
selector:
  app: tetris
ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: tetris-ingress
spec:
ingressClassName: nginx
rules:
- http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: tetris
          port:
            number: 80

```

### **Ejecución:**

bash

```bash
kubectl apply -f tetris.yaml
```

---

## **5. Verificación Final**

Cómo confirmar que todo funciona correctamente:

1. **Verificar Pods:** `kubectl get pods` -> Deben estar en estado **Running** (significa que la app arrancó).
2. **Verificar Dirección Pública:** `kubectl get ingress` -> Esperar a que aparezca la dirección en la columna **ADDRESS** (ej: `xxxx.elb.amazonaws.com`).
3. **Acceso:** Copiar esa dirección en el navegador. El juego debe cargar, confirmando que el tráfico fluye: Internet -> AWS Load Balancer -> NGINX -> Servicio -> Pod Tetris.

---

## **6. Best Practices (Siguientes Pasos)**

Para profesionalizar el entorno y facilitar el trabajo en equipo, se recomienda evolucionar hacia la siguiente arquitectura:

### **A. Separación de Repositorios**

- **Repo Infraestructura (Terraform):** Gestionado por el equipo de Plataforma. Ciclo de vida lento y crítico.
- **Repo Aplicación (Kubernetes YAMLs):** Gestionado por Desarrolladores. Ciclo de vida rápido.
- **Por qué:** Evita que un cambio en el color de la aplicación pueda destruir accidentalmente la red de la empresa.

### **B. Uso de Namespaces (Aislamiento)**

Dejar de usar el namespace `default`. Crear "habitaciones" virtuales para cada entorno dentro del cluster:

- `namespace: dev`
- `namespace: pre`
- `namespace: pro`
- **Por qué:** Permite tener múltiples versiones de la misma app conviviendo sin chocar entre ellas y aplicar límites de recursos (CPU/RAM) por entorno.

### **C. GitOps (ArgoCD)**

En lugar de hacer `kubectl apply` manual desde el portátil de un empleado, se configura un operador (ArgoCD) dentro del cluster que lee el repositorio Git y aplica los cambios automáticamente. Esto garantiza que "lo que hay en Git es lo que hay en Producción".
