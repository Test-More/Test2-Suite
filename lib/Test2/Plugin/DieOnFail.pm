package Test2::Plugin::DieOnFail;
use strict;
use warnings;

our $VERSION = '0.000064';

use Test2::API qw/test2_add_callback_context_release/;

my $LOADED = 0;
sub import {
    return if $LOADED++;

    test2_add_callback_context_release(sub {
        my $ctx = shift;
        return if $ctx->hub->is_passing;
        $ctx->throw("(Die On Fail)");
    });
}

1;

# ABSTRACT: Automatically die on the first test failure

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This module will die after the first test failure. This will prevent your tests
from continuing. The exception is thrown when the context is released, that is
it will run when the test function you are using, such as C<ok()>, returns.
This gives the tools the ability to output any extra diagnostics they may need.

=head1 SYNOPSIS

    use Test2::Bundle::Extended;
    use Test2::Plugin::DieOnFail;

    ok(1, "pass");
    ok(0, "fail");
    ok(1, "Will not run");

=cut
