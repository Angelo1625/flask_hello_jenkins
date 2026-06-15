pipeline {
  agent {
    kubernetes {
      label 'jenkins-agent-my-app'
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
  - name: docker
    image: docker:24.0-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    - name: DOCKER_HOST
      value: "tcp://localhost:2375"
  volumes:
  - name: workspace-volume
    emptyDir: {}
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
        container('python') {
          sh "sleep 15"
          sh "DOCKER_HOST=tcp://localhost:2375 docker build -t localhost:4000/pythontest:latest ."
          sh "DOCKER_HOST=tcp://localhost:2375 docker push localhost:4000/pythontest:latest"
        }
      }
    }
  }
}
