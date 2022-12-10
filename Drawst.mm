#pragma mark - 调用文件
#import "Drawst.h"
#import "Drawzb.h"
#import "Drawlm.h"
#import "Drawdk.h"
#import "JFPlayerPool.h"
#import "JFPropsPool.h"
#import "JFCommon.h"
#import "Color.h"
#import "imgui.h"
#import "imgui_internal.h"
#import "ImGuiWrapper.h"
#import "ImGuiStyleWrapper.h"
#import "TextEditorWrapper.h"
#import "GuiRenderer.h"

#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
using namespace std;
std::string string_format(const std::string &fmt, ...) {
    std::vector<char> str(100,'\0');
    va_list ap;
    while (1) {
        va_start(ap, fmt);
        auto n = vsnprintf(str.data(), str.size(), fmt.c_str(), ap);
        va_end(ap);
        if ((n > -1) && (size_t(n) < str.size())) {
            return str.data();
        }
        if (n > -1)
            str.resize( n + 1 );
        else
            str.resize( str.size() * 2);
    }
    return str.data();
}

@interface applenv() <GuiRendererDelegate> {
    ImFont *_espFont;
}

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) GuiRenderer *renderer;

@end

@implementation applenv

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;

        
        self.isStartTimer = false;
        self.isShowMenu = false;
        self.isLineEsp = false;
        self.isBoxEsp = false;
        self.isBoneEsp = false;
        self.isHpBarEsp = false;
        self.isTextEsp = false;
        self.isAimbot = false;//自瞄
        self.isNorecoil = false;//无后
        self.judian = false;//聚点
        self.fangdou = false;//防抖
        self.shun = false;//瞬击
        self.fang = false;//无后
        self.isSpeed = false;//顺击
        self.gzb = true;//过直播
        self.isNearDeathNotAim = false;
        self.isShowProps = false;
        self.isShowPropsVehicle = false;
        self.isShowPropsWeapon = false;
        self.isShowPropsArmor = false;
        self.isShowPropsSight = false;
        self.isShowPropsEarlyWarning = false;
        self.BPc = false;
        self.BoxWith = false;
        self.Pistol = false;
        self.isTeamMateEsp = false;
        self.isBulletTrack = false;
        self.isAdsAimbot = false;
         self.isGunAimbot = false;
        self.propsDistance = 300;
        self.aimbotPart = 6;
        self.aimbotRadius = 10;//自瞄大小
        self.shunjidaxiao = 0;
        self.wuhoutiaojie = 0;
        self.espDistance = 300;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.mtkView = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mtkView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.mtkView];
    
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!self.mtkView.device) {
        return;
    }
    
    self.renderer = [[GuiRenderer alloc] initWithView:self.mtkView];
    self.renderer.delegate = self;
    self.mtkView.delegate = self.renderer;
    [self.renderer initializePlatform];
}


#pragma mark - GuiRendererDelegate
- (void)setup
{
    ImGuiIO & io = ImGui::GetIO();
    ImFontConfig config;
    config.FontDataOwnedByAtlas = false;
    
    ImGui::StyleColorsClassic();
    NSString *fontPath = @"/System/Library/Fonts/LanguageSupport/PingFang.ttc";
    _espFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 20.f, &config, io.Fonts->GetGlyphRangesChineseFull());

}

- (void)draw
{
    [self drawOverlay];
    [self drawMenu];
}

