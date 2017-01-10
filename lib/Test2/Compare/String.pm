package Test2::Compare::String;
use strict;
use warnings;

use Carp qw/confess/;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/input/;

# Overloads '!' for us.
use Test2::Compare::Negatable;

sub stringify_got { 1 }

sub init {
    my $self = shift;
    confess "input must be defined for 'String' check"
        unless defined $self->{+INPUT};

    $self->SUPER::init(@_);
}

sub name {
    my $self = shift;
    my $in   = $self->{+INPUT};
    return "$in";
}

sub operator {
    my $self = shift;

    return '' unless @_;
    my ($got) = @_;

    return '' unless defined($got);

    return 'ne' if $self->{+NEGATE};
    return 'eq';
}

sub verify {
    my $self   = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;
    return 0 unless defined $got;

    my $input  = $self->{+INPUT};
    my $negate = $self->{+NEGATE};

    return "$input" ne "$got" if $negate;
    return "$input" eq "$got";
}

1;

# ABSTRACT: Compare two values as strings

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This is used to compare two items after they are stringified. You can also check
that two strings are not equal.

B<Note>: This will fail if the received value is undefined, it must be defined.

=cut
