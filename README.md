# **Kubernetes Development Environment**

## **Introduction**

This repository is designed to simplify the setup and use of a Kubernetes development environment. It includes:
- **Docker-based configurations**
- **Kubernetes source code as a submodule**
- **Tools and files to easily run and debug Kubernetes components locally**

The intention is to provide an efficient way for contributors and developers to work with Kubernetes.

---

## **Repository Structure**

```plaintext
kubernetes-devel/
├── .git/                     # Git metadata
├── .gitmodules               # Kubernetes submodule configuration
├── Dockerfile                # Docker image for the dev environment
├── docker-compose.yml        # Docker Compose for services
├── Makefile                  # Helper commands for setup and running components
├── kind-config.yaml          # KinD cluster configuration
├── k3d-cluster.yaml          # K3d cluster configuration
├── configs/                  # Additional configuration files
│   └── sample-config.yaml
├── vscode/                   # VSCode settings for debugging
│   └── launch.json
├── kubernetes/               # Kubernetes source code as a submodule
│   ├── README.md
│   └── ...
└── .gitignore                # Ignored files and directories