#pragma mark - 绘制
//绘制菜单
- (void)drawMenu
{
    self.userInteractionEnabled = self.isShowMenu;
    self.mtkView.userInteractionEnabled = self.isShowMenu;
    if (!_isShowMenu) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
                CGFloat width = SCREEN_WIDTH * 0.5;
                CGFloat height = SCREEN_HEIGHT * 3;
                
                if (SCREEN_WIDTH > SCREEN_HEIGHT) {
                
                    height = SCREEN_HEIGHT * 0.6;
                } else {
                  
                    width = SCREEN_WIDTH * 0.4;
                }
                

                ImGuiIO & io = ImGui::GetIO();
                
               
                
                if (iPhone8P){
                    io.DisplayFramebufferScale = ImVec2(2.60, 2.60);
                }else{
                    io.DisplayFramebufferScale = ImVec2(width, height);
                }
                io.DisplaySize = ImVec2(width, height);
                
                ImGui::SetNextWindowPos(ImVec2((SCREEN_WIDTH - width) * 0.2, (SCREEN_HEIGHT - height) * 0.3), 0, ImVec2(0, 0));
                ImGui::SetNextWindowSize(ImVec2(io.DisplaySize.x, io.DisplaySize.y));
              
            });
            
    ImGui::Begin("KAsar", &_isShowMenu, ImGuiWindowFlags_NoCollapse);
    //ImGui::Separator();//分割线
    //ImGui::SameLine();//下一个
    if (ImGui::BeginTabBar("选项卡", ImGuiTabBarFlags_NoTooltip))
    {
    if (ImGui::BeginTabItem("公告"))
    {
    if (ImGui::ShowStyleSelector("菜单风格##Selector"))
    ImGui::TextColored(ImColor(255, 64, 64), "注意事项");
    ImGui::Text("注意演戏 避免上巡查");
    ImGui::Text("开挂本就是逆天而行 请三思而后行");
    ImGui::Text("大鹏一日同风起 扶摇直上九万里");
    ImGui::Text("宣父犹能畏后生 丈夫未可轻年少");
    ImGui::Text("Copright YuWan All Rights Resevered");
    ImGui::EndTabItem();//结束
    }

        //**************************************************************************************************************************//

    if (ImGui::BeginTabItem("透视选项"))
    {
    ImGui::TextColored(ImColor(255, 64, 64), "•ESP");
    ImGui::Checkbox("ESP", &_isStartTimer);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Line", &_isLineEsp);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Bone", &_isBoneEsp);
    //换行
    ImGui::Checkbox("HpBar", &_isHpBarEsp);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Info", &_isTextEsp);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Box", &_isBoxEsp);
    ImGui::Separator();

        //***********************************************************************************//

    ImGui::TextColored(ImColor(255, 64, 64), "•娱乐专区");
    ImGui::Checkbox("No Recoil", &_isNorecoil);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Small Cross", &_judian);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Scope Recoil", &_fangdou);
    //换行
    ImGui::Checkbox("Fast bullet", &_shun);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("bullet tracking", &_isBulletTrack);
    ImGui::SameLine();//下一个
    ImGui::Checkbox("Aimbot", &_isAimbot);
    ImGui::Separator();//分割线

        //***********************************************************************************//

    ImGui::RadioButton("Head", &_aimbotPart, 6); 
    ImGui::SameLine();//下一个
    ImGui::RadioButton("脖子", &_aimbotPart, 5);
    ImGui::SameLine();//下一个
    ImGui::RadioButton("胸部", &_aimbotPart, 4);
    ImGui::SameLine();//下一个
    ImGui::RadioButton("屁股", &_aimbotPart, 1);
    ImGui::Separator();//分割线
    ImGui::EndTabItem();
        //结束
    }

        //***********************************************************************************//

        if (ImGui::BeginTabItem("物资选项"))
        {
        ImGui::TextColored(ImColor(255, 64, 64), "•物资选项");
        ImGui::Checkbox("ShowProps", &_isShowProps);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("ShowPropsArmor", &_isShowPropsArmor);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("ShowPropsDrug", &_isShowPropsDrug);
        //换行
        ImGui::Checkbox("PropsSight", &_isShowPropsSight);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("PropsAccessory", &_isShowPropsAccessory);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("Bullet", &_isShowPropsBullet);
        //换行
        ImGui::Checkbox("ShowProps", &_isShowProps);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("PropsVehicle", &_isShowPropsVehicle);
        ImGui::SameLine();//下一个
        ImGui::Checkbox("PropsWeapon", &_isShowPropsWeapon);

        ImGui::EndTabItem();//结束
        }

        //***********************************************************************************//

    if (ImGui::BeginTabItem("其他选项"))
    {
    ImGui::TextColored(ImColor(16, 43, 106), "•其他选项/QT Set");
        ImGui::SliderInt("Fast bullet Size", &_shunjidaxiao, 0, 1000000);
        //换行
        ImGui::SliderInt("props Distance", &_propsDistance, 0, 500);
        //换行
        ImGui::SliderInt("Esp Distance", &_espDistance, 0, 500);
        //换行
        ImGui::SliderInt("aim/track Radius", &_aimbotRadius, 10, 500);
        ImGui::Separator();//分割闲
        ImGui::Text("Copright YuWan All Rights Resevered.", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
        
    ImGui::EndTabItem();
        //结束
    }
    ImGui::EndTabBar();
    }
    ImGui::End();
}

