#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day19.pl
#
#        USAGE: ./day19.pl  
#
#  DESCRIPTION: Day 19 - Red Nose Reindeer medicine
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/18/15 23:49:16
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;


my ( @elements, %replacements, %molecules );
my ( @reverse, %reverse );

while ( <DATA> ) {
    chomp;
    last if m/^\s*$/;

    my ( $element, $replacement ) = split / => /;

    push @elements, $element if not exists $replacements{$element};
    push @{ $replacements{$element} }, $replacement;

    push @reverse, $replacement if not exists $reverse{$replacement};
    $reverse{$replacement} = $element;
}

my $molecule = <DATA>;

chomp $molecule;

for my $element ( @elements ) {
    my @replacements = @{ $replacements{$element} };
    my @split = split /$element/, $molecule, -1;

    while ( @split > 1 ) {
        for my $replacement ( @replacements ) {
            my $new = "$split[0]$replacement$split[1]";

            $new .= $element . join $element, @split[ 2 .. $#split] if @split > 2;

            $molecules{$new}++;
        }
        splice @split, 0, 2, "$split[0]$element$split[1]";
    }
}

say scalar keys %molecules;

my $count = 0;
my $string = $molecule;

$count++ while $string =~ s/(.*)(@{[ join "|", @reverse ]})/$1$reverse{$2}/;
say $count;



__END__
Al => ThF
Al => ThRnFAr
B => BCa
B => TiB
B => TiRnFAr
Ca => CaCa
Ca => PB
Ca => PRnFAr
Ca => SiRnFYFAr
Ca => SiRnMgAr
Ca => SiTh
F => CaF
F => PMg
F => SiAl
H => CRnAlAr
H => CRnFYFYFAr
H => CRnFYMgAr
H => CRnMgYFAr
H => HCa
H => NRnFYFAr
H => NRnMgAr
H => NTh
H => OB
H => ORnFAr
Mg => BF
Mg => TiMg
N => CRnFAr
N => HSi
O => CRnFYFAr
O => CRnMgAr
O => HP
O => NRnFAr
O => OTi
P => CaP
P => PTi
P => SiRnFAr
Si => CaSi
Th => ThCa
Ti => BP
Ti => TiTi
e => HF
e => NAl
e => OMg

ORnPBPMgArCaCaCaSiThCaCaSiThCaCaPBSiRnFArRnFArCaCaSiThCaCaSiThCaCaCaCaCaCaSiRnFYFArSiRnMgArCaSiRnPTiTiBFYPBFArSiRnCaSiRnTiRnFArSiAlArPTiBPTiRnCaSiAlArCaPTiTiBPMgYFArPTiRnFArSiRnCaCaFArRnCaFArCaSiRnSiRnMgArFYCaSiRnMgArCaCaSiThPRnFArPBCaSiRnMgArCaCaSiThCaSiRnTiMgArFArSiThSiThCaCaSiRnMgArCaCaSiRnFArTiBPTiRnCaSiAlArCaPTiRnFArPBPBCaCaSiThCaPBSiThPRnFArSiThCaSiThCaSiThCaPTiBSiRnFYFArCaCaPRnFArPBCaCaPBSiRnTiRnFArCaPRnFArSiRnCaCaCaSiThCaRnCaFArYCaSiRnFArBCaCaCaSiThFArPBFArCaSiRnFArRnCaCaCaFArSiRnFArTiRnPMgArF
