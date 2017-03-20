use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::EnvVar';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    local %ENV = %ENV;
    $ENV{FOO} = 0;
    is($CLASS->skip('FOO'), 'This test only runs if the $FOO environment variable is set', "will skip");

    $ENV{FOO} = 1;
    is($CLASS->skip('FOO'), undef, "will not skip");

    like(
        dies { $CLASS->skip },
        qr/no environment variable specified/,
        "must specify a var"
    );
}

done_testing;
