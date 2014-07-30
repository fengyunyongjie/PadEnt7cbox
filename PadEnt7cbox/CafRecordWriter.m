//
//  CafRecordWriter.m
//  MLAudioRecorder
//
//  Created by molon on 5/12/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "CafRecordWriter.h"

@interface CafRecordWriter()
{
    AudioFileID mRecordFile;
    SInt64 recordPacketCount;
    FILE *_file;
}

@end

@implementation CafRecordWriter


- (BOOL)createFileWithRecorder:(MLAudioRecorder*)recoder
{
    //建立文件
    recordPacketCount = 0;
    
    //模拟器上filepath有空格，真机没有，所以要去掉空格
    CFStringRef fileNameEscaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.filePath, NULL, NULL, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, fileNameEscaped, NULL);
    OSStatus err = AudioFileCreateWithURL(url, kAudioFileCAFType, (const AudioStreamBasicDescription	*)(&(recoder->_recordFormat)), kAudioFileFlags_EraseFile, &mRecordFile);
    CFRelease(url);
    
    return err==noErr;
}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(MLAudioRecorder*)recoder inAQ:(AudioQueueRef)						inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc
{
    OSStatus err = AudioFileWritePackets(mRecordFile, FALSE, data.length,
                                         inPacketDesc, recordPacketCount, &inNumPackets, data.bytes);
    if (err!=noErr) {
        return NO;
    }
    recordPacketCount += inNumPackets;
    
    return YES;
}

- (BOOL)completeWriteWithRecorder:(MLAudioRecorder*)recoder withIsError:(BOOL)isError
{
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
    
    //    NSData *data = [[NSData alloc]initWithContentsOfFile:self.filePath];
    //    NSLog(@"文件长度%ld",data.length);
    
    return YES;
}

-(void)dealloc
{
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
}
@end
