package Test2::Compare::Ref;
use strict;
use warnings;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/input/;

use Test2::Util::Ref qw/render_ref rtype/;
use Scalar::Util qw/refaddr/;
use Carp qw/croak/;

sub init {
    my $self = shift;

    croak "'input' is a required attribute"
        unless $self->{+INPUT};

    croak "'input' must be a reference, got '" . $self->{+INPUT} . "'"
        unless ref $self->{+INPUT};

    $self->SUPER::init();
}

sub operator { '==' }

sub name { render_ref($_[0]->{+INPUT}) }

sub verify {
    my $self   = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;

    my $in = $self->{+INPUT};
    return 0 unless ref $in;
    return 0 unless ref $got;

    my $in_type  = rtype($in);
    my $got_type = rtype($got);

    return 0 unless $in_type eq $got_type;

    # Don't let overloading mess with us.
    return refaddr($in) == refaddr($got);
}

1;

# ABSTRACT: Ref comparison

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

Used to compare two refs in a deep comparison.

=head1 SYNOPSIS

    my $ref = {};
    my $check = Test2::Compare::Ref->new(input => $ref);

    # Passes
    is( [$ref], [$check], "The array contains the exact ref we want" );

    # Fails, they both may be empty hashes, but we are looking for a specific
    # reference.
    is( [{}], [$check], "This will fail");

=cut
