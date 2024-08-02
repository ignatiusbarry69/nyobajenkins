node {
    docker.image('openjdk:17-slim').inside('-p 3001:3000') {

        stage('Build') {
            echo 'Building the project...'
            sh 'mvn clean compile'
        }

        stage('Test') {
            echo 'Running tests...'
            sh 'mvn test'

        }
    }
}
