package Scalish::Either::Either;

use Scalish::Exporter;
use parent 'Scalish::Either::Projection';

use Scalish::Option::Some;
use Scalish::Option::None;
use Scalish::Either::LeftProjection;
use Scalish::Either::RightProjection;

# override
sub _content { $_[0]->{content} }

# override
sub _is_available { $_[0]->is_right }

# override
sub filter {
    my ( $self, $code ) = @_;
    my $result = $self->exists($code);
    $result ? Scalish::Option::Some->new($self) : Scalish::Option::None->new;
}

# override
sub flat_map {
    my ( $self, $code ) = @_;
    $self->map($code)->join_right;
}

sub fold { Carp::croak 'you must define fold method.' }

sub is_left() { Carp::croak 'you must define is_left method.' }

sub is_right() { Carp::croak 'you must define is_right method.' }

sub join_left { Carp::croak 'you must define join_left method.' }

sub join_right { Carp::croak 'you must define join_right method.' }

sub left {
    my $self = shift;
    Scalish::Either::LeftProjection->new($self);
}

sub merge {
    my $self = shift;
    $self->{content};
}

sub match {}

sub right {
    my $self = shift;
    Scalish::Either::RightProjection->new($self);
}

sub swap { Carp::croak 'you must define swap method.' }

1;

