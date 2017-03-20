use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::Module';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


is($CLASS->skip('Scalar::Util'), undef, "will not skip, module installed");
is($CLASS->skip('Scalar::Util', 0.5), undef, "will not skip, module at sufficient version");

like(
    $CLASS->skip('Test2', '99999'),
    qr/Need 'Test2' version 99999, have \d+.\d+\./,
    "Skip, insufficient version"
);

is(
    $CLASS->skip('Some::Fake::Module'),
    "Module 'Some::Fake::Module' is not installed",
    "Skip, not installed"
);

done_testing;
