pipeline {
    agent any

    // ─── Global environment variables ─────────────────────────────────────────
    environment {
        GITHUB_REPO      = 'https://github.com/harshithld0141-rgb/my-webook-repo.git'
        GITHUB_BRANCH    = 'main'
        DOCKER_IMAGE     = 'myappwebhook'
        DOCKER_TAG       = "${env.BUILD_NUMBER}"
        DOCKER_LATEST    = 'latest'
        EXPORT_DIR       = '/var/lib/jenkins/docker-exports'
    }

    stages {

        // ── 1. Checkout ────────────────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "📥 Pulling code from GitHub branch: ${env.GITHUB_BRANCH}"
                git branch: "${env.GITHUB_BRANCH}",
                    url: "${env.GITHUB_REPO}"
            }
        }

        // ── 2. Build Docker Image ──────────────────────────────────────────────
        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                sh """
                    docker build \
                        --no-cache \
                        -t ${env.DOCKER_IMAGE}:${env.DOCKER_TAG} \
                        -t ${env.DOCKER_IMAGE}:${env.DOCKER_LATEST} \
                        .
                """
            }
        }

        // ── 3. Export Image as TAR ─────────────────────────────────────────────
        stage('Export Image as TAR') {
            steps {
                echo "📦 Saving Docker image as tar..."
                sh """
                    # Save image to tar
                    docker save -o ${env.EXPORT_DIR}/${env.DOCKER_IMAGE}-${env.DOCKER_TAG}.tar \
                        ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}

                    # Show file size and location
                    ls -lh ${env.EXPORT_DIR}/${env.DOCKER_IMAGE}-${env.DOCKER_TAG}.tar
                    echo "✅ TAR saved: ${env.EXPORT_DIR}/${env.DOCKER_IMAGE}-${env.DOCKER_TAG}.tar"

                    # Clean up old tars (keep last 3 builds only)
                    ls -t ${env.EXPORT_DIR}/*.tar | tail -n +4 | xargs rm -f 2>/dev/null || true
                """
            }
        }

        // ── 4. Deploy locally on same instance ────────────────────────────────
        stage('Deploy') {
            steps {
                echo "🟢 Deploying container on this instance..."
                sh """
                    docker stop myappwebhook-container 2>/dev/null || true
                    docker rm   myappwebhook-container 2>/dev/null || true

                    docker run -d \
                        --name myappwebhook-container \
                        --restart unless-stopped \
                        -p 9090:8080 \
                        ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                """
            }
        }
    }

    // ─── Post-build actions ────────────────────────────────────────────────────
    post {
        always {
            echo "🧹 Cleaning up dangling Docker images..."
            sh 'docker image prune -f'
        }
        success {
            echo "✅ Pipeline completed! Image: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
            echo "📦 TAR location: ${env.EXPORT_DIR}/${env.DOCKER_IMAGE}-${env.DOCKER_TAG}.tar"
        }
        failure {
            echo "❌ Pipeline FAILED. Check logs above for details."
        }
    }
}
