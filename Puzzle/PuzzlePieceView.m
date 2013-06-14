//
//  PuzzlePieceView.m
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import "PuzzlePieceView.h"


@implementation PuzzlePieceView
{
    float _xOffset, _yOffset;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Use initWithImageFile:andMaxWidth:MaxHeight: instead");
    return nil;
}

-(void)initShadow
{

    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowRadius = 4.0;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    return;
}



 

#pragma mark - dragging the puzzle piece
//1
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    _xOffset = pt.x - self.center.x;
    _yOffset = pt.y - self.center.y;
    if (self.dragDelegate)
        [self.dragDelegate puzzlePieceView:self didSelectPiece: self.tag];
}

//2
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    float dx = pt.x - _xOffset - self.center.x;
    float dy = pt.y - _yOffset - self.center.y;
    self.center = CGPointMake(pt.x - _xOffset, pt.y - _yOffset);
    if (self.dragDelegate)
    {
        [self.dragDelegate puzzlePieceView:self didMovePieceByDx: dx andDy: dy];
        
    }
}

//3
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
    if (self.dragDelegate) {
        [self.dragDelegate puzzlePieceView:self didDropPiece: self.tag];
    }
}



@end
