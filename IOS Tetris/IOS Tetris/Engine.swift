//
//  Engine.swift
//  IOS Tetris
//
//  Created by RMS on 24.10.2017.
//  Copyright © 2017 RMS. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 500

protocol EngineFunctions{

    func gameEnd(engine: Engine)
    
    func gameBegin(engine: Engine)
    
    func gameShapeLand(engine: Engine)
    
    func gameShapeMove(engine: Engine)

    func gameShapeDrop(engine: Engine)

    func gameNextLevel(engine: Engine)
}

class Engine{
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:EngineFunctions?
    
    var score = 0
    var level = 1
    
    init(){
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns:NumColumns, rows: NumRows)
    }
    
    func startGame(){
        if (nextShape == nil){
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameBegin(engine: self)
    }
    
    func newShape()->(fallingShape:Shape?, nextShape:Shape?){
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn,row: StartingRow)
        guard detectIllegalPlacement() == false else {
        nextShape = fallingShape
        nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
        endGame()
        return (nil, nil)
    }
        return (fallingShape, nextShape)
    }
    func detectIllegalPlacement() -> Bool {
            guard let shape = fallingShape else {
                return false
            }
            for block in shape.blocks {
                if block.column < 0 || block.column >= NumColumns
                    || block.row < 0 || block.row >= NumRows {
                    return true
                } else if blockArray[block.column, block.row] != nil {
                    return true
                }
            }
            return false
        }
    
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeLand(engine: self)
    }
    
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameEnd(engine: self)
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            // #11
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // #12
        if removedLines.count == 0 {
            return ([], [])
        }
        // #13
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameNextLevel(engine:self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            // #14
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDrop(engine: self)
    }
    
    
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                rotateShape()
            }
        } else {
            delegate?.gameShapeMove(engine: self)
            if detectTouch() {
                rotateShape()
            }
        }
    }
    
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.clockwiseRotation()
        guard detectIllegalPlacement() == false else {
            shape.counterClockwiseRotation()
            return
        }
        delegate?.gameShapeMove(engine: self)
    }
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeMove(engine: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeMove(engine: self)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}
