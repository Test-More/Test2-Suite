use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Regex';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


my $one = $CLASS->new(input => qr/abc/i);

is(qr/abc/i, $one, "same regex");

ok(!$one->verify(got => qr/xyz/i, exists => 1), "Different regex");
ok(!$one->verify(got => qr/abc/, exists => 1), "Different flags");
ok(!$one->verify(exists => 0), "Must exist");

ok(!$one->verify(exists => 1, got => {}), "Must be regex");
ok(!$one->verify(exists => 1, got => undef), "Must be defined");
ok(!$one->verify(exists => 1, got => 'aaa'), "String is not valid");

is($one->name, "" . qr/abc/i, "name is regex pattern");

is($one->operator, 'eq', "got operator");

ok($one->verify(got => qr/abc/i, exists => 1), "Same regex");

like(
    dies { $CLASS->new() },
    qr/'input' is a required attribute/,
    "require a pattern"
);

like(
    dies { $CLASS->new(input => 'foo') },
    qr/'input' must be a regex , got 'foo'/,
    "must be a regex"
);

done_testing;
