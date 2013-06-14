//
//  PuzzleController.h
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "PuzzlePieceView.h"
#include "PuzzleModel.h"


@interface PuzzleController : NSObject <PuzzlePieceDragDelegateProtocol>


//the view to add game elements to
@property (weak, nonatomic) UIView* puzzleView;

//the current puzzle
@property (strong, nonatomic) PuzzleModel* puzzleModel;

//the current puzzle pieces
@property (nonatomic, strong) NSMutableArray *puzzlePieces;


// open new puzzle
-(void) openPuzzleNum: (int) num;


@end
