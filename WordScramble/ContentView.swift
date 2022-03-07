//
//  ContentView.swift
//  WordScramble
//
//  Created by Hari Permadi on 07/03/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        NavigationView{
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                    
                }
                
                Text("Score: \(score)")
                    .font(.headline)
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear {
                startGame()
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart"){
                    withAnimation {
                        usedWords = [String]()
                        startGame()
                    }
                }
            }

        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        // validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "used other possible")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Try again!")
            return
        }
        
        guard isLessThanThree(word: answer) else {
            wordError(title: "Too short", message: "Used longer word!")
            return
        }
        guard isStartWord(word: answer) else {
            wordError(title: "Uh no", message: "Starting word not counted!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += answer.count
        }
        newWord = ""
    }
    
    func startGame(){
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileUrl) {
                let allWords = fileContents.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "awesome"
                return
            }
        }
        fatalError("Error when load start.txt file")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var temp = rootWord
        
        for letter in word {
            if let pos = temp.firstIndex(of: letter) {
                temp.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isLessThanThree(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        return true
    }
    
    func isStartWord(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
