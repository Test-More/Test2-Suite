package Test2::Util::Misc;
use strict;
use warnings;

use Importer Importer => qw/import/;

sub IMPORTER_MENU {
    return (
        export => [qw/deprecate_pins_before/],
    );
}

sub deprecate_pins_before {
    my $latest_pin = shift;
    my $exporter = caller;

    return sub {
        return unless $ENV{AUTHOR_TESTING} || $ENV{T2_WARN_OLD_PINS};
        my ($caller, $pin) = @_;

        unless (defined($pin)) {
            warn <<"            EOT";
Importing from $exporter without a pin is deprecated at $caller->[1] line $caller->[2].
This can be fixed quickly by using the 'v1' pin:

Change these

    use $exporter;     # Default imports
    use $exporter ...; # Custom list

to these:

    use $exporter ':v1';      # Default imports
    use $exporter '+v1', ...; # Custom list

Or you can use the latest pin (API may change between pins)

    use $exporter ':v$latest_pin';
    use $exporter '+v$latest_pin', ...;

            EOT
            return;
        }

        return unless $ENV{T2_WARN_OLD_PINS};
        return unless defined $latest_pin;
        return unless $pin =~ m/^v(\d+)$/;
        return if $1 >= $latest_pin;

        warn "Importing from $exporter using old pin $pin, latest pin is v$latest_pin at $caller->[1] line $caller->[2].\n";
    };
}

1;
