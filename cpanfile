requires 'perl', '5.014004';
requires 'Class::Accessor::Lite', '0.08';
requires 'Exception::Tiny', '0.2.1';

on 'test' => sub {
    requires 'Test::More', '1.302135';
};

