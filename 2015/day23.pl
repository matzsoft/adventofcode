#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day23.pl
#
#        USAGE: ./day23.pl  
#
#  DESCRIPTION: Day 23 - A really crappy computer for a present.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/23/15 08:57:28
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use Math::BigInt;


my $pc = 0;
my %registers = ( a => Math::BigInt->new( 0 ), b => Math::BigInt->new( 0 ) );
my @memory;
my %opcodes = (
    hlf => { register => 1 },
    tpl => { register => 1 },
    inc => { register => 1 },
    jmp => { offset => 1 },
    jie => { register => 1, offset => 1 },
    jio => { register => 1, offset => 1 },
);


########################################
# VSA - Very Stupid Assembler
########################################

while ( <DATA> ) {
    chomp;
    s/,//g;

    my ( $opcode, $operand1, $operand2 ) = split;

    exists $opcodes{$opcode} or die "$opcode invalid opcode on line $.\n";

    if ( exists $opcodes{$opcode}{register} ) {
        if ( exists $opcodes{$opcode}{offset} ) {
            push @memory, { opcode => $opcode, register => $operand1, offset => $operand2 };
        } else {
            push @memory, { opcode => $opcode, register => $operand1 };
        }

    } elsif ( exists $opcodes{$opcode}{offset} ) {
        push @memory, { opcode => $opcode, offset => $operand1 };

    } else {
        die "Bad opcode table for $opcode\n";
    }
}


########################################
# Now produce the answers
########################################

vmi( 0, 0, 0 );
vmi( 0, 1, 0 );


#######################################
# VMI - Very Moronic Interpreter
########################################

sub vmi {
    $pc = shift;
    $registers{a} = Math::BigInt->new( shift );
    $registers{b} = Math::BigInt->new( shift );

    while ( 0 <= $pc and $pc < @memory ) {
        my $opcode   = $memory[$pc]{opcode};
        my $register = $memory[$pc]{register};
        my $offset   = $memory[$pc]{offset};

        given ( $opcode ) {
            when ( 'hlf' ) {
                $registers{$register}->bdiv( 2 );
            }

            when ( 'tpl' ) {
                $registers{$register}->bmul( 3 );
            }

            when ( 'inc' ) {
                $registers{$register}->badd( 1 );
            }

            when ( 'jmp' ) {
                $pc += $offset - 1;
            }

            when ( 'jie' ) {
                if ( $registers{$register}->is_even ) {
                    $pc += $offset - 1;
                }
            }

            when ( 'jio' ) {
                if ( $registers{$register}->is_one ) {
                    $pc += $offset - 1;
                }
            }

            default {
                die "$opcode - invald opcode at address $pc\n";
            }
        }

        $pc++;
    }

    say "PC = $pc, a = $registers{a}, b = $registers{b}";
}



__END__
jio a, +22
inc a
tpl a
tpl a
tpl a
inc a
tpl a
inc a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
jmp +19
tpl a
tpl a
tpl a
tpl a
inc a
inc a
tpl a
inc a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
inc a
tpl a
tpl a
jio a, +8
inc b
jie a, +4
tpl a
inc a
jmp +2
hlf a
jmp -7
