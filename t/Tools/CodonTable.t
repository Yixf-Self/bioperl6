use v6;

BEGIN {
    @*INC.push('./lib');
}

use Test;
plan 56;
eval_lives_ok 'use Bio::Tools::CodonTable', 'Can use Bio::Tools::CodonTable';

use Bio::Tools::CodonTable; 


# create a table object by giving an ID
# my $DEBUG = test_debug();
my $myCodonTable = Bio::Tools::CodonTable.new( id => 16);
ok  $myCodonTable;
ok($myCodonTable ~~ Bio::Tools::CodonTable, 'Bio::Tools::CodonTable object');

# defaults to ID 1 "Standard"
$myCodonTable = Bio::Tools::CodonTable.new();
is $myCodonTable.id(), 1;

# change codon table
$myCodonTable.id =10;
is $myCodonTable.id, 10;
is $myCodonTable.name(), 'Euplotid Nuclear';

# enumerate tables as object method
#my $table = $myCodonTable.tables();
# cmp_ok (keys %{$table}, '>=', 17); # currently 17 known tables
# is $table.{11}, q{"Bacterial"};

# # enumerate tables as class method
# $table = Bio::Tools::CodonTable.tables;
# cmp_ok (values %{$table}, '>=', 17); # currently 17 known tables
# is $table.{23}, 'Thraustochytrium Mitochondrial';

# translate codons
$myCodonTable.id =1;

# eval {
#     $myCodonTable.translate();
# };
# ok ($@ =~ /EX/) ;

is $myCodonTable.translate(''), '';

my @ii  = <ACT acu ATN gt ytr sar>;
my @res = <T   T   X   V  L   Z  >;
my $test = 1;
for @ii Z @res -> $dna,$aa {
     if $aa ne $myCodonTable.translate($dna)  {
	$test = 0; 
#	print @ii[$i], ": |", @res[$i], "| ne |", $myCodonTable.translate(@ii[$i]), "|\n" if( $DEBUG);
	last ;
     }
}
ok ($test);
is $myCodonTable.translate('ag'), '';
is $myCodonTable.translate('jj'), '';
is $myCodonTable.translate('jjg'), 'X';
is $myCodonTable.translate('gt'), 'V'; 
is $myCodonTable.translate('g'), '';

# a more comprehensive test on ambiguous codes
my $seq = "
atgaaraayacmacracwackacyacsacvachacdacbacxagragyatmatwatyathcarcayc
cmccrccwcckccyccsccvcchccdccbccxcgmcgrcgwcgkcgycgscgvcghcgdcgbcgxctmctrct
wctkctyctsctvcthctdctbctxgargaygcmgcrgcwgckgcygcsgcvgchgcdgcbgcxggmggrggw
ggkggyggsggvgghggdggbggxgtmgtrgtwgtkgtygtsgtvgthgtdgtbgtxtartaytcmtcrtcwt
cktcytcstcvtchtcdtcbtcxtgyttrttytramgamggmgrracratrayytaytgytrsaasagsartaa";

$seq ~~ s:g/\s+//;
#so can have syntax highlighting and tabbing in emacs ::g
    
@ii = $seq.comb(/. ** 3/);

#print join (' ', @ii), "\n" if( $DEBUG);
my $prot = "
MKNTTTTTTTTTTTRSIIIIQHPPPPPPPPPPPRRRRRRRRRRRLLLLLLLLLLLEDAAAAAAAAAAAGGG
GGGGGGGGVVVVVVVVVVV*YSSSSSSSSSSSCLF*RRRBBBLLLZZZ*";


$prot ~~ s:g/\s//;
#so can have syntax highlighting and tabbing in emacs ::g
    
@res = $prot.comb();

# print join (' ', @res), "\n" if( $DEBUG );
$test = 1;
# for my $i (0..$#ii) {
for @ii Z @res -> $dna,$aa {
    if $aa ne $myCodonTable.translate($dna) {
	$test = 0; 
# 	print $ii[$i], ": |", $res[$i], "| ne |", 
# 	  $myCodonTable.translate($ii[$i]),  "| @ $i\n" if( $DEBUG);
	last ;
    }
}
ok $test;

