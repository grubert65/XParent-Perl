use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XML::XParent::Schema::DBI',
    AUTHOR              => q{Aleksander Sadecki <a.sadecki@gmail.com>},
    VERSION_FROM        => 'lib/XML/XParent/Schema/DBI.pm',
    ABSTRACT_FROM       => 'lib/XML/XParent/Schema/DBI.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XML-XParent-Schema-DBI-*' },
);