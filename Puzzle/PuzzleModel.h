//
//  PuzzleModel.h
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PuzzleModel : NSObject
{
    int pieces[5][6];
    int components[5][6];
    int adjacent[5][5];    
    int piecesInSelectedComponent[5];
    int imageWidth;

}

@property int puzzleNum;
@property int numPieces;
@property int numComponents;
@property int selectedPiece;
@property int selectedComponent;
@property int* piecesInSelectedComponent;



-(void) openPuzzleNum: (int) num;
-(NSMutableArray*) piecesToJoinToSelectedComponent;
-(void) moveSelectedPieceToX: (float) dx andY: (float) dy;
-(void) selectPiece: (int) pTag;


@end





