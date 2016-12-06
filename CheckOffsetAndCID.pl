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

my ($switches, $files) = @ARGV;

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

my %foundprop;

foreach my $bdf (@files){
	my $changes = 0;
	open(IPT, "<", $bdf) or die;
	while(<IPT>){
		if(m/^CQUAD4\*/ or m/^CTRIA3\*/){
			#skip long field,hoping for at least one short field
		elsif(m/^CQUAD4/ or m/^CTRIA3/){
			my @fields = unpack('(A8)*',$_);
			$fields[2] =~ m/(\d+)/;
			my $prop = $1;
			#get offset and CID
			unless($foundprop{$prop}){
				if(m/^CQUAD4/){
					my $string;
					if($fields[7] =~ m/(\S+)/){
						$string = $1;
					}
					if($fields[8] =~ m/(\S+)/){
						$string = $string.$1;
					}
                	$foundprop{$prop} = $string;
				else{
					my $string;
					if($fields[6] =~ m/(\S+)/){
						$string = $1;
					}
					if($fields[7] =~ m/(\S+)/){
						$string = $string.$1;
					}
                	$foundprop{$prop} = $string;
				}
			}
		}
	}
	close(IPT);
}

#check property pairs
my $optc = safelyOpen("Confirmed_".$switches);
my $optp = safelyOpen("NotConfirmed_".$switches);
my @props = keys(%change);
foreach my $key (@props){
	if($foundprop{$key} eq $foundprop{$change{$key}}){
		print $optc $key."\t".$change{$key}."\n";
	}
	else{
		print $optc $key."\t".$change{$key}."\n";
	}
}
