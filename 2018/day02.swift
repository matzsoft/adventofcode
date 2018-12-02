//
//  main.swift
//  day02
//
//  Created by Mark Johnson on 12/1/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
kbqwtcvzgumhpwelrnaxydpfuj
kbqwtcvzgsmhpoelryaxydiqij
kbqwpcvzssmhpoelgnaxydifuj
kbqgtcvxgsmhpoalrnaxydifuj
kbqwtcvygsmhpoelrnaxydiaut
kbqwtcvjgsmhpoelrnawydzfuj
kbqftcvzgsmhpoeprnaxydifus
rbqwtcgzgsxhpoelrnaxydifuj
kbqwtlvzgvmhpoelrnaxkdifuj
kbqwtcvzgsmhpolqrnaxydifub
kbqbtcqzgsmhposlrnaxydifuj
kbqwmcvzgswhpoelxnaxydifuj
kbqwtyvzgsmhkoelrnsxydifuj
khqwtcvzgsmhqoelinaxydifuj
koqwtcvzcsmhpoelrnaxydizuj
kbqwtcvzlsmhpoezrnaxydmfuj
kbqwtcvzdsmhpoelrjaxydifij
kbqwtcvzgsmhpoelrncxyjifuk
kbtwtcvzgsmhpoelonaxydiwuj
kbqwfcrzgsmhpoelrnaeydifuj
kbqutcvkgsmhpoelrnfxydifuj
kbqwtcvzgsmvvoelrnaxydihuj
kbqwtcvzhymhpoelrnaxydifyb
kbqctcvzgumhpoalrnaxydifuj
kuqktcvzgsmhpoelrnaxydieuj
kbqwtcvzgsmvpozlrnaxydifmj
kbqwtcvzgsmhpojlraaxydiouj
kbqwtcvzgmmhpoelknaxydizuj
kbwwtcvzgsmhpoefrnaxydifij
kbqwucvzgsmhpoelvnahydifuj
kbqwtcvzpsmhpgelrqaxydifuj
kblqtcvzgsmhpoeirnaxydifuj
kbqwtcvzgsmhpovlrnabydifum
kbqwwcvzgsmhpoelrnaoydnfuj
kyqwdcvzgsmhpoelrnaxfdifuj
kbqftcvzgsmxpoelknaxydifuj
kbqwtsvzksmhpoelqnaxydifuj
kbqwtcvzgsmhplelrnauydifux
kbqytcvzgsmhpkelrnaxydefuj
kbqwtcvzgsmjjoelrlaxydifuj
kbqvtcvzgsmhpoelnnaxydafuj
kbqwtcvzgsjhioelrnaxpdifuj
kbqptcvpgsmhpoelrnaxydiful
kbqwjcazgimhpoelrnaxydifuj
kbqxtcvzgwmhpaelrnaxydifuj
kbqwtcezgsmhqoelrnaxydifub
kbqwtcvzgsmhooelynaxydifuf
kbqwtwvzgsmkpoelrnaxrdifuj
nbqwtcvugsmhpoelrnzxydifuj
kbvwqcvzgsmhpoelsnaxydifuj
kbqwtcyzjsmhpoelrnaxymifuj
kbqwtcvzgsmhpoclrnaxykzfuj
kbbwtcvzgsmhyodlrnaxydifuj
kbwwtcvzgsmytoelrnaxydifuj
kbmwtcczgpmhpoelrnaxydifuj
ubqwtcvzgsmmpoblrnaxydifuj
kbqwtcvzgrmhpoelrnaxnrifuj
kbqwhcvzgsmhpoelynaaydifuj
kbqwtcvzgsmtpoelrcpxydifuj
kdqwtchzgsmhpoelrmaxydifuj
qbqrncvzgsmhpoelrnaxydifuj
kbqwtcvzghshpoelrnaxodifuj
kbqwhcvzgsmhpoelknaxydiwuj
ebqwtcvzgsmhpoelrotxydifuj
kbqwacvzusmhpoelryaxydifuj
kbqwtcvggsmhpoelrnaxygifyj
kbqwtcvzgsmhpoelrnaxycwfuo
kzqwzcvzgsmhpoelrxaxydifuj
khqwtcvzgsmhpoelrnaxldifyj
kbqwtbtzgsmhpoelrnaxydifud
gbqwtcvzgqmhpoelrnaxydifrj
kbqdtqvzgwmhpoelrnaxydifuj
kbqwscvzgsmhpoelrpaxypifuj
kmqwtcdzgsmhpoelenaxydifuj
klqwtcvvgsmhpoelrfaxydifuj
kbuwtcvzgsmhpoelrtaxyuifuj
kbqwtcvrgomhpoelrnaxydijuj
kbqwtgvzgsmhzoelrnpxydifuj
kbqltcvzgsmhooeljnaxydifuj
kbqwtcvzgbmxpoelrnaxydivuj
kbqdtcmzgsmhpoelrnaxydmfuj
kbqwtcazgsmhpoplrnacydifuj
kbqztcvegsmhpoelrnvxydifuj
kbqwtcvzgsmhpoecrnaxydzfsj
kbqwtcvzgsmepoelrnaqydifuf
kbqwtcqzgsmhpoelrnoxydivuj
kbqwtcvzgsmhpoeylnaxydhfuj
kbqwtcvfgsmhpoelrnaxgdifyj
kbqwtcvzgsmhnbelrnaxyfifuj
kbqwtcvzgsmhpoelrnaxbdffmj
kwqwtcvogtmhpoelrnaxydifuj
kdqwtcvzggyhpoelrnaxydifuj
kbqwtuvzgtmhpoelrnaxydifxj
kbqctdvzcsmhpoelrnaxydifuj
kbqwtcvzgsmhpoblrniyydifuj
kbqwucvzzsmhpoelrnvxydifuj
kbqwtcvzgslzpoelrnaxydiruj
kbqwtdmzgsmhpwelrnaxydifuj
kbqwtcvzgsmhpoilrnaxqiifuj
kbqwtcvzgsmhpgelrnaxydisnj
kbdwtqvzgsmhpoelrnaxydivuj
kbqvtdvzgsmhpoelrjaxydifuj
kfqwtcvzgsmhpoeurnyxydifuj
kbqwtcvzgsmhpoglrnaxqkifuj
kbqwtcvrgsmhpoelrnajydifnj
xbqwpcvzgjmhpoelrnaxydifuj
kbqwtcvzgsmhpoelrdaxvdihuj
kbuwtcvzssmhpoklrnaxydifuj
kbqwtcvzgqmhpoelrnzxydifbj
kbqwtcvzgsmhsoeoknaxydifuj
kfqltcvzgsmhpoelrnaxydifnj
qbqwtsvzgsmhpoelrnaxodifuj
kbqwwevzgsmypoelrnaxydifuj
kbqwtcuzgimhpoelrnaxydffuj
kxqwlcvzgsmhpoelrnaxyrifuj
nbqwtcvzgsmhpoelryaxyiifuj
kbqwtcvzgsmhhoxlreaxydifuj
mbqwtcvzfsmxpoelrnaxydifuj
kbqwttvzgsmhpoeqrnaxidifuj
kbqwtcvzgamhpielrnaxyiifuj
rfqwtcvzgsmhpoelrnaxydifun
kbpwtqvzgsmbpoelrnaxydifuj
kbqwtcvzgsmhpoqlroaxydifua
hbqwtcvzksmhpoelrnaxydbfuj
kaqutcvzgsmhpoelrnaxydiiuj
kbqctcvzgsnhpoelrcaxydifuj
kbqwtnvzgsmhpoelrnaxydqfoj
kbqwtcvzhsmhpoelrnaxydifyb
ubqwtcvcgsmhooelrnaxydifuj
kbqwtcvrgsmhpoelrnaxtdivuj
kbqwtcvzgsmhplelrnmxydifaj
ebqwlcvzghmhpoelrnaxydifuj
hbqwtcvzgsmhpoelrnaqyeifuj
kbqstcvzgsmeprelrnaxydifuj
kbqwtcvogsthpoelrnnxydifuj
ybqwtcvzgdmhpoelrnaxydufuj
kbqutcvzgsmhpoelrnaxydifgx
kbqwtcvzgsmhpozlunadydifuj
kkqwtcvzgsmhpuefrnaxydifuj
kbqrtcvzgsmhpoelrnaxcdifuq
kbqwtcvzjsmupoelrnaxydiluj
kbqwmcvzgsuhpoelrnaxydifhj
kbqwfcvzgsmhpoelrnaxydkzuj
kbqatcvzgsdhpoeyrnaxydifuj
kbtwtcvzusmhpoelrxaxydifuj
kbqwtcwzgsmhpoelrnaxysofuj
kbqqtcvmgsmhpoevrnaxydifuj
kbqwjcvzgsmhpoelrnaxydhuuj
mbdwtcvzgsmhpoelqnaxydifuj
kbqwtcvlgsmhpoelrdaxydifaj
kbqwtcvzgsmmpoelrlaxydnfuj
kbqwtchfggmhpoelrnaxydifuj
kbqqtcvzgsyhpoelrnaxyoifuj
knqwtcvzqsmupoelrnaxydifuj
kdqdtcvzgsmhpoelrnaxydmfuj
kbqwtcvzgsmhptelrnawyhifuj
kbqwtcvzgrmhpoeqrnaxydifuw
kbnxtcvzgsmhpoelrnauydifuj
kbqwacvsgsmhpoelrnaxydifgj
kbqwtcvzgsmhpperrnaxydifuc
gbqwtcvzgsqhxoelrnaxydifuj
kbqwtcvzgsmhpoeljgaxydifwj
kbqktcvzgsmhpotlrnatydifuj
bbqwtcvzgsmhpoilrnaxydjfuj
kbqwecvdgsmhpoelrnaxypifuj
keqwtcvzgemhpotlrnaxydifuj
kbqptcvzgsmvpoelrnaxydixuj
kbqwbctzgsmhpoelrnaxydifup
kbqwtcvzgszhpbelrnzxydifuj
mbqwtcvtgsmhpoeyrnaxydifuj
kbqwtcvzgsmhqcelrhaxydifuj
kbqotcvzgsmhooelrnazydifuj
kbqwtcvzgsmhpoelmpaxyiifuj
kbqwtcvwgsmypoclrnaxydifuj
kbqwtcvsgskhpoelrnaxykifuj
kbqwtcvzgszvpoelrnwxydifuj
kbqwtcvzgsmhpoejonaxydrfuj
kbqwtcvzgsmhkoelrnazyqifuj
kbzwtzvzgsmhptelrnaxydifuj
kbqwtcdzgsmhptelrnaxydiduj
kbqwtcvzgamhpoelrnakyzifuj
kbqwtcvzgsmhpoeonnaxydifxj
kbqwtcvzgsmhpoeranaxydifej
kbqwscvzgsmhpoelunaxydimuj
cbqwtcvzgsmhpoelrdaxydefuj
vbqwtcjzgsmhpoelrnaxydifua
kmqwtcvzksmhpoeljnaxydifuj
kbqwtcvzgsmppojlrnasydifuj
kaqwtcvfgsmhpoelrnaxydiauj
khqwccvzgsmhpoelrnaxydifud
vbqwtcvzrsmhpoelrhaxydifuj
kuqwtcvzgsmhpoelgnaiydifuj
kbqwtcvzdsmhpbelvnaxydifuj
kbowtcvzgnmhpoelrfaxydifuj
kbqwtcvsgsmhfoejrnaxydifuj
kbqwtcvzgskhtoelrnxxydifuj
kbqwtcvzgtmhpoevrnaxydivuj
bbqptcgzgsmhpoelrnaxydifuj
kbqwtpvzgsmnpoelhnaxydifuj
kbqwtovzgsmmpoelrnaxydifuw
kbqwtcvzgsihpwelrnaxydsfuj
kbqwtcvzggmhpollrnaxydifsj
kbqwtcjzgsmhpoelrnaxyxifub
ebqwtcvzgsmzpoelrnaaydifuj
kbqwtcvzusmhpoelrnqxydijuj
obqwtcvzgsghpoelrnaxydifkj
kbrwtcvzmdmhpoelrnaxydifuj
kbqwtcvzxsmhpoblrnhxydifuj
kbqwacvzgsahpoelrnaxydiguj
kyqwtcvzgsmipoelrnlxydifuj
kbbwtcvzgsmhboelpnaxydifuj
kbqwtcvzgsmhpoelrnaxhdosuj
kbqwtgvzgxmhpoelrnaxyrifuj
pbqwtsvzgsmhpoelrnabydifuj
kbqrtcvzgsmhpsblrnaxydifuj
kbqwtcvzgsmhpoexrnaaycifuj
kbqxtcvzgsjhkoelrnaxydifuj
kbqwtcvzgsmhpxelrnaxydifby
lbxwtcvzgsmdpoelrnaxydifuj
kbqwtcczgsmhpoklrnzxydifuj
zbqwtcvzgsmhpoelrbaxydifui
krqwtcvzbsmhpoelrjaxydifuj
kbkwtcvzgsmhpoelrnaxydiacj
kbqwtcvzgszhpseprnaxydifuj
kbxwtcvzxsmhpoesrnaxydifuj
kbqwdcvzgsmhpoelrbaxygifuj
kbqwthkzgsmhhoelrnaxydifuj
klqwtchzgamhpoelrnaxydifuj
obqwtcvzgsvcpoelrnaxydifuj
kblwtcvzgsmhpoelrnanydifuw
kbqwtrvzgsmhpoelynaxydifug
kbqwtcvzgsmhcoelmnaxydkfuj
kbqwtcvzgsmhpotlqoaxydifuj
kaqatcvzgsmhpoelrnaxyiifuj
kbqttcvwgsmhpoelrnaxydifgj
kpqwtcvzgsmhpwelynaxydifuj
kbqwucvzgsmhpyelrnaxyxifuj
kbqwucvzgsmhprelrnaxyfifuj
kbqwthvzgsmhphelrnaxylifuj
kbqwtcvzosmhdoelrnaxwdifuj
kbqwtxvsgsphpoelrnaxydifuj
koqwtcvfghmhpoelrnaxydifuj
kbtwicvzpsmhpoelrnaxydifuj
kbawtcvzgsmhmoelrnaxyiifuj
kbqwtcvzgslhpbelrnaxydifuk
kbqttcvzgsmypoelrnaxydifua
kbqwtcvrgqmhpnelrnaxydifuj
kbqwtcvzghmhpoekpnaxydifuj
kbqwtcvzgsmupoelrnaxidifui
kbqwtcvzgsmhpbelrnaxrdifux
"""
let lines = input.split(separator: "\n")

var twoCount = 0
var threeCount = 0

for line in lines {
    var histo: [ Character : Int ] = [:]
    
    for char in line {
        if histo[char] == nil {
            histo[char] = 1
        } else {
            histo[char]! += 1
        }
    }
    
    twoCount += histo.contains( where: { $0.value == 2 } ) ? 1 : 0
    threeCount += histo.contains( where: { $0.value == 3 } ) ? 1 : 0
}

print( "Part1:", twoCount * threeCount )

for i in 0 ..< lines.count {
    var arrayI = Array( lines[i] )
    
    for j in i ..< lines.count {
        let arrayJ = Array( lines[j] )
        var index: Int? = nil
        
        for k in 0 ..< arrayI.count {
            if arrayI[k] != arrayJ[k] {
                if index == nil {
                    index = k
                } else {
                    index = nil
                    break
                }
            }
        }
        
        if let index = index {
            arrayI.remove(at: index)
            print( "Part2:", String( arrayI ) )
            exit(0)
        }
    }
}
