# Optimal City Technologies

**Примечание:** При выполнении задания старался применять стек технологий, относящийся к модели GitOps

<hr>

Ответы на вопросы:
1. Вывод команды `kubectl get pods -A` после деплоя приложения.
```commandline
NAMESPACE     NAME                                               READY   STATUS    RESTARTS       AGE
argocd        argocd-application-controller-0                    1/1     Running   0              73m
argocd        argocd-applicationset-controller-949bd8b7b-qdm68   1/1     Running   0              77m
argocd        argocd-dex-server-55b7cb5dc-p6wtk                  1/1     Running   0              77m
argocd        argocd-image-updater-cbc5754bb-bsb8m               1/1     Running   0              70m
argocd        argocd-notifications-controller-84c87c668-lsx68    1/1     Running   0              77m
argocd        argocd-redis-58ddb6cd4b-kcg86                      1/1     Running   0              77m
argocd        argocd-repo-server-5f76695458-vqdkt                1/1     Running   0              73m
argocd        argocd-server-7655dc9cd9-dmjv4                     1/1     Running   0              77m
flaskapp      flaskapp-d97cf6789-9blkt                           1/1     Running   0              109s
kube-system   coredns-57b57bfc5b-fxgms                           1/1     Running   0              128m
kube-system   ip-masq-agent-bvtvr                                1/1     Running   0              128m
kube-system   kube-dns-autoscaler-bd7cc5977-b9rb4                1/1     Running   0              128m
kube-system   kube-proxy-c4dvk                                   1/1     Running   0              128m
kube-system   metrics-server-6f485d9c99-zpfdv                    2/2     Running   1 (127m ago)   128m
kube-system   npd-v0.8.0-qx9sm                                   1/1     Running   0              128m
kube-system   yc-disk-csi-node-v2-twjxm                          6/6     Running   0              128m
```

2. Вывод команды `kubectl get deploy -A`. Приложение должно быть развернуто в Kubernetes, к нему должен быть доступ с помощью NodePort
```commandline
NAMESPACE     NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
argocd        argocd-applicationset-controller   1/1     1            1           78m
argocd        argocd-dex-server                  1/1     1            1           78m
argocd        argocd-image-updater               1/1     1            1           71m
argocd        argocd-notifications-controller    1/1     1            1           78m
argocd        argocd-redis                       1/1     1            1           78m
argocd        argocd-repo-server                 1/1     1            1           78m
argocd        argocd-server                      1/1     1            1           78m
flaskapp      flaskapp                           1/1     1            1           71m
kube-system   coredns                            1/1     1            1           7h39m
kube-system   kube-dns-autoscaler                1/1     1            1           7h39m
kube-system   metrics-server                     1/1     1            1           7h39m
```

3. Ответ по `http://<url>:<port>>/metrics` (в моем случае - `http://158.160.21.0:30500/metrics`)
```commandline
# HELP python_gc_objects_collected_total Objects collected during gc
# TYPE python_gc_objects_collected_total counter
python_gc_objects_collected_total{generation="0"} 383.0
python_gc_objects_collected_total{generation="1"} 10.0
python_gc_objects_collected_total{generation="2"} 0.0
# HELP python_gc_objects_uncollectable_total Uncollectable objects found during GC
# TYPE python_gc_objects_uncollectable_total counter
python_gc_objects_uncollectable_total{generation="0"} 0.0
python_gc_objects_uncollectable_total{generation="1"} 0.0
python_gc_objects_uncollectable_total{generation="2"} 0.0
# HELP python_gc_collections_total Number of times this generation was collected
# TYPE python_gc_collections_total counter
python_gc_collections_total{generation="0"} 76.0
python_gc_collections_total{generation="1"} 6.0
python_gc_collections_total{generation="2"} 0.0
# HELP python_info Python platform information
# TYPE python_info gauge
python_info{implementation="CPython",major="3",minor="9",patchlevel="5",version="3.9.5"} 1.0
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 3.2632832e+07
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 2.6411008e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.73214109269e+09
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.22
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 7.0
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1.048576e+06
# HELP flask_exporter_info Information about the Prometheus Flask exporter
# TYPE flask_exporter_info gauge
flask_exporter_info{version="0.23.1"} 1.0
# HELP flask_http_request_duration_seconds Flask HTTP request duration in seconds
# TYPE flask_http_request_duration_seconds histogram
# HELP flask_http_request_total Total number of HTTP requests
# TYPE flask_http_request_total counter
# HELP flask_http_request_exceptions_total Total number of HTTP requests which resulted in an exception
# TYPE flask_http_request_exceptions_total counter
```
<hr>

