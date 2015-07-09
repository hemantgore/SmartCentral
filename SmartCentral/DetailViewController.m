//
//  DetailViewController.m
//  SmartCentral
//
//  Created by Sandeep on 07/07/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *servicesListTable;
@property (weak, nonatomic) IBOutlet UITableView *charcteristicsTable;

@end

@implementation DetailViewController
@synthesize selectedPeripheral;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    bleShield = [BLE sharedManager];
//    [bleShield controlSetup];
//    bleShield.delegate = self;
//    [bleShield connectPeripheral:self.selectedPeripheral];
    
}
-(void) bleDidDiscoverCharacteristic{
    NSLog(@"bleDidDiscoverCharacteristic");
    [self.servicesListTable reloadData];
}
#pragma mark - BLE Delegates -
-(void) bleDidConnect{
    [self.servicesListTable reloadData];
}
-(void) bleDidDisconnect{
    [self.servicesListTable reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (tableView==self.servicesListTable)?
    [self.selectedPeripheral.services count]:0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *pcell = nil;
    if(tableView==self.servicesListTable)
    {
        pcell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
        if (pcell == nil) {
            pcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceCell"];
        }
        CBService *s = [selectedPeripheral.services objectAtIndex:indexPath.row];
        //    CBPeripheral *p =[bleShield.peripherals objectAtIndex:indexPath.row];
        pcell.textLabel.text = [NSString stringWithFormat:@"%@",s.UUID];
        
        NSMutableString *chrStr = [[NSMutableString alloc]init];
//        for (CBCharacteristic *c in s.characteristics) {
//            [chrStr appendFormat:@"%@ \n",c.UUID];
//        }
        for (int i=0; i < s.characteristics.count; i++)
        {
            CBCharacteristic *c = [s.characteristics objectAtIndex:i];
            [chrStr appendFormat:@"%@",[self CBUUIDToString:c.UUID]];
            NSLog(@"Found characteristic %@ \n",chrStr);
        }
        NSLog(@"chrStr::%@",chrStr);
        pcell.detailTextLabel.text = [NSString stringWithFormat:@"%@",chrStr];//[NSString stringWithFormat:@"%@",p.identifier.UUIDString];
        
    }    
    return pcell;
}
-(NSString *) CBUUIDToString:(CBUUID *) cbuuid;
{
    NSData *data = cbuuid.data;
    
    if ([data length] == 2)
    {
        const unsigned char *tokenBytes = [data bytes];
        return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
    }
    else if ([data length] == 16)
    {
        NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
        return [nsuuid UUIDString];
    }
    
    return [cbuuid description];
}
-(IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
