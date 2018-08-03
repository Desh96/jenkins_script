def Notification(status, stage_n, err) {
    	def date = new Date()
   	mail to: 'manukevich96@gmail.com',
        	subject: "Status of stage: ${stage_n}",
        	body: "$date: ${env.BUILD_URL} has result - ${status}\n${stage_n}: $err"
}

node("${SLAVE}")  {
stage('Preparating (Checking out)'){
	try {
		git branch: 'ymaniukevich',
		url: 'https://github.com/MNT-Lab/p323line'
	} 
	catch (err) {
		Notification('Failure', 'Preparation (Checking out)', err)
		throw err;
	}
}	
stage('Building code'){
	try {
		withMaven(maven: 'mavenLocal') {
			sh "mvn -f ./helloworld-ws/pom.xml clean install"
		}
	}
	catch (err) {
		Notification('Failure', 'Building code', err)
		throw err;
	}
}
stage("Testing"){
	try{
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
	}
	catch(err) {
		Notification('Failure', 'Testing', err)
		throw err;
		}
}
stage("Triggering job and fetching"){
	try{
		build job: 'MNTLAB-ymaniukevich-child1-build-job',
		parameters: [string(name: 'BRANCH_NAME', value: 'ymaniukevich')]
		copyArtifacts filter: 'ymaniukevich_dsl_script.tar.gz',
		fingerprintArtifacts: true,
		projectName: 'MNTLAB-ymaniukevich-child1-build-job',
		selector: lastSuccessful()
	}
	catch(err) {
		Notification('Failure', 'Triggering job and fetching artefact after finishing', err)
		throw err;
	}
}
stage("Packaging and Publishing results"){
	try{
		sh "tar -xvf ymaniukevich_dsl_script.tar.gz"
		sh "tar -czf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz jobs.groovy Jenkinsfile -C helloworld-ws/target/ helloworld-ws.war"
		sh "/usr/local/groovy/latest/bin/groovy ./push.groovy"
	}
	catch(err) {
		Notification('Failure', 'Packaging and Publishing results', err)
		throw err;
	}
}
stage('Asking for manual approval') {
	try{
		timeout(time: 3, unit: 'MINUTES'){
			input 'Would you like to move on ?'
		}
	}
	catch(err) {
		Notification('Failure', 'Asking for manual approval', err)
		throw err;
		}
}
stage("Deployment"){
	try{
		sh "/usr/local/groovy/latest/bin/groovy ./pull.groovy"
		sh "scp -P2200 pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz vagrant@EPBYMINW7296:/opt/tomcat/latest/webapps"
		sh "ssh -p2200 vagrant@EPBYMINW7296 'cd /opt/tomcat/latest/webapps/ && tar xzf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz && rm -rf pipeline-ymaniukevich-${BUILD_NUMBER}.tar.gz Jenkinsfile jobs.groovy'"
	}
	catch (err) {
		Notification('Failure', 'Deployment', err)
		throw err;
	}
	Notification('Success', 'Deployment', 'Well done!')
	}
}
