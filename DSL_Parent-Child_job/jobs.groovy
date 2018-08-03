job("MNTLAB-ymaniukevich-main-build-job") {
	description()
  configure {
    project->
        project / 'properties' << 'hudson.model.ParametersDefinitionProperty' {
        parameterDefinitions {
            'com.cwctravel.hudson.plugins.extended__choice__parameter.ExtendedChoiceParameterDefinition' {
                name 'BRANCH_NAME'
                quoteValue 'false'
                saveJSONParameterToFile 'false'
                visibleItemCount '1'
                type 'PT_SINGLE_SELECT'
                value "ymaniukevich, master"
                multiSelectDelimiter ','
                projectName "MNTLAB-ymaniukevich-main-build-job"
            }
          'com.cwctravel.hudson.plugins.extended__choice__parameter.ExtendedChoiceParameterDefinition' {
                name 'BUILDS_TRIGGER'
                quoteValue 'false'
                saveJSONParameterToFile 'false'
                visibleItemCount '5'
                type 'PT_CHECKBOX'
                value 'MNTLAB-ymaniukevich-child1-build-job,MNTLAB-ymaniukevich-child2-build-job,MNTLAB-ymaniukevich-child3-build-job, MNTLAB-ymaniukevich-child4-build-job'
                multiSelectDelimiter ','
                projectName "MNTLAB-ymaniukevich-main-build-job"
            }
        }
    }
}
  disabled(false)
	concurrentBuild(false)
	steps {
        downstreamParameterized {
            trigger('$BUILDS_TRIGGER') {
                block {
                    buildStepFailure('FAILURE')
                    failure('FAILURE')
                    unstable('UNSTABLE')
                }
                parameters {
                    predefinedProp('BRANCH_NAME', '$BRANCH_NAME')
                             }
}
}
    }
disabled(false)
concurrentBuild(false)
}

def git_info = ("git ls-remote -h https://github.com/MNT-Lab/d323dsl").execute()
def branches = git_info.text.readLines().collect { it.split()[1].replaceAll('refs/heads/', '')}.unique()

for(i in 1..4) {
    job("MNTLAB-ymaniukevich-child${i}-build-job") {
        parameters {
            choiceParam('BRANCH_NAME', branches, 'Git branch choice')
        }
        scm {
            git {
                remote {
                    github("MNT-Lab/d323dsl", "https")
                }
                branch('$BRANCH_NAME')
            }
        }
        steps {
            shell('bash script.sh > output.txt')
            shell('tar cvf "$BRANCH_NAME"_dsl_script.tar.gz jobs.groovy')
        }
        publishers {
            archiveArtifacts {
              pattern('output.txt, ${BRANCH_NAME}_dsl_script.tar.gz')
                allowEmpty(false)
                onlyIfSuccessful(false)
                fingerprint(false)
                defaultExcludes(true)
            }
        }
    }
}
