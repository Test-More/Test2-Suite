package Test2::Tools::Target;
use strict;
use warnings;

our $VERSION = '0.000064';

use Carp qw/croak/;

use Test2::Util qw/pkg_to_file/;

sub import {
    my $class = shift;

    my $caller = caller;
    $class->import_into($caller, @_);
}

sub import_into {
    shift;
    my $into = shift or croak "no destination package provided";

    croak "No targets specified" unless @_;

    my %targets;
    if (@_ == 1) {
        ($targets{CLASS}) = @_;
    }
    else {
        %targets = @_;
    }

    for my $name (keys %targets) {
        my $target = $targets{$name};

        my $file = pkg_to_file($target);
        require $file;

        $name ||= 'CLASS';

        my $const;
        {
            my $const_target = "$target";
            $const = sub() { $const_target };
        }

        no strict 'refs';
        *{"$into\::$name"} = \$target;
        *{"$into\::$name"} = $const;
    }
}

1;

# ABSTRACT: Alias the testing target package

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This lets you alias the package you are testing into a constant and a package
variable.

=head1 SYNOPSIS

    use Test2::Tools::Target 'Some::Package';

    CLASS()->xxx; # Call 'xxx' on Some::Package
    $CLASS->xxx;  # Same

Or you can specify names:

    use Test2::Tools::Target pkg => 'Some::Package';

    PKG()->xxx; # Call 'xxx' on Some::Package
    $PKG->xxx;  # Same

=cut
