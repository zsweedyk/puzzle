//
//  ViewController.m
//  Puzzle
//
//  Created by Elizabeth Sweedyk on 6/1/13.
//  Copyright (c) 2013 Elizabeth Sweedyk. All rights reserved.
//

#import "ViewController.h"
#import "PuzzleController.h"

@interface ViewController()
@property (strong, nonatomic) PuzzleController *controller;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // set up view
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0,0,width,height)];
    [self.view addSubview:view];
    
    // setup controller
    _controller = [[PuzzleController alloc] init];
    _controller.puzzleView = view;
    [_controller openPuzzleNum: 1];
    

                

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
