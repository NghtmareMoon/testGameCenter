//
//  ViewController.swift
//  testGameCenter
//
//  Created by David Boydston on 1/12/18.
//  Copyright © 2018 Boydston. All rights reserved.
//

import UIKit
import GameKit
import MultipeerConnectivity

class ViewController: UIViewController{
    /*
     TESTING GAMECENTER: THIS GAME WILL CONNECT UP TO 4 PLAYERS. TURN BASED GAME
     EACH TURN ONE PLAYER CAN CLICK BUTTON A OR B AND THEN END HIS TURN
     LOG WILL BE DISPLAYED: PLAYER X CLICKED A 10 TIMES AND B 20 TIMES AND TOOK X SECONDS FOR HIS TURN
     GAME WILL END AFTER EACH PLAYER HAS HAD 2 TURNS
     TEST CONNECTIVITY AND HOW TURN BASED GAMES WORK.
     
     MAIN THINGS TO TEST:
     - GAMEKIT AUTHENTICATION
     - GAMEKIT NETWORK INTERFACE (TURN-BASED GAMES)
     - UPDATING GAMES, ARE THEY SAVED IN GAMEKIT CLOUD OR DO THEY NEED TO BE STORED IN PHONE?
     
 */
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var yourTurnLabel: UILabel!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var gameLog: UITextView!
    @IBOutlet weak var endGameBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    var match: GKMatch?
    var aTaps: Int = 0
    var bTaps: Int = 0
    var logString: String = ""
    
    @IBAction func endGameTapped(_ sender: Any) {
        if GKLocalPlayer.localPlayer().isAuthenticated
        {
            //report a highscore
            let scoreReporter = GKScore.init(leaderboardIdentifier: "testLB")
            scoreReporter.value = Int64(aTaps)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: nil)
            
            print("HighScore Reported")
        } else {
            print("ERROR REPORTING HIGHSCORE")
        }
    }
    
    @IBAction func aTapped(_ sender: Any) {
        aTaps += 1
    }
    
    @IBAction func bTapped(_ sender: Any) {
        bTaps += 1
    }
    
    @IBAction func endTapped(_ sender: Any) {
        let localPlayer = GKLocalPlayer.localPlayer().alias
        logString += "Player \(localPlayer ?? "P1") tapped A \(aTaps) times and B \(bTaps) times \n"
        gameLog.text = logString
        endTurn()
    }
    
    
    func startTurn()
    {
        let localPlayer = GKLocalPlayer.localPlayer().alias
        aTaps = 0
        bTaps = 0
        logString += "** Player \(localPlayer ?? "P1") begun his turn **\n"
        gameLog.text = logString
        yourTurnLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.yourTurnLabel.isHidden = true})
        
    }
    
    func endTurn() {
        //notify gamecenter
        // send data of progress or something?
        let localPlayer = GKLocalPlayer.localPlayer().alias
        let localPlayerID = GKLocalPlayer.localPlayer().playerID
        logString += " ** Player \(localPlayer ?? "P1") ended his turn **\n"
        let turnLog = "turnLog,\(localPlayerID ?? "ERROR: NO ID"),\(aTaps),\(bTaps), \(logString)"
        let turnData = turnLog.data(using: .utf8)
        sendData(turnLog: turnData!)
        gameLog.text = logString
        
    }
    
    func sendData(turnLog: Data) {
            do {
                try match?.sendData(toAllPlayers: turnLog, with: GKMatchSendDataMode.reliable)
                print("DATA SENT!")
            } catch {
            print("ERROR: \(error.localizedDescription)")
            }
    }
    
    func receiveData(turnLog: Data) {
        let receivedString = NSString(data: turnLog as Data, encoding: String.Encoding.utf8.rawValue)
        parseReceivedData(dataString: receivedString! as String)
        
    }
    
    func compareRands(random: Int) {
        let myInt = arc4random()
        if (myInt > random) {
            print("WE ARE PLAYER 1")
            startTurn()
        } else if (myInt == random) {
            print("EQUALS. RETRY")
            matchStart()
        } else {
            print("WE ARE PLAYER 2")
        }
    }
    
    func parseReceivedData(dataString: String) {
        //separate the values sent in the string.
        let separatedData = dataString.split(separator: ",")
        let receivedType = separatedData[0]
        let receivedPlayer = separatedData[1]
        let receivedATaps = Int(separatedData[2])
        let receivedBTaps = Int(separatedData[3])
        let receivedLog = separatedData[4]
        
        switch receivedType {
        case "turnLog":
            //append to string
            logString = String(receivedLog)
        case "initRand":
            //compare values of your generated rand and the received generated rand
            compareRands(random: receivedATaps!)
        case "startG":
            print("Start Game")
        case "endTurn":
            print("OPPONENT ENDED TURN, BEGIN OURS!")
            startTurn()
        default:
            print("UNKNOWN SHIT")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourTurnLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        matchStart()
    }
    
    func matchStart() {
        let localPlayerID = GKLocalPlayer.localPlayer().playerID
        let initialTurn = "initRand,\(localPlayerID ?? "ERROR: NO ID"),\(aTaps),0,0"
        let turnData = initialTurn.data(using: .utf8)
        print("Sending String: \(initialTurn)")
        sendData(turnLog: turnData!)
    }
    
}

extension ViewController: GKMatchDelegate {
    
    // The match received data sent from the player.
    @available(iOS 8.0, *)
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        print ("RECEIVED DATA 8.0")
        print ("Received \(data) from \(player)")
        receiveData(turnLog: data)
    }
    
    @available(iOS 9.0, *)
    public func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        print("RECEIVED DATA 9.0")
        print ("Received \(data) for \(recipient) from \(player)")
    }
    
    // The player state changed (eg. connected or disconnected)
    @available(iOS 4.1, *)
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        print("CHANGED STATE")
    }
    
    
    // The match was unable to be established with any players due to an error.
    @available(iOS 4.1, *)
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("FAILED")
    }
    
    
    // This method is called when the match is interrupted; if it returns YES, a new invite will be sent to attempt reconnection. This is supported only for 1v1 games
    @available(iOS 8.0, *)
    public func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return true
    }
    
}

