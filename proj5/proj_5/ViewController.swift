//
//  ViewController.swift
//  proj_5
//
//  Created by dh on 9/23/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {
    var allWords = [String]()
    dynamic var usedWords = [String]()
    var wordToPickIndex = 0
    var scoreButton: UIBarButtonItem!
    
    func configureView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        scoreButton = UIBarButtonItem(title: "current score: \(usedWords.count)", style: .plain, target: self, action: nil)
        
        toolbarItems = [scoreButton]
        navigationController?.isToolbarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        guard let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") else {
            loadDefaultWords()
            return
        }
        
        if let startWords = try? String(contentsOfFile: startWordsPath) {
            allWords = startWords.components(separatedBy: "\n")
        } else {
            loadDefaultWords()
        }
        
        startGame()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    // MARK: - gameplay
    func startGame() {
        if wordToPickIndex == 0 {
            allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        } else {
            wordToPickIndex += 1
        }
        
        title = allWords[wordToPickIndex]
        usedWords.removeAll(keepingCapacity: true)
        
        addObserver(self, forKeyPath: #keyPath(usedWords), options: .new, context: nil)
        
        tableView.reloadData()
    }
    
    func loadDefaultWords() {
        allWords = ["silkworm"]
    }
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in
            let answer = ac.textFields!.first!
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        var error: AnagramError?
        
        guard isPossible(word: answer) else {
            error = .notPossible(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
            showErrorMessage(type: error!)
            return
        }
        
        guard isOriginal(word: answer) else {
            error = .notPossible(title: "Word used already", message: "be more original!")
            showErrorMessage(type: error!)
            return
        }
        
        guard isReal(word: answer) else {
            error = .notPossible(title: "Word not recognised", message: "You can't just make them up, you know!")
            showErrorMessage(type: error!)
            return
        }
    
        usedWords.insert(answer.lowercased(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
    }
    
    func showErrorMessage(type: AnagramError) {
        var title: String
        var message: String
        
        switch type {
            case .notOriginal(let t, let m):
                title = t
                message = m
            case .notPossible(let t, let m):
                title = t
                message = m
            case .notReal(let t, let m):
                title = t
                message = m
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "usedWords" {
            scoreButton.title = "current score: \(usedWords.count)"
        }
    }
    // MARK: - validation of words
    
    
    /// this is where our custom game logic goes
    ///
    /// - parameter word: user submitted answer
    ///
    /// - returns: true if passes all the tests
    func isPossible(word: String) -> Bool {
        guard word.characters.count > 2 else {
            return false
        }
        
        guard word != title!.lowercased() else {
            return false
        }
        
        
        var tempWord = title!.lowercased()
        for c in word.characters {
            if let pos = tempWord.range(of: String(c)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // TODO: dragon ball
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
}

enum AnagramError  {
    case notPossible(title: String, message: String)
    case notOriginal(title: String, message: String)
    case notReal(title: String, message: String)
}

