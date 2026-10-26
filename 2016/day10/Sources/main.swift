//
//         FILE: main.swift
//  DESCRIPTION: day10 - Balance Bots
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/28/21 21:37:24
//

import Foundation
import Library

struct Rule {
    enum DestinationType: String { case bot, output }
    
    let lowType: DestinationType
    let lowID: Int
    let highType: DestinationType
    let highID: Int
}

class Bot {
    let ID: Int
    var chips: [Int] = []
    var rules: [Rule] = []
    
    init( ID: Int ) {
        self.ID = ID
    }
}


func parse( input: AOCinput ) -> [ Int : Bot ] {
    var bots: [ Int : Bot ] = [:]

    for line in input.lines {
        let words = line.split(separator: " ")
        
        switch words[0] {
        case "value":
            let value = Int( words[1] )!
            let bot = Int( words[5] )!
            
            if bots[bot] == nil {
                bots[bot] = Bot( ID: bot )
            }
            bots[bot]!.chips.append( value )

        case "bot":
            let bot = Int( words[1] )!
            let lowType = Rule.DestinationType( rawValue: String( words[5] ) )!
            let lowID = Int( words[6] )!
            let highType = Rule.DestinationType( rawValue: String( words[10] ) )!
            let highID = Int( words[11] )!
            let rule = Rule( lowType: lowType, lowID: lowID, highType: highType, highID: highID )

            if bots[bot] == nil {
                bots[bot] = Bot(ID: bot)
            }
            bots[bot]!.rules.append( rule )

        default:
            print( "Invalid input \(words[0])" )
        }
    }

    return bots
}


func applyRules( bots: [ Int : Bot ], part: AOCPart ) -> Int {
    var bins: [ Int : [Int] ] = [:]
    var queue: [Bot] = bots.values.filter( { $0.chips.count == 2} )

    while queue.count > 0 {
        let bot = queue.removeFirst()
        let rule = bot.rules.first!
        let low = bot.chips.min()!
        let high = bot.chips.max()!
        
        switch rule.lowType {
        case .bot:
            if let lowBot = bots[rule.lowID] {
                lowBot.chips.append( low )
                if lowBot.chips.count == 2 { queue.append( lowBot ) }
            }
        case .output:
            if bins[rule.lowID] == nil {
                bins[rule.lowID] = [low]
            } else {
                bins[rule.lowID]!.append(low)
            }
        }
        
        switch rule.highType {
        case .bot:
            if let highBot = bots[rule.highID] {
                highBot.chips.append( high )
                if highBot.chips.count == 2 { queue.append( highBot ) }
            }
        case .output:
            if bins[rule.highID] == nil {
                bins[rule.highID] = [high]
            } else {
                bins[rule.highID]!.append(high)
            }
        }
        
        if part == AOCPart.part1 && low == 17 && high == 61 { return bot.ID }
        bot.chips = []
    }

    return bins[0]![0] * bins[1]![0] * bins[2]![0]
}


func part1( input: AOCinput ) -> String {
    let bots = parse( input: input )
    return "\(applyRules( bots: bots, part: .part1 ))"
}


func part2( input: AOCinput ) -> String {
    let bots = parse( input: input )
    return "\(applyRules( bots: bots, part: .part2 ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
