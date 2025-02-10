# hello-world-app - containerized web application

This project is a simple containerized web application with a React frontend and a Node.js backend. The application is containerized using Docker and can be easily deployed using Docker Compose.

---

## **Table of Contents**
1. [Requirements](#requirements)
2. [Setup Instructions](#setup-instructions)
3. [Architecture Decisions](#architecture-decisions)
4. [Local Development Guide](#local-development-guide)
5. [Troubleshooting](#troubleshooting)

---


## **Requirements**
- Docker and Docker Compose installed
- Node.js (optional, for local development without Docker).
- Ports available:
  - **3000** (Frontend)
  - **3003** (Backend)
  - **9090** (Prometheus)
  - **3004** (Grafana)

---

## **Setup Instructions**
### **1. Clone the Repository**
   ```bash
   git clone https://github.com/alinzya/myapp.git
   cd hello-world-app
   ```
### **2. Build and start the application using Docker Compose**
   ```bash
   ./build-docker.sh --local
   ```
   Command-line arguments:
     --local: Builds Docker images locally without uploading.
     --docker: Builds Docker images and uploads them to Docker Hub. If selected, the script prompts the user to enter their Docker Hub username.
     --version: Specifies the version tag for the Docker images (default: latest).

   ```bash
   docker-compose up
   ```


### **3. Access the application**
- **Frontend:** [http://localhost:3000](http://localhost:3000)  
- **Backend API Endpoint:** [http://localhost:3003/api/hello](http://localhost:3003/api/hello)  
- **Prometheus Metrics:** [http://localhost:9090](http://localhost:9090)  
- **Grafana Dashboards:** [http://localhost:3004](http://localhost:3004)  

---

## **Architecture Decisions**

### **1. Microservice Design**
- The application is split into two core services:
  - **Frontend:** A static React-based app served by Nginx.
  - **Backend:** A Node.js-based REST API providing a simple JSON response. Language Consistent with the frontend and allows for a unified development experience.
  
### **2. Containerized Infrastructure**
- Each service is containerized to ensure consistent deployments across environments.

### **3. Monitoring Integration**
- **Prometheus** collects metrics for both frontend and backend services.
- **Grafana** visualizes metrics with custom dashboards.

### **4. Communication Between Services**
- Services communicate using internal Docker networking. The frontend makes API calls to `http://backend-app:3003`.

---

## **Local Development Guide**
Running Without Docker
### **1. Install dependencies for the backend and frontend:**
```bash
cd backend-app
npm install
cd ../frontend-app
npm install
```

### **2. Start the backend server**
- Navigate to the `backend-app` directory:
  ```bash
  cd backend-app
  node server.js
  ```
- Access the backend API at [http://localhost:3003/api/hello](http://localhost:3003/api/hello).

### **3. Start the frontend server**
- Navigate to the `frontend-app` directory:
  ```bash
  cd frontend-app
  npm start
  ```
-  Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## **Troubleshooting**

### **1. Docker Compose Fails to Start**
- Ensure docker is running
- Check if required ports are in use:
  ```bash
  sudo lsof -i :<port>
  ```
  Replace `<port>` with 3000, 3003, 9090, or 3004.


### **2. Cannot Access Frontend or Backend**
- Ensure services are up and running:
  ```bash
  docker-compose ps
  ```

### **3. Prometheus or Grafana Issues**
- **Prometheus Logs**:  
  ```bash
  docker logs prometheus
  ```
- **Grafana Logs**:  
  ```bash
  docker logs grafana
  ```
- If dashboards are missing, ensure persistent storage is configured in `docker-compose.yml`.

### **4. Metrics Not Showing**
- Verify services expose metrics:
  - Frontend: Visit `http://<frontend-container>:3000/metrics`.
  - Backend: Visit `http://<backend-container>:3003/metrics`.

---