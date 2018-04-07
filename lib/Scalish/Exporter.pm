package Scalish::Exporter;

use 5.014004;
use strict;
use warnings;
use utf8;

sub import {
  my $class = shift;
  $_->import for qw( strict warnings utf8 );
  feature->import(':5.14');
  require Carp;
}

1;
