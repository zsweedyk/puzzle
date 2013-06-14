//
//  PuzzleModel.m
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import "PuzzleModel.h"

const int COMPONENT_NUM = 0, PIECE_NUM = 1, MOVED_X = 2, MOVED_Y = 3,ORIGINAL_OFFSET_X = 4, ORIGINAL_OFFSET_Y = 5;



#define CLOSE_ENOUGH 5
int topLeft[6][2]={{0,0},{258,0},{549,0},{1116,0},{1410,0}}; //top left of image tile in whole image
int imageSizes[5][2]={{402,323},{351,378},{424,312},{370,372}};

@implementation PuzzleModel

-(id) init
{
    self = [super init];
    if (self)
    {
        _puzzleNum = -1;
        _numPieces =0;
        _numComponents=0;
        _selectedPiece=-1;
        _selectedComponent=-1;
        _piecesInSelectedComponent=&piecesInSelectedComponent[0];
        imageWidth = 1410;
    }
    return self;
}


-(void) openPuzzleNum: (int) num
{

    _puzzleNum = num;
    _numPieces = 5;
    _numComponents = 5;
    
    


    
  
    for (int i=0; i<5; i++)
    {
        pieces[i][ORIGINAL_OFFSET_X] = topLeft[i][0];
        pieces[i][ORIGINAL_OFFSET_Y] = topLeft[i][1];
    }
    
    // create initial pieces & components
    for (int i=0; i<_numComponents; i++)
    {

        // piece stores its component number, its number, its movement, and its initial offset
        
        pieces[i][PIECE_NUM]=i;
        pieces[i][COMPONENT_NUM]=i;
        components[i][0]=i;
        for (int j=1; j<=_numPieces; j++)
            components[i][j]=-1;
    
    
    }
    
    // create initial adjacencies
    // just for the simple case
    
    for (int i=0;i<5;i++)
         for (int j=0; j<5;j++)
             adjacent[i][j]=-1;
    
    for (int i=0; i<5; i++)
    {
        int count=0;
        for (int j=0; j<5; j++)
        {
            if (j==i-1 || j==i+1)
                adjacent[i][count++] = j;
        }
            
    }
    
}

-(void) selectPiece:(int) pNum
{
    _selectedPiece = pNum;
    _selectedComponent = pieces[_selectedPiece][COMPONENT_NUM];
    _piecesInSelectedComponent = &piecesInSelectedComponent[0]; 
    
    // we have to copy the pieces in the current component into a new single array
    // otherwise the model has to know about indexing -- or we have to do all the conversions
    // with NSNumber and put them into an NSArray
    
    for (int i=0;i<_numPieces; i++)
    {
        piecesInSelectedComponent[i]=components[_selectedComponent][i];
    }



    
}


-(NSMutableSet*) piecesToJoinToSelectedComponent
{
    
    bool joinComponents=false;
    NSMutableSet* piecesToMove;

    
    // check if the selected component matches up with another component
    // return any that are close
    if (_selectedPiece==-1)
    {
        NSLog(@"Can check component, none selected.");
        return nil;
    }
    
    // go through selected component

    int sIndex=0;
    int sPiece;
    
    while ((sPiece=components[_selectedComponent][sIndex])!=-1) // pick a piece in selected component
    {
    
        int cIndex=0;
        int cPiece;
        
        // go through the adjacency list for the chosen piece, sPiece, in the selected component
        while ((cPiece=adjacent[sPiece][cIndex])!=-1)
        {
            int currentComponent=pieces[cPiece][COMPONENT_NUM];
            // if cPiece in a different component we need to check if the is near enough to the sPiece
            if (currentComponent != _selectedComponent)
            {
                
                int origDX = pieces[sPiece][ORIGINAL_OFFSET_X] - pieces[cPiece][ORIGINAL_OFFSET_X];
                int currDX = pieces[sPiece][MOVED_X] - pieces[cPiece][MOVED_X];
                int origDY = pieces[sPiece][ORIGINAL_OFFSET_Y] - pieces[cPiece][ORIGINAL_OFFSET_Y];
                int currDY = pieces[sPiece][MOVED_Y] - pieces[cPiece][MOVED_Y];
                int diffX = origDX - currDX;
                int diffY = origDY - currDY;
                if ((cPiece == 0 && sPiece ==1) || (cPiece==1 && sPiece==0))
                    NSLog(@"Difference %d %d",diffX, diffY);
                if (abs(diffX)<CLOSE_ENOUGH && abs(diffY) < CLOSE_ENOUGH)
                {
                    if (!joinComponents)  // if this is the first join we've found we'll initialize our set of
                        // pieces to move
                    {
                        joinComponents=true;
                        piecesToMove = [[NSMutableSet alloc] init];
                    }
                    [self addToSelectedComponent: currentComponent withDx: diffX andDy: diffY storeIn: piecesToMove];
                } // end if Close Enough
            } // end current component different than selected
            cIndex++;
                
        }
        sIndex++;
    } // end walking through component
        
    return piecesToMove;
}

    
-(void) addToSelectedComponent: (int) addComponent withDx: (int) diffX andDy: (int) diffY storeIn: (NSMutableSet*) piecesToMove
{
    int offset=0;
    int joinIndex=0;
    while (components[_selectedComponent][joinIndex]!=-1)
        joinIndex++;
    while (components[addComponent][offset]!=-1)
    {
        // copy pieces to current component
        int pNum = components[addComponent][offset];
        components[_selectedComponent][joinIndex+offset] = pNum;
        pieces[pNum][COMPONENT_NUM]=_selectedComponent;
        
        // put pieces in a list for the controller to reset their positions
        // objects in pieces to move are the piece number and the offset to join the pieces
        [piecesToMove addObject:[[NSArray alloc] initWithObjects:
                                 [NSNumber numberWithInt:components[addComponent][offset]],
                                 [NSNumber numberWithInt: diffX],
                                 [NSNumber numberWithInt: diffY],
                                 nil]];
        components[addComponent][offset]=-1;
        offset++;
        
    }
}




-(void) moveSelectedPieceToX:(float) x andY:(float) y
{
    //NSAssert((_selectedPiece!=-1),@"Can move piece, none selected.");
    if (_selectedPiece==-1)
    {
       NSLog(@"Can't move piece, none selected.");
        return;
    }
    int i=0;
    int pNum;
    while ((pNum=components[_selectedComponent][i])!=-1)
    {
        pieces[pNum][MOVED_X] = x*imageWidth;
        pieces[pNum][MOVED_Y] = y;
        i++;
        //NSLog(@"Moved piece %d by %d %d",pNum, dx,dy);
    }

}




@end



