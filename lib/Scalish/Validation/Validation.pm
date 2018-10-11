package Scalish::Validation::Validation;

use Scalish::Exporter;

sub new {}

sub exists {}

sub fold {}

sub foreach {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    $self->yield($code);
    ();
}

sub flatten {
    my $self = shift;
    $self->{content}->isa('Scalish::Validation::Validation')
      ? $self->{content}
      : Carp::croak '$self->{content} is not Scalish::Validation::Validation type';
}

sub flat_map {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    $self->map($code)->flatten;
}

sub get_or_else {}

sub is_success {}

sub is_failure { !shift->is_success }

sub map {}

sub match {}

sub to_list {}

# あとで全モジュールで統一的に変更したい
sub to_option {}

# あとで全モジュールで統一的に変更したい
sub to_either {}

sub yield {
    my ( $self, $code ) = @_;
    Carp::croak 'Too few arguments (required: $code)' if @_ < 2;
    local $_ = $self->{content};

    # NOTE : in Scala, for - yield
    $code->( $self->{content} );
}

1;

__END__

Scalaz.Validation の実装

- flatten, flat_map あたりの実装はScalazと異なっています
  - そもそも flatten なんてメソッドはない
- NonEmptyList は使いません, 代わりにArrayRefを使います

