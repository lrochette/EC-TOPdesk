package EC::Plugin::Hooks;

use strict;
use warnings;
use MIME::Base64 qw(encode_base64);

use base qw(EC::Plugin::HooksCore);


=head1 SYNOPSYS

User-defined hooks

Available hooks types:

    before
    parameters
    request
    response
    parsed
    after

    ua - will be called when User Agent is created

    Accepts step name, hook name, hook code, options

    sub define_hooks {
        my ($self) = @_;

        $self->define_hook('my step', 'before', sub { ( my ($self) = @_; print "I'm before step my step" }, {run_before_shared => 1});
    }


    step name - the name of the step. If value "*" is specified, the hook will be "shared" - it will be executed for every step
    hook name - the name of the hook, see Available hook types
    hook code - CODEREF with the hook code
    options - hook options
        run_before_shared - this hook ("own" step hook) will be executed before shared hook (the one marked with "*")




=head1 SAMPLE


    sub define_hooks {
        my ($self) = @_;

        # step name is 'deploy artifact'
        # hook name is 'request'
        # This hook accepts HTTP::Request object
        $self->define_hook('deploy artifact', 'request', \&deploy_artifact);
    }

    sub deploy_artifact {
        my ($self, $request) = @_;

        # $self is a EC::Plugin::Hooks object. It has method ->plugin, which returns the EC::RESTPlugin object
        my $artifact_path = $self->plugin->parameters($self->plugin->current_step_name)->{filesystemArtifact};

        open my $fh, $artifact_path or die $!;
        binmode $fh;
        my $buffer;
        $self->plugin->logger->info("Writing artifact $artifact_path to the server");

        $request->content(sub {
            my $bytes_read = read($fh, $buffer, 1024);
            if ($bytes_read) {
                return $buffer;
            }
            else {
                return undef;
            }
        });
    }


=cut

# autogen end
use Data::Dumper;
use JSON;

sub define_hooks {
    my ($self) = @_;

    $self->define_hook('*', 'request', \&expand_generic_parameters);
    $self->define_hook('*', 'response', \&parse_json_error);
    $self->define_hook('createOperatorChange', 'parameters', \&createOperatorChange);
}

sub expand_generic_parameters {
    my ($self, $request) = @_;

    my $parameters = $self->plugin->parameters();

    my %req_params = $request->uri->query_form();

    if ($parameters->{fields}){
        $req_params{fields} = "values($parameters->{fields})";
    }
    if ($parameters->{expand}){
        # $req_params{}
    }

    $request->uri->query_form(%req_params);

    return $request;
}

sub parse_json_error {
    my ($self, $response) = @_;

    return if $response->is_success;

    my $json;
    eval {
        $json = decode_json($response->content);
        1;
    } or do {
        return;
    };

    my $formatted_response = JSON->new->utf8->pretty->encode($json);
    $self->plugin->logger->info('Got error', $formatted_response);
    my $message = $json->[0]->{messageText};
    if ($message) {
        $self->plugin->bail_out($message);
    }
}

sub createOperatorChange {

    my ($self, $params) = @_;

    my $values;
    eval {
        $values = decode_json($params->{values});
        1;
    } or do{
        $self->plugin->bail_out("Values should be a valid JSON object: $@");
    };

    unless($values->{values}) {
        $values = {values => $values};
    }

    $params->{values} = encode_json($values);
    return $params;
}

1;