- (void)drawOverlay


{
    
    if (!self.isStartTimer) {
        return;
    }

    if (self.isGunAimbot ||self.isAdsAimbot|| self.isBulletTrack) {
        
        [self drawAimRangeWithCenter:ImVec2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5) radius:self.aimbotRadius color:Color::Green numSegments:100 thicknes:1];

    }
    //圈颜色
    int enemyCount = 0;
    for (JFPlayer *player in [IFuckYou getInstance].playerList) {
        if (player.type == PlayerTypeEnemy) {
            enemyCount++;
        }
    }

    [self playerCountEsp:enemyCount];

    for (JFPlayer *player in [IFuckYou getInstance].playerList) {
    
        if (player.isDead || (player.type == PlayerTypeTeam && !self.isTeamMateEsp)) {
            continue;
        }
        
        Color color = Color::White;
        if (player.type == PlayerTypeTeam) {
            color = Color::Yellow;
        } else {
            //颜色
            if (player.isVisible) {
                color = Color::Yellow;
            } else {
                color = Color::Red;
            }
        }
        if (player.type == PlayerTypeEnemy && player.isFallDown) {
            color = Color::Xue2;
        }
      
       if ((self.isGunAimbot ||self.isAdsAimbot|| self.isBulletTrack) && player.isBestAimTarget) {
            
            [self drawCircleFilledWithCenter:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) radius:3/*准心判断点大小*/ color:Color::Blue numSegments:20];  //准心判断
            
            
            [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5,SCREEN_HEIGHT * 0.5)
                                endPoint:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) color:Color::Blue thicknes:0.1];

        }
        //  血条颜色
        if (self.isTextEsp) {
            [self textEsp:player distanceColor:color];
        }

        if (self.isHpBarEsp) {
            [self hpBarEsp:player];
        }

        if (self.isBoxEsp) {
            
            [self drawRectWithPos:ImVec2(player.box.origin.x, player.box.origin.y) size:ImVec2(player.box.size.width, player.box.size.height) color:color thicknes:1];
        }

        if (self.isLineEsp) {
            float offset = 5;
    
            if (self.isHpBarEsp) {
                offset += 10;
            }

            if (self.isTextEsp) {
                offset += 20;
            }
          
            [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5, 55) endPoint:ImVec2(CGRectGetMidX(player.box), CGRectGetMinY(player.box) - offset) color:color thicknes:0.05];
        }

        if (self.isBoneEsp) {
            [self boneEsp:player];
        }
    }
    for (JFProps *props in [IFuckYou getInstance].propsList) {
        
        if (props.type == PropsTypeWeapon && self.isShowPropsWeapon) {
            [self propsEsp:props color:Color::Quan];
        }

        if (props.type == Flaregun && self.Pistol) {
            [self propsEsp:props color:Color::Quan];
        }
  
        if (props.type == PropsTypeArmor && self.isShowPropsArmor) {
            [self propsEsp:props color:Color(238, 238, 0)];
        }
      
        if (props.type == PropsTypeSight && self.isShowPropsSight) {
            [self propsEsp:props color:Color(238, 238, 0)];
        }
 
        if (props.type == PropsTypeAccessory && self.isShowPropsAccessory) {
            [self propsEsp:props color:Color(238, 238, 0)];
        }

        if (props.type == PropsTypeBullet && self.isShowPropsBullet) {
            [self propsEsp:props  color:Color::Wuqi];
        }

        if (props.type == PropsTypeDrug && self.isShowPropsDrug) {
            [self propsEsp:props color:Color::Yao];
        }

        if (props.type == PickUpListWrapperActor && self.BoxWith) {
                   [self propsEsp:props color:Color::Yao];
               }

        if (props.type == AirDropBox && self.BPc) {
                          [self propsEsp:props color:Color::Yao];
                      }

        if (props.type == PropsTypeVehicle && self.isShowPropsVehicle) {
            [self propsEsp:props color:Color::Che];
        }

        if (props.type == PropsTypeEarlyWarning && self.isShowPropsEarlyWarning) {
            
            [self propsEsp:props color:Color::Red];
      
            if (props.distance <= 10) {
      
                [self drawTextWithText:props.name pos:ImVec2(SCREEN_WIDTH * 0.5, 65) isCentered:true color:Color::Red outline:true fontSize:25];
                   
                [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5, 55) endPoint:ImVec2(props.screenPos.X, props.screenPos.Y) color:Color::Blue thicknes:0.1];
            }
        }
    }
    
}
//物资绘制
- (void)propsEsp:(JFProps *)props color:(Color)color
{
    [self drawTextWithText:string_format("%s [%dM]", props.name.c_str(), props.distance)
                       pos:ImVec2(props.screenPos.X, props.screenPos.Y)
                isCentered:true
                     color:color
                   outline:false
                  fontSize:15];
}
//绘制人数
- (void)playerCountEsp:(int)count
{
    [self drawTextWithText:string_format("%d", count)
                       pos:ImVec2(SCREEN_WIDTH * 0.5, 25)
                isCentered:true
                   color:Color::White
                   outline:true
                  fontSize:33];
}
//绘制雪条
- (void)hpBarEsp:(JFPlayer *)player
{
    //血条
    float rate = 1.0f * player.hp / player.maxHp;
    float width = 100;
    float height = 1.5;
    float x = CGRectGetMidX(player.box) - width * 0.5;
    float y = CGRectGetMinY(player.box) - height - 7;
    
    ImVec2 vec[3];
    vec[0] = ImVec2(x+45,y+2);
    vec[1] = ImVec2(x+50,y+7);
    vec[2] = ImVec2(x+55,y+2);
    Color colorT = Color::Red;
    colorT.a = 0.5 * 255;
    
    ImGui::GetBackgroundDrawList()->AddConvexPolyFilled(vec, 3, [self getImU32:colorT]);
    
    Color color = Color::White;
    
    if (rate < 0.35) {

        color = Color::Red;

    } else if (rate < 0.75) {

        color = Color::Orange;
        
    }

    color.a = 0.7*255;

    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(width * rate, height) color:Color::White];
    
}
//信息
- (void)textEsp:(JFPlayer *)player distanceColor:(Color)distanceColor
{
    float width = 100;//50 左右
    float height = 14;//14//高度
    float x = CGRectGetMidX(player.box) - width * 0.5;
    float y = CGRectGetMinY(player.box) - height - 10;

    Color colorTeamNumber =Color::rrtt;
    Color colorTeam =Color::Red;
    float teamNoWidth = 20;
    
    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(width, height) color:colorTeam];
    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(teamNoWidth, height) color:colorTeamNumber];

    [self drawTextWithText:string_format("%d", player.teamNo)
                                                              pos:ImVec2(x + teamNoWidth * 0.5, y)
                isCentered:true
                     color:Color::White
                   outline:false
                  fontSize:13];
    
    string name = string_format("%s", player.name.c_str());
    if (player.isAI) {
        name.append("[AI]");
    }

        [self drawTextWithText:name
                       pos:ImVec2(x + teamNoWidth + 3, y + 0)
                isCentered:false
                     color:Color::White
                   outline:false
                  fontSize:13];
        string distance = string_format("[%dM]", player.distance);
        ImVec2 distanceSize = _espFont->CalcTextSizeA(10, MAXFLOAT, 0.0f, distance.c_str());
        [self drawTextWithText:distance
            pos:ImVec2(CGRectGetMidX(player.box), y - distanceSize.y)
                    isCentered:true
                      color:Color::Yellow
                       outline:false
                      fontSize:13];
    }

