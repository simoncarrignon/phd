#!/usr/bin/perl
#la premiere ligne la sert a precisé quel langage de script tu utilise, pas importante


my $file = 'Nombre de page.csv';
open my $content,$file or die "impossible d'ouvrir le ficheir";
while(my $line = <$content>){
	if ($line =~ m/\s*\d+\s*-\s*\d+\s*\;\;\;/){ 
		my ($beg)= ($line =~ m/\s*(\d+)\s*-\s*\d+\s*\;\;\;/);
		my ($end)= ($line =~ m/\s*\d+\s*-\s*(\d+)\s*\;\;\;/);
		print $beg,";",$end,";",(1+$end-$beg),"\n";
	}
	else {
		my ($digit)= ($line =~ m/\s*(\d+)\s*\;\;\;/);
		print $digit,";",$digit,";1\n";
	}
		
}
close $content;
