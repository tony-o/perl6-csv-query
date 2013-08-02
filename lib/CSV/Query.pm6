#!/usr/bin/env perl6
 
use CSV::Parser;

class CSV::Query {
  has %.work = Nil;

  multi method index ( Str $str , @fields ) {
    my $fh = open $str, :r;
    my $r  = $.index( $fh , @fields );
    $fh.close;
  }

  multi method index ( IO::Handle $fh , @fields ) {
    my $headerrow = @fields[0] ~~ 'Str' ?? 0 !! 1;
    my $parser = CSV::Parser.new( file_handle => $fh , contains_header_row => $headerrow );
    return $.index( $parser, @fields );
  }

  multi method index ( CSV::Parser $parser , @fields ) {
    #going to generate a byte map
    %.work = Array.new;
    while $parser.get_line -> %line {
      $.build_tree( %line , @fields , $parser.file_handle.tell );
    }
  }

  method build_tree ( %line , @fields , $fpos ) {
    my @compounder;
    for @fields -> $field {
      die 'Couldn\'t find field to index: ' ~ $field if !defined %line{ $field };
      @compounder.push(%line{ $field });
    }
    my $pos  = 0;
    my $done = 0;
    my $compound;
    my $work = %.work;
    while not $done {
      $compound = '';
      for @compounder -> $data {
        $compound ~= $data.substr($pos, 1) if $data.chars > $pos;
      }
      $done = 1 if $compound eq '';
      next if $compound eq '';
      $work{ $compound } = { children => Hash.new , indices => Array.new } if ! defined $work{ $compound };
      $work{ $compound }<indices>.push($fpos);
      $work = $work{ $compound }<children>;
      $pos++;
    }
  }

  method find ( @values ) {
    my $pos  = 0;
    my $done = 0;
    my $compound;
    my $work = %.work;
    my $cind;
    while not $done {
      $compound = '';
      for @values -> $data {
        $compound ~= $data.substr($pos, 1) if $data.chars > $pos;
      }
      $done = 1 if $compound eq '';
      next if $compound eq '';
      $cind = $work{ $compound }<indices>;
      $done = 1   if ! defined $work{ $compound };
      $work = Nil if ! defined $work{ $compound };
      $cind = Nil if ! defined $work{ $compound };
      $work = $work{ $compound }<children> if defined $work{ $compound };
      $pos++;
    }
    say $work.perl;
    say $cind.perl;
  }
};
