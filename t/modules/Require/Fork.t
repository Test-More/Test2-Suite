use strict;
use warnings;

# Prevent Test2::Util from making 'CAN_FORK' a constant
my $forks;
BEGIN {
    require Test2::Util;
    local $SIG{__WARN__} = sub { 1 }; # no warnings is not sufficient on older perls
    *Test2::Util::CAN_FORK = sub { $forks };
}

use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::Fork';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    $forks = 0;
    is($CLASS->skip(), 'This test requires a perl capable of forking.', "will skip");

    $forks = 1;
    is($CLASS->skip(), undef, "will not skip");
}

done_testing;
