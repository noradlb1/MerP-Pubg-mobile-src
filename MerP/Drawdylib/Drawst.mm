

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

#import "baidu_font.h"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define kScale [UIScreen mainScreen].scale
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

@interface JFOverlayView () <GuiRendererDelegate> {
    ImFont *_espFont;
}

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) GuiRenderer *renderer;

@end

@implementation JFOverlayView

#pragma mark - 菜单开关字符串
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
        self.isAimbot = false;
        self.isNorecoil = false;
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
        self.propsDistance = 300;
        self.aimbotPart = 4;
        self.aimbotRadius = 50;
        self.espDistance = 300;
        
        [self setupUI];
    }
    return self;
}

#pragma mark
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

#pragma mark -
- (void)setup
{
    ImGui::StyleColorsDark();
    ImGuiIO & io = ImGui::GetIO();
    ImFontConfig config;
    config.FontDataOwnedByAtlas = false;
   
    NSString *fontPath = @"/System/Library/Fonts/LanguageSupport/PingFang.ttc";
    _espFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 24.f, &config, io.Fonts->GetGlyphRangesChineseFull());
    

}

- (void)draw
{
    [self drawOverlay];
    [self drawMenu];
}

#pragma mark

- (void)drawMenu
{
    self.userInteractionEnabled = self.isShowMenu;
    self.mtkView.userInteractionEnabled = self.isShowMenu;
    if (!_isShowMenu) return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = SCREEN_WIDTH * 0.5;
        CGFloat height = SCREEN_HEIGHT * 0.7;
        if (SCREEN_WIDTH > SCREEN_HEIGHT) {

            height = SCREEN_HEIGHT * 0.5;
        } else {
            // 竖屏
            width = SCREEN_WIDTH * 0.7;
        }
       
        ImGuiIO & io = ImGui::GetIO();
       
    
        io.DisplaySize = ImVec2(width, height);
        ImGui::SetNextWindowPos(ImVec2((SCREEN_WIDTH - width) * 0.5, (SCREEN_HEIGHT - height) * 0.5), 0, ImVec2(0, 0));
        ImGui::SetNextWindowSize(ImVec2(io.DisplaySize.x, io.DisplaySize.y));
        io.FontGlobalScale = 0.5f;
       
      
        


    });

    
    ImGui::Begin("LASSiosDEV ~ ESP 2.1.0", &_isShowMenu, ImGuiWindowFlags_NoCollapse);
    if (ImGui::BeginTabBar("LASS", ImGuiTabBarFlags_NoTooltip))
    {
             {
               ImGui::TextColored(ImColor(16, 43, 106), "Esp-Enemies");
               ImGui::Checkbox("Esp On", &_isStartTimer); ImGui::SameLine();
               ImGui::Checkbox("Box", &_isBoxEsp); ImGui::SameLine();
               ImGui::Checkbox("Line", &_isLineEsp); ImGui::SameLine();
               ImGui::Checkbox("Bone", &_isBoneEsp);
               ImGui::Checkbox("Info", &_isTextEsp); ImGui::SameLine();
               ImGui::Checkbox("HP", &_isHpBarEsp);
              ImGui::Separator();                              ImGui::TextColored(ImColor(16, 43, 106), "Esp-Items");
               ImGui::Checkbox("Items On", &_isShowProps); ImGui::SameLine();
               ImGui::Checkbox("Vehicle", &_isShowPropsVehicle); ImGui::SameLine();
               ImGui::Checkbox("Weapon", &_isShowPropsWeapon); ImGui::SameLine();
               ImGui::Checkbox("Armor", &_isShowPropsArmor);
               ImGui::Checkbox("Sight", &_isShowPropsSight); ImGui::SameLine();
               ImGui::Checkbox("Accessory", &_isShowPropsAccessory); ImGui::SameLine();
               ImGui::Checkbox("Bullet", &_isShowPropsBullet); ImGui::SameLine();
               ImGui::Checkbox("Drug", &_isShowPropsDrug);
               ImGui::Checkbox("EarlyWarning", &_isShowPropsEarlyWarning); ImGui::SameLine();
               ImGui::Checkbox("BoxWith", &_BoxWith); ImGui::SameLine();
               ImGui::Checkbox("BPc", &_BPc); ImGui::SameLine();
               ImGui::Checkbox("Pistol", &_Pistol);            
      ImGui::Separator();

ImGui::TextColored(ImColor(16, 43, 106), "Aim");


                ImGui::Checkbox("Aimbot", &_isAimbot);
  ImGui::SameLine();              ImGui::Checkbox("DeathNotAim", &_isNearDeathNotAim);  
                ImGui::RadioButton("Head", &_aimbotPart, 6); ImGui::SameLine();
                ImGui::RadioButton("Neck", &_aimbotPart, 5); ImGui::SameLine();
                ImGui::RadioButton("Chest", &_aimbotPart, 4); ImGui::SameLine();
                ImGui::RadioButton("Foot", &_aimbotPart, 1); 
 ImGui::Separator(); 
             
ImGui::SliderInt("EspDistance", &_espDistance, 0, 500);
ImGui::SliderInt("ItemsDistance", &_propsDistance, 0, 500);              ImGui::SliderInt("AimBotRadius", &_aimbotRadius, 0, 300);

                ImGui::Separator();
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

    if (self.isAimbot || self.isBulletTrack) {
        
        [self drawAimRangeWithCenter:ImVec2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5) radius:self.aimbotRadius color:Color::Green numSegments:80 thicknes:1];
    }
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
            if (player.isVisible) {
                color = Color::Green;
            } else {
                color = Color::Red;
            }
        }

        if (player.type == PlayerTypeEnemy && player.isFallDown) {
            color = Color::Xue2;
        }
 
        if ((self.isAimbot || self.isBulletTrack) && player.isBestAimTarget) {

         [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5,SCREEN_HEIGHT * 0.5)                                endPoint:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) color:Color::Blue thicknes:0.1];
            
            [self drawCircleFilledWithCenter:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) radius:3 color:Color::Blue numSegments:20];
        }

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

            [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5, 45) endPoint:ImVec2(CGRectGetMidX(player.box), CGRectGetMinY(player.box) - offset) color:color thicknes:0.05];
        }

        if (self.isBoneEsp) {
            [self boneEsp:player];
        }
    }

    for (JFProps *props in [IFuckYou getInstance].propsList) {
  
        if (props.type == PropsTypeWeapon && self.isShowPropsWeapon) {
            [self propsEsp:props color:Color::Red];
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

        if (props.type == PropsTypeVehicle && self.isShowPropsVehicle) {
            [self propsEsp:props color:Color::Green];
        }
  
        if (props.type == PropsTypeEarlyWarning && self.isShowPropsEarlyWarning) {
            
            [self propsEsp:props color:Color::Red];

            if (props.distance <= 10) {

                /*[self drawTextWithText:props.name pos:ImVec2(SCREEN_WIDTH * 0.5, 65) isCentered:true color:Color::Red outline:true fontSize:25 filled:false colorFilled:ImColor(0,0,0,0)];*/

                [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5, 50) endPoint:ImVec2(props.screenPos.X, props.screenPos.Y) color:Color::Blue thicknes:0.1];
            }
        }
    }
    
}
#pragma mark
- (void)propsEsp:(JFProps *)props color:(Color)color
{
    [self drawTextWithText:string_format("%s [%dm]", props.name.c_str(), props.distance)
                       pos:ImVec2(props.screenPos.X, props.screenPos.Y)
                isCentered:false
                     color:color
                   outline:true
                  fontSize:15
                    filled:false
               colorFilled:ImColor(0,0,0,0)];
}

