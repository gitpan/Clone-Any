package Clone::Any;

use strict;
use vars qw($VERSION @EXPORT_OK);

$VERSION = 1.00;

@EXPORT_OK = qw( clone ); # lazy Exporter
sub import { require Exporter and &_clone_any_init and goto &Exporter::import } 

sub _clone_any_candidates {
  'Clone' => 'clone',
  'Clone::PP' => 'clone',
  'Storable' => sub { Storable::dclone( shift ) },
}

sub _clone_any_init {
  my @candidates = my %candidates = _clone_any_candidates();
  while ( my ($class, $function) = splice @candidates, 0, 2 ) {
    (my $pm = "$class.pm") =~ s{::}{/}g;
    # warn "Require $pm\n";
    eval { require $pm };
    next if ( $@ );
    # warn "Installing $class\::$function\n";
    return *clone = ref($function) ? $function : \&{"$class\::$function"};
  }
  die "Can't locate any Clone module (" . join(', ', keys %candidates) . ")";
}

1;

__END__

=head1 NAME

Clone::Any - Select an available recursive-copy function

=head1 SYNOPSIS

  use Clone::Any qw(clone);
  
  $a = { 'foo' => 'bar', 'move' => 'zig' };
  $b = [ 'alpha', 'beta', 'gamma', 'vlissides' ];
  $c = new Foo();
  
  $d = clone($a);
  $e = clone($b);
  $f = clone($c);

=head1 DESCRIPTION

This module checks for several different modules which can provide
a clone() method which makes recursive copies of nested hash, array,
scalar and reference types, including tied variables and objects.

Depending on which modules are available, this will either use Clone, Clone::PP or Storable.

The clone() function takes a scalar argument to copy. To duplicate
lists, arrays or hashes, pass them in by reference. e.g.
    
  my $copy = clone (\@array);
  # or
  my %copy = %{ clone (\%hash) };  

=head1 SEE ALSO

For various implementations, see L<Clone>, L<Clone::PP> and <Storable>.

=head1 CREDITS AND COPYRIGHT

Developed by Matthew Simon Cavalletto, simonm@cavalletto.org. 
Mode modules from Evolution Softworks are available at www.evoscript.org.
Copyright 2003 Matthew Simon Cavalletto. 

Interface based on Clone by Ray Finch, rdf@cpan.org. 
Portions Copyright 2001 Ray Finch.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
