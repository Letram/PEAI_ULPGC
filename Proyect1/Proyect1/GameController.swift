//
//  ViewController.swift
//  Proyect1
//
//  Created by Alumno on 13/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class GameController: UIViewController {

    
    @IBOutlet weak var p1ScoreLabel: UILabel!
    @IBOutlet weak var p2ScoreLabel: UILabel!
    @IBOutlet weak var accScoreLabel: UILabel!
    @IBOutlet weak var currentPlayerLabel: UILabel!
    @IBOutlet weak var collectBtn: UIButton!
    @IBOutlet weak var progressBar1: UIProgressView!
    @IBOutlet weak var progressBar2: UIProgressView!
    @IBOutlet weak var dice: UIImageView!
    
    var currentPlayer = 1
    var accScore = 0
    var scores = [0.0,0.0]
    var rollsNumber = 0
    var duration = 1
    
    let goal = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameSetup()
    }

    @IBAction func onRollBtn(_ sender: UIButton) {
        dice.startAnimating()
        Timer.scheduledTimer(timeInterval: TimeInterval(duration), target: self, selector: #selector(self.stop), userInfo: nil, repeats: false)
    }
    
    @objc func stop(){
        self.dice.stopAnimating()
        let roll = arc4random_uniform(6) + 1
        self.dice.image = UIImage(named: roll.description)
        self.accScore = (roll == 1) ? 0 : self.accScore + Int(roll)
        if(self.accScore == 0 || self.accScore + Int(self.scores[self.currentPlayer-1]) >= Int(self.goal)){
            self.collect()
        } else {
            if(!self.collectBtn.isEnabled){
                self.collectBtn.isEnabled = true
            }
            self.updateTexts()
        }
    }
    @IBAction func onCollectBtn(_ sender: UIButton) {
        collect()
    }
    func collect(){
        scores[currentPlayer-1] = (Double(accScore) + scores[currentPlayer-1] >= goal) ? goal : Double(accScore) + scores[currentPlayer-1]
        if(scores[currentPlayer-1] == goal){
            gameEnded(currentPlayer: currentPlayer)
        }
        changeCurrentPlayer()
    }
    func gameEnded(currentPlayer: Int) -> Void {
        let alert = UIAlertController(title: "End of game", message: "Winner is P\(currentPlayer)!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) {_ in
            self.reset()
        })
        //TODO perform segue when clicking on "Cancel"
        alert.addAction(UIAlertAction(title: "Exit", style: .cancel){_ in
            self.reset()
            self.performSegue(withIdentifier: "unwindToInstructions", sender: self)
        })
        present(alert, animated: true)
    }
    func changeCurrentPlayer(){
        currentPlayer = currentPlayer == 1 ? 2 : 1
        resetCounters()
        updateTexts()
        let alert = UIAlertController(title: "End of turn", message: "Next player is: P\(currentPlayer)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateTexts(){
        currentPlayerLabel.text = "P" + currentPlayer.description
        accScoreLabel.text = accScore.description
        
        p1ScoreLabel.text = Int(scores[0]).description
        progressBar1.setProgress(Float(scores[0]/goal), animated: true)
        
        p2ScoreLabel.text = Int(scores[1]).description
        progressBar2.setProgress(Float(scores[1]/goal), animated: true)
    }
    func resetCounters(){
        accScore = 0
        collectBtn.isEnabled = false
    }
    func gameSetup(){
        loadImages()
        collectBtn?.isEnabled = false
        progressBar1?.setProgress(Float(scores[0]), animated: false)
        progressBar2?.setProgress(Float(scores[1]), animated: false)
    }
    
    func loadImages(){
        var faces : [UIImage] = []
        for image in 1...6 {
            faces.insert(UIImage(named: image.description)!, at: image - 1)
        }
        self.dice?.animationImages = faces
        self.dice?.animationDuration = 0.5
        self.dice?.image = self.dice.animationImages![Int(arc4random() % 6)]
    }
    func reset(){
        accScore = 0
        scores = [0.0,0.0]
        updateTexts()
    }
    
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        coder.encode(scores[0], forKey: "SCORES_0")
        coder.encode(scores[1], forKey: "SCORES_1")
        coder.encode(accScore, forKey: "ACCSCORE")
        coder.encode(currentPlayer, forKey: "CURRENT_PLAYER")
        coder.encode(duration, forKey:"ANIMATION_DURATION")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        scores[0] = coder.decodeDouble(forKey: "SCORES_0")
        scores[1] = coder.decodeDouble(forKey: "SCORES_1")
        accScore = coder.decodeInteger(forKey: "ACCSCORE")
        currentPlayer = coder.decodeInteger(forKey: "CURRENT_PLAYER")
        duration = coder.decodeInteger(forKey: "ANIMATION_DURATION")
        
        updateTexts()
    }
}

