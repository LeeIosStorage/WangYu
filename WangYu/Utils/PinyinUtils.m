//
//  PinyinUtils.m
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PinyinUtils.h"

#define MAKEWORD(a, b) ((unsigned short)((unsigned char)(a)) | ((unsigned short)((unsigned char)(b)) << 8))

enum ECONST{
    E_MAX_PINYIN_STRING_LENGTH = 6,
    E_MAX_CHARACTER_NUM = 6834
};

typedef struct UICODE_PINYIIN{
    unsigned short iUincode;
    char szPinYin[E_MAX_PINYIN_STRING_LENGTH +1];
}UICODE_PINYIIN;

static struct UICODE_PINYIIN *unicodeYins = nil;

@implementation PinyinUtils

+ (void)initData{
    unsigned char * pBuf = NULL;
    int i = 0;
    unsigned char * p;
    NSUInteger len = 0;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"UnicodeToPinYin.dat" ofType:nil];
    
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData* data = [file readDataToEndOfFile];
    
    unicodeYins = malloc(sizeof(struct UICODE_PINYIIN)*E_MAX_CHARACTER_NUM);
    
    len = [data length];
    
    pBuf = (unsigned char *)[data bytes];
    //p = pBuf;
    int iIndex = 0;
    while (i < len) {
        p = pBuf + i;
        UICODE_PINYIIN *pUnicodePinYin = (UICODE_PINYIIN*)((char*)unicodeYins + sizeof(UICODE_PINYIIN)*iIndex);
        
        
        unsigned char bLow = *(p+1);
        unsigned char bHigh = *p;
        
        (*pUnicodePinYin).iUincode = MAKEWORD(bLow,bHigh);
        
        i += 2;
        p += 2;
        
        int ipyLength = (int)strlen((char *)p);
        if(ipyLength > E_MAX_PINYIN_STRING_LENGTH)
            break;
        strcpy((*pUnicodePinYin).szPinYin,(char *)p);
        
        
        //NSString* pinyin = [NSString stringWithCString:(*pUnicodePinYin).szPinYin encoding:NSASCIIStringEncoding];
        //NSLog(@"%@",pinyin);
        
        
        i += ipyLength;
        i++;
        
        iIndex ++;
        
    }
    
    [file closeFile];
}


+(NSString*)Unicode2Pinyin:(NSString*)text{
    if (unicodeYins == nil) {
        [PinyinUtils initData];
    }
    
    NSMutableString* strRes = [NSMutableString stringWithString:@""];
    int iUnicodeChar = (int)[text length];
    int i =0;
    for(i = 0; i < iUnicodeChar;i++)
    {
        int iFirst,iMid,iLast;
        iFirst = 0;
        iMid = 0;
        iLast = E_MAX_CHARACTER_NUM - 1;
        unsigned short wMid = 0;
        unsigned short wComp = [text characterAtIndex:i];
        //binary search
        while(iFirst <= iLast)
        {
            iMid = (iFirst + iLast)/2;
            wMid = unicodeYins[iMid].iUincode;
            if(wMid ==  wComp)
                break;
            else if(wMid > wComp)
                iLast = iMid - 1;
            else
                iFirst = iMid + 1;
        }
        if(wComp != unicodeYins[iMid].iUincode)
        {
            //			iPYLen = 1;
            //			szPinYin[0] = (char)*(szUC+i);
            //			if(szPinYin[0] > 127)
            //				szPinYin[0] = 0x7e;
            //			szPinYin[1] = 0;
            //			iTotalPinYinChar += iPYLen;	
            
            [strRes appendString:[NSString stringWithCharacters:&wComp length:1]];
        }
        else
        {
            [strRes appendString:[NSString stringWithUTF8String:unicodeYins[iMid].szPinYin]];
        }
        
    }
    
    return strRes;
}

@end
