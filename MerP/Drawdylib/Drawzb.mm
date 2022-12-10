#import "Drawzb.h"
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <stdio.h>
#import <string>

#import "JFCommon.h"
#import "Drawlm.h"
#import "JFPlayerPool.h"
#import "Drawdk.h"
#import "JFPropsPool.h"
#import "utf.h"

using namespace std;

kaddr module;
kaddr localPlayerController;
kaddr controlRotation;
MinimalViewInfo POV;
kaddr ownerShootWeapon;

namespace Offsets {
    
    kaddr LineOfSightTo_Func = 0x104A04444;
}

#pragma mark
bool IsValidAddress(kaddr addr) {
    return addr > 0x100000000 && addr < 0x2000000000;
}

bool _read(kaddr addr, void *buffer, int len)
{
    if (!IsValidAddress(addr)) return false;
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != len)
    {
        return false;
    }
    return true;
}

bool _write(kaddr addr, void *buffer, int len)
{
    if (!IsValidAddress(addr)) return false;
    kern_return_t error = vm_write(mach_task_self(), (vm_address_t)addr, (vm_offset_t)buffer, (mach_msg_type_number_t)len);
    if(error != KERN_SUCCESS)
    {
        return false;
    }
    return true;
}

kaddr GetRealOffset(kaddr offset) {
    if (module == 0) {
        return 0;
    }
    return (module + offset);
}

template<typename T> T Read(kaddr address) {
    T data;
    _read(address, reinterpret_cast<void *>(&data), sizeof(T));
    return data;
}

template<typename T> void Write(kaddr address, T data) {
    _write(address, reinterpret_cast<void *>(&data), sizeof(T));
}

template<typename T> T *ReadArr(kaddr address, unsigned int size) {
    T data[size];
    T *ptr = data;
    _read(address, reinterpret_cast<void *>(ptr), (sizeof(T) * size));
    return ptr;
}

string ReadStr2(kaddr address, unsigned int size) {
    string name(size, '\0');
    _read(address, (void *) name.data(), size * sizeof(char));
    name.shrink_to_fit();
    return name;
}

kaddr GetPtr(kaddr address) {
    return Read<kaddr>(address);
}

string getUEString(kaddr address) {
    unsigned int MAX_SIZE = 100;
    
    string uestring(ReadStr2(address, MAX_SIZE));
    uestring.shrink_to_fit();
    
    return uestring;
}


string GetFName(kaddr actorAddress) {
    UInt32 FNameID = Read<UInt32>(actorAddress + 0x18);
    
    kaddr gname_1 = GetRealOffset(0x103A56E94);
    kaddr gname_2 = GetRealOffset(0x107E3CB10);
    auto TNameEntryArray = reinterpret_cast<long(__fastcall*)(kaddr)>(gname_1)(gname_2);
    
    
    kaddr FNameEntryArr = GetPtr(TNameEntryArray + ((FNameID / 0x4000) * 8));
    kaddr FNameEntry = GetPtr(FNameEntryArr + ((FNameID % 0x4000) * 8));
    return getUEString(FNameEntry + 0xc);
}

#pragma mark
bool isEqual(string s1, const char* check) {
    string s2(check);
    return (s1 == s2);
}

bool isEqual(string s1, string s2) {
    return (s1 == s2);
}

bool isContain(string str, const char* check) {
    size_t found = str.find(check);
    return (found != string::npos);
}

#pragma mark
bool isPlayer(string FName) {
    return isContain(FName, "BP_TrainPlayerPawn") || isContain(FName, "BP_PlayerPawn");
}


string getVehicleWithFName(string FName) {
    if (isContain(FName, "VH_Scooter_")) {
        return "Scooter";
    }
    if (isContain(FName, "VH_Dacia_")) {
        return "Dacia";
    }
    if (isContain(FName, "VH_Motorcycle_")) {
        return "Motorcycle";
    }
    if (isContain(FName, "VH_MotorcycleCart_")) {
        return "MotorcycleCart";
    }
    if (isContain(FName, "BP_VH_Tuk_")) {
        return "Tuk";
    }
    if (isContain(FName, "BP_VH_Buggy_")) {
        return "Buggy";
    }
    if (isContain(FName, "PickUp_0")) {
        return "PickUp";
    }
    if (isContain(FName, "Mirado_")) {
        return "Mirado";
    }
    if (isContain(FName, "VH_MiniBus_")) {
        return "MiniBus";
    }
    if (isContain(FName, "VH_BRDM_")) {
        return "BRDM";
    }
    if (isContain(FName, "VH_UAZ")) {
        return "UAZ";
    }


     if (isContain(FName, "VH_MonsterTruck_")) {
        return "Monster Truck";
    }  
    
    return "";//VH_MiniBus_
}


