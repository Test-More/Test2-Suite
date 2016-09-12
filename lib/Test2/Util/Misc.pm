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
        my ($caller, $pin) = @_;

        unless (defined($pin)) {
            warn <<"            EOT";
Importing from $exporter without a pin is deprecated at $caller->[1] line $caller->[2].
This can be fixed by using the 'v1' pin:
    use $exporter ':v1';

Or you can use the latest pin (API may change between pins)
    use $exporter ':v$latest_pin';
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
