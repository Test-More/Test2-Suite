package Test2::Compare::Refcount;
use strict;
use warnings;

use base 'Test2::Compare::Base';

use Carp qw/croak/;
use B qw( svref_2object );

our $VERSION = '0.000156';

use Test2::Util::HashBase qw/input/;

sub init {
    my $self = shift;

    croak "'input' is a required attribute"
        unless $self->{+INPUT};

    $self->SUPER::init();
}

sub operator { '==' }

sub name { $_[0]->{+INPUT} }

sub verify {
    my $self = shift;
    my %params = @_;
    my ($exists) = @params{qw/exists/};

    my $gotcount = svref_2object( $params{got} )->REFCNT;

    require Devel::MAT::Dumper;
    Devel::MAT::Dumper::dump("test2.pmat");
    print STDERR "Reference is $params{got}\n";

    die "TODO: verify Refcount() == $gotcount\n";
}

1;

__END__

