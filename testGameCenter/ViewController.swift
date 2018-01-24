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

//Every command send will be a string with the following properties separated by a comma:
// [SUBMISSIONKEY, INT (ATAPS), INT (BTAPS), GAMELOG]
// SUBMISSION KEYS are to identify what to do with the rest of the data.

let CHECKRAND = "checkRandomNumberKey" //this only comes with 1 int to compare
let TURNEND = "playersTurnHasEnded" //this comes with the score and game log attached
let STARTGAME = "readyToStartGame" //this is to nofity that player 1/2 have been asigned and are ready to start
let ENDGAME = "gameHasEnded" //notify the game ended

class ViewController: UIViewController{
    /*
     TESTING GAMECENTER: THIS GAME WILL CONNECT UP TO 2 PLAYERS. TURN BASED GAME
     EACH TURN ONE PLAYER CAN CLICK BUTTON A OR B AND THEN END HIS TURN
     LOG WILL BE DISPLAYED: PLAYER X CLICKED A 10 TIMES AND B 20 TIMES AND TOOK X SECONDS FOR HIS TURN
     GAME WILL END AFTER EACH PLAYER HAS HAD 2 TURNS
     TEST CONNECTIVITY AND HOW TURN BASED GAMES WORK.
     
     MAIN THINGS TO TEST:
     - GAMEKIT AUTHENTICATION
     - GAMEKIT NETWORK INTERFACE (TURN-BASED GAMES)
     - UPDATING GAMES, ARE THEY SAVED IN GAMEKIT CLOUD OR DO THEY NEED TO BE STORED IN PHONE?
     
 */
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
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
        
        let localPlayer = GKLocalPlayer.localPlayer().alias
        logString += " ** Player \(localPlayer ?? "P1") ended his turn **\n"
        let turnLog = "\(TURNEND),\(aTaps),\(bTaps)"
        let turnData = turnLog.data(using: .utf8)
        sendData(turnLog: turnData!)
        gameLog.text = logString
        
    }
    
    func checkScoreWin(aTaps: Int, bTaps: Int) {
        //check to see if you win
    }
    
    func sendData(turnLog: Data) {
            do {
                if GKLocalPlayer.localPlayer().isAuthenticated {
                    print("Player is Authenticated")
                    if match != nil {
                        print("Match is NOT nil")
                        print("Match expected players: \(match?.expectedPlayerCount ?? -99)")
                        
                    try match?.sendData(toAllPlayers: turnLog, with: GKMatchSendDataMode.reliable)
                    print("DATA SENT!")
                } else {
                    print("MATCH IS NIL")
                }
                }
            } catch {
            print("ERROR: \(error.localizedDescription)")
            }
    }
    
    func receiveData(turnLog: Data, player: GKPlayer) {
        let receivedString = NSString(data: turnLog as Data, encoding: String.Encoding.utf8.rawValue)
        print ("Received: \(receivedString ?? "ERROR ERROR REDRUM REDRUM")")
        parseReceivedData(dataString: receivedString! as String, player: player)
        
    }
    
    func compareRands(random: Int) {
        print("Comparing Randoms:")
        let myInt = arc4random()
        
        print("Received Random is \(random), my random is \(myInt)")
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
    
    func parseReceivedData(dataString: String, player: GKPlayer) {
        //separate the values sent in the string.
        let separatedData = dataString.split(separator: ",")
        let receivedType = String(separatedData[0]) //KEY
        let receivedATaps = Int(separatedData[1]) //ATAPS
        let receivedBTaps = Int(separatedData[2]) //BTAPS
        
        switch receivedType {
        case TURNEND:
            //append to string
            logString += "Player \(player.alias) tapped A \(receivedATaps!) times and B \(receivedBTaps!) times \n"
            checkScoreWin(aTaps: receivedATaps!, bTaps: receivedBTaps!)
            //since the other turn ended, we get to start our turn
            startTurn()
        case CHECKRAND:
            //compare values of your generated rand and the received generated rand
            compareRands(random: receivedATaps!)
        case STARTGAME:
            //all players ready
            print("Start Game")
        case ENDGAME:
            print("OPPONENT ENDED TURN, BEGIN OURS!")
            startTurn()
        default:
            print("UNKNOWN SHIT")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourTurnLabel.isHidden = true
        if match != nil{
            match!.delegate = self
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        matchStart()
        loadPlayers()
    }
    
    func loadPlayers(){
        //get players and add them to the P1: & P2 labels
        let playerArray = match?.players
        print ("The player array count is \(playerArray?.count ?? -99)")
        if playerArray!.count > 0 {
            p1Label.text = GKLocalPlayer.localPlayer().alias
            p2Label.text = playerArray?[0].alias
        }
    }
    
    func matchStart() {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            print("Local Player still authenticated, commencing match")
            aTaps = Int(arc4random())
            let initialTurn = "\(CHECKRAND),\(aTaps),0,0"
            let turnData = initialTurn.data(using: .utf8)
            sendData(turnLog: turnData!)
        }
    }
    
}

extension ViewController: GKMatchDelegate {
    
    // The match received data sent from the player.
    @available(iOS 8.0, *)
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        print ("RECEIVED DATA 8.0")
        receiveData(turnLog: data, player: player)
    }
    
    @available(iOS 9.0, *)
    func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        print("RECEIVED DATA 9.0")
        receiveData(turnLog: data, player: player)
    }
    
    // The player state changed (eg. connected or disconnected)
    @available(iOS 4.1, *)
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
        if match.expectedPlayerCount == 0 {
            print("READY STEADY CAPTAIN!")
            print("Players in Match: \(match.players.count)")
        } else {
            print ("SHIT SON, PLAYERS ARE MISSING!")
            print("Players in Match: \(match.players.count)")
        }
    }
    
    
    // The match was unable to be established with any players due to an error.
    @available(iOS 4.1, *)
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("FAILED")
    }
    
    
    // This method is called when the match is interrupted; if it returns YES, a new invite will be sent to attempt reconnection. This is supported only for 1v1 games
    @available(iOS 8.0, *)
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return true
    }
}