string getWeaponWithFName(string FName) {
    if (isContain(FName, "BP_Rifle_VAL_Wrapper_C")) {
        return "VAL";
    }
    if (isContain(FName, "BP_Rifle_AKM_Wrapper_C")) {
        return "AKM";
    }
    if (isContain(FName, "BP_Rifle_M416_Wrapper_C")) {
        return "M416";
    }
    if (isContain(FName, "BP_Rifle_M762_Wrapper_C")) {
        return "M762";
    }

    if (isContain(FName, "BP_Rifle_SCAR_Wrapper_C")) {
        return "SCAR";
    }
    if (isContain(FName, "BP_Rifle_QBZ_Wrapper_C")) {
        return "QBZ";
    }
    if (isContain(FName, "BP_Sniper_Kar98k_Wrapper_C")) {
        return "Kar98k";
    }
    if (isContain(FName, "BP_Sniper_Mini14_Wrapper_C")) {
        return "Mini14";
    }

   if (isContain(FName, "BP_Sniper_SKS_Wrapper_C")) {
        return "SKS";
    }

    if (isContain(FName, "BP_Sniper_M24_Wrapper_C")) {
        return "M24";
    }

    if (isContain(FName, "BP_MachineGun_UMP9_Wrapper_C")) {
        return "UMP45";
    }

    if (isContain(FName, "BP_MachineGun_Uzi_Wrapper_C")) {
        return "UZI";
    }

    if (isContain(FName, "BP_MachineGun_Vector_Wrapper_C")) {
        return "Vector";
    }

    if (isContain(FName, "BP_SMG_Thompson SMG_Wrapper_C")) {
        return "Tomygun";
    }


    return "";
}

string getArmorWithFName(string FName) {
    if (isContain(FName, "PickUp_BP_Helmet_Lv2_C") || isEqual(FName, "PickUp_BP_Helmet_Lv2_A_C") || isEqual(FName, "PickUp_BP_Helmet_Lv2_B_C")) {
        return "Helmet Lv 2";
    }
    if (isContain(FName, "PickUp_BP_Armor_Lv2_C") || isEqual(FName, "PickUp_BP_Armor_Lv2_A_C") || isEqual(FName, "PickUp_BP_Armor_Lv2_B_C")) {
        return "Armor Lv 2";
    }
    if (isContain(FName, "PickUp_BP_Bag_Lv2_C") || isEqual(FName, "PickUp_BP_Bag_Lv2_A_C") || isEqual(FName, "PickUp_BP_Bag_Lv2_B_C")) {
        return "Bag Lv2";
    }
    if (isContain(FName, "PickUp_BP_Helmet_Lv3_C") || isEqual(FName, "PickUp_BP_Helmet_Lv3_A_C") || isEqual(FName, "PickUp_BP_Helmet_Lv3_B_C")) {
        return "Helmet Lv3";
    }
    if (isContain(FName, "PickUp_BP_Armor_Lv3_C") || isEqual(FName, "PickUp_BP_Armor_Lv3_A_C") || isEqual(FName, "PickUp_BP_Armor_Lv3_B_C")) {
        return "Armor Lv 3";
    }
    return "";
}


string getSightWithFName(string FName) {
    if (isContain(FName, "BP_MZJ_3X_Pickup_C")) {
        return "3X";//PickUpListWrapperActor
    }
    if (isContain(FName, "BP_MZJ_4X_Pickup_C")) {
        return "4X";
    }
    
    if (isContain(FName, "BP_MZJ_6X_Pickup_C")) {
        return "6X";
    }


    if (isContain(FName, "BP_MZJ_8X_Pickup_C")) {
        return "8X";
    }

   if (isContain(FName, "BP_MZJ_2X_Pickup_C")) {
        return "2X";
    }

    return "";
}


string getAccessoryWithFName(string FName) {
    if (isContain(FName, "BP_QK_Mid_Compensator_Pickup_C")) {
        return "Compensator";
    }
    if (isContain(FName, "BP_QK_Large_Compensator_Pickup_C")) {
        return "Compensator";
    }
    if (isContain(FName, "BP_QT_UZI_Pickup_C")) {
        return "7";
    }
    
    
    if (isContain(FName, "BP_WB_LightGrip_Pickup_C")) {
        return "LightGrip";
    }
    return "";
}

