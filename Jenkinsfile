pipeline {
  agent any
  stages {
    stage('') {
      steps {
        script {
          node {
            def app
            
            stage('Clone repository') {
              /* Let's make sure we have the repository cloned to our workspace */
              
              checkout scm
            }
            
            stage('Build image') {
              /* This builds the actual image; synonymous to
              * docker build on the command line */
              
              app = docker.build("kevinanderson1/samba-timemachine")
            }
            
            stage('Test image') {
              /* Ideally, we would run a test framework against our image.
              * For this example, we're using a Volkswagen-type approach ;-) */
              
              app.inside {
                sh 'echo "Tests passed"'
              }
            }
          }
        }
        
      }
    }
  }
}