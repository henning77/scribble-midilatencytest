//
//  ViewController.m
//  MidiLatencyTest
//
//  Created by Henning Böger on 15.06.12.
//  Copyright (c) 2012 Skycoders GmbH. All rights reserved.
//

#import "ViewController.h"
#import "PGMidiAllSources.h"

@implementation ViewController

- (void) logMsg:(NSString*)str
{
    NSLog(@"Log: %@", str);
    outputTextView.text = [outputTextView.text stringByAppendingString:str];   
}

- (void) sendMidi
{
    const UInt8 midiMessage[]  = { 0x90, 0x40, 0x10 };
    [midi sendBytes:midiMessage size:sizeof(midiMessage)];
    midiSendTimestamp = [NSDate timeIntervalSinceReferenceDate];
    [self logMsg:@"Sent\n"];
}

// Runs in background thread
- (void) midiSource:(PGMidiSource*)input midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        // handle packet (only use 3-byte MIDI messages)
        if (packet->length >= 3) {
            // Calculate latency
            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval diff = now - midiSendTimestamp;

            uint8_t type = packet->data[0];
            uint8_t data1 = packet->data[1];
            uint8_t data2 = packet->data[2];                
            
            NSString* msg = [NSString stringWithFormat:@"MIDI IN type: %0xd d1: %0xd d2: %0xd diff: %f\n", type, data1, data2, diff];
            [self performSelectorOnMainThread:@selector(logMsg:) withObject:msg waitUntilDone:NO];
        }         
        
        packet = MIDIPacketNext(packet);        
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    midi = [[PGMidi alloc] init];
    [midi enableNetwork:YES];
        
    midiAllSources = [[PGMidiAllSources alloc] init];
    midiAllSources.midi = midi;
    midiAllSources.delegate = self;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    outputTextView = nil;
    [super viewDidUnload];
    
    midi = nil;
    midiAllSources = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    midiSendTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendMidi) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [midiSendTimer invalidate];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