string getBulletWithFName(string FName) {
    if (isContain(FName, "BP_Ammo_762mm_Pickup_C")) {
        return "7.62mm";
    }
    if (isContain(FName, "BP_Ammo_556mm_Pickup_C")) {
        return "5.56mm";
    }
    return "";
}

string getDrugWithFName(string FName) {
    if (isContain(FName, "Injection_Pickup_C")) {
        return "Injection";
    }
    if (isContain(FName, "Firstaid_Pickup_C")) {
        return "Firstaid";
    }
    
    return "";
}

string getBoxWithFName(string FName) {
    if (isContain(FName, "PickUpListWrapperActor")) {
        return "AirDropBox";
    }
    return "";
}



string getWrapperWithFName(string FName) {
    if (isContain(FName, "BP_Pistol_Flaregun_Wrapper_C")) {
        return "Flaregun";
    }
    return "";
}

string getEarlyWarningWithFName(string FName) {
    if (isContain(FName, "ProjGrenade_BP_C")) {
        return "Grenade";
    }
    return "";
}

#pragma mark
Vector3 MatrixToVector(FMatrix matrix) {
    return Vector3(matrix[3][0], matrix[3][1], matrix[3][2]);
}

FMatrix MatrixMulti(FMatrix m1, FMatrix m2) {
    FMatrix matrix = FMatrix();
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                matrix[i][j] += m1[i][k] * m2[k][j];
            }
        }
    }
    return matrix;
}

FMatrix TransformToMatrix(FTransform transform) {
    FMatrix matrix;
    
    matrix[3][0] = transform.Translation.X;
    matrix[3][1] = transform.Translation.Y;
    matrix[3][2] = transform.Translation.Z;
    
    float x2 = transform.Rotation.x + transform.Rotation.x;
    float y2 = transform.Rotation.y + transform.Rotation.y;
    float z2 = transform.Rotation.z + transform.Rotation.z;
    
    float xx2 = transform.Rotation.x * x2;
    float yy2 = transform.Rotation.y * y2;
    float zz2 = transform.Rotation.z * z2;
    
    matrix[0][0] = (1.0f - (yy2 + zz2)) * transform.Scale3D.X;
    matrix[1][1] = (1.0f - (xx2 + zz2)) * transform.Scale3D.Y;
    matrix[2][2] = (1.0f - (xx2 + yy2)) * transform.Scale3D.Z;
    
    float yz2 = transform.Rotation.y * z2;
    float wx2 = transform.Rotation.w * x2;
    matrix[2][1] = (yz2 - wx2) * transform.Scale3D.Z;
    matrix[1][2] = (yz2 + wx2) * transform.Scale3D.Y;
    
    float xy2 = transform.Rotation.x * y2;
    float wz2 = transform.Rotation.w * z2;
    matrix[1][0] = (xy2 - wz2) * transform.Scale3D.Y;
    matrix[0][1] = (xy2 + wz2) * transform.Scale3D.X;
    
    float xz2 = transform.Rotation.x * z2;
    float wy2 = transform.Rotation.w * y2;
    matrix[2][0] = (xz2 + wy2) * transform.Scale3D.Z;
    matrix[0][2] = (xz2 - wy2) * transform.Scale3D.X;
    
    matrix[0][3] = 0;
    matrix[1][3] = 0;
    matrix[2][3] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}

FMatrix RotatorToMatrix(FRotator rotation) {
    float radPitch = rotation.Pitch * ((float) M_PI / 180.0f);
    float radYaw = rotation.Yaw * ((float) M_PI / 180.0f);
    float radRoll = rotation.Roll * ((float) M_PI / 180.0f);
    
    float SP = sinf(radPitch);
    float CP = cosf(radPitch);
    float SY = sinf(radYaw);
    float CY = cosf(radYaw);
    float SR = sinf(radRoll);
    float CR = cosf(radRoll);
    
    FMatrix matrix;
    
    matrix[0][0] = (CP * CY);
    matrix[0][1] = (CP * SY);
    matrix[0][2] = (SP);
    matrix[0][3] = 0;
    
    matrix[1][0] = (SR * SP * CY - CR * SY);
    matrix[1][1] = (SR * SP * SY + CR * CY);
    matrix[1][2] = (-SR * CP);
    matrix[1][3] = 0;
    
    matrix[2][0] = (-(CR * SP * CY + SR * SY));
    matrix[2][1] = (CY * SR - CR * SP * SY);
    matrix[2][2] = (CR * CP);
    matrix[2][3] = 0;
    
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}

