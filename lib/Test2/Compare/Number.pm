package Test2::Compare::Number;
use strict;
use warnings;

use Carp qw/confess/;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/input/;

# Overloads '!' for us.
use Test2::Compare::Negatable;

sub init {
    my $self  = shift;
    my $input = $self->{+INPUT};

    confess "input must be defined for 'Number' check"
        unless defined $input;

    # Check for ''
    confess "input must be a number for 'Number' check"
        unless length($input) && $input =~ m/\S/;

    $self->SUPER::init(@_);
}

sub name {
    my $self = shift;
    my $in   = $self->{+INPUT};
    return $in;
}

sub operator {
    my $self = shift;
    return '' unless @_;
    my ($got) = @_;

    return '' unless defined($got);
    return '' unless length($got) && $got =~ m/\S/;

    return '!=' if $self->{+NEGATE};
    return '==';
}

sub verify {
    my $self   = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;
    return 0 unless defined $got;
    return 0 if ref $got;
    return 0 unless length($got) && $got =~ m/\S/;

    my $input  = $self->{+INPUT};
    my $negate = $self->{+NEGATE};

    my @warnings;
    my $out;
    {
        local $SIG{__WARN__} = sub { push @warnings => @_ };
        $out = $negate ? ($input != $got) : ($input == $got);
    }

    for my $warn (@warnings) {
        if ($warn =~ m/numeric/) {
            $out = 0;
            next;    # This warning won't help anyone.
        }
        warn $warn;
    }

    return $out;
}

1;

# ABSTRACT: Compare two values as numbers

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This is used to compare two numbers. You can also check that two numbers are not
the same.

B<Note>: This will fail if the received value is undefined. It must be a number.

B<Note>: This will fail if the comparison generates a non-numeric value warning
(which will not be shown). This is because it must get a number. The warning is
not shown as it will report to a useless line and filename. However, the test
diagnostics show both values.

=cut
