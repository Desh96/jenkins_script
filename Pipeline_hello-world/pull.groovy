def nexus_path = 'EPBYMINW7296/nexus'
def group = 'org.jboss'
def artifact = 'jboss-parent'
def version = '23'
def repo = 'project-releases'
def build_num = System.getenv("BUILD_NUMBER")
def work_path = System.getenv("WORKSPACE")

new File("/${work_path}/${artifact}-${version}.tar.gz").withOutputStream { out ->
        def url = new URL("http://${nexus_path}/repository/${repo}/${group}/${artifact}/${version}/pipeline-ymaniukevich-${build_num}.tar.gz").openConnection()
out << url.inputStream
}
