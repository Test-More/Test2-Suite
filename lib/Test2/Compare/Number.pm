package Test2::Compare::Number;
use strict;
use warnings;

use Carp qw/confess/;

use base 'Test2::Compare::Base';

our $VERSION = '0.000041';

use Scalar::Util qw/looks_like_number/;
use Test2::Util::HashBase qw/input negate/;

sub init {
    my $self  = shift;
    my $input = $self->{ +INPUT };

    confess "input must be defined for 'Number' check"
      unless defined $input;

    # Check for ''
    confess "input must be a number for 'Number' check"
      unless looks_like_number($input);

    $self->SUPER::init(@_);
}

sub name {
    my $self = shift;
    my $in   = $self->{ +INPUT };
    return $in;
}

sub operator {
    my $self = shift;
    return '' unless @_;
    my ($got) = @_;

    return '' unless defined($got);
    return '' unless looks_like_number($got);

    return $self->{ +NEGATE } ? '!=' : '==';
}

sub verify {
    my $self   = shift;
    my %params = @_;
    my ( $got, $exists ) = @params{qw/got exists/};

    return 0 unless $exists;
    return 0 unless defined $got;
    return 0 if ref $got;
    return 0 unless looks_like_number($got);

    my $input  = $self->{ +INPUT };
    my $negate = $self->{ +NEGATE };

    my @warnings;
    my $out;
    {
        local $SIG{__WARN__} = sub { push @warnings => @_ };
        $out = $negate ? ( $input != $got ) : ( $input == $got );
    }

    for my $warn (@warnings) {
        if ( $warn =~ m/numeric/ ) {
            $out = 0;
            next;    # This warning won't help anyone.
        }
        warn $warn;
    }

    return $out;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Compare::Number - Compare 2 values as numbers

=head1 DESCRIPTION

This is used to compare 2 numbers. You can also check that 2 numbers are not
the same.

B<Note>: This will fail if the recieved value is undefined, it must be a number.

B<Note>: This will fail if the comparison generates a non-numeric value warning
(which will not be shown), this is because it must get a number. The warning is
not shown as it will report to a useless line and filename, however the test
diagnotics show both values.

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<http://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2016 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
