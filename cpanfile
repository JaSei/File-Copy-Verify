requires 'perl', '5.0010';
requires 'Path::Tiny', '0.056';
requires 'Class::Tiny';
requires 'Safe::Isa';
requires 'namespace::autoclean';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
};

