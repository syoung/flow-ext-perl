package ActiveState::YAML;

use strict;
our $VERSION = '0.01';

use base qw(Exporter);
our @EXPORT_OK = qw(yaml_load_file yaml_dump_file yaml_load yaml_dump);

use ActiveState::YAML::CPAN::YAML qw(LoadFile DumpFile Load Dump);

*yaml_load_file = \&LoadFile;
*yaml_dump_file = \&DumpFile;
*yaml_load = \&Load;
*yaml_dump = \&Dump;

1;

__END__

=head1 NAME

ActiveState::YAML - YAML API

=head1 SYNOPSIS

 use ActiveState::YAML qw(yaml_load_file);
 my $foo = yaml_load_file("foo.yml");

=head1 DESCRIPTION

This is currently just a frontend for the C<YAML> module from CPAN,
but its internals will change as YAML for perl evolves.  Currently
YAML for perl appears to be in a state of flux and this module provide
a stable interface for ActiveState modules that needs to deal with
YAML.

The following functions are provided:

=over

=item yaml_load_file( $filename )

This will parse YAML from the given file and return the
corresponding perl data structure.  The function will croak on errors.

=item yaml_dump_file( $filename, @data )

This will save the @data as YAML to the given file.  The function will
croak on errors.

=item yaml_load( $string )

This will parse a string of YAML and return the corresponding perl
data structure.  The function will croak on errors.

=item yaml_dump( @data )

This will return @data represented as string of YAML.

=back

=head1 SEE ALSO

L<YAML>

