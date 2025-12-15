Práctica en la que se monta un cluster en local usando KIND para cargar una aplicación con Docker de un tetris y hacerla correr en localhost.

1. Crear una carpeta para el proyecto
2. Luego me creo un archivo de configuración de kind → 

```bash
cat > kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
EOF
```

1. Luego creo el cluster con esa configuración

```bash
kind create cluster --name tetris-cluster --config kind-config.yaml
```

*Notas:* 

**Qué ocurrirá internamente (resumen):**

- Docker descargará imágenes necesarias y creará un contenedor llamado algo como `tetris-cluster-control-plane`.
- Dentro de ese contenedor se inicia un Kubernetes mínimo (kubelet, kube-apiserver, etc.).
- `kind` actualiza tu `kubectl` config para que puedas controlar ese clúster con `kubectl` sin más cambios.
1. Instalar el **ingress-controller (ingress-nginx)**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

*Descarga y aplica los manifests que despliegan el controlador **ingress-nginx** adaptado para clusters creados con kind.*

Puedo comprobar que los recursos se han creado con:

```bash
kubectl -n ingress-nginx get deploy
kubectl -n ingress-nginx get pods -o wide
```

1. Lo siguiente es desplegar `tetris.yaml` y comprobar que los recursos quedan expuestos por un Service. 
- Aplicar el manifiesto `tetris.yaml` . Con esto se crean los recursos declarados en el archivo (Deployment,  Service, etc…)

```bash
kubectl apply -f tetris.yaml
```

NOTA: He obtenido un error porque no se había creado el namespace en el cluster y la imagen de tetris.yaml indica que se debe crear en un namespace llamado **application-web.** Asi que hay que proceder a crear el namespace

```bash
kubectl create namespace application-web
```

Y posteriormente volvemos a aplicar el comando de 

```bash
kubectl apply -f tetris.yaml
```

Y ahora ya está creado el deployment y el service.

El deployment crea pods por debajo, podemos comprobarlos con:

```bash
kubectl get pods -n application-web
```

En este punto el contenedor del tetris se ha descargado, la aplicación está arrancada y kubernetes no tiene errores. El problema ahora es como accedemos a ella. 

El Service es lo que conecta el mundo Kubernetes con los pods internos. Si ejecutamos este comando veremos que tipo de Service se ha definido en tetris.yaml

```bash
kubectl get svc -n application-web
```

Según el tipo de Service (`ClusterIP`, `NodePort`, `LoadBalancer`):

- podremos acceder **directamente**
- necesitaremos **Ingress**
- o tendremos que hacer **port-forward**

Sin saber esto, **no se puede avanzar correctamente**.

Para este caso, la respuesta obtenida es la siguiente:

NAME     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
tetris   ClusterIP   10.96.172.29   <none>        80/TCP    6m16s

Esto significa que nuestro TYPE: ClusterIP PORT: 80 solo es accesible dentro del cluster y no es accesible desde el mac. Y el tetris está escuhando en el puerto 80. Entonces lo siguiente sería crear un puente entre mi navegador y el Service interno. Usaremos para ello el INGRESS.

En primer lugar probamos el acceso con PORT-FORWARD

```bash
kubectl port-forward -n application-web svc/tetris 8080:80
```

Sin cerrar la terminal nos vamos al chrome y accedemos a [`http://localhost:8080`](http://localhost:8080) y deberíamos ver el tetris corriendo → ✅

Sabiendo esto, seguimos para acceder al tetris a través de ingress.

INGRESS = Punto de entrada HTTP al cluster. Es como un router HTTP que decide a que Service mandar una petición segun la URL.  Ingress es solo una regla (un YAML) **ingress-nginx** es el programa que entiende estas reglas. Yo ya instale previamente el ingress-nginx que esta funcionando (cuando vimos el error 404) Que ese error básicamente lo que nos dice es que está vivo, pero que no sabe donde mandar el tráfico. Asi que ahora creamos la regla ingress para el tetris.

En la ruta del proyecto creamos un archivo `tetris-ingress.yaml` y le pegamos este contenido:

```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tetris-ingress
  namespace: application-web
spec:
  ingressClassName: nginx
  rules:
    - host: localhost
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: tetris
                port:
                  number: 80
```

Con esto le estamos diciendo que cuando alguien acceda a http://localhost/ manda el trafico al Service `tetris` por el puerto `80`.

Para aplicar el ingress ingresamos el siguiente comando:

```bash
kubectl apply -f tetris-ingress.yaml
```

## Que pasa si quiero borrar algo?

### Nivel 1 — Borrar solo lo desplegado en Kubernetes (lo más habitual)

Para limpiar el entorno pero **seguir usando el clúster**:

```bash
kubectl delete namespace application-web
```

(opcional, si ese namespace era solo para el Tetris)

O bien, archivo a archivo:

```bash
kubectl delete -f tetris.yaml
kubectl delete -f tetris-ingress.yaml
```

**Resultado:**

- El Tetris desaparece
- El clúster sigue vivo
- Puedo desplegar otra app inmediatamente

👉 Esto es lo que haría **el 80 % de las veces**.

---

### Nivel 2 — Borrar el clúster KIND completo

Para empezar de cero con Kubernetes, pero **mantener Colima**:

```bash
kind delete cluster --name tetris-cluster
```

**Resultado:**

- Kubernetes desaparece por completo
- Colima sigue funcionando
- Docker sigue disponible
- Puedo crear otro clúster cuando quieras

👉 Esto es lo habitual cuando:

- un clúster se ha ensuciado
- cambiar configuración
- empezar otro ejercicio
