//
//  PuzzlePieceView.h
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PuzzlePieceView;

@protocol PuzzlePieceDragDelegateProtocol <NSObject>

-(void) puzzlePieceView:(PuzzlePieceView*) puzzlePieceView didSelectPiece: (int) num;
-(void) puzzlePieceView:(PuzzlePieceView*) puzzlePieceView didDropPiece: (int) num;
-(void) puzzlePieceView:(PuzzlePieceView *)puzzlePieceView didMovePieceByDx: (float) dx andDy: (float) dy;
@end;

@interface PuzzlePieceView : UIImageView




@property (weak, nonatomic) id<PuzzlePieceDragDelegateProtocol> dragDelegate;

-(void) initShadow;



@end





