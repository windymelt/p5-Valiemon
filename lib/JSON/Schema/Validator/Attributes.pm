package JSON::Schema::Validator::Attributes;
use strict;
use warnings;
use utf8;

use Carp qw(croak);
use Class::Load qw(is_class_loaded try_load_class);
use JSON::Schema::Validator::ValidationError;

use Exporter::Lite;
our @EXPORT_OK = qw(attr);

# TODO have package mappings instead of dinamic load
sub attr {
    my ($name) = @_;
    $name =~ s/^\$//;
    my $class = join '::', __PACKAGE__, (ucfirst $name);
    return $class if is_class_loaded($class);

    my ($is_success) = try_load_class($class);
    return $is_success ? $class : undef;
}

sub attr_name {
    croak '`attr_name` method must be implemented';
}

sub is_valid {
    my ($class, $context, $schema, $data) = @_;
    croak '`is_valid` method must be implemented';
}

1;