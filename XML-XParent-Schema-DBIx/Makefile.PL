use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XML::XParent::Schema::DBIx',
    AUTHOR              => q{Marco Masetti <marco.masetti@softeco.it>},
    VERSION_FROM        => 'lib/XML/XParent/Schema/DBIx.pm',
    ABSTRACT_FROM       => 'lib/XML/XParent/Schema/DBIx.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XML-XParent-Schema-DBIx-*' },
);
