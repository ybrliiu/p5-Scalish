package Scalish::NoSuchElementException;

use Scalish::Exporter;
use parent 'Exception::Tiny';

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/ stack_trace /]
);
  
# override
sub throw {
  my $class = shift;

  my %args;
  if (@_ == 0) {
      $args{message} = $class;
  } elsif (@_ == 1) {
      $args{message} = shift;
  } else {
      %args = @_;
  }
  $args{message} = $class unless defined $args{message} && $args{message} ne '';

  ($args{package}, $args{file}, $args{line}) = caller(0);
  $args{subroutine}  = (caller(1))[3];
  $args{stack_trace} = $args{message} . Carp::longmess();

  die $class->new(%args);
}

# override
sub as_string { shift->{stack_trace} }

1;
