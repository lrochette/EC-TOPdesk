procedure 'createOperatorChange', description: 'Create a new change for an operator', { // [PROCEDURE]
    // [REST Plugin Wizard step]

    step 'createOperatorChange',
        command: """
\$[/myProject/scripts/preamble]
use EC::TOPdesk::Plugin;
EC::TOPdesk::Plugin->new->run_step('createOperatorChange');
""",
        errorHandling: 'failProcedure',
        exclusiveMode: 'none',
        releaseMode: 'none',
        shell: 'ec-perl',
        timeLimitUnits: 'minutes'
    
    // [REST Plugin Wizard step ends]
    // [Output Parameters Begin]
formalOutputParameter 'change', description: 'JSON representation of the created operator change'
formalOutputParameter 'changeId', description: 'Change ID of the created operator change'

    // [Output Parameters End]
}
