use v5.14;
use strict;
use warnings FATAL => 'all';
no warnings qw(void once uninitialized numeric);

package Moops::Keyword::Class;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.036';

use Moo;
use B 'perlstring';
extends qw( Moops::Keyword::Role );

my %using = (
	Moo   => 'use Moo; use MooX::late;',
	Moose => 'use Moose; use MooseX::KavorkaInfo;',
	Mouse => 'use Mouse;',
	Tiny  => 'use Class::Tiny; use Class::Tiny::Antlers;',
);

sub generate_package_setup_oo
{
	my $self  = shift;
	my $using = $self->relations->{using}[0] // $self->default_oo_implementation;
	
	exists($using{$using})
		or Carp::croak("Cannot create a package using $using; stopped");
	
	my @lines = (
		'use namespace::autoclean -also => "has";',
		'use Lexical::Accessor;',
	);
	push @lines, "use MooseX::MungeHas qw(@{[ $self->arguments_for_moosex_mungehas ]});"
		if $using =~ /^Mo/;

	if ($using eq 'Moose')
	{
		state $has_xs = !!eval('require MooseX::XSAccessor');
		push @lines, 'use MooseX::XSAccessor;' if $has_xs;
	}

	my @return = (
		$using{$using},
		$self->generate_package_setup_relationships,
		@lines,
	);
	
	# Note that generate_package_setup_relationships typically adds
	# `with` statements for composing roles, so we need to add this
	# make_immutable *after* calling it.
	$self->_mk_guard('__PACKAGE__->meta->make_immutable;')
		if $self->should_make_immutable;
	
	return @return;
}

sub should_make_immutable
{
	my $self  = shift;
	my $using = $self->relations->{using}[0] // $self->default_oo_implementation;
	($using eq 'Moose' or $using eq 'Mouse');
}

around generate_package_setup_relationships => sub
{
	my $orig = shift;
	my $self = shift;
	
	my @classes = @{ $self->relations->{extends} || [] };
	return (
		@classes ? sprintf("extends(%s);", join ",", map perlstring($_), @classes) : (),
		$self->$orig(@_),
	);
};

around known_relationships => sub
{
	my $next = shift;
	my $self = shift;
	return($self->$next(@_), qw/ extends /);
};

1;
