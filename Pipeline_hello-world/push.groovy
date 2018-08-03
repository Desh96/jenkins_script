def nexus_path = 'EPBYMINW7296/nexus'
def group = "org.jboss"
def artifact = "jboss-parent"
def version = "23"
def repo = "project-releases"
def build_num = System.getenv("BUILD_NUMBER")

    def File = new File ("pipeline-ymaniukevich-${build_num}.tar.gz").getBytes()
    def con = new URL("http://${nexus_path}/repository/${repo}/${group}/${artifact}/${version}/pipeline-ymaniukevich-${build_num}.tar.gz").openConnection()
    def authString = "admin:admin123".getBytes().encodeBase64().toString()
    con.setRequestProperty( "Authorization", "Basic ${authString}")
    con.setRequestMethod("PUT")
    con.doOutput = true
    con.setRequestProperty( "Content-Type", "application/x-gzip" )
    def writer = new DataOutputStream(con.outputStream)
    writer.write(File)
    writer.close()
println con.responseCode