- (void)playerCountEsp:(int)count
{
    [self drawTextWithText:string_format("Players Around [%d]", count)
                       pos:ImVec2(SCREEN_WIDTH * 0.5, 25)
                isCentered:true
                     color:Color::Red
                   outline:true
                  fontSize:20
                    filled:false
               colorFilled:ImColor(0,0,0,0)];
}

- (void)hpBarEsp:(JFPlayer *)player
{
    //血条
    float rate = 1.0f * player.hp / player.maxHp;
    float width = 50;
    float height = 2.0;
    float x = CGRectGetMidX(player.box) - width * 0.5;
    float y = CGRectGetMinY(player.box) - height - 0;
    
    Color color = Color::White;

    if (rate < 0.35) {
        color = Color::Red;
    } else if (rate < 0.75) {
        color = Color::Orange;
    }

    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(width * rate, height) color:color];//

}

- (void)textEsp:(JFPlayer *)player distanceColor:(Color)distanceColor
{//信息
    float width = 50;
    float height = 5;
    float x = CGRectGetMidX(player.box) - width * 0.5;
    float y = CGRectGetMinY(player.box) - height - 8;
    
    //float teamNoWidth = 40;
    string teamNoText = string_format("%d", player.teamNo);
    const char *strTeamNoText = teamNoText.c_str();
    ImVec2 teamNoWidth = _espFont->CalcTextSizeA(11, MAXFLOAT, 0.0f, strTeamNoText);
    
    ImColor nameColor = ImColor(0,0,0,190);
    string name = string_format("%s", player.name.c_str());
    if (player.isAI) {
        name = "  BOT     ";
        nameColor = ImColor(0,0,0,190);
    }
    
    name += string_format("   %dM", player.distance);
    string nameText = string_format("%s", name.c_str());
    const char *strNameText = nameText.c_str();
    ImVec2 nameWidth = _espFont->CalcTextSizeA(11, MAXFLOAT, 0.0f, strNameText);
    
    x -= ((teamNoWidth.x + nameWidth.x + 12) * 0.5f) - SCREEN_WIDTH * 0.026f;
    
    
    [self drawTextWithText:string_format("%d", player.teamNo)
                       pos:ImVec2(x + 0, y + 0)
                isCentered:false
                     color:Color::White
                   outline:false
                  fontSize:11
                    filled:true
               colorFilled:ImColor(0,0,0,190)];

        [self drawTextWithText:name
                       pos:ImVec2(x + teamNoWidth.x + 6, y + 0)
                isCentered:false
                     color:Color::Yellow
                   outline:false
                  fontSize:11
                    filled:true
               colorFilled:nameColor];
        /*string distance = string_format("[ %dm ]", player.distance);
        ImVec2 distanceSize = _espFont->CalcTextSizeA(10, MAXFLOAT, 0.0f, distance.c_str());
        [self drawTextWithText:distance
                           pos:ImVec2(CGRectGetMidX(player.box), y - distanceSize.y-7)
                    isCentered:true
                         color:Color::Red
                       outline:false
                      fontSize:14
                        filled:false
                   colorFilled:ImColor(0,0,0,0)];*/
    }

- (void)boneEsp:(JFPlayer *)player
{

    Color invisibleColor = Color::Red;
    Color visibleColor = Color::Green;

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

- (void)drawTextWithText:(string)text pos:(ImVec2)pos isCentered:(bool)isCentered color:(Color)color outline:(bool)outline fontSize:(float)fontSize filled:(bool)filled colorFilled:(ImColor)colorFilled
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    if (isCentered) {
        ImVec2 textSize = _espFont->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = [self getImU32:Color::Black];//
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    if (filled) {
        ImGui::GetBackgroundDrawList()->AddRectFilled(ImVec2(vec2.x-3,vec2.y-3), ImVec2(vec2.x + _espFont->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str).x + 3, vec2.y + 12), colorFilled, 0, 0);
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
