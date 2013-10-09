#!/usr/bin/perl
# 
# Intel 4004 CPU Simulator 
# kasemo@gmail.com 
# 

# 0 0 0 0 
# 8 4 2 1
# 1 1 1 1 = 15 

$ax = 0;
$bx = 0;
$cx = 0;
$dx = 0;
$acc = 0;
$ind = 0;
$cry = 0;
$file = "program.4004";

print "i4004 CPU Simulator , enter \'help\' for command list.\n";

&com_input;

sub com_input {
	$execute = 1; 
	while ($execute) {
		print "\n> ";
		$com = <STDIN>;
		chomp $com;
		&com_interpret($com);
	}
}

sub load_file { 
		open (FILE,"$file");
		@file = <FILE>;
		close (FILE);
		$size = @file;

		print "Read: $size lines.\n";
		if ($size > 0) {
			print "Executing...\n";
				foreach $line (@file) {
				&mne_int_ex_single($line);
			}
		}
}

sub com_interpret {
	my $cmd = $_[0];
	if ($cmd =~ /quit/) {
		exit;
	} elsif ($cmd =~ /loadf/) {
		print "Loading from file $file\n";
		&load_file();
	} elsif ($cmd =~ /exsingle/) {
		print "Enter Opcode: "; 
		$in = <STDIN>;
		chomp $in;
		&mne_int_ex_single($in); 
	} elsif ($cmd =~ /setreg/) {
		# Set a register value 
		print "Set Register [reg,value]: ";
		$in = <STDIN>;
		($mr,$val) = split(/\,/,$in);
		chomp($val);
		if (!($val =~ /^\d+$/)) {
			print "Invalid value $val , Rejecting.\n";
		} else {
			if ($mr =~ /ax/) {
				$ax = $val;
			} elsif ($mr =~ /bx/) {
				$bx = $val;
			} elsif ($mr =~ /dx/) {
				$dx = $val;
			} elsif ($mr =~ /cx/) {
				$cx = $val;
			} elsif ($mr =~ /acc/) {
				$acc = $val;
			} else { 
				print "Invalid register $mr , Rejecting.\n";
			}
		}
	} elsif ($cmd =~ /env/) {
		# Dump Envrionment 
		print "[Environment]\n";
		print "AX: $ax BX: $bx CX: $cx DX: $dx\n";
		print "ACC: $acc \n";
	} elsif ($cmd =~ /help/) {
		print "Commands: \n";
		print "quit - exit\n";
		print "loadf - Load File\n";
		print "env - dump current contents of emulated environment\n";
		print "exsingle - execute a single opcode\n";
		print "setreg - push value to a register\n";
	} else {
		print "Invalid command $cmd , Rejecting.\n"; 
	}
}

sub mne_int_ex_single { 
	my $mne = $_[0];
	if ($mne =~ /add/) {
		#print "Executing opcode: add\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\D+$/)) {
			print "ERROR: Invalid operand, $opd .  Rejecting.\n";
		} else { 
			if ($opd =~ /ax/) {
				$acc += $ax;
			} elsif ($opd =~ /bx/) {
				$acc += $bx;
			} elsif ($opd =~ /dx/) {
				$acc += $dx;
			} elsif ($opd =~ /cx/) {
				$acc += $cx;
			} else { 
				print "ERROR: Invalid operand, $opd .  Rejecting.\n";
			}
		}
	} elsif ($mne =~ /sub/) {
		#print "Executing opcode: sub\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\D+$/)) {
			print "ERROR: Invalid operand, $opd .  Rejecting.\n";
		} else { 
			if ($opd =~ /ax/) {
				$acc -= $ax;
			} elsif ($opd =~ /bx/) {
				$acc -= $bx;
			} elsif ($opd =~ /dx/) {
				$acc -= $dx;
			} elsif ($opd =~ /cx/) {
				$acc -= $cx;
			} else { 
				print "ERROR: Invalid operand, $opd .  Rejecting.\n";
			}
		}
	} elsif ($mne =~ /inc/) {
		#print "Executing opcode: inc\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\D+$/)) {
			print "ERROR: Invalid operand, $opd .  Rejecting.\n";
		} else { 
			if ($opd =~ /ax/) {
				$ax++;
			} elsif ($opd =~ /bx/) {
				$bx++;
			} elsif ($opd =~ /dx/) {
				$dx++;
			} elsif ($opd =~ /cx/) {
				$cx++;
			} else { 
				print "ERROR: Invalid operand, $opd .  Rejecting.\n";
			}
		}
	} elsif ($mne =~ /iac/) {
		#print "Executing opcode: iac\n";
		$acc++;
	} elsif ($mne =~ /dac/) {
		#print "Executing opcode: dac\n";
		$acc--;
	} elsif ($mne =~ /clb/) {
		#print "Executing opcode: clb\n";
		$acc = 0;
		$cry = 0;
	} elsif ($mne =~ /clc/) {
		#print "Executing opcode: clc\n";
		$cry = 0;
	} elsif ($mne =~ /tcc/) {
		#print "Executing opcode: tcc\n";
		$acc = $cry;
		$cry = 0;
	} elsif ($mne =~ /stc/) {
		#print "Executing opcode: stc\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\d+$/)) {
			print "ERROR: Invalid operand, $opd .  Rejecting.\n";
		} else { 
			$cry = $opd;
		}
	} elsif ($mne =~ /ldm/) {
		#print "Executing opcode: ldm\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\d+$/)) {
			print "ERROR: Invalid operand, $opd.  Rejecting.\n";
		} else { 
			$acc = $opd;
		}
	} elsif ($mne =~ /xch/) {
			#print "Executing opcode: xch\n";
			# Exchange Index and Accumulator registers.  
			($ope,$opd) = split (/\s/,$mne);

			if ($opd =~ /ax/) {
				$tmp = $ax;
				$ax = $acc;
				$acc = $tmp;
			} elsif ($opd =~ /bx/) {
				$tmp = $bx;
				$bx = $acc;
				$acc = $tmp;
			} elsif ($opd =~ /dx/) {
				$tmp = $dx;
				$dx = $acc;
				$acc = $tmp;
			} elsif ($opd =~ /cx/) {
				$tmp = $cx;
				$cx = $acc;
				$acc = $tmp;
			} else { 
				print "ERROR: Invalid operand, $opd .  Rejecting.\n";
			}
	
	} elsif ($mne =~ /ld/) {
		#print "Executing opcode: ld\n";
		($ope,$opd) = split (/\s/,$mne);
		if (!($opd =~ /^\D+$/)) {
			print "ERROR: Invalid operand, $opd .  Rejecting.\n";
		} else { 
			if ($opd =~ /ax/) {
				$acc = $ax;
			} elsif ($opd =~ /bx/) {
				$acc = $bx;
			} elsif ($opd =~ /dx/) {
				$acc = $dx;
			} elsif ($opd =~ /cx/) {
				$acc = $cx;
			} else { 
				print "ERROR: Invalid operand, $opd .  Rejecting.\n";
			}
		}
	} elsif ($mne =~ /nop/) {
		#print "Executing opcode: nop\n";
	}
}