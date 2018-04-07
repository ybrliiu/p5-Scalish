package Scalish::Either::LeftProjection;

use Scalish::Exporter;
use parent 'Scalish::Either::Projection';

# override
sub new {
    my ( $class, $either ) = @_;
    Carp::croak 'type mismatch. required Either'
      unless $either->isa('Scalish::Either::Either');
    bless { either => $either }, $class;
}

# override
sub _is_available {
    my $self = shift;
    $self->{either}->is_left;
}

# override
sub flat_map {
    my ( $self, $code ) = @_;
    $self->map($code)->join_left;
}

1;
