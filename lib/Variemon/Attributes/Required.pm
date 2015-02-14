package Variemon::Attributes::Required;
use strict;
use warnings;
use utf8;
use parent qw(Variemon::Attributes);

use Carp qw(croak);
use List::MoreUtils qw(all);

sub attr_name { 'required' }

sub is_valid {
    my ($class, $context, $schema, $data) = @_;

    return 1 unless ref $data eq 'HASH'; # ignore

    my $required = $schema->prop('required');
    $context->in_attr($class, sub {
        if (ref $required ne 'ARRAY' || scalar @$required < 1) {
            croak sprintf '`required` must be an array and have at leas one element at %s', $context->position
        }
        all {
            my $prop_def = ($schema->prop('properties') || {})->{$_};
            my $has_default = $prop_def && do {
                # resolve $ref TODO refactor
                my $definition = $prop_def->{'$ref'} ?
                    $schema->resolve_ref($prop_def->{'$ref'})->raw : $prop_def;
                $definition->{'default'};
            };
            $has_default || exists $data->{$_}
        } @$required;
    });
}

1;