# reverse translate amino acids 

is $myCodonTable.revtranslate('U'), 0;
is $myCodonTable.revtranslate('O'), 0;
is $myCodonTable.revtranslate('J'), 9;
is $myCodonTable.revtranslate('I'), 3;

@ii = <A l ACN Thr sER ter Glx>;
@res = (
	[<gct gcc gca gcg>],
	[<ggc gga ggg act acc aca acg>],
	[<tct tcc tca tcg agt agc>],
	[<act acc aca acg>],
	[<tct tcc tca tcg agt agc>],
	[<taa tag tga>],
	[<gaa gag caa cag>]
	);

$test = 1;
#TESTING: {
for 0..@ii.end() -> $i {
 	 my @codonres = $myCodonTable.revtranslate(@ii[$i]);
         for 0..@codonres.end() -> $j {
	     if (@codonres[$j] ne @res[$i][$j]) {
		 $test = 0;
# 		 print $ii[$i], ': ', $codonres[$j], " ne ", 
# 		 $res[$i][$j], "\n" if( $DEBUG);
 		 last;
 	     }
 	 }
      }
#}
ok $test;

#  boolean tests
$myCodonTable.id =1;

ok $myCodonTable.is_start_codon('ATG');  
is $myCodonTable.is_start_codon('GGH'), 0;
ok $myCodonTable.is_start_codon('HTG');
is $myCodonTable.is_start_codon('CCC'), 0;

ok $myCodonTable.is_ter_codon('UAG');
ok $myCodonTable.is_ter_codon('TaG');
ok $myCodonTable.is_ter_codon('TaR');
ok $myCodonTable.is_ter_codon('tRa');
is $myCodonTable.is_ter_codon('ttA'), 0;

ok $myCodonTable.is_unknown_codon('jAG');
ok $myCodonTable.is_unknown_codon('jg');
is $myCodonTable.is_unknown_codon('UAG'), 0;

is $myCodonTable.translate_strict('ATG'), 'M';



#
# adding a custom codon table
#

my @custom_table =
    ( 'test1',
      'FFLLSSSSYY**CC*WLLLL**PPHHQQR*RRIIIMT*TT*NKKSSRRV*VVAA*ADDEE*GGG'
    );

ok my $custct = $myCodonTable.add_table(@custom_table);
is $custct, 24;
is $myCodonTable.translate('atgaaraayacmacracwacka'), 'MKNTTTT';
ok ($myCodonTable.id= $custct);
is $myCodonTable.translate('atgaaraayacmacracwacka'), 'MKXXTTT';

# test doing this via Bio::PrimarySeq object

use Bio::PrimarySeq;
ok $seq = Bio::PrimarySeq.new(seq=>'atgaaraayacmacracwacka', alphabet=>'dna');
is $seq.translate().seq, 'MKNTTTT';
is $seq.translate(Any, Any, Any, Any, Any, Any, $myCodonTable).seq, 'MKXXTTT';

# test gapped translated

ok $seq = Bio::PrimarySeq.new(seq      => 'atg---aar------aay',
			                   alphabet => 'dna');
is $seq.translate.seq, 'M-K--N';

ok $seq = Bio::PrimarySeq.new(seq =>'ASDFGHKL');
is $myCodonTable.reverse_translate_all($seq), 'GCBWSNGAYTTYGGVCAYAARYTN';
ok $seq = Bio::PrimarySeq.new(seq => 'ASXFHKL');
is $myCodonTable.reverse_translate_all($seq), 'GCBWSNNNNTTYCAYAARYTN';

#
# test reverse_translate_best(), requires a Bio::CodonUsage::Table object
# 
#	use_ok('Bio::CodonUsage::IO');
#ok $seq = Bio::PrimarySeq.new(seq =>'ACDEFGHIKLMNPQRSTVWY');
#ok my $io = Bio::CodonUsage::IO.new(-file => test_input_file('MmCT'));
#ok my $cut = $io.next_data();
#is $myCodonTable.reverse_translate_best($seq,$cut), 'GCCTGCGACGAGTTCGGCCACATCAAGCTGATGAACCCCCAGCGCTCCACCGTGTGGTAC';

done();