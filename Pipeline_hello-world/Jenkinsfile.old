node("${SLAVE}")  {
    try {
    try {
        stage('Preparating (Checking out)')
        git branch: 'ymaniukevich',
                url: 'https://github.com/MNT-Lab/p323line'
        stage('Building code')
        withMaven(maven: 'mavenLocal') {
            sh "mvn -f ./helloworld-ws/pom.xml clean install"
        }
    } catch(e) {
	mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
   	throw e;
    }

    try{
        stage("Testing")
        withMaven(maven: 'mavenLocal'){
            parallel (
                    "pre-Integration test": {
                        sh "mvn -f ./helloworld-ws/pom.xml pre-integration-test"
                    },
                    "Integration test": {
                        sh "mvn -f ./helloworld-ws/pom.xml integration-test"
                    },
                    "post-Integration test": {
                        sh "mvn -f ./helloworld-ws/pom.xml post-integration-test"
                    })
        }
    } catch(e) {
        mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
        throw e;
    }
    try{
        stage("Triggering job and fetching"){
            build job: 'MNTLAB-ymaniukevich-child1-build-job',
                    parameters: [string(name: 'BRANCH_NAME', value: 'ymaniukevich')]
            copyArtifacts filter: 'ymaniukevich_dsl_script.tar.gz',
                    fingerprintArtifacts: true,
                    projectName: 'MNTLAB-ymaniukevich-child1-build-job',
                    selector: lastSuccessful()
        }
    } catch(e) {
        mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
        throw e;
    }

    try{
        stage("Packaging and Publishing results"){
            sh "tar -xvf ymaniukevich_dsl_script.tar.gz"
            sh "tar -czf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz jobs.groovy Jenkinsfile -C helloworld-ws/target/ helloworld-ws.war"
            sh "/usr/local/groovy/latest/bin/groovy ./push.groovy"
        }
    } catch(e) {
        mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
   	throw e;
    }

    try{
        stage('Asking for manual approval') {
            input 'Would you like to move on ?'
        }
    } catch(e) {
        mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
   	throw e;
    }
    try{
        stage("Deployment"){
            sh "/usr/local/groovy/latest/bin/groovy ./pull.groovy"
            sh "scp -P2200 pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz vagrant@EPBYMINW7296:/opt/tomcat/latest/webapps"
            sh "ssh -p2200 vagrant@EPBYMINW7296 'cd /opt/tomcat/latest/webapps/ && tar xzf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz && rm -rf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz Jenkinsfile jobs.groovy'"
   	}
	    currentBuild.result = 'SUCCESS'
    }
    catch(e) {
        mail bcc: '', body: "${env.BUILD_URL} has failed ${failed}", cc: '', from: '', replyTo: '', subject: "stage failed ${failed}", to: 'manukevich96@gmail.com'
	throw e;
    }
}
  catch (e) {
    	  currentBuild.result = 'FAILURE'
	  throw e;
  }
  finally {
	mail to: 'manukevich96@gmail.com',
      subject: "Status of pipeline: ${currentBuild.fullDisplayName}",
      body: "${env.BUILD_URL} has result ${currentBuild.result}"
}
}
