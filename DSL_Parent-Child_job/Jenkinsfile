node("${SLAVE}") {
   checkout scm
   sh 'pwd'
    step([
        $class: 'ExecuteDslScripts',
        targets: ['jobs.groovy'].join('\n'),
        removedJobAction: 'DELETE',
        removedViewAction: 'DELETE',
        lookupStrategy: 'SEED_JOB'
    ])

}
