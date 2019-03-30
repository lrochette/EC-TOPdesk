procedure 'createIncident', description: 'Create a new incident', { // [PROCEDURE]
    // [REST Plugin Wizard step]

    step 'createIncident',
        command: """
\$[/myProject/scripts/preamble.pl]
use EC::TOPdesk::Plugin;
EC::TOPdesk::Plugin->new->run_step('createIncident');
""",
        errorHandling: 'failProcedure',
        exclusiveMode: 'none',
        releaseMode: 'none',
        shell: 'ec-perl',
        timeLimitUnits: 'minutes'

    // [REST Plugin Wizard step ends]
    // [Output Parameters Begin]
formalOutputParameter 'incidentId', description: 'Entry ID of the incident'
formalOutputParameter 'incident',   description: 'JSON representation of the incident'

    // [Output Parameters End]
}
