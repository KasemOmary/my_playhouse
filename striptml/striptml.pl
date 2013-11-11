#!/usr/bin/perl
=head1 Name
striptml - a simple html scrubber

=head1 SYNOPSIS
striptml.pl inputfile.ext 

=head1 DESCRIPTION
Strips html out of an input file, output to stdout.  Very simple.

=head1 SEE ALSO

=head1 COPYRIGHT
Copyright 2013 K. Omary 
Released under the terms of GPLv2

=cut


$file = $ARGV[0]; 

if ($file !~ /\w+/i) {
	print "striptml - usage\n";
	print "striptml.pl inputfile\n";
	print "Output to stdout.\n";
} else { 
	if (-e $file) {
		open (FILE,$file) || die "striptml - fatal\n I can't open the file $file.\n";
		while (<FILE>) {
			#$y = $_;
			#$y =
			s/\<[\w\/].*\>//g;
			print "$x: $_";
			$x++;
		}
		close(FILE);
	} else { 
		print "striptml - fatal\n";
		print "flie $file not found.\n"	;
	}
}