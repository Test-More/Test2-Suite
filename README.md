# NAME

Test2::Suite - Distribution with a rich set of tools built upon the Test2
framework.

# DESCRIPTION

Rich set of tools, plugins, bundles, etc built upon the [Test2](https://metacpan.org/pod/Test2) testing
library. If you are interested in writing tests, this is the distribution for
you.

## WHAT ARE TOOLS, PLUGINS, AND BUNDLES?

- TOOLS

    Tools are packages that export functions for use in test files. These functions
    typically generate events. Tools **SHOULD NEVER** alter behavior of other tools,
    or the system in general.

- PLUGINS

    Plugins are packages that produce effects, or alter behavior of tools. An
    example would be a plugin that causes the test to bail out after the first
    failure. Plugins **SHOULD NOT** export anything.

- BUNDLES

    Bundles are collections of tools and plugins. A bundle should load and
    re-export functions from Tool packages. A bundle may also load and configure
    any number of plugins.

If you want to write something that both exports new functions, and effects
behavior, you should write both a Tools distribution, and a Plugin distribution,
then a Bundle that loads them both. This is important as it helps avoid the
problem where a package exports much-desired tools, but
also produces undesirable side effects.

# NOTE ON EXPORT PINS

**The current pin used by all of Test::Suite is `v2`.**

Export pins are how [Test2::Suite](https://metacpan.org/pod/Test2::Suite) manages changes that could break backwords
compatability. If we need to break backwards compatability we will do so by
releasing a new pin. Old pins will continue to import the old functionality
while new pins will import the new functionality.

There are several ways to specify a pin:

    # Import all the defaults provided by the 'v2' pin
    use Package ':v2';

    # Import foo, bar, and baz deom the v2 pin.
    use Package '+v2' => [qw/foo bar baz/];

    # Import 'foo' from the v2 pin, and import 'bar' and 'baz' from the v1 pin
    use Package qw/+v2 foo +v1 bar baz/;

If you do not specify a pin the default is to use the `v1` pin (for legacy
reasons). When the `$AUTHOR_TESTING` environment variable is set, importing
without a pin will produce a warning. In the future this warning may occur
without the environment variable being set.

# INCLUDED BUNDLES

- Extended

        use Test2::Bundle::Extended ':v2';
        # strict and warnings are on for you now.

        ok(...);

        # Note: is does deep checking, unlike the 'is' from Test::More.
        is(...);

        ...

        done_testing;

    This bundle includes every tool listed in the ["INCLUDED TOOLS"](#included-tools) section below,
    except for [Test2::Tools::ClassicCompare](https://metacpan.org/pod/Test2::Tools::ClassicCompare). This bundle provides most of what
    anyone writing tests could need. This is also the preferred bundle/toolset of
    the [Test2](https://metacpan.org/pod/Test2) author.

    See [Test2::Bundle::Extended](https://metacpan.org/pod/Test2::Bundle::Extended) for complete documentation.

- More

        use Test2::Bundle::More ':v2';
        use strict;
        use warnings;

        plan 3; # Or you can use done_testing at the end

        ok(...);

        is(...); # Note: String compare

        is_deeply(...);

        ...

        done_testing; # Use instead of plan

    This bundle is meant to be a _mostly_ drop-in replacement for [Test::More](https://metacpan.org/pod/Test::More).
    There are some notable differences to be aware of however. Some exports are
    missing: `eq_array`, `eq_hash`, `eq_set`, `$TODO`, `explain`, `use_ok`,
    `require_ok`. As well it is no longer possible to set the plan at import:
    `use .. tests => 5`. `$TODO` has been replaced by the `todo()`
    function. Planning is done using `plan`, `skip_all`, or `done_testing`.

    See [Test2::Bundle::More](https://metacpan.org/pod/Test2::Bundle::More) for complete documentation.

- Simple

        use Test2::Bundle::Simple ':v2';
        use strict;
        use warnings;

        plan 1;

        ok(...);

    This bundle is meant to be a _mostly_ drop-in replacement for [Test::Simple](https://metacpan.org/pod/Test::Simple).
    See [Test2::Bundle::Simple](https://metacpan.org/pod/Test2::Bundle::Simple) for complete documentation.

# INCLUDED TOOLS

- Basic

    Basic provides most of the essential tools previously found in [Test::More](https://metacpan.org/pod/Test::More).
    However it does not export any tools used for comparison. The basic `pass`,
    `fail`, `ok` functions are present, as are functions for planning.

    See [Test2::Tools::Basic](https://metacpan.org/pod/Test2::Tools::Basic) for complete documentation.

- Compare

    This provides `is`, `like`, `isnt`, `unlike`, and several additional
    helpers. **Note:** These are all _deep_ comparison tools and work like a
    combination of [Test::More](https://metacpan.org/pod/Test::More)'s `is` and `is_deeply`.

    See [Test2::Tools::Compare](https://metacpan.org/pod/Test2::Tools::Compare) for complete documentation.

- ClassicCompare

    This provides [Test::More](https://metacpan.org/pod/Test::More) flavored `is`, `like`, `isnt`, `unlike`, and
    `is_deeply`. It also provides `cmp_ok`.

    See [Test2::Tools::ClassicCompare](https://metacpan.org/pod/Test2::Tools::ClassicCompare) for complete documentation.

- Class

    This provides functions for testing objects and classes, things like `isa_ok`.

    See [Test2::Tools::Class](https://metacpan.org/pod/Test2::Tools::Class) for complete documentation.

- Defer

    This provides functions for writing test functions in one place, but running
    them later. This is useful for testing things that run in an altered state.

    See [Test2::Tools::Defer](https://metacpan.org/pod/Test2::Tools::Defer) for complete documentation.

- Encoding

    This exports a single function that can be used to change the encoding of all
    your test output.

    See [Test2::Tools::Encoding](https://metacpan.org/pod/Test2::Tools::Encoding) for complete documentation.

- Exports

    This provides tools for verifying exports. You can verify that functions have
    been imported, or that they have not been imported.

    See [Test2::Tools::Exports](https://metacpan.org/pod/Test2::Tools::Exports) for complete documentation.

- Mock

    This provides tools for mocking objects and classes. This is based largely on
    [Mock::Quick](https://metacpan.org/pod/Mock::Quick), but several interface improvements have been added that cannot
    be added to Mock::Quick itself without breaking backwards compatibility.

    See [Test2::Tools::Mock](https://metacpan.org/pod/Test2::Tools::Mock) for complete documentation.

- Ref

    This exports tools for validating and comparing references.

    See [Test2::Tools::Ref](https://metacpan.org/pod/Test2::Tools::Ref) for complete documentation.

- Subtest

    This exports tools for running subtests.

    See [Test2::Tools::Subtest](https://metacpan.org/pod/Test2::Tools::Subtest) for complete documentation.

- Target

    This lets you load the package(s) you intend to test, and alias them into
    constants/package variables.

    See [Test2::Tools::Target](https://metacpan.org/pod/Test2::Tools::Target) for complete documentation.

# INCLUDED PLUGINS

- BailOnFail

    The much requested "bail-out on first failure" plugin. When this plugin is
    loaded, any failure will cause the test to bail out immediately.

    See [Test2::Plugin::BailOnFail](https://metacpan.org/pod/Test2::Plugin::BailOnFail) for complete documentation.

- DieOnFail

    The much requested "die on first failure" plugin. When this plugin is
    loaded, any failure will cause the test to die immediately.

    See [Test2::Plugin::DieOnFail](https://metacpan.org/pod/Test2::Plugin::DieOnFail) for complete documentation.

- ExitSummary

    This plugin gives you statistics and diagnostics at the end of your test in the
    event of a failure.

    See [Test2::Plugin::ExitSummary](https://metacpan.org/pod/Test2::Plugin::ExitSummary) for complete documentation.

- SRand

    Use this to set the random seed to a specific seed, or to the current date.

    See [Test2::Plugin::SRand](https://metacpan.org/pod/Test2::Plugin::SRand) for complete documentation.

- UTF8

    Turn on utf8 for your testing. This sets the current file to be utf8, it also
    sets STDERR, STDOUT, and your formatter to all output utf8.

    See [Test2::Plugin::UTF8](https://metacpan.org/pod/Test2::Plugin::UTF8) for complete documentation.

# INCLUDED REQUIREMENT CHECKERS

- AuthorTesting

    Using this package will cause the test file to be skipped unless the
    AUTHOR\_TESTING environment variable is set.

    See [Test2::Require::AuthorTesting](https://metacpan.org/pod/Test2::Require::AuthorTesting) for complete documentation.

- EnvVar

    Using this package will cause the test file to be skipped unless a custom
    environment variable is set.

    See [Test2::Require::EnvVar](https://metacpan.org/pod/Test2::Require::EnvVar) for complete documentation.

- Fork

    Using this package will cause the test file to be skipped unless the system is
    capable of forking (including emulated forking).

    See [Test2::Require::Fork](https://metacpan.org/pod/Test2::Require::Fork) for complete documentation.

- RealFork

    Using this package will cause the test file to be skipped unless the system is
    capable of true forking.

    See [Test2::Require::RealFork](https://metacpan.org/pod/Test2::Require::RealFork) for complete documentation.

- Module

    Using this package will cause the test file to be skipped unless the specified
    module is installed (and optionally at a minimum version).

    See [Test2::Require::Module](https://metacpan.org/pod/Test2::Require::Module) for complete documentation.

- Perl

    Using this package will cause the test file to be skipped unless the specified
    minimum perl version is met.

    See [Test2::Require::Perl](https://metacpan.org/pod/Test2::Require::Perl) for complete documentation.

- Threads

    Using this package will cause the test file to be skipped unless the system has
    threading enabled.

    **Note:** This will not turn threading on for you.

    See [Test2::Require::Threads](https://metacpan.org/pod/Test2::Require::Threads) for complete documentation.

# SEE ALSO

See the [Test2](https://metacpan.org/pod/Test2) documentation for a namespace map. Everything in this
distribution uses [Test2](https://metacpan.org/pod/Test2).

# CONTACTING US

Many Test2 developers and users lurk on [irc://irc.perl.org/#perl](irc://irc.perl.org/#perl). We also
have a slack team that can be joined by anyone with an `@cpan.org` email
address [https://perl-test2.slack.com/](https://perl-test2.slack.com/) If you do not have an `@cpan.org`
email you can ask for a slack invite by emailing Chad Granum
<exodist@cpan.org>.

# SOURCE

The source code repository for Test2-Suite can be found at
`http://github.com/Test-More/Test2-Suite/`.

# MAINTAINERS

- Chad Granum <exodist@cpan.org>

# AUTHORS

- Chad Granum <exodist@cpan.org>

# COPYRIGHT

Copyright 2016 Chad Granum <exodist@cpan.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See `http://dev.perl.org/licenses/`
