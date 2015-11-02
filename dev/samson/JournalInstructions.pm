#!/usr/bin/perl -w
package JournalInstructions;
use strict;
use Data::Dumper;
use HTML::TreeBuilder;

#	my $SpringerGetArticlesInstr->{"Article"} = {"Tag"=>"class","Value"=>"journalArticle"};
#	my $SdGetArticlesInstr->{"Article"} = {"Tag"=>"class","Value"=>"resultRow"};
#
#
#
#
#
sub get_instructions {
	my ($Journal) = @_;
	my $Instr={};
	$Instr->{"Jstor"}=jstor_instr();
	$Instr->{"Springer"}=springer_instr();
	$Instr->{"SD"}=sd_instr();
	return $Instr->{$Journal};
}

#### SD ####

sub sd_instr {
	my $Instr={};
	$Instr->{"ArticlesInstr"}={"class"=>"resultRow"};
	$Instr->{"ArticlesInstrType"}="LookDown";
	$Instr->{"Instr"}={
		"pages" => {'LookDown'=> {'_tag' => 'i'}},
		"title" => {'LookDown' => {'style' => 'font-weight : bold ;', '_tag' => 'span'}},
		"authors" => {'OutputFunction' => __PACKAGE__."::get_sd_authors"},
	};
	return $Instr;
}


sub get_sd_authors {
	my ($Input)=@_;
	my $Test=$Input->as_HTML();
	print "$Test\n";
	my ($Out) = ( $Input->as_HTML() =~ m@.*</i><br>(.+)<br>.*@ );
#	my ($Out) = ( $Input->as_HTML() =~ m@.*</a>&nbsp;\((.+)\)</div>.*@ );
	print "$Out\n";
	return $Out;
}

#### SPRINGER #####

sub springer_instr {
	my $Instr={};
	$Instr->{"ArticlesInstr"}={"class" => qr/journalArticle/};
	$Instr->{"ArticlesInstrType"}="LookDown";
	$Instr->{"Instr"}={
		"title" => {},
		"pages" => {"Value"=>"contextTag"},
		"authors" => {'LookDown'=>{'title' => qr/View content where Author is/}},
		"pdf_link" => { 
			"LookDown"=>{"class" => qr/pdf-resource-sprite/},
			'OutputFormat'=>'attr',
			'OutputOption'=>'href'
		}
	};
	return $Instr;
}

##### JSTOR #######

sub jstor_instr {
	my $JstorInstr={};
	$JstorInstr->{"ArticlesInstr"}= "JournalInstructions::get_jstor_articles";
	$JstorInstr->{"ArticlesInstrType"}="Function";
	$JstorInstr->{"Instr"}= {
		'title' => {'LookDown'=> {'class' => 'title', '_tag' => 'a'}},
		'authors' => {'Value'=>'author'},
		'doi' => {'Tag'=>'name','OutputFormat'=>'attr','OutputOption'=>'value'},
		'pdf_link' => {'Value' => "pdflink",'OutputFormat'=>'attr','OutputOption'=>'href' },
		'stable_link' => {'LookDown'=> {"class" => "title", "_tag" => "a"},'OutputFormat'=>'attr','OutputOption'=>'href'},
		'pages' => {'Value'=>'Title','OutputFunction'=>__PACKAGE__.'::get_jstor_pages'},
		'acccess' => {'Value'=>'accessIcon','OutputFunction'=>__PACKAGE__."::get_jstor_access"}
		
	};
	return $JstorInstr;
}

sub get_jstor_pages {
	my ($Input)=@_;
	my ($Out) = ( $Input->as_HTML() =~ m@.*</a>&nbsp;\((.+)\)</div>.*@ );
	return $Out;
}

sub get_jstor_access {
	my ($Input)=@_;
	my $Out;
	my $Access=$Input->attr("title");
	if ( $Access eq "No Access" ) {$Out="No"}
	elsif ( $Access eq "Full Access" ) {$Out="Yes"}
	else { warn("Unknown full text access: $Access"); $Out=$Access }
	return $Out;
}

sub get_jstor_articles {
	my ($tree)=@_;
	my $CiteList=$tree->look_down("class" => "citeList");
	my @articles=$CiteList->look_down("class" => "cite");
	return @articles;
}

1;
