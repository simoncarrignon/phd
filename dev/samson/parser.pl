#!/usr/bin/perl
binmode(STDOUT, ":utf8");
use utf8;

#ce script parcours les fichiers html du site ams téléchargés au préalable et en extrait les noms d'auteurs i tutti quanti
use HTML::Tree;
use HTML::Entities;


#print "\"Label\",\"Type\",\"Année\",\"Auteur\",\"Journal\",\"Pays du Journal\",\"Série\",\"Numéro\",\"pp\",\"Année orginal\",\"Auteur Original\",\"Fichier\"\n";

my $jtype = $ARGV[0];
my $amsurl = "http://www.ams.org/journals/";
foreach my $filename (<$jtype/*>){
	my $p = HTML::Tree->new_from_file($filename);

	my ($volume) = ( $p->as_HTML() =~ m@Volume (.*), Number .*</title>@);
	my ($number) = ( $p->as_HTML() =~ m@Volume .*, Number (.*)</title>@);
	my ($journal) = ( $p->as_HTML() =~ m@<title>(.*) -- Volume .*, Number .*</title>@);


	my @item = $p->look_down(_tag=>'dl');
	foreach my $i (@item){
		my $title="";
		my $review=0;	
		my $article = HTML::Tree->new_from_content($i->as_HTML);
		my $titleA=$article->look_down('class','articleTitleInAbstract');
		my $titleR=$article->look_down('class','bookTitleInAbstract');
		my $type="";
		my $pp="";my $Pauthor="";my $Oauthor="";my $year="";
		if( $titleA) {
			$title=$titleA->as_text;
			$type="Article";
		}
		else{
			$review=1;
			$title=$titleR->as_text;
			$type="Review";
		}
		my $author=$article->look_down('href',qr/^.*$/);
		my @testauthor=$article->look_down('href',qr/^.*authorName.*$/);
		my @allReviewer = "";
		my @allAuthors = "";
		foreach $a (@testauthor){
			my @l=$a->lineage();
			if($l[0]->as_text =~ m/.*Reviewer:.*/){
				@allAuthors = (@allAuthors,$a->as_text);	
			}
			else{

				if($review){ @allReviewer = (@allReviewer,$a->as_text);}
				else{@allAuthors = (@allAuthors,$a->as_text);	}
			}

		}
		($pdf) = ( $article->as_HTML() =~ m@<br />.*<a href="(.*)\.pdf">Full-text PDF</a>@);
		($pdftitle) =  ( $pdf =~ m@(.*)/@);

		$pdftitle=$pdftitle.".pdf";

		$pdfurl=$amsurl.$filename."/".$pdf.".pdf";

		print $pdfurl,"\n";

		if($review){
			($pp) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \(.*\), (.*)<br /><a .*>Review information</a>@);
			($year) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \((.*)\), .*<br /><a .*>Review information</a>@);
		}
		else{
			($pp) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \(.*\), (.*)<br /><a .*>.*Abstract, references.*</a>@);
			($year) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \((.*)\), .*<br /><a .*>.*Abstract, references.*</a>@);

			$Pauthor=$author->as_text;
			if($Pauthor ne "" && $pp eq "" && $Pauthor ne " More Information "){
				($pp) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \(.*\), (.*)<br /><a .*>.*More Information.*</a>@);
				($year) = ( $article->as_HTML() =~ m@.*<strong>.*</strong> \((.*)\), .*<br /><a .*>.*More Information.*</a>@);
				$type="Article CR";
			}
			$Oauthor="";
		}

		if($year ne ""){
			#print "\"",$title,"\",\"",$type,"\",",$year,",\"",join(" and ",@allAuthors[1 .. $#allAuthors]),"\",\"",$journal,"\",\"Etats-Unis\",",$volume,",",$number,",\"",$pp=~s/-/--/r,"\",,\"",join(" and ",@allReviewer[1 .. $#allReviewer]),"\",\"",$pdftitle,"\"","\n";
		}
	}
}

