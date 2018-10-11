package Scalish::Validation::Success;

use Scalish::Exporter;
use parent 'Scalish::Validation::Validation';

use Scalish::Option::Some;
use Scalish::Either::Right;

# override
sub new {
    my ( $class, $content ) = @_;
    Carp::croak 'Too few arguments (required: $content)' if @_ < 2;
    bless +{ content => $content }, $class;
}

# override
sub exists {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required : $code)' if @_ < 2;
    local $_ = $self->{content};
    $code->( $self->{content} );
}

# override
sub fold {
    my ( $self, $failure_code, $success_code ) = @_;
    Carp::croak 'Too few arguments (required : $failure_code, $success_code)' if @_ < 3;
    $success_code->( $self->{content} );
}

# override
sub get_or_else {
    my ( $self, $failure_code ) = @_;
    Carp::croak 'Too few arguments (required : $failure_code)' if @_ < 2;
    $self->{content};
}

# override
sub is_success { 1 }

# override
sub match {
    my ( $self, %args ) = @_;
    Carp::croak 'Invalid arguments' if @_ < 5;
    for (qw/ Success Failure /) {
        my $code = $args{$_};
        Carp::croak "Please specify process of $_ " if ref $code ne 'CODE';
    }
    local $_ = $self->{content};
    $args{Success}->( $self->{content} );
}


# override
sub to_list {
    my $self = shift;
    if ( $self->{content}->isa('Scalish::Validation::Validation') ) {
        ( $self->{content}, $self->{content}->to_list );
    }
    else {
        ();
    }
}

# override
sub to_option {
  my $self = shift;
  Scalish::Option::Some->new( $self->{content} );
}

# override
sub to_either {
  my $self = shift;
  Scalish::Either::Right->new( $self->{content} );
}

1;
