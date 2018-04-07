use Scalish::Exporter;
use Test::More;
use Test::Exception;

use Scalish ':all';

subtest 'for_each' => sub {
  for_each [ map { option $_ } (6, 4, 2, 5) ], sub {
    my ($n1, $n2, $n3, $n4) = @_;
    is $n1 * $n2 * $n3 * $n4, 240;
  };
  lives_ok {
    for_each [ map { option $_ } (6, 4, undef, 5) ], sub {
      my ($n1, $n2, $n3, $n4) = @_;
      die $n1 * $n2 * $n3 * $n4;
    }
  };
};

subtest 'for_yield' => sub {
  my $result = for_yield [ map { option $_ } (6, 4, 2, 5) ], sub {
    my ($n1, $n2, $n3, $n4) = @_;
    $n1 * $n2 * $n3 * $n4;
  };
  $result->map(sub { is $_, 240 });
  $result = for_yield [ map { option $_ } (6, 4, undef, 5) ], sub {
    my ($n1, $n2, $n3, $n4) = @_;
    $n1 * $n2 * $n3 * $n4;
  };
  ok $result->isa('Scalish::Option::None');
  $result = for_yield [ map { option $_ } (undef) x 4 ], sub {
    my ($n1, $n2, $n3, $n4) = @_;
    $n1 * $n2 * $n3 * $n4;
  };
  ok $result->isa('Scalish::Option::None');
};

done_testing;
