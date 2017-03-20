use strict;
use warnings;

# Prevent Test2::Util from making 'CAN_THREAD' a constant
my $threads;
BEGIN {
    require Test2::Util;
    local $SIG{__WARN__} = sub { 1 }; # no warnings is not sufficient on older perls
    *Test2::Util::CAN_THREAD = sub { $threads };
}

use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::Threads';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    $threads = 0;
    is($CLASS->skip(), 'This test requires a perl capable of threading.', "will skip");

    $threads = 1;
    is($CLASS->skip(), undef, "will not skip");
}

done_testing;
