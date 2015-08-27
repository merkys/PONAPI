package PONAPI::Resource;
# ABSTRACT: A Perl implementation of the JASON-API (http://jsonapi.org/format) spec - Resource

use strict;
use warnings;
use Moose;

has id => (
    is       => ro,
    isa      => 'Str',
    required => 1,
);

has type => (
    is       => ro,
    isa      => 'Str',
    required => 1,
);

has attributes => (
    is       => ro,
    isa      => 'HashRef',
    default  => sub { +{} },
);

has relationships => (
    is       => ro,
    isa      => 'HashRef',
    default  => sub { +{} },
);

has meta => (
    is       => ro,
    isa      => 'HashRef',
    default  => sub { +{} },
);

has links => (
    is        => ro,
    isa       => 'PONAPI::Links',
    predicate => 'has_links',
);


sub pack {
    my $self = shift;

    my %ret = (
        type => $self->type,
        id   => $self->id,
    );

    keys %{ $self->attributes }    and $ret{attributes}    = $self->attributes;
    keys %{ $self->relationships } and $ret{relationships} = $self->relationships;
    keys %{ $self->meta }          and $ret{meta}          = $self->meta;

    $self->has_links and $ret{links} = $self->links;

    return \%ret;
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 ATTRIBUTES

=head2 id



=head2 type



=head2 attributes



=head2 relationships



=head2 links



=head2 meta

