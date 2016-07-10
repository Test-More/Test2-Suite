use Test2::Require::Module 'Moose';
use Test2::Bundle::Extended -Moose => 1;

use Moose;

isa_ok(__PACKAGE__->meta, "Moose::Meta::Class");

ok(lives { __PACKAGE__->meta->make_immutable }, "Make Immutible worked");

is({}, meta_check { prop this => {} }, "meta {...} works");

done_testing;
