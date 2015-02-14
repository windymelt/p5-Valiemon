package Variemon;
use 5.008001;
use strict;
use warnings;
use utf8;

use Carp qw(croak);
use Scalar::Util qw(blessed);

use Variemon::Primitives;
use Variemon::Context;
use Variemon::SchemaObject;
use Variemon::Attributes qw(attr);

use Class::Accessor::Lite (
    ro => [qw(schema options pos schema_cache)],
);

our $VERSION = "0.02";

sub new {
    my ($class, $in_schema, $options) = @_;

    # TODO should validate own schema
    # if ($options->{validate_schema}) {}
    # croak 'schema must be a hashref' unless ref $raw_schema eq 'HASH';

    my $schema = blessed $in_schema
        ? $in_schema : Valiemon::SchemaObject->new($in_schema);
    return bless {
        schema       => $schema,
        options      => $options,
        schema_cache => +{},
    }, $class;
}

sub validate {
    my ($self, $data, $context) = @_;

    $context //= Variemon::Context->new($self, $self->schema);

    for my $key (keys %{$self->schema->raw}) {
        my $attr = attr($key);
        if ($attr) {
            my ($is_valid, $error) = $attr->is_valid($context, $self->schema, $data);
            unless ($is_valid) {
                $context->push_error($error);
                next;
            }
        }
    }

    my $errors = $context->errors;
    my $is_valid = scalar @$errors ? 0 : 1;
    return wantarray ? ($is_valid, $errors->[0]) : $is_valid;
}

sub prims {
    my ($self) = @_;
    return $self->{prims} //= Variemon::Primitives->new(
        $self->options
    );
}

1;

__END__

=encoding utf-8

=head1 NAME

Variemon - It's a validation module based on JSON Schema

http://json-schema.org/latest/json-schema-core.html
http://json-schema.org/latest/json-schema-validation.html

This module is under development!
So there are some unimplemented features, and module api will be changed.

=head1 SYNOPSIS

    use Variemon;

    # create instance with schema definition
    my $validator = Variemon->new({
        type => 'object',
        properties => {
            name  => { type => 'string'  },
            price => { type => 'integer' },
        },
        requried => ['name', 'price'],
    });

    # validate data
    my ($res, $error);
    ($res, $error) = $validator->validate({ name => 'unadon', price => 1200 });
    # $res   => 1
    # $error => undef

    ($res, $error) = $validator->validate({ name => 'tendon', price => 'hoge' });
    # $res   => 0
    # $error => object Variemon::ValidationError
    # $error->position => '/properties/price/type'

=head1 LICENSE

MIT

=head1 AUTHOR

pokutuna E<lt>popopopopokutuna@gmail.comE<gt>

=cut
