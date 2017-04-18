package Test2::Tools::AsyncSubtest;
use strict;
use warnings;

use Test2::AsyncSubtest;
use Test2::API qw/context/;
use Carp qw/croak/;

our @EXPORT = qw/subtest_start subtest_finish subtest_run/;
use base 'Exporter';

sub subtest_start {
    my ($name) = @_;

    croak "The first argument to subtest_start should be a subtest name"
        unless $name;

    my $subtest = Test2::AsyncSubtest->new(name => $name);

    return $subtest;
}

sub subtest_run {
    my $subtest = shift;
    my ($code) = @_;

    my $ctx = context();

    my $ok = $subtest->run(trace => $ctx->trace, $code);

    $ctx->release;

    return $ok;
}

sub subtest_finish {
    my $subtest = shift;
    my $ctx = context();

    $subtest->finish(trace => $ctx->trace);

    my $e = $ctx->build_event(
        'Subtest',
        $subtest->event_data,
    );

    $ctx->hub->send($e);
    $ctx->failure_diag($e) unless $e->pass;

    my @extra_diag = $subtest->diagnostics;
    $ctx->diag($_) for @extra_diag;

    $ctx->release;

    return $e->pass;
}

1;
