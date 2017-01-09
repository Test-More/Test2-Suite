requires "B" => "0";
requires "Carp" => "0";
requires "Data::Dumper" => "0";
requires "Exporter" => "0";
requires "Importer" => "0.024";
requires "List::Util" => "0";
requires "Scalar::Util" => "0";
requires "Test2" => "1.302032";
requires "Test2::API" => "0";
requires "Test2::Hub::Interceptor" => "0";
requires "Test2::Util" => "0";
requires "Test2::Util::HashBase" => "0";
requires "Test2::Util::Trace" => "0";
requires "base" => "0";
requires "overload" => "0";
requires "perl" => "5.008001";
requires "strict" => "0";
requires "utf8" => "0";
requires "warnings" => "0";
recommends "Term::ReadKey" => "0";
recommends "Unicode::GCString" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "PerlIO" => "0";
  requires "Test::More" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Code::TidyAll::Plugin::Test::Vars" => "0.02";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Parallel::ForkManager" => "1.19";
  requires "Perl::Tidy" => "20160302";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::CPAN::Meta::JSON" => "0.16";
  requires "Test::CleanNamespaces" => "0.15";
  requires "Test::Code::TidyAll" => "0.50";
  requires "Test::EOL" => "0";
  requires "Test::Mojibake" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Portability::Files" => "0";
  requires "Test::Spelling" => "0.12";
  requires "Test::Synopsis" => "0";
  requires "Test::Vars" => "0.009";
  requires "Test::Version" => "2.05";
};
