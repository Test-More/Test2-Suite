package Test2::Compare::Undef;
use strict;
use warnings;

use Carp qw/confess/;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase;

# Overloads '!' for us.
use Test2::Compare::Negatable;

sub name { '<UNDEF>' }

sub operator {
    my $self = shift;

    return 'IS NOT' if $self->{+NEGATE};
    return 'IS';
}

sub verify {
    my $self   = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;

    return !defined($got) unless $self->{+NEGATE};
    return defined($got);
}

1;

# ABSTRACT: Check that something is undefined

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

Make sure something is undefined in a comparison. You can also check that
something is defined.

=cut
