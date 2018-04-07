package Scalish::Option::Some;

use Scalish::Exporter;
use parent 'Scalish::Option::Option';

use Scalish::Either::Right;
use Scalish::Either::Left;

# override
sub new {
    my ( $class, $content ) = @_;
    Carp::croak 'Too few arguments (required : $content)' if @_ < 2;

# Scala では null を許容するが、このモジュールでは許容しない
    Carp::croak "Can't use undefined value at $class" unless defined $content;
    bless { content => $content }, $class;
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
    my ( $self, $for_none ) = @_;
    Carp::croak 'Too few arguments (required : $for_none)' if @_ < 2;
    sub {
        Carp::croak 'Too few arguments (required : $code)' if @_ < 1;
        my $code = shift;
        local $_ = $self->{content};
        $code->( $self->{content} );
    };
}

# override
sub flatten {
    my $self = shift;
    $self->{content}->isa('Scalish::Option::Option')
      ? $self->{content}
      : Carp::croak '$self->{content} is not Scalish::Option::Option type';
}

# override
sub get { shift->{content} }

# override
sub get_or_else {
    my ( $self, $default ) = @_;
    Carp::croak 'Too few arguments (required: $default)' if @_ < 2;
    $self->{content};
}

# override
sub is_defined { 1 }

# override
sub map {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    Scalish::Option::Some->new( $self->yield($code) );
}

# override
sub match {
    my ( $self, %args ) = @_;
    Carp::croak 'Invalid arguments' if @_ < 5;
    for (qw/ Some None /) {
        my $code = $args{$_};
        Carp::croak "Please specify process of $_ " if ref $code ne 'CODE';
    }
    local $_ = $self->{content};
    $args{Some}->( $self->{content} );
}

# override
sub to_left {
    my ( $self, $default ) = @_;
    Carp::croak 'Too few arguments (required: $default)' if @_ < 2;
    Scalish::Either::Left->new( $self->{content} );
}

# override
sub to_list {
    my $self = shift;
    if ( $self->{content}->isa('Scalish::Option::Option') ) {
        ( $self->{content}, $self->{content}->to_list );
    }
    else {
        ();
    }
}

# override
sub to_right {
    my ( $self, $default ) = @_;
    Carp::croak 'Too few arguments (required: $default)' if @_ < 2;
    Scalish::Either::Right->new( $self->{content} );
}

# override
sub yield {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    local $_ = $self->{content};

    # NOTE : in Scala, for - yield
    $code->( $self->{content} );
}

1;
