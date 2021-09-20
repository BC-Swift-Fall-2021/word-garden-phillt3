//
//  ViewController.swift
//  WordGarden
//
//  Created by Phillip  Tracy on 9/11/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var wordGuessedLabel: UILabel!
    @IBOutlet weak var wordsMissedLabel: UILabel!
    @IBOutlet weak var wordsRemainingLabel: UILabel!
    @IBOutlet weak var wordsInGameLabel: UILabel!
    @IBOutlet weak var wordBeingRevealedLabel: UILabel!
    @IBOutlet weak var guessedLetterTextField: UITextField!
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusMessageLabel: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    var wordsToGuess = ["SWIFT","DOG","CAT"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongGuessesRemaining = 8
    var wordsGuessedCount = 0
    var wordsMissedCount = 0
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = guessedLetterTextField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
    }
    
    func updateUIAfterGuess(){
        guessedLetterTextField.resignFirstResponder()
        guessedLetterTextField.text = ""
        guessLetterButton.isEnabled = false
    }
    
    func formatRevealWord(){
        var revealedWord = ""
        for letter in wordToGuess{
            if lettersGuessed.contains(letter){
                revealedWord = revealedWord + "\(letter) "
                print(revealedWord)
            } else {
                revealedWord = revealedWord + "_ "
            }
        }
        revealedWord.removeLast()
        wordBeingRevealedLabel.text = revealedWord
    }
    
    func updateWinOrLose() {
        currentWordIndex += 1
        guessedLetterTextField.isEnabled = false
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = false
    }
    
    func updateStatusLabels(){
        wordGuessedLabel.text = "Words Guessed: \(wordsGuessedCount)"
        wordsMissedLabel.text = "Words Guessed: \(wordsMissedCount)"
        wordsRemainingLabel.text = "Words Guessed: \(wordsToGuess.count - (wordsGuessedCount + wordsMissedCount))"
        wordsInGameLabel.text = "Words Guessed: \(wordsToGuess.count)"
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed: String){
        if wordToGuess.contains(currentLetterGuessed) == false {
            wrongGuessesRemaining = wrongGuessesRemaining - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                UIView.transition(with: self.flowerImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.flowerImageView.image = UIImage(named: "wilt\(self.wrongGuessesRemaining)")}){ (_) in
                    
                    if self.wrongGuessesRemaining != 0{
                        self.flowerImageView.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")
                    } else {
                        self.playSound(name: "word-not-guessed")
                        UIView.transition(with: self.flowerImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.flowerImageView.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")}, completion: nil)
                    }
                }
                self.playSound(name: "incorrect")
            }
            
            
        } else {
            playSound(name: "correct")
        }
    }
    
    func guessALetter(){
        let currentLetterGuessed = guessedLetterTextField.text ?? ""
        lettersGuessed = lettersGuessed + currentLetterGuessed
        formatRevealWord()
        
        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)
        
        guessCount += 1
        //        var guesses = "Guesses"
        ////        if guessCount == 1{
        ////            guesses = "Guess"
        ////        }
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessageLabel.text = "You've made \(guessCount) \(guesses)."
        
        if wordBeingRevealedLabel.text!.contains("_") == false {
            gameStatusMessageLabel.text = "You have guessed it! It took you \(guessCount) tries!"
            wordsGuessedCount += 1
            playSound(name: "word-guessed")
            updateWinOrLose()
        } else if wrongGuessesRemaining == 0{
            gameStatusMessageLabel.text = "So sorry, all out of guesses!"
            wordsMissedCount += 1
            updateWinOrLose()
        }
        if currentWordIndex == wordsToGuess.count{
            gameStatusMessageLabel.text! += "\n\n You've tried all the words, start from the beginning?"
            
        }
    }
    
    func playSound(name: String){
        if let sound = NSDataAsset(name: name) {
            do {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            } catch {
                print("Error \(error.localizedDescription)")
            }
        } else {
            print("Could not read data file for sound")
        }
    }
    
    @IBAction func guessedLetterFieldChanged(_ sender: UITextField) {
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        updateUIAfterGuess()
        print("Done Key Pressed")
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        updateUIAfterGuess()
        print("guessLetterButtonPressed")
    }
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        if currentWordIndex == wordToGuess.count {
            currentWordIndex = 0
            wordsGuessedCount = 0
            wordsMissedCount = 0
        }
        
        playAgainButton.isHidden = true
        guessedLetterTextField.isEnabled = true
        guessLetterButton.isEnabled = false
        wordToGuess = wordsToGuess[currentWordIndex]
        wrongGuessesRemaining = maxNumberOfWrongGuesses
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        guessCount = 0
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        lettersGuessed = ""
        updateStatusLabels()
        gameStatusMessageLabel.text = "You've made zero guesses."
    }
    
}

