//
//  DetailViewController.h
//  SmartCentral
//
//  Created by Sandeep on 07/07/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "ViewController.h"
#import "BLE.h"
@interface DetailViewController : UIViewController<BLEDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BLE *bleShield;
}
@property (nonatomic,strong) CBPeripheral *selectedPeripheral;
@end
