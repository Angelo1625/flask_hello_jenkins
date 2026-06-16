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
  serviceAccountName: jenkins
  containers:
  - name: python
    image: python:3.7
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.0-debug
    command:
    - sleep
    args:
    - "9999999"
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.17.2
    command:
    - cat
    tty: true
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
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context=dir:///home/jenkins/agent/workspace/flask_hello_jenkins_main \
              --destination=registry-service.jenkins.svc.cluster.local:5000/pythontest:latest \
              --insecure \
              --skip-tls-verify
          """
        }
      }
    }
    stage('Deploy') {
      steps {
        container('kubectl') {
          sh "kubectl apply -f ./kubernetes/deployment.yaml"
          sh "kubectl apply -f ./kubernetes/service.yaml"
          sh "kubectl rollout status deployment/pythontest -n jenkins"
        }
      }
    }
  }
}
