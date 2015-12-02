//
//  DispatchGroup.h
//
//  Created by Aleksey Garbarev on 20.12.13.
//

@interface DispatchGroup : NSObject

- (void) enter;
- (void) leave;
- (void) leaveAll;

- (void) notifyOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;
- (void) notifyOnBackgrounQueueWithBlock:(dispatch_block_t)block;
- (void) notifyOnMainQueueWithBlock:(dispatch_block_t)block;

@end