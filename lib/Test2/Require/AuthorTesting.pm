package Test2::Require::AuthorTesting;
use strict;
use warnings;

use base 'Test2::Require';

our $VERSION = '0.000064';

sub skip {
    return undef if $ENV{'AUTHOR_TESTING'};
    return 'Author test, set the $AUTHOR_TESTING environment variable to run it';
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Require::AuthorTesting - Only run a test when the AUTHOR_TESTING
environment variable is set.

=head1 DESCRIPTION

It is common practice to write tests that are only run when the AUTHOR_TESTING
environment variable is set. This module automates the (admittedly trivial) work
of creating such a test.

=head1 SYNOPSIS

    use Test2::Require::AuthorTesting;

    ...

    done_testing;

=cut
