#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day22.pl
#
#        USAGE: ./day22.pl  
#
#  DESCRIPTION: Day 22 - RPG as a wizard
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: 1242 is too high
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/21/15 21:12:10
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use Storable qw( dclone );
use List::Util qw( max min );


my @spells = (
    { name => 'Magic Missle', cost => 53,  damage   => 4 },
    { name => 'Drain',        cost => 73,  damage   => 2, heal => 2 },
    { name => 'Shield',       cost => 113, armor    => 7, duration => 6 },
    { name => 'Poison',       cost => 173, damage   => 3, duration => 6 },
    { name => 'Recharge',     cost => 229, duration => 5, mana => 101 },
);
my %spells = map { $_->{name} => $_ } @spells;
my @timers      = map { $_->{name} } grep { exists $_->{duration} } @spells;
my $boss_damage = 9;
my %state       = (
    hp      => 50,
    mana    => 500,
    armor   => 0,
    boss_hp => 51,
    spent   => 0,
    timers  => { map { $_ => 0 } @timers },
    spells  => [ map { $_->{name} } @spells ],
);
my @stack = ( dclone( \%state ) );
my $cheapest_win = 2000000000;              # Approximate infinity.
my $dearest_loss = 0;
my ( $report_count, $report_limit ) = ( 0, 300 );

while ( @stack ) {
    # Work with top of stack, move to state for convenience.
    %state = %{ dclone( $stack[-1] ) };
    report( "Stack depth ", scalar( @stack ) );

    implement_effects();
    if ( players_move() ) {
        implement_effects();

        if ( $state{boss_hp} <= 0 ) {
            report( "Player wins." );
            if ( $state{spent} < $cheapest_win ) {
                $cheapest_win = $state{spent};
                say $state{spent};
            }

        } else {
            # Boss action here.
            $state{hp} -= max( $boss_damage - $state{armor}, 1 );

            if ( $state{hp} <= 0 ) {
                report( "Player loses." );
                $dearest_loss = max( $dearest_loss, $state{spent} );

            } else {
                # Take this path one more step down the tree.
                push @stack, dclone( \%state );
                $stack[-1]{spells} = [ map { $_->{name} } @spells ];
                next;
            }
        }
    }

    # We have hit an end (win, loss, or no more moves), so try again at this
    # level or backtrack if all spells have been tried.
    if ( not @{ $stack[-1]{spells} } ) {
        pop @stack;
    }
}

say $cheapest_win;
say $dearest_loss;
say $report_count;



sub implement_effects {
    for my $timer ( grep { $state{timers}{$_} > 0 } @timers ) {
        $state{timers}{$timer}--;
        given ( $timer ) {
            when ( 'Shield' ) {
                $state{armor} -= $spells{$timer}{armor} if $state{timers}{$timer} == 0;
            }

            when ( 'Poison' ) {
                $state{boss_hp} -= $spells{$timer}{damage};
            }

            when ( 'Recharge' ) {
                $state{mana} += $spells{$timer}{mana};
            }

            default {
                die "Unknown effect $timer\n";
            }
        }
    }
}



sub players_move {
    my $spell = shift @{ $stack[-1]{spells} };

    return undef if not defined $spell;

    exists $spells{$spell} or die "Unknown spell $spell cast.\n";

    return undef if $spells{$spell}{cost} > $state{mana};
    return undef if exists $state{timers}{$spell} and $state{timers}{$spell} != 0;

    $state{mana} -= $spells{$spell}{cost};
    $state{spent} += $spells{$spell}{cost};
    report( "Player casts $spell, $state{spent} spent" );

    given ( $spell ) {
        when ( 'Magic Missle' ) {
            $state{boss_hp} -= $spells{$spell}{damage};
        }

        when ( 'Drain' ) {
            $state{boss_hp} -= $spells{$spell}{damage};
            $state{hp} += $spells{$spell}{heal};
        }

        when ( 'Shield' ) {
            $state{armor} += $spells{$spell}{armor};
            $state{timers}{$spell} = $spells{$spell}{duration};
        }

        when ( 'Poison' ) {
            $state{timers}{$spell} = $spells{$spell}{duration};
        }

        when ( 'Recharge' ) {
            $state{timers}{$spell} = $spells{$spell}{duration};
        }

        default {
            die "Unknown spell $spell cast.\n";
        }
    }

    return 1;
}



sub report {
    $report_count++;
    

=begin  BlockComment  # BlockCommentNo_1

    $report_count <= $report_limit or die "Report limit exceeded\n";

    say @_;

=end    BlockComment  # BlockCommentNo_1

=cut

}



__END__
Hit Points: 51
Damage: 9
