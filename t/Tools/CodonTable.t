use v6;

use lib './lib';

use Test;

#eval_lives_ok 'use Bio::Tools::CodonTable', 'Can use Bio::Tools::CodonTable';

use Bio::PrimarySeq;
use Bio::Type::Sequence;

# create a table object by giving an ID
# my $DEBUG = test_debug();
my $myCodonTable = Bio::Tools::CodonTable.new( id => 16);
ok  $myCodonTable;
is $myCodonTable.id(), 16, '.id';
ok($myCodonTable ~~ Bio::Tools::CodonTable, 'Bio::Tools::CodonTable object');

# defaults to ID 1 "Standard"
$myCodonTable = Bio::Tools::CodonTable.new();
is $myCodonTable.id(), 1, '.id';

# CodonTable is now immutable, can't change attributes
dies-ok { $myCodonTable.id = 10 };

# change codon table
$myCodonTable = Bio::Tools::CodonTable.new( id => 10);
is $myCodonTable.id, 10, 'change .id';
is $myCodonTable.name(), 'Euplotid Nuclear';

# enumerate tables as object method
my %table = $myCodonTable.tables();
is %table.keys.elems, 17; # currently 17 known tables
is %table{11}, qw<"Bacterial">;

# enumerate tables as class method
#todo need to implement as class method in the future
# %table = Bio::Tools::CodonTable.tables;
# is %table.keys.elems, 17; # currently 17 known tables
# is %table{23}, 'Thraustochytrium Mitochondrial';

# translate codons
$myCodonTable = Bio::Tools::CodonTable.new(id => 1);

is $myCodonTable.translate(''), '', 'Empty sequence translate';

my @ii  = <ACT acu ATN gt ytr sar>;
my @res = <T   T   X   V  L   Z  >;
my $test = 1;
for @ii Z @res -> ($dna, $aa) {
    is($myCodonTable.translate($dna), $aa, "$dna: $aa");
}
ok ($test);
is $myCodonTable.translate('ag'), '', 'ag:';
is $myCodonTable.translate('jj'), '', 'jj:';
is $myCodonTable.translate('jjg'), 'X', 'jjg:Z';
is $myCodonTable.translate('gt'), 'V', 'gt:V';
is $myCodonTable.translate('g'), '', 'gt:V';

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
for @ii Z @res -> ($dna,$aa) {
    is($myCodonTable.translate($dna), $aa, "$dna: $aa");
}

## reverse translate amino acids

is $myCodonTable.revtranslate('U'), ();
is $myCodonTable.revtranslate('O'), ();
# NYI
# is $myCodonTable.revtranslate('J'), ('att','atc','ata','tta','ttg','ctt','ctc','cta','ctg');
# is $myCodonTable.revtranslate('I'), ('att','atc','ata');


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
ok $test;

#  boolean tests
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

my @custom_table = 'FFLLSSSSYY**CC*WLLLL**PPHHQQR*RRIIIMT*TT*NKKSSRRV*VVAA*ADDEE*GGG',
      'test1';

#changed inferface from p5 version. Since cannot have require parameter after optional, going to have pass the table first,
#so we can have optional table name and starts

ok my $custct = Bio::Tools::CodonTable.new(table => @custom_table[0],
                                           table-name   => @custom_table[1]);

is $custct.id, 24;
is $myCodonTable.translate('atgaaraayacmacracwacka'), 'MKNTTTT';
is $custct.translate('atgaaraayacmacracwacka'), 'MKXXTTT';

# test doing this via Bio::PrimarySeq object

ok $seq = Bio::PrimarySeq.new(seq=>'atgaaraayacmacracwacka', alphabet=> dna);
is $seq.translate().seq, 'MKNTTTT','Bio::PrimarySeq translate';
is $seq.translate(codonTable => $custct).seq, 'MKXXTTT';

# test gapped translated
ok $seq = Bio::PrimarySeq.new(seq      => 'atg---aar------aay',
			      alphabet => dna);
is $seq.translate.seq, 'M-K--N';

# NYI
# ok $seq = Bio::PrimarySeq.new(seq =>'ASDFGHKL');
# is $myCodonTable.reverse_translate_all($seq), 'GCBWSNGAYTTYGGVCAYAARYTN';
# ok $seq = Bio::PrimarySeq.new(seq => 'ASXFHKL');
# is $myCodonTable.reverse_translate_all($seq), 'GCBWSNNNNTTYCAYAARYTN';

#
# test reverse_translate_best(), requires a Bio::CodonUsage::Table object
#
#	use_ok('Bio::CodonUsage::IO');
#ok $seq = Bio::PrimarySeq.new(seq =>'ACDEFGHIKLMNPQRSTVWY');
#ok my $io = Bio::CodonUsage::IO.new(-file => test_input_file('MmCT'));
#ok my $cut = $io.next_data();
#is $myCodonTable.reverse_translate_best($seq,$cut), 'GCCTGCGACGAGTTCGGCCACATCAAGCTGATGAACCCCCAGCGCTCCACCGTGTGGTAC';

done-testing();
