package Scalish;

use Scalish::Exporter; # enables strict, warnigns and utf8
our $VERSION = '0.01';

use Scalish::Option::Some;
use Scalish::Option::None;
use Scalish::Either::Right;
use Scalish::Either::Left;
use Scalish::Validation::Success;
use Scalish::Validation::Failure;

use Exporter qw( import );
our @EXPORT_OK = qw(
  option
  some
  none
  right
  left
  success
  failure
  for_each
  for_yield
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub option($) {
    defined $_[0] ? Scalish::Option::Some->new( $_[0] ) : Scalish::Option::None->new;
}

sub some($) { Scalish::Option::Some->new( $_[0] ) }

sub none() { Scalish::Option::None->new() }

sub right($) { Scalish::Either::Right->new( $_[0] ) }

sub left($) { Scalish::Either::Left->new( $_[0] ) }

sub success($) { Scalish::Validation::Success->new( $_[0] ) }

sub failure($) { Scalish::Validation::Failure->new( $_[0] ) }

sub _rec_for_each {
    my ( $iters, $index, $params, $code ) = @_;
    if ( $index == @$iters - 1 ) {
        $iters->[$index]->foreach(
            sub {
                my $c = shift;
                $code->( @$params, $c );
            }
        );
    }
    else {
        $iters->[$index]->foreach(
            sub {
                my $c = shift;
                push @$params, $c;
                _rec_for_each( $iters, $index + 1, $params, $code );
            }
        );
    }
}

sub for_each {
    my ( $iters, $code ) = @_;
    _rec_for_each( $iters, 0, [], $code );
}

sub _rec_for_yield {
    my ( $iters, $index, $params, $code ) = @_;
    if ( $index == @$iters - 1 ) {
        $iters->[$index]->map(
            sub {
                my $c = shift;
                $code->( @$params, $c );
            }
        );
    }
    else {
        $iters->[$index]->flat_map(
            sub {
                my $c = shift;
                push @$params, $c;
                _rec_for_yield( $iters, $index + 1, $params, $code );
            }
        );
    }
}

sub for_yield {
    my ( $iters, $code ) = @_;
    _rec_for_yield( $iters, 0, [], $code );
}


1;

__END__

=encoding utf-8

=head1 NAME

Scalish - It's new $module

=head1 SYNOPSIS

    use Scalish;

=head1 DESCRIPTION

Scalish is ...

=head1 LICENSE

Copyright (C) mp0liiu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mp0liiu E<lt>raian@reeshome.orgE<gt>

=cut