- (void)boneEsp:(JFPlayer *)player
{
   //骨骼颜色
    Color invisibleColor = Color::Yellow;
    Color visibleColor = Color::Red;

    float thicknes = 0.1;

    [self drawCircleWithCenter:ImVec2(player.boneData.head.X, player.boneData.head.Y) radius:CGRectGetWidth(player.box) * 0.15f color:player.boneVisibleData.head ? visibleColor : invisibleColor numSegments:15 thicknes:thicknes];
    
    [self drawLineWithStartPoint:ImVec2(player.boneData.chest.X, player.boneData.chest.Y) endPoint:ImVec2(player.boneData.pelvis.X, player.boneData.pelvis.Y) color:player.boneVisibleData.chest ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.chest.X, player.boneData.chest.Y) endPoint:ImVec2(player.boneData.leftShoulder.X, player.boneData.leftShoulder.Y) color:player.boneVisibleData.chest ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.chest.X, player.boneData.chest.Y) endPoint:ImVec2(player.boneData.rightShoulder.X, player.boneData.rightShoulder.Y) color:player.boneVisibleData.chest ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.leftShoulder.X, player.boneData.leftShoulder.Y) endPoint:ImVec2(player.boneData.leftElbow.X, player.boneData.leftElbow.Y) color:player.boneVisibleData.leftShoulder ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.rightShoulder.X, player.boneData.rightShoulder.Y) endPoint:ImVec2(player.boneData.rightElbow.X, player.boneData.rightElbow.Y) color:player.boneVisibleData.rightShoulder ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.pelvis.X, player.boneData.pelvis.Y) endPoint:ImVec2(player.boneData.leftThigh.X, player.boneData.leftThigh.Y) color:player.boneVisibleData.pelvis ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.pelvis.X, player.boneData.pelvis.Y) endPoint:ImVec2(player.boneData.rightThigh.X, player.boneData.rightThigh.Y) color:player.boneVisibleData.pelvis ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.leftElbow.X, player.boneData.leftElbow.Y) endPoint:ImVec2(player.boneData.leftHand.X, player.boneData.leftHand.Y) color:player.boneVisibleData.leftElbow ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.rightElbow.X, player.boneData.rightElbow.Y) endPoint:ImVec2(player.boneData.rightHand.X, player.boneData.rightHand.Y) color:player.boneVisibleData.rightElbow ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.leftThigh.X, player.boneData.leftThigh.Y) endPoint:ImVec2(player.boneData.leftKnee.X, player.boneData.leftKnee.Y) color:player.boneVisibleData.leftThigh ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.rightThigh.X, player.boneData.rightThigh.Y) endPoint:ImVec2(player.boneData.rightKnee.X, player.boneData.rightKnee.Y) color:player.boneVisibleData.rightThigh ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.leftKnee.X, player.boneData.leftKnee.Y) endPoint:ImVec2(player.boneData.leftFoot.X, player.boneData.leftFoot.Y) color:player.boneVisibleData.leftKnee ? visibleColor : invisibleColor thicknes:thicknes];
    [self drawLineWithStartPoint:ImVec2(player.boneData.rightKnee.X, player.boneData.rightKnee.Y) endPoint:ImVec2(player.boneData.rightFoot.X, player.boneData.rightFoot.Y) color:player.boneVisibleData.rightKnee ? visibleColor : invisibleColor thicknes:thicknes];
}


