use Scalish::Exporter;
use Test::More;
use Test::Exception;

use Scalish qw( option some none );

subtest 'exists' => sub {
  my $some = some(5);
  ok $some->exists(sub { $_ < 10 });
  ok !$some->exists(sub { $_ > 10 });
  my $none = none;
  ok !$none->exists(sub { $_ == 0 });
};

subtest 'fold' => sub {
  ok my $none = option(undef);
  dies_ok { $none->fold(sub { die 'undef' })->(sub { 'some' }) };
  ok my $some = option('string');
  is $some->fold(sub { die 'undef' })->(sub { $_ . '_value' }), 'string_value';
};

subtest 'foreach' => sub {
  my $some = option("aaa");
  ok! $some->foreach(sub { $_ . '+aaa' });
  dies_ok { $some->foreach(sub { die }) };
  my $none = option(undef);
  lives_ok { $none->foreach(sub { die }) };
};

subtest 'flatten' => sub {

  my $func = sub {
    my ($c1, $c2) = @_;
    my ($v1, $v2) = (option($c1), option($c2));
    $v1->map(sub { my $s1 = $_; $v2->map(sub { my $s2 = $_; $s1 * $s2 }) })->flatten;
  };

  $func->(5, 6)->map(sub { is $_, 30 });
  ok $func->(5, undef)->isa('Scalish::Option::None');
  ok $func->(undef, 6)->isa('Scalish::Option::None');
  ok $func->(undef, undef)->isa('Scalish::Option::None');

  my $func2 = sub {
    my @args = @_;
    my ($v1, $v2, $v3, $v4) = map { option($_) } @args;
    $v1->map(sub {
      my $s1 = shift;
      $v2->map(sub {
        my $s2 = shift;
        $v3->map(sub {
          my $s3 = shift;
          $v4->map(sub {
            my $s4 = shift;
            $s1 * $s2 * $s3 * $s4;
          })
        })->flatten
      })->flatten
    })->flatten
  };
  
  my $some = $func2->(6, 4, 2, 5);
  $some->map(sub { is $_, 240 });
  ok $func2->(6, 4, 2, undef)->isa('Scalish::Option::None');
  ok $func2->(6, 4, undef, 5)->isa('Scalish::Option::None');
  ok $func2->(undef, 4, 2, 5)->isa('Scalish::Option::None');
  ok $func2->(undef, undef, undef, undef)->isa('Scalish::Option::None');

};

subtest 'flat_map' => sub {

  my $func = sub {
    my @args = @_;
    my ($v1, $v2, $v3, $v4) = map { option($_) } @args;
    $v1->flat_map(sub {
      my $s1 = shift;
      $v2->flat_map(sub {
        my $s2 = shift;
        $v3->flat_map(sub {
          my $s3 = shift;
          $v4->map(sub {
            my $s4 = shift;
            $s1 * $s2 * $s3 * $s4;
          })
        })
      })
    })
  };

  my $some = $func->(6, 4, 2, 5);
  $some->map(sub { is $_, 240 });
  ok $func->(6, 4, 2, undef)->isa('Scalish::Option::None');
  ok $func->(6, 4, undef, 5)->isa('Scalish::Option::None');
  ok $func->(undef, 4, 2, 5)->isa('Scalish::Option::None');
  ok $func->(undef, undef, undef, undef)->isa('Scalish::Option::None');

};

subtest 'get' => sub {
  my $s = some(6);
  is $s->get, 6;
  my $n = none;
  dies_ok { $n->get };
};

subtest 'get_or_else' => sub {
  my $s = option(5);
  is $s->get_or_else(4), 5;
  my $n = none;
  is $n->get_or_else(4), 4;
};

subtest 'is_defined' => sub {
  ok some(6)->is_defined;
  ok !none->is_defined;
};

subtest 'is_empty' => sub {
  ok !some(10)->is_empty;
  ok none->is_empty;
};

subtest 'map' => sub {
  my $s = option(9);
  ok $s->map(sub { is $_, 9; $_ * 9 })->isa('Scalish::Option::Some');
  my $n = none;
  lives_ok { $n->map(sub { die }) };
};

subtest 'match' => sub {
  my $option = option('SOMETHING');
  my $ret = $option->match(
    Some => sub { 200 },
    None => sub { 404 },
  );
  is $ret, 200;

  my $none = option(undef);
  my $ret_2 = $none->match(
    Some => sub { 200 },
    None => sub { 404 },
  );
  is $ret_2, 404;
};

subtest 'to_left' => sub {
  my $s = some('o');
  my $sl = $s->to_left('p');
  ok $sl->isa('Scalish::Either::Left');
  lives_ok { $sl->map(sub { die }) };
  my $n = none;
  my $nl = $n->to_left('p');
  ok $nl->isa('Scalish::Either::Right');
  $nl->map(sub { is $_, 'p' });
};

subtest 'to_list' => sub {
  ok my $opt = option(option(option(100)));
  my $val = do {
    my ($opt1, $has_100) = $opt->to_list;
    $has_100;
  }->get_or_else(404);
  is $val, 100;
  ok my $none = option(option(none));
  my $val2 = do {
    my ($opt1, $has_100) = $none->to_list;
    $has_100;
  }->get_or_else(404);
  is $val2, 404;
};

subtest 'to_right' => sub {
  my $s = some('o');
  my $sl = $s->to_right('p');
  ok $sl->isa('Scalish::Either::Right');
  $sl->map(sub { is $_, 'o' });
  my $n = none;
  my $nl = $n->to_right('p');
  ok $nl->isa('Scalish::Either::Left');
  lives_ok { $nl->map(sub { die }) };
};

done_testing;

