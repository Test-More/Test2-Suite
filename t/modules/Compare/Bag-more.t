#!/usr/bin/env perl
use strict;
use warnings;
use Test2::Bundle::Extended -target => 'Test2::Tools::Compare';

sub test_this {
    my ($name,$bag,%tests) = @_;

    subtest $name => sub {
        my @yes = @{$tests{yes} // []};
        while (@yes) {
            my ($case_name,$case_value) = splice @yes,0,2;
            is(
                $case_value,
                $bag,
                "should match $case_name",
            );
        }

        my @no = @{$tests{no} // []};
        while (@no) {
            my ($case_name,$case_value) = splice @no,0,2;
            isnt(
                $case_value,
                $bag,
                "should not match $case_name",
            );
        }
    };
}

test_this 'empty bag' => bag { },
    yes => [
        'empty array' => [],
        'non-empty array' => ['abc'],
    ];

test_this 'empty, closed bag' => bag { end; },
    yes => [
        'empty array' => [],
    ],
    no => [
        'non-empty array' => ['abc'],
    ];

test_this '1-element bag' => bag { item match qr/a/; },
    yes => [
        '1-element array' => ['abc'],
        '2-element array' => ['abc','def'],
        '2-valid-element array' => ['abc','daf'],
    ],
    no => [
        'different 1-element array' => ['def'],
        'empty array' => [],
    ];

test_this '1-element, closed bag' => bag { item match qr/a/; end; },
    yes => [
        '1-element array' => ['abc'],
    ],
    no => [
        '2-element array' => ['abc','def'],
        '2-valid-element array' => ['abc','daf'],
        'different 1-element array' => ['def'],
        'empty array' => [],
    ];

test_this '2-element bag' => bag { item match qr/a/; item match qr/ab/; },
    yes => [
        '2-element array' => ['abc','def'], # the 1st element satisfies *both* checks
        '1-element array' => ['abc'], # the single element satisfies *both* checks
        '2-valid-element array' => ['abc','daf'],
        '2-valid-element array, different order' => ['daf','abc'],
        '3-element array' => ['no','abc','daf'],
        '3-element array, different order' => ['daf','no','abc'],
        '3-valid-element array' => ['abc','daf','bad'],
        '3-valid-element array, different order' => ['daf','bad','abc'],
    ],
    no => [
        'different 1-element array' => ['def'],
        'empty array' => [],
    ];

test_this '2-element, closed bag' => bag { item match qr/a/; item match qr/ab/; end; },
    yes => [
        '2-valid-element array' => ['abc','daf'],
        '2-valid-element array, different order' => ['daf','abc'],
    ],
    no => [
        '2-element array' => ['abc','def'],
        '1-element array' => ['abc'],
        'different 1-element array' => ['def'],
        'empty array' => [],
        '3-element array' => ['no','abc','daf'],
        '3-element array, different order' => ['daf','no','abc'],
        '3-valid-element array' => ['abc','daf','bad'],
        '3-valid-element array, different order' => ['daf','bad','abc'],
    ];

done_testing;
