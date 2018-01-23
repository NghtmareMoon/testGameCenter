//
//  HomeVC.swift
//  testGameCenter
//
//  Created by David Boydston on 1/13/18.
//  Copyright © 2018 Boydston. All rights reserved.
//

import UIKit
import GameKit

class HomeVC: UIViewController {
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var leaderBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var xtraBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func leaderTapped(_ sender: Any) {
        //connect to game center and check leaderboard
        //let currentVC = self.view.window?.rootViewController
        let GameCenterVC = GKGameCenterViewController()
        GameCenterVC.gameCenterDelegate = self
        //currentVC?.present(GameCenterVC, animated: true, completion: nil)
        
        self.present(GameCenterVC, animated: true, completion: nil)
    }
    
    @IBAction func challengeTapped(_ sender: Any) {
        //challenge a specific player to a game
    }
    
    @IBAction func xtraTapped(_ sender: Any) {
        findMatch()
    }
    
    
    @IBAction func staratTapped(_ sender: Any) {
        let request = GKMatchRequest()
        request.maxPlayers = 2
        request.minPlayers = 2
        request.inviteMessage = "Play it or suck it!"
        request.playerGroup = 1
        
        let mmvc = GKMatchmakerViewController(matchRequest: request)
        mmvc?.matchmakerDelegate = self
        present(mmvc!, animated: true, completion: nil)
    }
    
    func findMatch() {
            performSegue(withIdentifier: "startGameSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // login the player to Game Center and authenticate
        authenticatePlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToGame(match: GKMatch) {
        let gameScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "mainGame") as! ViewController
        gameScreenVC.providesPresentationContextTransitionStyle = true
        gameScreenVC.definesPresentationContext = true
        gameScreenVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        gameScreenVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        gameScreenVC.match = match
        self.present(gameScreenVC, animated: true, completion: nil)
    }
}

extension HomeVC: GKGameCenterControllerDelegate
{
    
    func authenticatePlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {
            (view, error) in
            if view != nil
            {
                self.present(view!, animated: true, completion: nil)
            } else {
                print("AUTHENTICATED!")
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

extension HomeVC: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
       print("match was cancelled")
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("didFailwithError: \(error.localizedDescription)")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("Match found")
        if match.expectedPlayerCount == 0 {
            viewController.dismiss(animated: true, completion: {self.goToGame(match: match)})
        }
    }
}

