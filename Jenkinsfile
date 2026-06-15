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
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.0-debug
    command:
    - sleep
    args:
    - "9999999"
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
  }
}
