//
//  ViewController.m
//  SmartCentral
//
//  Created on 24/06/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
}
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
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
    [self.scanBtn setTitle:@"Connect" forState:UIControlStateNormal];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) bleDidConnect
{
    [self.scanBtn setTitle:@"Disconnect" forState:UIControlStateNormal];

    
    NSLog(@"bleDidConnect");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
