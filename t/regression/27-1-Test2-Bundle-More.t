use Test2::Bundle::More ':v2';
use strict;
use warnings;

is_deeply({a => [1]}, {a => [1]}, "is_deeply() works, stuff is loaded");

done_testing;