Vector2 WorldToScreen(Vector3 worldLocation, MinimalViewInfo camViewInfo, int width, int height) {
    FMatrix tempMatrix = RotatorToMatrix(camViewInfo.Rotation);
    
    Vector3 vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
    Vector3 vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
    Vector3 vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);
    
    Vector3 vDelta = worldLocation - camViewInfo.Location;
    
    Vector3 vTransformed(Vector3::Dot(vDelta, vAxisY), Vector3::Dot(vDelta, vAxisZ), Vector3::Dot(vDelta, vAxisX));
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }
    
    float fov = camViewInfo.FOV;
    float screenCenterX = (width / 2.0f);
    float screenCenterY = (height / 2.0f);
    
    return Vector2(
                   (screenCenterX + vTransformed.X * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z),
                   (screenCenterY - vTransformed.Y * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z)
                   );
}

#pragma mark
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[IFuckYou getInstance] entry];
    });
}

__attribute__((constructor)) static void initialize()
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
}

#pragma mark
@interface IFuckYou ()

@property (nonatomic, strong) NSTimer *dataTimer;
@property (nonatomic, strong) NSTimer *actionTimer;

@end

@implementation IFuckYou

- (instancetype)init
{
    if (self = [super init]) {
        self.playerList = [NSMutableArray array];
        self.propsList = [NSMutableArray array];
        self.playerPool = [[JFPlayerPool alloc] init];
        self.propsPool = [[JFPropsPool alloc] init];
        
        self.localPlayer = [self.playerPool getObjFromPool];
        self.localPlayer.type = PlayerTypeMyself;
    }
    return self;
}

static IFuckYou *instance = nil;

