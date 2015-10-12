package Dancer2::Plugin::JSONAPI::Params;

use Dancer2::Plugin;

on_plugin_import {
    my $dsl = shift;

    ### read jsonapi configuration

    # force explicit setting of 'sort' support configuration
    my $supports_sort = $dsl->config->{jsonapi}{supports_sort};
    defined $supports_sort and ( $supports_sort == 0 or $supports_sort == 1 )
        or die "[JSON-API] configuration missing: {jsonapi}{supports_sort}";


    ### add 'before' hook

    $dsl->app->add_hook(
        Dancer2::Core::Hook->new(
            name => 'before',
            code => sub {
                my %params = ( fields => {}, filter => {}, page => {}, include => {} );

                # loop over query parameters (unique keys)
                for my $k ( keys %{ $dsl->query_parameters } ) {
                    my ( $p, $f ) = $k =~ /^ (\w+?) (?:\[(\w+)\])? $/x;

                    # valid parameter names
                    grep { $p eq $_ } qw< fields filter page include sort >
                        or $dsl->send_error(
                            "[JSON-API] Bad request (unsupported parameters)", 400
                        );

                    # 'sort' requested but not supported
                    if ( $p eq 'sort' and !$supports_sort ) {
                        $dsl->send_error(
                            "[JSON-API] Server-side sorting not supported", 400
                        );
                    }

                    # values can be passed as CSV
                    my @values = map { split /,/ } $dsl->query_parameters->get_all($k);

                    # remove original values
                    $dsl->query_parameters->remove($k);

                    # values passed on in array-ref
                    grep { $p eq $_ } qw< fields filter page >
                        and $params{$p}{$f} = \@values;

                    # values passed on in hash-ref
                    $p eq 'include'
                        and $params{include}{$_} = 1 for @values;
                }

                # add manipulated parameters structure back
                $dsl->query_parameters->add( $_, $params{$_} ) for keys %params;
            },
        )
    );
};

register_plugin;

1;
