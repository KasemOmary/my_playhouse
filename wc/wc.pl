#!/usr/bin/perl
# wc.pl 
# GNU wc clone 

my $file_cnt;
my @flags;
	# Command Line Options.
my @files;
	# List of files to process.
my %errors; 
	# List of file-not-found errors.
my %results;
	# Results to return.

foreach $arg (@ARGV) {
	# Valid Flags:  -c -m -l -L -w --help --version
	if ($arg =~ /\-/) {
		$arg =~ s/--bytes/c/;
		$arg =~ s/--chars/m/;
		$arg =~ s/--lines/l/;
		$arg =~ s/--max-line-length/L/;
		$arg =~ s/--words/w/;
		# Truncate long args.

		if ($arg =~ /files0-from=/) {
			# File List Load Flag
			$arg =~ s/.*=(.*)/$1/;
			if (-e $arg) {
				open (IN, $arg);
				while (<IN>) {
					my $fAdd = $_;
					chomp($fAdd);
					push (@files,$fAdd);
				}
				close (IN);
			}
		} elsif ($arg !~ /--help|--version|-[cmlLw]|--bytes|--chars|--lines|--max-line-length|--words/) {
			&infoPrint(3,$arg);
			# Bad switch.  Throw error & exit. 
		} else { 
			if ($arg =~ /--help/) { 
				&infoPrint(1); 
				# Print help & exit. 
			} 
			elsif ($arg =~ /--version/) { 
				&infoPrint(2);
				# Print version & exit. 
			}
			$arg =~ s/-//g;
			push (@flags,$arg);
		}
	} else {
		push (@files,$arg);
	}
}
$file_cnt = @files;
# Number of files to check, 0 or more. 

# Load Files 
if  ($file_cnt == 0) { 
	my @buffer;
	@files[0] = "STDIN";
	my $lines, $chars, $bytes, $max_length, $words;
	while (<STDIN>) {
		$line = $_;
		chomp($line);
		$lines++;
		$chars += length($line);
		$bytes += length($line);
		$w_c =()= $line =~ /\s/g;
			# Count the spaces in the line.  
		$words += $words + $w_c + 1;
			# The word count is spaces + 1. 
		if (length($line) > $max_length) {
			$max_length = length($line);
		}
		push (@buffer, $line); # wc uses OS interrupt to finish input. 
		
	}
	$results{$files[0]} = ($lines, $chars, $bytes, $max_length, $words);

	# Get lines from STDIN 
} else {
	foreach $file (@files) {
		if (-e $file) {
			open (IN,"$file");
			my $lines, $chars, $bytes, $max_length, $words;

			while (<IN>) {
				$line = $_;
				chomp($line);
				$lines++;
				$chars += length($line);
				$bytes += length($line);
				$w_c =()= $line =~ /\S\s\S/g;
					# Count the spaces surrounded by characters in the line
				if (length($line) > 0) {
					$words += $w_c + 1;
					# The word count is spaces + 1, or 1.
				}
				if (length($line) > $max_length) {
					$max_length = length($line);
				}
				push (@buffer, $line); # wc uses OS interrupt to finish input. 
				
			}
			$results{$file} = {lines => $lines, chars => $chars, bytes => $bytes, max_length => $max_length, words => $words};
			close(IN);
			$max_length = 0; 
				# Reset the longest line. 
		} else {
			print "wc: $file: No such file or directory\n";
			$errors{$file} = "1";
				# File is an error, don't process later. 
		}
	}
}

$total_lines = 0;
$total_bytes = 0;
$total_words = 0;
$total_chars = 0;
$longest_line = 0;

foreach $file (@files) {
	if ($errors{$file} != 1) {
		# @flags; 
		# Valid Flags:  -c -m -l -L -w
		if ($flags[0] =~ /\S/) {
			# If flags exist 
			foreach $flag (@flags) {
				if ($flag =~ /c/) {
					print "$results{$file}->{bytes}\t";
					$total_bytes += $results{$file}->{bytes};
				} elsif ($flag =~ /m/) {
					print "$results{$file}->{chars}\t";
					$total_chars += $results{$file}->{chars};
				} elsif ($flag =~ /l/) {
					print "$results{$file}->{lines}\t";
					$total_lines += $results{$file}->{lines};
				} elsif ($flag =~ /L/) {
					print "$results{$file}->{max_length}\t";
					if ($results{$file}->{max_length} > $longest_line) {
						$longest_line = $results{$file}->{max_length};
					}
				} elsif ($flag =~ /w/) {
					print "$results{$file}->{words}\t";
					$total_words += $results{$file}->{words};
				}
			}
			print "$file\n";
		} else { 
			print "$results{$file}->{lines}\t$results{$file}->{words}\t$results{$file}->{chars}\t$file\n";
			#print "$results{$file}->{lines} - $results{$file}->{bytes} - $results{$file}->{max_length}  - $results{$file}->{words}  - $file\n";
			$total_lines += $results{$file}->{lines};
			$total_bytes += $results{$file}->{bytes};
			$total_words += $results{$file}->{words};
			$total_chars += $results{$file}->{chars};
		}
	}
}

if ($flags[0] =~ /\S/) {
			foreach $flag (@flags) {
				if ($flag =~ /c/) {
					print "$total_bytes\t";
				} elsif ($flag =~ /m/) {
					print "$total_chars\t";
				} elsif ($flag =~ /l/) {
					print "$total_lines\t";
				} elsif ($flag =~ /L/) {
					print "$longest_line\t";
				} elsif ($flag =~ /w/) {
					print "$total_words\t";
				}
			}
			print "total\n";
} else {
	print "$total_lines\t$total_words\t$total_chars\ttotal\n";	
}

##################################
sub infoPrint {

if ($_[0] == 1) {

print << '__END_DATA__';
Usage: wc [OPTION]... [FILE]...
  or:  wc [OPTION]... --files0-from=F
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  With no FILE, or when FILE is -,
read standard input.  A word is a non-zero-length sequence of characters
delimited by white space.
  -c, --bytes            print the byte counts
  -m, --chars            print the character counts
  -l, --lines            print the newline counts
      --files0-from=F    read input from the files specified by
                           NUL-terminated names in file F;
                           If F is - then read names from standard input
  -L, --max-line-length  print the length of the longest line
  -w, --words            print the word counts
      --help     display this help and exit
      --version  output version information and exit

Report wc bugs to bug-coreutils@gnu.org
GNU coreutils home page: <http://www.gnu.org/software/coreutils/>
General help using GNU software: <http://www.gnu.org/gethelp/>
For complete documentation, run: info coreutils 'wc invocation'
__END_DATA__

} elsif ($_[0] == 2) { 

print << '__END_DATA__';
wc (Perl Clone) 1.0
Copyright (C) 2010 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Paul Rubin and David MacKenzie.
__END_DATA__

} else {

print "wc: invalid option -- '$_[1]'\n";
print "Try `wc --help' for more information.\n";

}

exit;

}
##################################