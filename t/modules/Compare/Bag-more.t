#!/usr/bin/env perl
use strict;
use warnings;
use Test2::Bundle::Extended -target => 'Test2::Tools::Compare';

sub test_this {
    my ($name,$bag,@tests) = @_;

    subtest $name => sub {
        for my $test (@tests) {
            my ($case_name,$case_value,@wanted_deltas) = @{$test};
            if (!@wanted_deltas) {
                is(
                    $case_value,
                    $bag,
                    "should match $case_name",
                );
            }
            else {
                my $conv = Test2::Compare->can('strict_convert');
                my @deltas = $bag->deltas(
                    convert => $conv,
                    seen => {},
                    got => $case_value,
                );
                ok(scalar @deltas,"should not match $case_name");

                like(
                    \@deltas,
                    array {
                        item $_ for @wanted_deltas;
                        end;
                    },
                    "$case_name should return the exepected deltas",
                );
                diag "$case_name returned deltas:";
                diag $_->diag for @deltas;
                diag "end";
            }
        }
    };
}

test_this 'empty bag' => bag { },
    [ 'empty array' => [] ],
    [ 'non-empty array' => ['abc'] ],
    ;

test_this 'empty, closed bag' => bag { end; },
    [ 'empty array' => [] ],

    [
        'non-empty array' => ['abc'],
        {
            dne => 'check',
            id  => [ARRAY => 0],
            got => 'abc',
            chk => DNE,
        },
    ],
    ;

test_this '1-element bag' => bag { item match qr/a/; },
    [ '1-element array' => ['abc'] ],
    [ '2-element array' => ['abc','def'] ],
    [ '2-valid-element array' => ['abc','daf'] ],

    [
        'different 1-element array' => ['def'],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
    ],
    [
        'empty array' => [],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
    ],
    ;

test_this '1-element, closed bag' => bag { item match qr/a/; end; },
    [ '1-element array' => ['abc'] ],

    [
        '2-element array' => ['abc','def'],
        {
            id  => [ARRAY => '1'],
            got => 'def',
            chk => { pattern => qr/a/ },
        },
    ],
    [
        '2-valid-element array' => ['abc','daf'],
        # this delta is terrible, it's reporting a *match*!
        {
            dne => DNE,
            id  => [ARRAY => '1'],
            got => 'daf',
            chk => { pattern => qr/a/ },
        },
    ],
    [
        'different 1-element array' => ['def'],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
    ],
    [
        'empty array' => [],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
    ],
    ;

test_this '2-element bag' => bag { item match qr/a/; item match qr/ab/; },
    # the 1st element satisfies *both* checks
    [ '2-element array' => ['abc','def'] ],
    # the single element satisfies *both* checks
    [ '1-element array' => ['abc'] ],
    [ '2-valid-element array' => ['abc','daf'] ],
    [ '2-valid-element array, different order' => ['daf','abc'] ],
    [ '3-element array' => ['no','abc','daf'] ],
    [ '3-element array, different order' => ['daf','no','abc'] ],
    [ '3-valid-element array' => ['abc','daf','bad'] ],
    [ '3-valid-element array, different order' => ['daf','bad','abc'] ],

    [
        'different 1-element array' => ['def'],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        'empty array' => [],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/ab/ },
        },
    ],
    ;

test_this '2-element, closed bag' => bag { item match qr/a/; item match qr/ab/; end; },
    [ '2-valid-element array' => ['abc','daf'] ],
    [ '2-valid-element array, different order' => ['daf','abc'] ],


    [
        '2-element array' => ['abc','def'],
        # should we be returing this:
        # {
        #    dne => 'check',
        #    id  => [ARRAY => 1],
        #    got => 'def',
        # },
        # or these:
        {
            id  => [ARRAY => 1],
            got => 'def',
            chk => { pattern => qr/a/ },
        },
        {
            id  => [ARRAY => 1],
            got => 'def',
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        '1-element array' => ['abc'],
        # is this sensible? "there's no element 1"
        {
            dne => 'got',
            id  => [ARRAY => 1],
        },
    ],
    [
        'different 1-element array' => ['def'],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        'empty array' => [],
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/a/ },
        },
        {
            dne => 'got',
            id  => [ARRAY => '*'],
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        '3-element array' => ['no','abc','daf'],
        {
            id  => [ARRAY => '0'],
            got => 'no',
            chk => { pattern => qr/a/ },
        },
        {
            id  => [ARRAY => '0'],
            got => 'no',
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        '3-element array, different order' => ['daf','no','abc'],
        {
            id  => [ARRAY => '1'],
            got => 'no',
            chk => { pattern => qr/a/ },
        },
        {
            id  => [ARRAY => '1'],
            got => 'no',
            chk => { pattern => qr/ab/ },
        },
    ],
    [
        '3-valid-element array' => ['abc','daf','bad'],
        # what should we be returning here?
        {},
    ],
    [
        '3-valid-element array, different order' => ['daf','bad','abc'],
        # what should we be returning here?
        {},
    ];

done_testing;