+ (IFuckYou *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (id)allocWithZone:(struct _NSZone*)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark
- (void)entry
{
    module = (kaddr)_dyld_get_image_vmaddr_slide(0);
    if (!self.floatingMenuView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
        [[UIApplication sharedApplication].keyWindow addSubview:self.floatingMenuView];
    }
    [self startFuckYou];
}

- (void)startFuckYou
{
    [self cancelTimer];
    self.dataTimer = [NSTimer timerWithTimeInterval:1.0f/60 target:self selector:@selector(readData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.dataTimer forMode:NSRunLoopCommonModes];
    
    self.actionTimer = [NSTimer timerWithTimeInterval:1.0f/60 target:self selector:@selector(localPlayerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.actionTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTimer
{
    if (self.dataTimer) {
        [self.dataTimer invalidate];
        self.dataTimer = nil;
    }
    if (self.actionTimer) {
        [self.actionTimer invalidate];
        self.actionTimer = nil;
    }
    [self recyclePlayer];
}

- (void)recyclePlayer
{
    for (JFPlayer *player in self.playerList) {
        [self.playerPool putObj2Pool:player];
    }
    [self.playerList removeAllObjects];
    
    for (JFProps *props in self.propsList) {
        [self.propsPool putObj2Pool:props];
    }
    [self.propsList removeAllObjects];
}

#pragma mark
- (void)readData
{
    if (!self.overlayView.isStartTimer) {
        return;
    }
    [self recyclePlayer];
    
    if (![self readLocalPlayerInfo]) return;
    
    kaddr gworld_1 = GetRealOffset(0x102517D5C);
    kaddr gworld_2 = GetRealOffset(0x1081C6318);
    auto GWorld = reinterpret_cast<long(__fastcall*)(kaddr)>(gworld_1)(gworld_2);
    
    auto ULevel = GetPtr(GWorld + 0x30);
    auto ActorArray = GetPtr(ULevel + 0xA0);
    auto ActorCount = Read<int>(ULevel + 0xA8);
    
    for (int i = 0; i < ActorCount; i++) {
        kaddr base = GetPtr(ActorArray + i * 8);
        if (!IsValidAddress(base) || base == self.localPlayer.base) continue;
        
        string FName = GetFName(base);
        if (FName.empty()) continue;
        
        if (isPlayer(FName)) {
            JFPlayer *player = [self.playerPool getObjFromPool];
            player.base = base;
            
            if ([self readPlayerInfo:player]) {
                if (self.localPlayer.teamNo == player.teamNo) {
                    player.type = PlayerTypeTeam;
                } else {
                    player.type = PlayerTypeEnemy;
                }
                [self.playerList addObject:player];
            } else {
                [self.playerPool putObj2Pool:player];
            }
        } else {
            if (!self.overlayView.isShowProps) continue;
            
            string name;
            PropsType type = PropsTypeNone;
#pragma mark
            
            if (self.overlayView.isShowPropsEarlyWarning && !((name = getEarlyWarningWithFName(FName)).empty())) {
                
                type = PropsTypeEarlyWarning;
            } else if (self.overlayView.isShowPropsVehicle && !((name = getVehicleWithFName(FName)).empty())) {
                type = PropsTypeVehicle;
            } else if (self.overlayView.isShowPropsWeapon && !((name = getWeaponWithFName(FName)).empty())) {
                type = PropsTypeWeapon;
            } else if (self.overlayView.isShowPropsArmor && !((name = getArmorWithFName(FName)).empty())) {
                type = PropsTypeArmor;
            } else if (self.overlayView.isShowPropsSight && !((name = getSightWithFName(FName)).empty())) {
                type = PropsTypeSight;
            } else if (self.overlayView.isShowPropsAccessory && !((name = getAccessoryWithFName(FName)).empty())) {
                type = PropsTypeAccessory;
            } else if (self.overlayView.isShowPropsBullet && !((name = getBulletWithFName(FName)).empty())) {
                type = PropsTypeBullet;
            } else if (self.overlayView.isShowPropsDrug && !((name = getDrugWithFName(FName)).empty())) {
                type = PropsTypeDrug;
                
            } else if (self.overlayView.BoxWith && !((name = getBoxWithFName(FName)).empty())) {
                type = PickUpListWrapperActor;
                
            } else if (self.overlayView.Pistol && !((name = getWrapperWithFName(FName)).empty())) {
                type = Flaregun;
                
            }
            
            
            if (name.empty() || type == PropsTypeNone) {
                continue;
            }
            
            JFProps *props = [self.propsPool getObjFromPool];
            props.base = base;
            props.name = name;
            props.type = type;
            
            auto rootComponent = GetPtr(props.base + 0x1b8);
            if (IsValidAddress(rootComponent)) {
                props.worldPos = Read<Vector3>(rootComponent + 0x160);
                props.distance = Vector3::Distance(props.worldPos, POV.Location) / 100.0f;
                if (props.distance > self.overlayView.propsDistance) {
                    [self.propsPool putObj2Pool:props];
                    continue;
                }
                
                props.screenPos = WorldToScreen(props.worldPos, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
                
                [self.propsList addObject:props];
            } else {
                [self.propsPool putObj2Pool:props];
            }
        }
    }
}
#pragma mark
- (bool)readLocalPlayerInfo
{
    kaddr gworld_1 = GetRealOffset(0x102517D5C);
    kaddr gworld_2 = GetRealOffset(0x1081C6318);
    auto GWorld = reinterpret_cast<long(__fastcall*)(kaddr)>(gworld_1)(gworld_2);
    
    auto NetDriver = GetPtr(GWorld + 0x38);
    auto ServerConnection = GetPtr(NetDriver + 0x78);
    localPlayerController = GetPtr(ServerConnection + 0x30);
    self.localPlayer.base = GetPtr(localPlayerController + 0x450);
    
    if (IsValidAddress(self.localPlayer.base)) {
        string FName = GetFName(self.localPlayer.base);
        if (FName.empty()) return false;
        
        if (isPlayer(FName)) {
            if ([self readPlayerInfo:self.localPlayer]) {
                self.isFire = Read<bool>(self.localPlayer.base + 0x14E8);
                auto weaponManagerComponent = GetPtr(self.localPlayer.base + 0x1e98);
                auto cachedCurUseWeapon = GetPtr(weaponManagerComponent + 0x2f0);
                auto shootWeaponComponent = GetPtr(cachedCurUseWeapon + 0xd68);
                ownerShootWeapon = GetPtr(shootWeaponComponent + 0x208);
            }
        } else {
            ownerShootWeapon = 0;
        }
    } else {
        self.localPlayer.base = 0;
    }
    
    auto playerCameraManager = GetPtr(localPlayerController + 0x470);
    POV = Read<MinimalViewInfo>(playerCameraManager + 0xff0 + 0x10);
    controlRotation = localPlayerController + 0x408;
    
    return IsValidAddress(localPlayerController) && IsValidAddress(playerCameraManager);
}

- (bool)readPlayerInfo:(JFPlayer *)player
{
    auto rootComponent = GetPtr(player.base + 0x1b8);
    if (IsValidAddress(rootComponent)) {
        player.worldPos = Read<Vector3>(rootComponent + 0x160);
        
        player.distance = Vector3::Distance(player.worldPos, POV.Location) / 100.0f;
        if (player.distance > self.overlayView.espDistance) return false;
    } else {
        return false;
    }
    
    player.hp = Read<float>(player.base + 0xcc8);
    
    player.maxHp = Read<float>(player.base + 0xccc);
    
    player.signalHP = Read<float>(player.base + 0xcd0);
    player.signalHPMax = Read<float>(player.base + 0xcdc);
    player.isFallDown = player.hp == 0;
    
    
    player.isDead = Read<bool>(player.base + 0xd0c);
    
    if (player.hp < 0 || player.hp > 100 ||
        player.maxHp != 100 ||
        player.hp > player.maxHp ||
        player.signalHP < 0 || player.signalHPMax > 100 ||
        player.signalHPMax != 100 ||
        player.signalHP > player.signalHPMax ||
        player.isDead) return false;
    
    auto nameAddr = GetPtr(player.base + 0x888);
    if (IsValidAddress(nameAddr)) {
        UTF8 name[32] = "";
        UTF16 buf16[16] = {0};
        _read(nameAddr, buf16, 28);
        Utf16_To_Utf8(buf16, name, 28, strictConversion);
        
        player.name = string((const char *)name);
    }
    
    player.playerKey = Read<UInt32>(player.base + 0x870);
    
    
    player.isAI = Read<bool>(player.base + 0x960);
    
    player.teamNo = Read<int>(player.base + 0x8d0);
    
    Vector2 topScreenPos = WorldToScreen(Vector3(player.worldPos.X, player.worldPos.Y, player.worldPos.Z + 100), POV, SCREEN_WIDTH, SCREEN_HEIGHT);
    Vector2 bottomScreenPos = WorldToScreen(Vector3(player.worldPos.X, player.worldPos.Y, player.worldPos.Z - 100), POV, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    float height = max<float>(bottomScreenPos.Y - topScreenPos.Y, 5.0f);
    float width = height * 0.5f;
    float x = topScreenPos.X - width * 0.5f;
    float y = topScreenPos.Y;
    player.box = CGRectMake(x, y, width, height);
    
    if (self.overlayView.isBoneEsp) {
        [self readBoneData:player];
    }
    
    player.isVisible = [self lineOfSightToViewPoint:Vector3(player.worldPos.X, player.worldPos.Y, player.worldPos.Z + 100)];
    return true;
}

- (bool)lineOfSightToViewPoint:(Vector3)viewPoint
{
    if (!IsValidAddress(self.localPlayer.base) || !IsValidAddress(localPlayerController)) {
        return false;
    }
    return reinterpret_cast<bool(__fastcall *)(kaddr, kaddr, Vector3*, bool)>(GetRealOffset(Offsets::LineOfSightTo_Func))(localPlayerController, self.localPlayer.base, &viewPoint, false);
}

#pragma mark
- (Vector3)getBoneWorldPos:(kaddr)base index:(int)index
{
    auto mesh = GetPtr(base + 0x438);
    if (IsValidAddress(mesh)) {
        FTransform meshTrans = Read<FTransform>(mesh + 0x1a0);
        FMatrix c2wMatrix = TransformToMatrix(meshTrans);
        auto boneArray = GetPtr(mesh + 0x738);
        if (IsValidAddress(boneArray)) {
            FTransform boneTrans = Read<FTransform>(boneArray + index * 48);
            FMatrix boneMatrix = TransformToMatrix(boneTrans);
            return MatrixToVector(MatrixMulti(boneMatrix, c2wMatrix));
        }
    }
    return Vector3();
}

- (Vector2)getBoneScreenPos:(kaddr)boneTransAddr c2wMatrix:(FMatrix)c2wMatrix
{
    FTransform boneTrans = Read<FTransform>(boneTransAddr);
    FMatrix boneMatrix = TransformToMatrix(boneTrans);
    Vector3 relLocation = MatrixToVector(MatrixMulti(boneMatrix, c2wMatrix));
    return WorldToScreen(relLocation, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (Vector3)getBoneWorldPos:(kaddr)boneTransAddr c2wMatrix:(FMatrix)c2wMatrix
{
    FTransform boneTrans = Read<FTransform>(boneTransAddr);
    FMatrix boneMatrix = TransformToMatrix(boneTrans);
    return MatrixToVector(MatrixMulti(boneMatrix, c2wMatrix));
}

- (void)readBoneData:(JFPlayer *)player
{
    auto mesh = GetPtr(player.base + 0x438);
    if (IsValidAddress(mesh)) {
        FTransform meshTrans = Read<FTransform>(mesh + 0x1a0);
        FMatrix c2wMatrix = TransformToMatrix(meshTrans);
        auto boneArray = GetPtr(mesh + 0x738);
        if (IsValidAddress(boneArray)) {
            BoneData boneData;
            BoneVisibleData boneVisibleData;
            
            Vector3 head = [self getBoneWorldPos:boneArray + 6 * 48 c2wMatrix:c2wMatrix];
            boneData.head = WorldToScreen(head, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.head = [self lineOfSightToViewPoint:head];
            
            Vector3 chest = [self getBoneWorldPos:boneArray + 4 * 48 c2wMatrix:c2wMatrix];
            boneData.chest = WorldToScreen(chest, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.chest = [self lineOfSightToViewPoint:chest];
            
            Vector3 pelvis = [self getBoneWorldPos:boneArray + 1 * 48 c2wMatrix:c2wMatrix];
            boneData.pelvis = WorldToScreen(pelvis, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.pelvis = [self lineOfSightToViewPoint:pelvis];
            
            Vector3 leftShoulder = [self getBoneWorldPos:boneArray + 12 * 48 c2wMatrix:c2wMatrix];
            boneData.leftShoulder = WorldToScreen(leftShoulder, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftShoulder = [self lineOfSightToViewPoint:leftShoulder];
            
            Vector3 rightShoulder = [self getBoneWorldPos:boneArray + 33 * 48 c2wMatrix:c2wMatrix];
            boneData.rightShoulder = WorldToScreen(rightShoulder, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightShoulder = [self lineOfSightToViewPoint:rightShoulder];
            
            Vector3 leftElbow = [self getBoneWorldPos:boneArray + 13 * 48 c2wMatrix:c2wMatrix];
            boneData.leftElbow = WorldToScreen(leftElbow, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftElbow = [self lineOfSightToViewPoint:leftElbow];
            
            Vector3 rightElbow = [self getBoneWorldPos:boneArray + 34 * 48 c2wMatrix:c2wMatrix];
            boneData.rightElbow = WorldToScreen(rightElbow, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightElbow = [self lineOfSightToViewPoint:rightElbow];
            
            Vector3 leftHand = [self getBoneWorldPos:boneArray + 14 * 48 c2wMatrix:c2wMatrix];
            boneData.leftHand = WorldToScreen(leftHand, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftHand = [self lineOfSightToViewPoint:leftHand];
            
            Vector3 rightHand = [self getBoneWorldPos:boneArray + 35 * 48 c2wMatrix:c2wMatrix];
            boneData.rightHand = WorldToScreen(rightHand, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightHand = [self lineOfSightToViewPoint:rightHand];
            
            Vector3 leftThigh = [self getBoneWorldPos:boneArray + 53 * 48 c2wMatrix:c2wMatrix];
            boneData.leftThigh = WorldToScreen(leftThigh, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftThigh = [self lineOfSightToViewPoint:leftThigh];
            
            Vector3 rightThigh = [self getBoneWorldPos:boneArray + 57 * 48 c2wMatrix:c2wMatrix];
            boneData.rightThigh = WorldToScreen(rightThigh, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightThigh = [self lineOfSightToViewPoint:rightThigh];
            
            Vector3 leftKnee = [self getBoneWorldPos:boneArray + 54 * 48 c2wMatrix:c2wMatrix];
            boneData.leftKnee = WorldToScreen(leftKnee, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftKnee = [self lineOfSightToViewPoint:leftKnee];
            
            Vector3 rightKnee = [self getBoneWorldPos:boneArray + 58 * 48 c2wMatrix:c2wMatrix];
            boneData.rightKnee = WorldToScreen(rightKnee, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightKnee = [self lineOfSightToViewPoint:rightKnee];
            
            Vector3 leftFoot = [self getBoneWorldPos:boneArray + 55 * 48 c2wMatrix:c2wMatrix];
            boneData.leftFoot = WorldToScreen(leftFoot, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.leftFoot = [self lineOfSightToViewPoint:leftFoot];
            
            Vector3 rightFoot = [self getBoneWorldPos:boneArray + 59 * 48 c2wMatrix:c2wMatrix];
            boneData.rightFoot = WorldToScreen(rightFoot, POV, SCREEN_WIDTH, SCREEN_HEIGHT);
            boneVisibleData.rightFoot = [self lineOfSightToViewPoint:rightFoot];
            
            player.boneData = boneData;
            player.boneVisibleData = boneVisibleData;
        }
    }
}

#pragma mark
- (void)localPlayerAction
{
    if (!self.overlayView.isStartTimer || self.localPlayer == nil) return;
    
    [self modifyWeaponData];
    [self aimbot];
}
#pragma mark
- (void)modifyWeaponData
{
    if (IsValidAddress(ownerShootWeapon)) {
        kaddr shootWeaponEntityComp = GetPtr(ownerShootWeapon + 0xce8);
        
        
        
        if (self.overlayView.isNorecoil && self.isFire) {
            if (IsValidAddress(shootWeaponEntityComp)) {
                Write<float>(shootWeaponEntityComp + 0xfb8, 0.001);
                Write<float>(shootWeaponEntityComp + 0x10e0, 0.001);
                
                
            }
        }
        
    }
}
#pragma mark
- (void)aimbot
{
    if (!(self.overlayView.isAimbot || self.overlayView.isBulletTrack)) return;
    
    [self filterBestAimPlayer];
    if (self.isFire) {
        if (IsValidAddress(self.lockActor)) {
            float targetHp = Read<float>(self.lockActor + 0xcc8);
            float localPlayerHp = Read<float>(self.localPlayer.base + 0xcc8);
            if (targetHp >= 0 && localPlayerHp > 0) {
                
                if (self.overlayView.isAimbot) {
                    Vector3 lockBoneV3 = [self getBoneWorldPos:self.lockActor index:self.overlayView.aimbotPart];
                    Vector3 diffV3 = lockBoneV3 - POV.Location;
                    float pitch = atan2f(diffV3.Z, sqrt(diffV3.X * diffV3.X + diffV3.Y * diffV3.Y)) * 57.29577951308f;
                    float yaw = atan2f(diffV3.Y, diffV3.X) * 57.29577951308f;
                    if (IsValidAddress(controlRotation)) {
                        if (Read<float>(controlRotation) != 0) {
                            Write<float>(controlRotation, pitch);
                        }
                        if (Read<float>(controlRotation + 0x4) != 0) {
                            Write<float>(controlRotation + 0x4, yaw);
                        }
                    }
                }
            } else {
                self.lockActor = 0;
                self.isFire = false;
            }
        }
    } else {
        self.lockActor = 0;
        self.isFire = false;
    }
}

#pragma mark

- (void)filterBestAimPlayer
{
    if (IsValidAddress(self.lockActor)) {
        for (JFPlayer *player in self.playerList) {
            if (self.lockActor == player.base) {
                player.isBestAimTarget = true;
            }
        }
        return;
    }
    
    JFPlayer *bestAimPlayer = nil;
    float minCrossCenter = 100000;
    
    for (JFPlayer *player in self.playerList) {
        player.isBestAimTarget = false;
        if (player.isVisible &&
            player.type == PlayerTypeEnemy &&
            player.hp >= 0 &&
            !(self.overlayView.isNearDeathNotAim && player.hp == 0)) {
            float crossCenter = Vector2::Distance(Vector2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5), Vector2(CGRectGetMidX(player.box), CGRectGetMidY(player.box)));
            if (crossCenter < self.overlayView.aimbotRadius && crossCenter < minCrossCenter) {
                minCrossCenter = crossCenter;
                bestAimPlayer = player;
            }
        }
    }
    
    if (bestAimPlayer) {
        bestAimPlayer.isBestAimTarget = true;
        self.lockActor = bestAimPlayer.base;
        bestAimPlayer = nil;
    }
}

#pragma mark
- (JFFloatingMenuView *)floatingMenuView
{
    if (!_floatingMenuView) {
        _floatingMenuView = [[JFFloatingMenuView alloc] initWithFrame:CGRectMake(489, 58, 45, 45)];
    }
    return _floatingMenuView;
    //return nil;
}

- (JFOverlayView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[JFOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _overlayView;
}

@end
