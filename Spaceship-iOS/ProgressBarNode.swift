//
//  ProgressBarNode.swift
//  Spaceship
//

/*  Imports SpriteKit frameworks  */
import SpriteKit

/* Create the class ProgressBarNode as a subclass of SKNode */
class ProgressBarNode: SKNode {
  /* This array stores the pieces of the progress bar */
  private var pieces: [SKShapeNode]!
  /* This variable stores the size of the progress bar */
 // var size: CGSize!

  
  /* Object Initialization */
 override init() {
    super.init()
  /* Adds the pieces */
    addPieces()
  
    /* Calculates the size of the progress bar */
   // self.size = self.calculateAccumulatedFrame().size
  }
  
private func addPieces() {
    /* Initializes pieces array */
    pieces = [SKShapeNode]()
 
   /* The width and height of the piece */
    let width: CGFloat = 20.0
    let height: CGFloat = 24.0
  
  /* The space between two pieces */
  let space: CGFloat = 1.0
  
    /* Creates ten pieces */
    for index in 0 ..< 10 {
      /* Calculates the position of the piece */
      let xPos = (width + space) * CGFloat(index)
      let yPos: CGFloat = 0

      /* Initializes the piece (Draws a rectangle) */
      let piece = SKShapeNode(rectOf: CGSize(width: width, height: height))
      /* Fill Color: Red */
      piece.fillColor = SKColor.red
      /* Stroke Color: Dark Red */
      piece.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
      /*  Piece's position*/
      piece.position = CGPoint(x: xPos, y: yPos)
      /* Add piece on the node */
      addChild(piece)
      
      /* Insert piece in the array */
      pieces.append(piece)
    }
  }
  
  /* Removes all the pieces of the progress bar */
  func empty() {
    self.removeAllChildren()
    /* Initializes shapes' array */
    pieces = [SKShapeNode]()
  }
  
  
  /* Sets the progress bar at full */
  func full() {
    empty()
    addPieces()
  }
  
  /* Removes one piece from the progress bar */
  func decrease() -> Int{
      /* Removes the last piece from the progress bar */
      if let piece = pieces.last {
        piece.removeFromParent()
       /* Removes the last element from the array */
        pieces.removeLast()
      }
   
    /* Return the rest pieces */
     return pieces.count
  }
  
  
  
/* Required initializer - Not used */
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
