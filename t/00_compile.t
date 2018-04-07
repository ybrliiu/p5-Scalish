use strict;
use Test::More;

use_ok $_ for qw(
    Scalish::Exporter
    Scalish::NoSuchElementException
    Scalish::Option::Option
    Scalish::Option::Some
    Scalish::Option::None
    Scalish::Either::Either
    Scalish::Either::Projection
    Scalish::Either::LeftProjection
    Scalish::Either::RightProjection
    Scalish::Either::Left
    Scalish::Either::Right
    Scalish
);

done_testing;
