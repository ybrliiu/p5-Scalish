package Scalish::Either::Projection;

use Scalish::Exporter;

use Scalish::Option::Some;
use Scalish::Option::None;
use Scalish::NoSuchElementException;

sub new { Carp::croak 'you must define constructer.' }

sub _content { $_[0]->{either}->{content} }

sub _is_available { Carp::croak 'you must define _is_available method.' }

sub exists {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    my $content = $self->_content;
    local $_ = $content;
    $self->_is_available && $code->($content);
}

sub filter {
    my ( $self, $code ) = @_;
    my $result = $self->exists($code);
    $result
      ? Scalish::Option::Some->new( $self->{either} )
      : Scalish::Option::None->new;
}

sub flat_map { Carp::croak 'you must define flat_map method.' }

sub foreach {
    my ( $self, $code ) = @_;
    my $content = $self->_content;
    if ( $self->_is_available ) {
        Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
        local $_ = $content;
        $code->($content);
    }
    ();
}

sub get {
    my $self    = shift;
    my $content = $self->_content;
    $self->_is_available ? $content : Scalish::NoSuchElementException->throw;
}

sub get_or_else {
    my ( $self, $default ) = @_;
    Carp::croak 'Too few arguments (required: $default)' if @_ < 2;
    my $content = $self->_content;
    $self->_is_available ? $content : $default;
}

sub map {
    my ( $self, $code ) = @_;
    my $content = $self->_content;
    if ( $self->_is_available ) {
        Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
        local $_ = $content;
        my $ret = $code->($content);
        Scalish::Either::Right->new($ret);
    }
    else {
        Scalish::Either::Left->new( $self->_content );
    }
}

sub to_option {
    my $self = shift;
    $self->_is_available
      ? Scalish::Option::Some->new( $self->_content )
      : Scalish::Option::None->new;
}

1;