- (void)drawAimRangeWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments thicknes:(float)thicknes
{
    ImGui::GetOverlayDrawList()->AddCircle(center, radius, [self getImU32:color], numSegments, thicknes);
}
- (void)drawLineWithStartPoint:(ImVec2)startPoint endPoint:(ImVec2)endPoint color:(Color)color thicknes:(float)thicknes
{
    ImGui::GetBackgroundDrawList()->AddLine(startPoint, endPoint, [self getImU32:color], thicknes);
}

- (void)drawCircleWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments thicknes:(float)thicknes
{
    ImGui::GetBackgroundDrawList()->AddCircle(center, radius, [self getImU32:color], numSegments, thicknes);
}

- (void)drawCircleFilledWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments
{
    ImGui::GetBackgroundDrawList()->AddCircleFilled(center, radius, [self getImU32:color], numSegments);
}
- (void)drawTextWithText:(string)text pos:(ImVec2)pos isCentered:(bool)isCentered color:(Color)color outline:(bool)outline fontSize:(float)fontSize
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    if (isCentered) {
        ImVec2 textSize = _espFont->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = [self getImU32:Color::Red];//
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, vec2, [self getImU32:color], str);
}

- (void)drawRectWithPos:(ImVec2)pos size:(ImVec2)size color:(Color)color thicknes:(float)thicknes
{
    ImGui::GetBackgroundDrawList()->AddRect(pos, ImVec2(pos.x + size.x, pos.y + size.y), [self getImU32:color], 0, 0, thicknes);
}

- (void)drawRectFilledWithPos:(ImVec2)pos size:(ImVec2)size color:(Color)color
{
    ImGui::GetBackgroundDrawList()->AddRectFilled(pos, ImVec2(pos.x + size.x, pos.y + size.y), [self getImU32:color], 0, 0);
}

- (ImU32)getImU32:(Color)color
{
    return ((color.a & 0xff) << 24) + ((color.b & 0xff) << 16) + ((color.g & 0xff) << 8) + (color.r & 0xff);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

@end
