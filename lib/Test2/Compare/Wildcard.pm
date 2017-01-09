package Test2::Compare::Wildcard;
use strict;
use warnings;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/expect/;

use Carp qw/croak/;

sub init {
    my $self = shift;
    croak "'expect' is a require attribute"
        unless exists $self->{+EXPECT};

    $self->SUPER::init();
}

1;

# ABSTRACT: Placeholder check

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This module is used as a temporary placeholder for values that still need to be
converted. This is necessary to carry forward the filename and line number which
would be lost in the conversion otherwise.

=cut
