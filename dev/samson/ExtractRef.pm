#!/usr/bin/perl -w
package ExtractRef;
use strict;
use Data::Dumper;
use HTML::TreeBuilder;
use JournalInstructions;

sub test {
	my ($file,$Journal) = @_;
	my $Warn="Warn:$file";
	my $Instr=JournalInstructions::get_instructions($Journal);

	my $ArticlesInstr=$Instr->{"ArticlesInstr"};
	my $ArticlesInstrType=$Instr->{"ArticlesInstrType"};
	my $GetInstr=$Instr->{"Instr"};
	if (! ($ArticlesInstr && $ArticlesInstrType && $GetInstr) ) { warn("$Warn:Not enough instruction to get the data !"); next}
	
	my @ARTICLES=get_articles($file,$ArticlesInstr,$ArticlesInstrType);
	if (! @ARTICLES){warn("$Warn:No articles found !"); next}
	foreach my $ARTICLE (@ARTICLES) {
#		my $OUT=$ARTICLE->look_down(_tag=>"a",class=>"title");
#		print $OUT->as_trimmed_text()."\n";
	
#		my $ArtInfo=get_article_info($ARTICLE,$JstorInstr,$Warn);
		my $ArtInfo=get_article_info($ARTICLE,$GetInstr,$Warn);
		print Dumper($ArtInfo);
	}
}

sub get_article_info {
	## Instruction hash format: 
	#
	# $Instr = {
	#	'LookDown' => {},
	#	'Tag' => {},
	#	'Value' => {},
	#	'OutputFormat' => {},
	#	'OutputOption' => {}
	#	}

	my ($Article,$ToDo,$Warn) = @_;
	my $Output = {};
	if (! $Article ) {exit("$Warn:No article: can't proceed !")}
	if (! %$ToDo){exit("$Warn:No instructions: can't proceed !")}
	foreach my $Item ( keys(%$ToDo) ) {
		my (@Elements,$OutputFormat,$OutputOption,$OutValue);
		# If a LookDown value is defined, it is used as direct query to grep the element. 
		# LookDown is a hash containing the look_down instructions
		if ( $ToDo->{$Item}{"LookDown"} ) {
			my $LookDown=$ToDo->{$Item}{"LookDown"};
			@Elements = $Article->look_down(%$LookDown) 
		}
		# If no lookdown specified: look for "Tag" and "Value" tags, and use it as look_down instruction
		elsif ( (! %{$ToDo->{$Item}} ) || ($ToDo->{$Item}{"Value"}) || ($ToDo->{$Item}{"Tag"}) ) {
			my ($Tag,$Value);
			# Get "Value" info. If no "Value" is given, use the $Item name instead
			if ( $ToDo->{$Item}{"Value"} ) {$Value = $ToDo->{$Item}{"Value"}}
			else { $Value=$Item }
			# Get "Tag" info. Default value will be "class"
			if ( $ToDo->{$Item}{"Tag"} ) { $Tag=$ToDo->{$Item}{"Tag"} }
			else { $Tag="class" }
			# Get element
			@Elements = $Article->look_down($Tag => $Value);
		}
#		if ( ! @Elements ) { warn("No element found for this item: $Item"); next }
		elsif ( $ToDo->{$Item}{"OutputFunction"} ) { @Elements=$Article }
		else { warn("$Warn:No clue to get this item: $Item"); next}
		# If no item found, go to next iteration
		if ( ! @Elements ) {warn("$Warn:No HTML element found for this item: $Item"); next}
		# Which method from HTML::Element class use to display output ? 
		# 
		my @OutValue=();
		my $n=0;
		foreach my $Element (@Elements) 
		{
			# Si un nom de fonction est donnée dans OutputFunction, elle est utilisée sur l'élément extrait pour récupérer la donnée voulue.
			# Cette fonction doit prendre un seul argument (l'élément à traiter, au format HTML) et renvoyer la valeur recherchée.
			if ( $ToDo->{$Item}{"OutputFunction"} ) {
				my $Function=$ToDo->{$Item}{"OutputFunction"};
				{no strict "refs";
				$OutValue[$n]=&$Function($Element);
				}
			}
			else {
				# Default: "as_trimmed_text"
				if ( $ToDo->{$Item}{"OutputFormat"} ){ $OutputFormat= $ToDo->{$Item}{"OutputFormat"} }
				else {  $OutputFormat='as_trimmed_text'}
				# Get Value (if OutputOption is specified, it is used as argument to the OutputFormat fonction used.)
				if ( $ToDo->{$Item}{"OutputOption"} ){ 
					$OutputOption= $ToDo->{$Item}{"OutputOption"};
					$OutValue[$n]=$Element->$OutputFormat($OutputOption)
				}
				else { $OutValue[$n]=$Element->$OutputFormat() }
			}
			# Vérifie qu'une valeur a bien été trouvée
			if ($OutValue[$n]) {$Output->{$Item}->[$n] = $OutValue[$n] }
			else { warn("$Warn:No value found for this item: $Item")}
			$n++;
		}
	}
	return $Output;
}

sub get_articles {
	my ($file,$Instr,$InstrType) = (@_) ;
	my @ARTICLES;
	my $Tree = HTML::TreeBuilder->new_from_file($file);
	# If Instruction is a look_down instruction
	if ( $InstrType eq "LookDown") {
		@ARTICLES = $Tree->look_down(%$Instr);
	}
	# If instruction is a function to get the articles. The function takes a HTML::Element tree as input, and gives a list articles as output
	elsif ( $InstrType eq "Function") {
		no strict "refs";
		@ARTICLES = &$Instr($Tree)
	}
	else { warn("Invalid instruction type: $InstrType. Possible values: \"LookDown\" and \"Function\"."); exit 68}
	return @ARTICLES;
}

#sub get_articles_old {
#	my ($file,$ToDo) = (@_) ;
#	my $Tree = HTML::TreeBuilder->new_from_file($file);
#	my $ArticlesPart;
#
#	if ( $ToDo->{"ArticlesPart"} ) 
#	{ 
#		my $ArticlesPartTag=$ToDo->{"ArticlesPart"}{"Tag"};
#		my $ArticlesPartValue=$ToDo->{"ArticlesPart"}{"Value"};
#		$ArticlesPart = $Tree->look_down($ArticlesPartTag => qr/$ArticlesPartValue/);
#	}
#	else { $ArticlesPart=$Tree }
#
#
#	if (! $ToDo->{"Article"} ) { warn("No clue for Articles isolation in input data !"); exit 68}
#	my $ArticleTag=$ToDo->{"Article"}{"Tag"};
#	my $ArticleValue=$ToDo->{"Article"}{"Value"};
#
#	my @ARTICLES = $ArticlesPart->look_down($ArticleTag => qr/$ArticleValue/);
#	return @ARTICLES;
#}
1;
