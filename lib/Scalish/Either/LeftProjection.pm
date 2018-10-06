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
sub map {
    my ( $self, $code ) = @_;
    my $content = $self->_content;
    if ( $self->_is_available ) {
        Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
        local $_ = $content;
        my $ret = $code->($content);
        Scalish::Either::Left->new($ret);
    }
    else {
        Scalish::Either::Right->new( $self->_content );
    }
}

# override
sub flat_map {
    my ( $self, $code ) = @_;
    $self->map($code)->join_left;
}

1;
