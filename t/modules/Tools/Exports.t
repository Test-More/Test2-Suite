use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Tools::Exports';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    package Temp;
    use Test2::Tools::Exports;

    imported_ok(qw/imported_ok not_imported_ok/);
    not_imported_ok(qw/xyz/);
}

like(
    intercept { imported_ok('x') },
    array {
        fail_events Ok => { pass => 0 };
        event Diag => { message => "'x' was not imported." };
        end;
    },
    "Failed, x is not imported"
);

like(
    intercept { not_imported_ok('ok') },
    array {
        fail_events Ok => { pass => 0 };
        event Diag => { message => "'ok' was imported." };
        end;
    },
    "Failed, 'ok' is imported"
);

done_testing;
