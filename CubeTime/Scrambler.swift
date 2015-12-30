//
//  Scrambler.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 12/14/15.
//  Copyright © 2015 Bibek. All rights reserved.
//

import Foundation

// Creates a single notation and names it.
class Step {
    var notation: String
    init (notation: String) {
        self.notation = notation
    }
}

class Algorithm {
    
    // Returns a 2D array of notations which can then be chosen from randomly.
    private func notationList() -> [[Step]] {
        
        // Front face
        let F = Step(notation: "F")
        let Fi = Step(notation: "F'")
        let F2 = Step(notation: "F2")
        let frontArray: [Step] = [F, Fi, F2]
        
        // Back face
        let B = Step(notation: "B")
        let Bi = Step(notation: "B'")
        let B2 = Step(notation: "B2")
        let backArray: [Step] = [B, Bi, B2]
        
        // Left face
        let L = Step(notation: "L")
        let Li = Step(notation: "L'")
        let L2 = Step(notation: "L2")
        let leftArray: [Step] = [L, Li, L2]
        
        // Right face
        let R = Step(notation: "R")
        let Ri = Step(notation: "R'")
        let R2 = Step(notation: "R2")
        let rightArray: [Step] = [R, Ri, R2]
        
        // Up face
        let U = Step(notation: "U")
        let Ui = Step(notation: "U'")
        let U2 = Step(notation: "U2")
        let upArray: [Step] = [U, Ui, U2]
        
        // Down face
        let D = Step(notation: "D")
        let Di = Step(notation: "D'")
        let D2 = Step(notation: "D2")
        let downArray: [Step] = [D, Di, D2]
        
        // Makes 2D array
        let notationArray = [frontArray, backArray, leftArray, rightArray, upArray, downArray]
        return notationArray
    }
    
    // Generates an algorithm of a specified length
    func createAlgorithm(length: Int) -> String {
        
        var previousFace = 0
        var randomFace = Int(arc4random_uniform(6))
        let notations = notationList()
        var algorithm = ""
        
        // Builds algorithm, one notation at a time
        for var i = 0; i < length; i++ {
            
            // Choose random face (UP, DOWN, LEFT, RIGHT, FRONT, BACK)
            while previousFace == randomFace {
                randomFace = Int(arc4random_uniform(6))
            }
            previousFace = randomFace
            
            // Chooses random turn (X, X' X2)
            let randomTurn = Int(arc4random_uniform(3))
            
            // Accesses one notation using random face and turn
            let notation = notations[randomFace][randomTurn]
            
            // Appends single notation to full algorithm.
            if i == 0 {
                algorithm += String(notation.notation)
            } else {
                algorithm += " \(notation.notation)"
            }
        }
        return algorithm
    }
    
}
