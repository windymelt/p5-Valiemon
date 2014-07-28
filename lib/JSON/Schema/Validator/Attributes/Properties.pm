package JSON::Schema::Validator::Attributes::Properties;
use strict;
use warnings;
use utf8;
use parent qw(JSON::Schema::Validator::Attributes);

use List::MoreUtils qw(all);
use JSON::Schema::Validator;

sub attr_name { 'properties' }

sub is_valid {
    my ($class, $context, $schema, $data) = @_;
    $context->in_attr($class, sub {
        return 1 unless ref $data eq 'HASH'; # ignore

        my $properties = $schema->{properties};
        my $is_valid = all {
            my $key = $_;
            my $sub_data = $data->{$key};
            my $sub_schema = $properties->{$key};

            $context->in($key, sub {
                $context->sub_validator($sub_schema)->validate($sub_data, $context);
            });
        } (keys %$properties);
        $is_valid
    });
}

1;
