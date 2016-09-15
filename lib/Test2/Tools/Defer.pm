package Test2::Tools::Defer;
use strict;
use warnings;

our $VERSION = '0.000059';

use Carp qw/croak/;

use Test2::Util qw/get_tid/;
use Test2::API qw{
    test2_add_callback_exit
    test2_pid test2_tid
};

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/def do_def/;
sub IMPORTER_MENU {
    return (
        export        => \@EXPORT,
        export_on_use => deprecate_pins_before(2),
        export_pins   => {
            root_name => 'no-pin',
            'v1'      => {inherit => 'no-pin'},
            'v2'      => {inherit => 'v1'},
        },
    );
}

my %TODO;

sub def {
    my ($func, @args) = @_;

    my @caller = caller(0);

    $TODO{$caller[0]} ||= [];
    push @{$TODO{$caller[0]}} => [$func, \@args, \@caller];
}

sub do_def {
    my $for = caller;
    my $tests = delete $TODO{$for} or croak "No tests to run!";

    for my $test (@$tests) {
        my ($func, $args, $caller) = @$test;

        my ($pkg, $file, $line) = @$caller;

        chomp(my $eval = <<"        EOT");
package $pkg;
# line $line "(eval in Test2::Tools::Defer) $file"
\&$func(\@\$args);
1;
        EOT

        eval $eval and next;
        chomp(my $error = $@);

        require Data::Dumper;
        chomp(my $td = Data::Dumper::Dumper($args));
        $td =~ s/^\$VAR1 =/\$args: /;
        die <<"        EOT";
Exception: $error
--eval--
$eval
--------
Tool:   $func
Caller: $caller->[0], $caller->[1], $caller->[2]
$td
        EOT
    }

    return;
}

sub _verify {
    my ($context, $exit, $new_exit) = @_;

    my $not_ok = 0;
    for my $pkg (keys %TODO) {
        my $tests = delete $TODO{$pkg};
        my $caller = $tests->[0]->[-1];
        print STDOUT "not ok - deferred tests were not run!\n" unless $not_ok++;
        print STDERR "# '$pkg' has deferred tests that were never run!\n";
        print STDERR "#   $caller->[1] at line $caller->[2]\n";
        $$new_exit ||= 255;
    }
}

test2_add_callback_exit(\&_verify);

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Defer - Write tests that get executed at a later time

=head1 DESCRIPTION

Sometimes you need to test things BEFORE loading the necessary functions. This
module lets you do that. You can write tests, and then have them run later,
after C<Test2> is loaded. You tell it what test function to run, and what
arguments to give it.  The function name and arguments will be stored to be
executed later. When ready, run C<do_def()> to kick them off once the functions
are defined.

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Test2::Tools::Defer ':v2';

    BEGIN {
        def ok => (1, 'pass');
        def is => ('foo', 'foo', 'runs is');
        ...
    }

    use Test2::Tools::Basic;

    do_def(); # Run the tests

    # Declare some more tests to run later:
    def ok => (1, "another pass");
    ...

    do_def(); # run the new tests

    done_testing;

=head1 EXPORTS

=head2 EXPORT PINS

B<The current pin used by all of Test::Suite is C<v2>.>

Export pins are how L<Test2::Suite> manages changes that could break backwords
compatability. If we need to break backwards compatability we will do so by
releasing a new pin. Old pins will continue to import the old functionality
while new pins will import the new functionality.

There are several ways to specify a pin:

    # Import all the defaults provided by the 'v2' pin
    use Package ':v2';

    # Import foo, bar, and baz deom the v2 pin.
    use Package '+v2' => [qw/foo bar baz/];

    # Import 'foo' from the v2 pin, and import 'bar' and 'baz' from the v1 pin
    use Package qw/+v2 foo +v1 bar baz/;

If you do not specify a pin the default is to use the C<v1> pin (for legacy
reasons). When the C<$AUTHOR_TESTING> environment variable is set, importing
without a pin will produce a warning. In the future this warning may occur
without the environment variable being set.

=head3 DIFFERENCES BETWEEN PINS

=over 4

=item From v1 to v2

This package does not have any differences between pins C<v1> and C<v2>. This
package has 'v2' because all Test2::Suite packages gain new pins at the same
time for consistency.

=back

=head2 EXPORTED SYMBOLS


=over 4

=item def function => @args;

This will store the function name, and the arguments to be run later. Note that
each package has a separate store of tests to run.

=item do_def()

This will run all the stored tests. It will also reset the list to be empty so
you can add more tests to run even later.

=back

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
