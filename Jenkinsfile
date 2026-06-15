pipeline {
  agent {
    kubernetes {
      inheritFrom 'jenkins-agent-my-app'
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

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - 99d
    # AJOUT : Récupération dynamique de l'IP de votre machine
    env:
    - name: HOST_IP
      valueFrom:
        fieldRef:
          fieldPath: status.hostIP

  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.17.2
    command:
    - cat
    tty: true
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
        container('kaniko') {
          // Utilisation de guillemets simples ' ' pour que Jenkins laisse le conteneur interpréter $HOST_IP
          sh '/kaniko/executor --context=dir://. --dockerfile=Dockerfile --destination=$HOST_IP:4000/pythontest:latest --insecure'
        }
      }
    }

    stage('Deploy') {
      steps {
        container('kubectl') {
          sh "kubectl apply -f ./kubernetes/deployment.yaml"
          sh "kubectl apply -f ./kubernetes/service.yaml"
        }
      }
    }
  }
}