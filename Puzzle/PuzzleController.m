//
//  PuzzleController.m
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import "PuzzleController.h"

int myTopLeft[6][2]={{0,0},{295,0},{553,0},{872,0},{1142,0},{1410,0}}; //top left of image tile in whole image
int myImageSizes[5][2]={{402,323},{351,378},{424,312},{370,372}};

@interface PuzzleController()
{
    int puzzleNum;
    NSMutableArray *pieces;
    PuzzlePieceView *selectedPiece;
    PuzzleModel *model;
    float viewWidth, viewHeight;
}
@end

@implementation PuzzleController

-(id) init
{
    self = [super init];
    if (self)
    {
        pieces = [[NSMutableArray alloc] init];
        model = [[PuzzleModel alloc] init];
    }
    return self;
}

-(void) openPuzzleNum: (int) num
{
    int scaleFactor=1;
    
    // this is hard-coded for puzzle 1
    puzzleNum = 1;
    [model openPuzzleNum: 1];
    int numPieces = 5; //model.numPieces;
    
    // use first image as sample for size

    viewWidth = self.puzzleView.bounds.size.width;
    viewHeight = self.puzzleView.bounds.size.height;
    float scale = 355.0/1410.0;  // hard coded from puzzle1 image data, 355 is the width of the first piece and
            // image is 1410 wide.  for now just doing one row of pixels.

    
    for (int i=0; i<numPieces; i++)
    {


        NSString *filename;
        if (i<10)
        {
            filename = [NSString stringWithFormat:@"puzzle01_0%d.png",i];
            
        }
        else{
            filename = [NSString stringWithFormat:@"puzzle01_%d.png",i];
        }
        UIImage* theImage = [UIImage imageNamed:filename];
        
        // need to scale image to correct size
        // not sure why this has to be done, figure out later
        UIImage* scaledImage = [UIImage imageWithData:UIImagePNGRepresentation(theImage) scale:3];
        PuzzlePieceView *ppv = [[PuzzlePieceView alloc] initWithImage: scaledImage];
        ppv.userInteractionEnabled = YES;
        ppv.dragDelegate = self;
        ppv.tag = i;
        
        // use the upper left corner to situate the piece
        //ppv.contentMode=UIViewContentModeTopLeft;
        // clip to the bounds
        ppv.clipsToBounds=YES;
        
        // lets draw a background so we can see the frame
        //ppv.backgroundColor = [UIColor redColor];
        // this is size of frame
        float fWidth = ppv.bounds.size.width;
        float fHeight = ppv.bounds.size.height;

        // without scaling, the views preserve aspect ratio.  But how do they fit in the frame? The frames are square!
        // need to scale
        // want frameWidth/viewWidth = scale
        // and want to presever the aspect ration of the image that is imbedded in a square frame
        
        
        // add shadow
        [ppv initShadow];
        
        // (0,0) is upper left corner
        // choose random place to put center
        // for some reason this puts them too close to the top
        // so offset by 100
        int maxX = viewWidth-fWidth;
        int maxY = (viewHeight-fHeight)*.9;  // need to account for status bar
        float randX = arc4random() % maxX;  //
        float randY = arc4random() % maxY; 
                                      
        float cx = fWidth/2 + randX;
        float cy = fHeight/2 + randY +100; // because of bar at top of screen?

        
        // let's try to line them up so they work
        cx = myTopLeft[i][0]/2 + fWidth/2;
        cy = fHeight/2;
        NSLog(@"Image %d at %f %f",i,cx,cy);
        
        if (i==0)
            scaleFactor =  402/fWidth;

        float left = myTopLeft[i][0] / scaleFactor;
        float top = 100;
        ppv.frame = CGRectMake(left, top, fWidth, fHeight);

        //ppv.center = CGPointMake(cx,cy);

        
        // in models space we deal with top/left and we give it as a percentage of the view
        [model selectPiece:ppv.tag];
//        float left = (cx-fWidth/2.0)/viewWidth;
//        float top = (cy-fHeight/2.0)/viewHeight;
        
        [model moveSelectedPieceToX: left andY: top];
        //NSLog(@"size of of %d at %f %f", i, fwidth, fheight);  // need to figure out problem with placement
        [self.puzzleView addSubview:ppv];
        [pieces addObject:ppv];
        
        
    }
    
}

//a tile was dragged, check if matches a target
-(void)puzzlePieceView:(PuzzlePieceView*)puzzlePieceView didDropPiece: (int) num
{

    NSLog(@"Dropped piece %d.",selectedPiece.tag);
    selectedPiece = nil;
    model.selectedPiece = -1;
    model.selectedComponent = -1;
    model.piecesInSelectedComponent = nil;
}

-(void) puzzlePieceView:(PuzzlePieceView*) puzzlePieceView didMovePieceByDx:(float) dx andDy:(float) dy {
    
    // move other views in same component as selected
    int* ptr = model.piecesInSelectedComponent;
    int pNum=*ptr;
    while (pNum!=-1)
    {
        
        PuzzlePieceView *ppv =[pieces objectAtIndex:pNum];
        if (ppv != puzzlePieceView)
        {
            ppv.center = CGPointMake(ppv.center.x+dx,ppv.center.y+dy );
        }
        ptr++;
        pNum = *ptr;
        if (ptr-model.piecesInSelectedComponent>model.numPieces)
        {
            NSLog(@"problem with component list");
            break;
        }
        
    }
    
    // move the piece in the model
    PuzzlePieceView *ppv=puzzlePieceView;
    float x = (ppv.center.x - ppv.bounds.size.width)/viewWidth;
    float y = (ppv.center.y - ppv.bounds.size.height)/viewHeight;
    [model moveSelectedPieceToX:x andY:y];
    
    
    // then find collisions
    
    if (fabsf(dx)>1 || fabsf(dy)>1)
    {
        float x = puzzlePieceView.center.x;
        float y = puzzlePieceView.center.y;
        [model moveSelectedPieceToX:x andY:y];
  
        NSMutableArray* collidingPieces = [model piecesToJoinToSelectedComponent];
        if (collidingPieces)
        {
            for (NSArray* join in collidingPieces)
            {
                int index = [[join objectAtIndex:0] integerValue];
                int moveX = [[join objectAtIndex:1] integerValue];
                int moveY = [[join objectAtIndex:2] integerValue];
                PuzzlePieceView* thePiece = [pieces objectAtIndex:index];
                thePiece.center = CGPointMake(thePiece.center.x - moveX,thePiece.center.y - moveY);
                
            }
        }
    }
}


-(void) puzzlePieceView:(PuzzlePieceView*) puzzlePieceView didSelectPiece: (int) num
{

    [model selectPiece: num];
    NSLog(@"Selected piece %d.",selectedPiece.tag);
}

@end
