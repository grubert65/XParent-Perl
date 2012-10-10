use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XML::XParent',
    AUTHOR              => q{Marco Masetti <marco.masetti@softeco.it>},
    VERSION_FROM        => 'lib/XML/XParent.pm',
    ABSTRACT_FROM       => 'lib/XML/XParent.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'DBIx::Class'           => 0,
        'YAML'                  => 0,
        'Log::Log4perl'         => 0,
        'Modern::Perl'          => 0,
        'Moose'                 => 0,
        'MooseX::UndefTolerant' => 0,
        'XML::Twig'             => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XML-XParent-*' },
);
