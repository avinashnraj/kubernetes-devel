# **Kubernetes Development Environment**

## **Introduction**

This repository provides a streamlined Kubernetes development environment using Docker Compose, KinD, and K3d. The included `Makefile` simplifies managing clusters and Docker setups.

---

## **Setup Instructions**

### **Prerequisites**

Ensure the following tools are installed:
- **Docker**
- **Docker Compose**
- **KinD** (Kubernetes in Docker)
- **K3d** (Lightweight Kubernetes using Docker)
- **kubectl** (Kubernetes CLI)

---

## **Using the Makefile**

The `Makefile` includes commands to simplify Docker, KinD, and K3d operations. Below are the available targets:

### **Docker Compose Commands**

- **Start the environment**  
  Start the Docker Compose environment:
  ```bash
  make up
