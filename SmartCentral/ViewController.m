//
//  ViewController.m
//  SmartCentral
//
//  Created on 24/06/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (strong, nonatomic) IBOutlet UIView *cyclingModeBtn;
@property (weak, nonatomic) IBOutlet UITextView *degubInfoTextView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.degubInfoTextView.text=@"";
    bleShield = [BLE sharedManager];
    [bleShield controlSetup];
    bleShield.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    bleShield.delegate = self;
}
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
//        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
//        [activityIndicator stopAnimating];
    }
}
- (IBAction)ScanForBLE:(id)sender
{
    if (bleShield.activePeripheral)
        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}
#pragma mark - BLE Manager Delegates -
-(void) bleDidDiscovered
{
    [self.deviceTable reloadData];
    
}
-(void) bleResponse:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"bleResponse::%@",error);
}
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
    NSMutableString *bleData = [NSMutableString string ];
    
    for (int i=0; i<length; i++)
        [bleData  appendFormat:@"%02x", data[i]];
    
    [bleData appendFormat:@"\n"];
    
    switch (data[1]) {
        case 0xB0:
        {
            NSLog(@"System msg");
            break;
        }
        case 0xB1:
        {
            NSLog(@"H/W msg");
        }
        case 0xB2:
        {
            NSLog(@"Info msg");
        }
        case 0xB3:
        {
            NSLog(@"Ackn msg");
        }
        default:
            break;
    }
    
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [bleShield readRSSI];
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    [self.scanBtn setTitle:@"Scan" forState:UIControlStateNormal];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [self.deviceTable reloadData];
}

-(void) bleDidConnect
{
    [self.scanBtn setTitle:@"Disconnect" forState:UIControlStateNormal];

    DetailViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
    detailsVC.selectedPeripheral = bleShield.activePeripheral;
    bleShield.delegate = detailsVC;
    [self presentViewController:detailsVC animated:YES completion:nil];
    NSLog(@"bleDidConnect");
//    [bleShield getAllServicesFromPeripheral:bleShield.activePeripheral];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(int) decimalIntoHex:(char) number
{
    char ge  =number/10*16;
    char shi =number%10;
    int total =ge +shi;
    return total;
}
- (IBAction)setCyclingMode:(id)sender{
    
    uint8_t send[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    /*
     4.3.1 System Message Format
     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
     */
    //    uint8_t send[20];
    send[0]=[self decimalIntoHex:1];
    send[1]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
    send[2]=0x00;//5 bit, used for H/w msg type: 0xFD
    send[3]=0xC3;
    send[4]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
    send[5]=0xA0;//CMD,e,g: SetSysMod:0xEC
    send[6]=0x01; // 0x01:Cycling
    send[7]=0x01;//Priority: (0x01)in HEX==1 in Decimal
    send[8]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
    NSData *data = [[NSData alloc] initWithBytes:send length:9];
    if (bleShield.activePeripheral.state == CBPeripheralStateConnected) {
        [bleShield write:data];
        NSMutableString *temp = [[NSMutableString alloc] init];
        for (int i = 0; i < 9; i++) {
            
            NSString *strTmp = [NSString stringWithFormat:@"%x",send[i]];
            if([strTmp length]<2)
                [temp appendFormat:@" 0x0%x ", send[i]];
            else
                [temp appendFormat:@" 0x%x ", send[i]];
        }
        if (str == nil) {
            str = [NSMutableString stringWithFormat:@"%@\n", temp];
        } else {
            [str appendFormat:@"%@\n", temp];
        }
        self.degubInfoTextView.text =str;
    }
}
- (IBAction)setLED:(UISwitch*)sender{
    
    uint8_t send[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    /*
     4.3.1 System Message Format
     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
     */
    //    uint8_t send[20];
    send[0]=[self decimalIntoHex:1];
    send[1]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
    send[2]=0x00;//5 bit, used for H/w msg type: 0xFD
    send[3]=0xC3;
    send[4]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
    send[5]=0xA0;//CMD,e,g: SetSysMod:0xEC
    send[6]=0x01; // 0x01:Cycling
    send[7]=0x01;//Priority: (0x01)in HEX==1 in Decimal
    send[8]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
    NSData *data = [[NSData alloc] initWithBytes:send length:9];
    if (bleShield.activePeripheral.state == CBPeripheralStateConnected) {
        [bleShield write:data];
    }
}
#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    BLECentralManager *centralManager = [BLECentralManager sharedService];
//    return [centralManager.ymsPeripherals count];
    return [bleShield.peripherals count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"peripheralCell";
    UITableViewCell *pcell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CBPeripheral *p =[bleShield.peripherals objectAtIndex:indexPath.row];
    pcell.textLabel.text = p.name;
    pcell.detailTextLabel.text = [NSString stringWithFormat:@"%@",p.identifier.UUIDString];
    return pcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    [bleShield getAllServicesFromPeripheral:[bleShield.peripherals objectAtIndex:indexPath.row]];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailViewController"])
    {
        NSIndexPath *indexPath = [self.deviceTable indexPathForSelectedRow];
        
        DetailViewController *destViewController = segue.destinationViewController;
        destViewController.selectedPeripheral = [bleShield.peripherals objectAtIndex:indexPath.row];
//        bleShield.delegate = destViewController;
    }
}
-(void) bleDidDiscoverCharacteristic{
    NSLog(@"VC bleDidDiscoverCharacteristic");
}
@end
