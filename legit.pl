#!/usr/bin/perl -w

use strict;
use File::Compare;

my $index = ".legit/.index";
my $repository = "";
my $command =  $ARGV[0];

shift @ARGV;
sub my_copy{
	my ($from, $to) = @_;
	open my $f, "<", $from or die "legit.pl: error: can not open \'$from\'\n";
	open my $new_f, ">", $to or die "legit.pl: error: can not open \'$to\'\n";
	while (my $line = <$f>){	
		print $new_f $line;
	}
	close $f;
	close $new_f;
}

sub check_file_in_repo{
	my ($repository, @file_list) = @_;
	foreach my $file (@file_list){
		die "legit.pl: error: \'$file\' is not in the legit repository" if (! -e "$repository/$file");
	}
}

sub init{
	die "legit.pl: error: .legit already exists\n" if (-e ".legit");
	mkdir ".legit";
	print "Initialized empty legit repository in .legit\n";
}

sub add{
	mkdir $index if (! -e $index);
	foreach my $file (@ARGV){
		if ( ! -e $file && -e "$index/$file"){
			unlink "$index/$file" ;		
		} else {
			my_copy($file, "$index/$file");
		}
	}
}

sub repo{
	my ($repo) = @_;
	foreach my $path (glob ".legit/.commit.*"){
		$repo = $path;
	}
	return $repo;
}
################################################################################

if ($command eq "init"){
	init;
}

if ($command eq "add"){
	die "legit.pl: error: no .legit directory containing legit repository exists\n" if (! -e ".legit");
	add;
}

if ($command eq "commit"){
	my $commit_number = 0;
	my $COMMITA = 0;
	if ($ARGV[0] eq "-a"){
		shift @ARGV;
		$COMMITA = 1;
	}
	if ($ARGV[0] eq "-m"){
		if ($COMMITA){
			foreach my $file (glob "$index/*"){
				$file =~ /$index\/(.*)/;
				my $from_file = $1;
				if ( ! -e $from_file && -e $file){
					unlink "$file" ;		
				} else {
					my_copy($from_file, $file) if ( compare($file, $from_file) );
				}
			}
		}
		die "empty commit message\n" if (! $ARGV[1]);

		while (-e ".legit/.commit.$commit_number"){
			$commit_number++;
		}
		if ( $commit_number ){
			$repository = repo;
			my $diff = 0;
			foreach my $file (glob "$repository/*"){
				$file =~ /$repository\/(.*)/;
				$file = $1;
				$diff++ if (compare( "$repository/$file", "$index/$file" ));
			}
			foreach my $file (glob "$index/*"){
				$file =~ /$index\/(.*)/;
				$file = $1;
				$diff++ if (compare( "$repository/$file", "$index/$file" ));
			}
			die "nothing to commit\n" if (! $diff);
		}

		$repository=".legit/.commit.$commit_number";
		mkdir $repository;
		foreach my $file (glob "$index/*"){
			$file =~ /$index\/(.+)$/ ;
			my $to_file = $1;
			my_copy($file, "$repository/$to_file");
		}
		print "Committed as commit $commit_number\n";
		open LOG, ">>", ".legit/log.txt" or die "Cannot open log";
		print LOG "$commit_number $ARGV[1]\n";
		close LOG;
	}
}

if ($command eq "log"){
	my @list;
	open LOG, "<", ".legit/log.txt" or die "legit.pl: error: your repository does not have any commits yet";
	while (my $line = <LOG>){
		push @list, $line;
	}
	close LOG;
	print reverse @list;
}

if ($command eq "show"){
	my $show_content = $ARGV[0];
	$show_content =~ /(.*):(.*)/;
	my $show_commit = $1;
	my $show_file = $2;
	if ($show_commit ne ""){
		die "legit.pl: error: unknown commit \'$show_commit\'\n" if (! -e ".legit/.commit.$show_commit");
		open FILE, "<", ".legit/.commit.$show_commit/$show_file" or die "legit.pl: error: \'$show_file\' not found in commit $show_commit\n";
		while (my $line = <FILE>) {
			print $line;
		}
	} else {
		open FILE, "<", "$index/$show_file" or die "legit.pl: error: \'$show_file\' not found in index\n";
		while (my $line = <FILE>) {
			print $line;
		}
	}
}

if ($command eq "rm"){
	my $RM_FORCE = 0;
	my $RM_CACHED = 0;

	if ($ARGV[0] eq "--force"){
		$RM_FORCE = 1;
		shift @ARGV;
	}
	if ($ARGV[0] eq "--cached"){
		$RM_CACHED = 1;
		shift @ARGV;
	}
	$repository = repo;
	foreach my $file (@ARGV){
		next if (! -e "$file");
		die "legit.pl: error: \'$file\' is not in the legit repository\n" if (! -e "$repository/$file" && ! -e "$index/$file") || ( $RM_FORCE && ! -e "$index/$file");
		if ( compare("$repository/$file","$index/$file") && compare($file,"$index/$file") && ! $RM_FORCE ){
			die "legit.pl: error: \'$file\' in index is different to both working file and repository\n";
		}
		if ( compare("$repository/$file","$index/$file") && ! $RM_FORCE && ! $RM_CACHED){
			die "legit.pl: error: \'$file\' has changes staged in the index\n";
		}
		if ( compare("$repository/$file","$file") && ! $RM_FORCE && ! $RM_CACHED){
			die "legit.pl: error: \'$file\' in repository is different to working file\n";
		}
		# check_file_in_repo($repository, $file);
		unlink "$file" if (! $RM_CACHED);
		unlink "$index/$file";
	}
}

if ($command eq "status"){
	my $status = "";
	my %hash_status;
	$repository = repo;
	foreach my $file (glob "*"){
		if ( ! compare("$repository/$file", "$index/$file") && ! compare("$index/$file", $file) ){
			$status = "same as repo" ;
		} elsif ( compare("$repository/$file", "$index/$file") && compare("$index/$file", $file) ){
			$status = "file changed, different changes staged for commit"
		} elsif ( compare("$repository/$file", "$index/$file") ){
			$status = "file changed, changes staged for commit";
		} elsif ( compare("$index/$file", $file) ) {
			$status = "file changed, changes not staged for commit";
		}
		$status = "added to index" if (! -e "$repository/$file" && -e "$index/$file" && ! compare("$index/$file", $file));
		$status = "untracked" if ( -e $file && ! -e "$index/$file" );
		$hash_status{$file} = $status;
	}

	foreach my $file (glob "$repository/*"){
		$file =~ /$repository\/(.*)/;
		$file = $1;

		next if ( $hash_status{$file});
		$status = "file deleted" if ( ! -e $file && (-e "$repository/$file" || -e "$index/$file"));
		$status = "deleted" if ( -e "$repository/$file" && ! -e "$index/$file" && ! -e $file );
		$hash_status{$file} = $status;
	}
	foreach my $file (sort keys %hash_status){
		print "$file - $hash_status{$file}\n";
	}

}