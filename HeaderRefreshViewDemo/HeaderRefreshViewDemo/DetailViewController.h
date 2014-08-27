//
//  DetailViewController.h
//  HeaderRefreshViewDemo
//
//  Created by nijino on 14/8/25.
//  Copyright (c) 2014年 www.nijino.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

