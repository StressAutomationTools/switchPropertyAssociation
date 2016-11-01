use warnings;
use strict;

sub safelyOpen{
	#prevents files from getting overwritten by checking first if a file with the 
	#same name already exists. If it does, a warning will be printed and the 
	#program will exit.
	my $file = $_[0];
	if(-e $file){
		print $file." already exists.\n";
		print "To protect the file from being overwritten, the program will now exit.\n";
		exit;
	}
	elsif(not $file){
		print "No filename was provided.\n";
		print "As no file could be created, the program will now exit\n";
		exit;
	}
	else{
		open(my $filehandle, ">", $file) or print "File could not be opened.\n" and die;
		return $filehandle;
	}
}

my ($switches, $files, $name_mod) = @ARGV;

unless($name_mod){
    print "No file name modifier was defined, program exiting.\n";
    die;
}

my @files;
if($files eq "bdfs"){
    @files = <*.bdf>;
}
elsif($files eq "dats"){
    @files = <*.dat>;
}
else{
    open(IPT, "<", $files) or die "Could not find file list\n";
    while(<IPT>){
        my $line = $_;
        chomp($line);
        unless($line eq ''){
            push(@files, $line);
        }
    }
    close(IPT);
}
open(IPT, "<", $switches) or die "Could not find file containing changes\n";
my %change;
while(<IPT>){
    if(m/(\d+)\t(\d+)/){
        $change{$1} = $2;
    }
}

close(IPT);

foreach my $bdf (@files){
	my $changes = 0;
	open(IPT, "<", $bdf) or die;
	my $opt = safelyOpen($name_mod.$bdf);
	while(<IPT>){
                if(m/^CQUAD4\*/ or m/^CTRIA3\*/){
			my @fields = unpack('(A8)(A16)*',$_);
			$fields[2] =~ m/(\d+)/;
			my $prop = $1;
			if($change{$prop}){
                            $fields[2] = $change{$prop};
                            $changes = 1;
                            my $line = pack('(A8)',shift(@fields));
                            foreach my $field (@fields){
                                $line = $line.pack('(A16)',$field);
                            }
                            print $opt $line."\n";
			}
			else{
                            print $opt $_;
                        }
                }
		elsif(m/^CQUAD4/ or m/^CTRIA3/){
			my @fields = unpack('(A8)*',$_);
			$fields[2] =~ m/(\d+)/;
			my $prop = $1;
			if($change{$prop}){
                            $fields[2] = $change{$prop};
                            $changes = 1;
                            my $line = "";
                            foreach my $field (@fields){
                                $line = $line.pack('(A8)',$field);
                            }
                            print $opt $line."\n";
			}
			else{
                            print $opt $_;
                        }
		}
		else{
                    print $opt $_;
		}
	}
	close(IPT);
	close($opt);
	unless($changes){
            unlink $name_mod.$bdf;
	}
}
