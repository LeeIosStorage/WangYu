//
//  InviteFriendsViewCell.m
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "InviteFriendsViewCell.h"

@implementation InviteFriendsViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.phoneNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.phoneNameLabel.font = SKIN_FONT_FROMNAME(14);
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPbUserInfo:(PbUserInfo *)pbUserInfo{
    _pbUserInfo = pbUserInfo;
    
    self.avatarImageView.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
    
    self.phoneNameLabel.text = pbUserInfo.name;
    if (!pbUserInfo.name) {
        self.phoneNameLabel.text = pbUserInfo.phoneNUm;
    }
    self.stateImageView.highlighted = pbUserInfo.selected;
    
}

- (void)setPbUserInfo:(PbUserInfo*)userInfo withddressBookRef:(ABAddressBookRef)addressBook{
    _pbUserInfo = userInfo;
    
    if (addressBook) {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, userInfo.recordId);
        if(ABPersonHasImageData(person)){
            CFDataRef dataRef = ABPersonCopyImageData(person);
            UIImage *image = [UIImage imageWithData:(__bridge NSData *)dataRef];
            if(dataRef) CFRelease(dataRef);
            [_avatarImageView setImage:image];
        }else{
            self.avatarImageView.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
        }
    }else{
        self.avatarImageView.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
    }
    
    self.phoneNameLabel.text = _pbUserInfo.name;
    if (!_pbUserInfo.name) {
        self.phoneNameLabel.text = _pbUserInfo.phoneNUm;
    }
    self.stateImageView.highlighted = _pbUserInfo.selected;
}
@end
