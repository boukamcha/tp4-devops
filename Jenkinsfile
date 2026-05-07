pipeline {
    agent any

    environment {
        SONAR_TOKEN  = credentials('sonar-token')
        DOCKER_IMAGE = "boukamcha27/flask-devops-app"
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }

    stages {

        // ─── EXERCISE 1: CI ───────────────────────────────────────────
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest test_app.py -v --cov=app --cov-report=xml
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=flask-devops-app \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://sonarqube:9000 \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ─── EXERCISE 2: CD ARTEFACTS ─────────────────────────────────
        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 0 \
                      $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }

        // ─── EXERCISE 3: DEPLOY ───────────────────────────────────────
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sh '''
                    ansible-playbook -i ansible/inventory.ini \
                      ansible/deploy.yml \
                      -e "image=$DOCKER_IMAGE:$DOCKER_TAG"
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    sleep 20
                    curl -f http://$(minikube ip):30080/health
                    echo "Smoke test passed!"
                '''
            }
        }
    }

    post {
        success { echo 'Full pipeline passed! App is live.' }
        failure { echo 'Pipeline failed. Check the logs.' }
    }
}