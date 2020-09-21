//
//  Game.swift
//  PNReplay
//
//  Created by PJ Gray on 5/25/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation
import CryptoSwift

public class Game: NSObject {

    var debugHandAction: Bool = false
    var showErrors: Bool = false
    
    public var hands: [Hand] = []
    var currentHand: Hand?

    var dealerId: String?

    public init(rows: [[String:String]]) {
        super.init()

        if self.isSupportedLog(at: rows.reversed().first?["at"]) {
            for row in rows.reversed() {
                self.parseLine(msg: row["entry"], at: row["at"], order: row["order"])
            }
        } else {
            print("Unsupported log format: the PokerNow.club file format has changed since this log was generated")
        }
    }
        
    private func isSupportedLog(at: String?) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: at ?? "") ?? Date()
        let oldestSupportedLog = Date(timeIntervalSince1970: 1594731595)
        
        return date > oldestSupportedLog
    }
    
    private func parseLine(msg: String?, at: String?, order: String? ) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: at ?? "")
        
        if msg?.starts(with: "-- starting hand ") ?? false {

            let startingHandComponents = msg?.components(separatedBy: " (dealer: \"")
            let unparsedDealer = startingHandComponents?.last?.replacingOccurrences(of: "\") --", with: "")
            
            // for legacy logs
            var dealerSeparator = " @ "
            if unparsedDealer?.contains(" # ") ?? false {
                dealerSeparator = " # "
            }

            if msg?.contains("dead button") ?? false {
                let hand = Hand()

                let handIdHex = String("deadbutton-\(date?.timeIntervalSince1970 ?? 0)".md5().bytes.toHexString().prefix(15))
                var hexInt: UInt64 = 0
                let scanner = Scanner(string: handIdHex)
                scanner.scanHexInt64(&hexInt)
                hand.id = hexInt
                
                hand.date = date
                hand.dealer = nil
                self.currentHand = hand
                self.hands.append(hand)
            } else {
                let dealerNameIdArray = unparsedDealer?.components(separatedBy: dealerSeparator)
                
                let hand = Hand()
                self.dealerId = dealerNameIdArray?.last
                let handIdHex = String("\(self.dealerId ?? "error")-\(date?.timeIntervalSince1970 ?? 0)".md5().bytes.toHexString().prefix(15))
                var hexInt: UInt64 = 0
                let scanner = Scanner(string: handIdHex)
                scanner.scanHexInt64(&hexInt)
                hand.id = hexInt
                
                hand.date = date
                self.currentHand = hand
                self.hands.append(hand)
            }
        } else if msg?.starts(with: "-- ending hand ") ?? false {
            if debugHandAction {
                print("----")
            }
        } else if msg?.starts(with: "Player stacks") ?? false {
            let playersWithStacks = msg?.replacingOccurrences(of: "Player stacks: ", with: "").components(separatedBy: " | ")
            
            var players : [Player] = []
            
            for playerWithStack in playersWithStacks ?? [] {
                let seatNumber = playerWithStack.components(separatedBy: " ").first
                let playerWithStackNoSeat = playerWithStack.replacingOccurrences(of: "\(seatNumber ?? "") ", with: "")
                let seatNumberInt = (Int(seatNumber?.replacingOccurrences(of: "#", with: "") ?? "0") ?? 0)
                
                let nameIdArray = playerWithStackNoSeat.components(separatedBy: "\" ").first?.replacingOccurrences(of: "\"", with: "").components(separatedBy: " @ ")
                let stackSize = playerWithStack.components(separatedBy: "\" (").last?.replacingOccurrences(of: ")", with: "")
                
                let player = Player(admin: false, id: nameIdArray?.last, stack: Double(stackSize ?? "0") ?? 0, name: nameIdArray?.first)
                players.append(player)
                
                self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false, number: seatNumberInt))
            }
                        
            self.currentHand?.players = players
            if let dealer = players.filter({$0.id == self.dealerId}).first {
                self.currentHand?.dealer = dealer
            }
        } else if msg?.starts(with: "Your hand is ") ?? false {
            self.currentHand?.hole = msg?.replacingOccurrences(of: "Your hand is ", with: "").components(separatedBy: ", ").map({
                return EmojiCard(rawValue: $0)?.emojiFlip ?? .error
            })

            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - hole cards: \(self.currentHand?.hole?.map({$0.rawValue}) ?? [])")
            }
        } else if msg?.starts(with: "flop") ?? false {
            let line = msg?.slice(from: "[", to: "]")
            self.currentHand?.flop = line?.replacingOccurrences(of: "flop: ", with: "").components(separatedBy: ", ").map({
                return EmojiCard(rawValue: $0)?.emojiFlip ?? .error
            })
            
            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - flop: \(self.currentHand?.flop?.map({$0.rawValue}) ?? [])")
            }

        } else if msg?.starts(with: "turn") ?? false {
            let line = msg?.slice(from: "[", to: "]")
            self.currentHand?.turn = EmojiCard(rawValue: line?.replacingOccurrences(of: "turn: ", with: "") ?? "error")?.emojiFlip ?? .error

            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - turn: \(self.currentHand?.turn?.rawValue ?? "?")")
            }

        } else if msg?.starts(with: "river") ?? false {
            let line = msg?.slice(from: "[", to: "]")
            self.currentHand?.river = EmojiCard(rawValue: line?.replacingOccurrences(of: "river: ", with: "") ?? "error")?.emojiFlip ?? .error

            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - river: \(self.currentHand?.river?.rawValue ?? "?")")
            }

        } else {
            let nameIdArray = msg?.components(separatedBy: "\" ").first?.components(separatedBy: " @ ")
            if let player = self.currentHand?.players.filter({$0.id == nameIdArray?.last}).first {
                
                if msg?.contains("big blind") ?? false {
                    let bigBlindSize = Double(msg?.components(separatedBy: "big blind of ").last ?? "0") ?? 0
                    self.currentHand?.bigBlindSize = bigBlindSize
                    self.currentHand?.bigBlind.append(player)

                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") posts big \(bigBlindSize)  (Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                if msg?.contains("small blind") ?? false {
                    let smallBlindSize = Double(msg?.components(separatedBy: "small blind of ").last ?? "0") ?? 0
                    self.currentHand?.smallBlindSize = smallBlindSize
                    if msg?.contains("missing") ?? false {
                        self.currentHand?.missingSmallBlinds.append(player)
                    } else {
                        self.currentHand?.smallBlind = player
                    }
                    
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") posts small \(smallBlindSize)  (Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }
            }
        }
        self.currentHand?.lines.append(msg ?? "unknown line")
    }
        
}
