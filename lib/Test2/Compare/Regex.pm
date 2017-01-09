package Test2::Compare::Regex;
use strict;
use warnings;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/input/;

use Test2::Util::Ref qw/render_ref rtype/;
use Carp qw/croak/;

sub init {
    my $self = shift;

    croak "'input' is a required attribute"
        unless $self->{+INPUT};

    croak "'input' must be a regex , got '" . $self->{+INPUT} . "'"
        unless rtype($self->{+INPUT}) eq 'REGEXP';

    $self->SUPER::init();
}

sub stringify_got { 1 }

sub operator { 'eq' }

sub name { "" . $_[0]->{+INPUT} }

sub verify {
    my $self = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;

    my $in = $self->{+INPUT};
    my $got_type = rtype($got) or return 0;

    return 0 unless $got_type eq 'REGEXP';

    return "$in" eq "$got";
}

1;

# ABSTRACT: Regex direct comparison

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

Used to compare two regexes. This compares the stringified form of each regex.

=cut
