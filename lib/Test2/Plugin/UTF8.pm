package Test2::Plugin::UTF8;
use strict;
use warnings;

our $VERSION = '0.000064';

use Test2::API qw{
    test2_add_callback_post_load
    test2_stack
};

sub import {
    my $class = shift;

    # Load and import UTF8 into the caller.
    require utf8;
    utf8->import;

    # Set the output formatters to use utf8
    test2_add_callback_post_load(sub {
        my $stack = test2_stack;
        $stack->top; # Make sure we have at least 1 hub

        my $warned = 0;
        for my $hub ($stack->all) {
            my $format = $hub->format || next;

            unless ($format->can('encoding')) {
                warn "Could not apply UTF8 to unknown formatter ($format)\n" unless $warned++;
                next;
            }

            $format->encoding('utf8');
        }
    });
}

1;

# ABSTRACT: Test2 plugin to test with utf8

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

When used, this plugin will make tests work with utf8. This includes
turning on the utf8 pragma and updating the Test2 output formatter to
use utf8.

=head1 SYNOPSIS

    use Test2::Plugin::UTF8;

This is similar to:

    use utf8;
    BEGIN {
        require Test2::Tools::Encoding;
        Test2::Tools::Encoding::set_encoding('utf8');
    }

=head1 NOTES

This module currently sets output handles to have the ':utf8' output
layer. Some might prefer ':encoding(utf-8)' which is more strict about
verifying characters.  There is a debate about weather or not encoding
to utf8 from perl internals can ever fail, so it may not matter. This
was also chosen because the alternative causes threads to segfault,
see L<perlbug 31923|https://rt.perl.org/Public/Bug/Display.html?id=31923>.

=cut
