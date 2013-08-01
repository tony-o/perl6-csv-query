#!/usr/bin/env perl6

use Test;
plan 1;

use CSV::Index;

my $q = CSV::Index.new;

my Int @column1 = 0 .. 1;
my Str @column2 = <playerID yearID>;
#playerID,yearID,gameNum,gameID,teamID,lgID,GP,startingPos
my $fh = open 'data/AllstarFull.csv', :r;
say 'indexing';
$q.index( $fh, @column2 );
$fh.close;

say 'finding';
$q.find( Array.new('gomezle01' , '1933') ); 
