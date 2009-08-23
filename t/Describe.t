use v6;

use Test;
use Bio::Role::Describe;

plan 6;

class Desc does Bio::Role::Describe {  };

my $s = Desc.new(display_name => <ABCD1234>,
                 description => 'Hello, my name is Mr. Ed');

is($s.display_name, 'ABCD1234');
is($s.description, 'Hello, my name is Mr. Ed');

$s.display_name = 'WXYZ4567';
$s.description = 'Goodbye, Mr. Bond';

is($s.display_name, 'WXYZ4567');

# testing aliases out
is($s.description, 'Goodbye, Mr. Bond');
is($s.desc, 'Goodbye, Mr. Bond');
$s.desc     = 'Frankly, my dear...';
is($s.description, 'Frankly, my dear...');

