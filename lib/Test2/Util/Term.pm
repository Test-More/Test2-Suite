package Test2::Util::Term;
use strict;
use warnings;

use Term::Table::Util qw/term_size USE_GCS USE_TERM_READKEY uni_length/;
use Test2::Util qw/IS_WIN32/;

our $VERSION = '0.000071';

use Importer Importer => 'import';
our @EXPORT_OK = qw/term_size USE_GCS USE_TERM_READKEY uni_length USE_ANSI_COLOR/;

{
    my $use = 0;
    local ($@, $!);

    if (eval { require Term::ANSIColor }) {
        if (IS_WIN32) {
            if (eval { require Win32::Console::ANSI }) {
                Win32::Console::ANSI->import();
                $use = 1;
            }
        }
        else {
            $use = 1;
        }
    }

    if ($use) {
        *USE_ANSI_COLOR = sub() { 1 };
    }
    else {
        *USE_ANSI_COLOR = sub() { 0 };
    }
}

1;
