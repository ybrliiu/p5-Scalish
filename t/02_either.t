use Scalish::Exporter;
use Test::More;
use Test::Exception;

use Scalish qw( right left );

subtest 'fold' => sub {
  my $r = right(1);
  is $r->fold(sub { $_ * 2 }, sub { $_ * 3 }), 3;
  my $l = left(1);
  is $l->fold(sub { $_ * 2 }, sub { $_ * 3 }), 2;
};

subtest 'is_right and is_left' => sub {
  my $r = right(0);
  ok $r->is_right;
  ok not $r->is_left;
  my $l = left(0);
  ok not $l->is_right;
  ok $l->is_left;
};

subtest 'join_left' => sub {
  my $l = left(10);
  dies_ok { $l->join_left };
  my $ll = left($l);
  is_deeply $ll->join_left, $l;
  my $r = right(1);
  is $r->join_left, $r;
  my $lr = left($r);
  is_deeply $lr->join_left, $r;
  my $rl = right($l);
  is $rl->join_left, $rl;
  my $rr = right($r);
  is $rr->join_left, $rr;
};

subtest 'join_right' => sub {
  my $l = left(10);
  is $l->join_right, $l;
  my $ll = left($l);
  is $ll->join_right, $ll;
  my $r = right(1);
  dies_ok { $r->join_right };
  my $lr = left($r);
  is $lr->join_right, $lr;
  my $rl = right($l);
  is_deeply $rl->join_right, $l;
  my $rr = right($r);
  is_deeply $rr->join_right, $r;
};

subtest 'left' => sub {
  my $lp = left(33)->left;
  ok $lp->isa('Scalish::Either::LeftProjection');
  is $lp->get_or_else(0), 33;
  my $lp2 = right(9)->left;
  is $lp2->get_or_else(404), 404;
};

subtest 'merge' => sub {
  my $r = right(1);
  is $r->merge, 1;
  my $l = left(0);
  is $l->merge, 0;
};

subtest 'match' => sub {
  ok my $r = right(100);
  my $content = $r->match(
    Right => sub { $_ * 100 },
    Left  => sub { "err" },
  );
  is $content, 10000;
  ok my $l = left("error");
  $content = $l->match(
    Right => sub { $_ ** 2 },
    Left  => sub { "error_mes is $_." }
  );
  is $content, 'error_mes is error.';
};

subtest 'right' => sub {
  my $rp = right(88)->right;
  ok $rp->isa('Scalish::Either::RightProjection');
  is $rp->get_or_else(400), 88;
  my $rp2 = left("hello")->right;
  is $rp2->get_or_else(401), 401;
};

subtest 'swap' => sub {
  my $l = left(0);
  ok $l->swap->is_right;
  my $r = right(1);
  ok $r->swap->is_left;
};

subtest 'exists' => sub {
  my $r = right(1);
  ok $r->exists(sub { $_ == 1 });
  ok not $r->exists(sub { $_ == 0 });
  my $l = left(0);
  ok not $l->exists(sub { $_ == 0 });
  ok not $l->exists(sub { $_ == 1 });
};

subtest 'filter' => sub {
  my $r = right(10);
  my $or = $r->filter(sub { $_ > 5 });
  ok $or->isa('Scalish::Option::Some');
  $or->foreach(sub { $_->map(sub { is $_, 10 }) });
  ok $r->filter(sub { $_ < 5 })->isa('Scalish::Option::None');
  my $l = left(7);
  ok $l->filter(sub { $_ > 5 })->isa('Scalish::Option::None');
  ok $l->filter(sub { $_ < 5 })->isa('Scalish::Option::None');
};

subtest 'flat_map' => sub {
  my $r = right(1);
  dies_ok { $r->flat_map(sub { $r * 2 }) };
  my $l = left(0);
  is $l->flat_map(sub { $l + 10 }), $l;
  my $rr = right($r);
  $rr->flat_map(sub {
    my $c = shift;
    $c->map(sub { is $_, 1 });
  });
  my ($r1, $r2, $r3) = map { right($_) } (2, 7, 4);

  my $tester = sub {
    my ($r1, $r2, $r3) = @_;
    my $c1 = shift;
    $r1->flat_map(sub {
      my $c1 = shift;
      $r2->flat_map(sub {
        my $c2 = shift;
        $r3->map(sub {
          my $c3 = shift;
          $c1 * $c2 * $c3;
        })
      })
    });
  };

  my $result1 = $tester->( map { right($_) } (4, 2, 7) );
  $result1->map(sub { is $_, 56 });
  my $result2 = $tester->( right(5), left(2), right(6) );
  ok $result2->is_left;
  $result2->foreach(sub { is $_, 2 });
};

subtest 'foreach' => sub {
  my $r = right(1);
  dies_ok { $r->foreach(sub { die }) };
  my $l = left(0);
  lives_ok { $l->foreach(sub { die }) };
};

subtest 'get' => sub {
  my $r = right(1);
  is $r->get, 1;
  my $l = left(0);
  dies_ok { $l->get };
};

subtest 'get_or_else' => sub {
  my $r = right(2);
  is $r->get_or_else(77), 2;
  my $l = left(100);
  is $l->get_or_else(55), 55;
};

subtest 'map' => sub {
  my $r = right(2.5);
  my $r2 = $r->map(sub { $_ * 6 });
  $r2->map(sub { is $_, 15 });
  my $l = left(9);
  is $l->map(sub { $_ ** $_ }), $l;
};

subtest 'to_option' => sub {
  my $or = right(5)->to_option;
  ok $or->isa('Scalish::Option::Some');
  $or->foreach(sub { $_, 5 });
  my $ol = left(88)->to_option;
  ok $ol->isa('Scalish::Option::None');
};

done_testing;

