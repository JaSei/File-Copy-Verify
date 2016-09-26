requires 'perl', '5.008001';
requires 'Path::Tiny';
requires 'Class::Tiny';
requires 'Safe::Isa';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

