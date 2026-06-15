pipeline {
  agent {
    kubernetes {
      inheritFrom 'jenkins-agent-my-app' // Utilisation de inheritFrom (le label seul est obsolète comme le dit votre log)
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.7
    command:
    - cat
    tty: true

  # 1. Le conteneur Client (celui qui tape les commandes)
  - name: docker-client
    image: docker:latest
    command:
    - cat
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://127.0.0.1:2375  # On lui dit de parler au démon voisin sur le port 2375
    - name: HOST_IP
      valueFrom:
        fieldRef:
          fieldPath: status.hostIP

  # 2. Le conteneur Démon (Le moteur Docker qui tourne en tâche de fond)
  - name: dind-daemon
    image: docker:dind
    securityContext:
      privileged: true
    args:
    - --insecure-registry=0.0.0.0/0 # Autorise le push vers le protocole HTTP de votre PC
    env:
    - name: DOCKER_TLS_CERTDIR
      value: "" # Désactive le TLS pour simplifier la communication interne au Pod
"""
    }
  }
  triggers {
    pollSCM('* * * * *')
  }
  stages {
    stage('Test python') {
      steps {
        container('python') {
          sh "pip install -r requirements.txt"
          sh "python test.py"
        }
      }
    }
    stage('Build image') {
      steps {
        // IMPORTANT: On se place dans le conteneur client
        container('docker-client') {
          // 1. On build l'image localement dans le DinD
          sh "docker build -t pythontest:latest ."
          
          // 2. On la taggue avec l'IP de votre PC pour pouvoir sortir du cluster
          sh "docker tag pythontest:latest \$HOST_IP:4000/pythontest:latest"
          
          // 3. On pousse vers votre registre local
          sh "docker push \$HOST_IP:4000/pythontest:latest"
        }
      }
    }
  }
}