## От себя
1. При выполнении задания я старался продемонстировать немного более, чем просили. Например, в системе были использован Kubernetes 
от облака Yandex Cloud. Kubernetes и остальные необходимые компоненты поднимались с помощью **Terraform**, а также добавлен небольшой **Lint тест** в пайплайн. Применял **Helm**
2. GitLab **не** разворачивался с помощью облака. Для него я арендовывал отдельный сервер и устанавливал его там как Self-Hosted (ниже будут конфиги)
3. Запуск всей системы происходил без доверенных сертификатов. По этой причине, чтобы некоторые образы в Docker-контейнерах работали, я создавал несколько своих собственных. Там реализовано внедрение
доверенных сертификатов.
4. С ArgoCD был использован паттерн App of Apps и argocd-image-uploader (с ним есть проблемы вследствие самоподписанных сертификатов, но в целом система рабочая)
5. GitLab Instance и GitLab Runner были установлены на одной машине в Docker-контейнерах
6. Container Registry тоже был от Self-Hosted Gitlab
7. Нежелательные для публичного обзора файлы, такие как в папке `infra/values` зашифрованы при помощи утилит [Sops](https://github.com/getsops/sops#1download) и [Age](https://github.com/FiloSottile/age#installation). Для работы с зашифрованными файлами был применен **helm secrets**

<hr>

# Различные конфигурационные файлы

- `docker-compose.yaml` (для GitLab и GitLab Runner)
```yaml
version: '3.6'
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    restart: always
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://89.169.171.91'
        letsencrypt['enable'] = false
        gitlab_rails['gitlab_shell_ssh_port'] = 2424

        nginx['redirect_http_to_https'] = true
        nginx['redirect_http_to_https_port'] = 80

        registry_external_url 'https://89.169.171.91:7000'
    ports:
      - '80:80'
      - '443:443'
      - '2424:22'
      - '7000:7000'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    networks:
      - gitlab-network
    shm_size: '256m'

  gitlab_runner:
    image: gitlab/gitlab-runner:latest
    container_name: gitlab-runner
    restart: always
    depends_on:
      - gitlab
    volumes:
      - '$GITLAB_RUNNER_HOME/config:/etc/gitlab-runner'
      - '/var/run/docker.sock:/var/run/docker.sock'
    networks:
      - gitlab-network

networks:
  gitlab-network:
```

- `config.toml` (для зарегистрированного docker-executor)
```toml
concurrent = 2
check_interval = 0
log_level = "debug"
connection_max_age = "15m0s"
shutdown_timeout = 0

[session_server]
  session_timeout = 1800


[[runners]]
  name = "ci-cd1"
  url = "https://89.169.171.91"
  id = 6
  token = "glrt-t3_A1nzK9cRM7zzkVS-YsP9"
  token_obtained_at = 2024-11-20T06:02:36Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = true
    image = "myalpine:latest"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache", "/certs/client"]
    shm_size = 0
    allowed_pull_policies = ["never", "if-not-present"]
    pull_policy = "never"
    network_mtu = 0
```


<hr>

Сервера я остановил, найденные IP-адреса в конфигах неактуальные