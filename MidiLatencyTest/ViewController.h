//
//  ViewController.h
//  MidiLatencyTest
//
//  Created by Henning Böger on 15.06.12.
//  Copyright (c) 2012 Skycoders GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMidi.h"

@class PGMidiAllSources;

@interface ViewController : UIViewController<PGMidiSourceDelegate> {
    PGMidi* midi;
    PGMidiAllSources* midiAllSources;

    NSTimer* midiSendTimer;
    
    NSTimeInterval midiSendTimestamp;
    
    __weak IBOutlet UITextView *outputTextView;
}

@end
