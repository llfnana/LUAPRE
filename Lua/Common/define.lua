
--[[
	一些全局管理对象的引入
--]]

JSON = require 'cjson'
------------------------------------------LuaFramework
Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
ByteBuffer = LuaFramework.ByteBuffer;

PanelManager = Core.Instance.PanelMgr;
NetManager = Core.Instance.NetworkMgr;
LuaTimer = Core.Instance.LuaTimerMgr;
LuaManager = Core.Instance.LuaMgr;
AudioManager = Core.Instance.AudioMgr;
GameManagerMgr = Core.Instance.GameMgr;
GlobalBhvManager = Core.Instance.GlobalBehaviourMgr;
AnimationManager = Core.Instance.AnimMgr;
ParticleMgr = Core.Instance.ParticleMgr;
NotificationMgr = Core.Instance.NotificationMgr;
--ShareResPool = Core.Instance.ShareResPool;

WebView = Core.Instance.WebView;
--BugTracker = Core.Instance.BugTracker;
HttpAgent = Core.Instance.Http;
-------------------------------------------------UnityEngine
WWW = UnityEngine.WWW;
Transform = UnityEngine.Transform; ---@class UnityEngine.Transform
GameObject = UnityEngine.GameObject; ---@class UnityEngine.GameObject
Rigidbody = UnityEngine.Rigidbody;
PlayerPrefs = UnityEngine.PlayerPrefs;
LineRenderer = UnityEngine.LineRenderer;
TrailRenderer = UnityEngine.TrailRenderer;
LineTextureMode = UnityEngine.LineTextureMode;
QueueMode = UnityEngine.QueueMode;
Rect = UnityEngine.Rect;
ParticleSystem = UnityEngine.ParticleSystem;
Camera = UnityEngine.Camera; ---@class UnityEngine.Camera
Debug = UnityEngine.Debug;
BoxCollider = UnityEngine.BoxCollider
Shader = UnityEngine.Shader;
Application = UnityEngine.Application;
Animator = UnityEngine.Animator;
Input 		= UnityEngine.Input;
Text = UnityEngine.UI.Text;
MeshRenderer = UnityEngine.MeshRenderer;
RectTransformUtility = UnityEngine.RectTransformUtility;
Material = UnityEngine.Material;
Object = UnityEngine.Object;
InputField = UnityEngine.UI.InputField;
SystemInfo = UnityEngine.SystemInfo;
SpriteRenderer = UnityEngine.SpriteRenderer; ---@class UnityEngine.SpriteRenderer
Screen = UnityEngine.Screen
CanvasGroup = UnityEngine.CanvasGroup
SortingGroup = UnityEngine.Rendering.SortingGroup
GOInstantiate = GameObject.Instantiate;
GODestroy = GameObject.Destroy;

---@class UnityEngine.Component 组件
Renderer = UnityEngine.Renderer ---@class UnityEngine.Renderer 渲染器

---@class UnityEngine.Vector3 向量
---@field x number @x
---@field y number @y
---@field z number @z

-------------------------------------------------GameFramework
BaseConfig = GameFramework.GameBaseConfig;
--Version = GameFramework.GameVersion;
--MapInputComponent = GameFramework.MapInputComponent;
BigMapInputHandler = GameFramework.BigMapInputHandler;
HomeInputHandler = GameFramework.HomeInputHandler;
BattleInputHandler = GameFramework.BattleInputHandler;
--DungeonInputHandler = GameFramework.DungeonInputHandler;
MoveObjectControl = GameFramework.MoveObjectControl;
CameraControl = GameFramework.CameraControl;
MapObjectBindData = GameFramework.MapObjectBindData;
ConstDefine = GameFramework.ConstDefine;
UIBindSceneObject = GameFramework.UIBindSceneObject;
UIBindSceneObjectScale = GameFramework.UIBindSceneObjectScale;
ParabolaMove1 = GameFramework.ParabolaMove1;
ParabolaMove2 = GameFramework.ParabolaMove2;
ParabolaMove3 = GameFramework.ParabolaMove3;
NPCController = GameFramework.NPCController;
SmoothSlider = GameFramework.SmoothSlider;
UIInterface = GameFramework.UIInterface;
ModelUIBehaviour = GameFramework.ModelUIBehaviour;
GameObjList = GameFramework.GameObjList;
ScrollItemAutoScale = GameFramework.ScrollItemAutoScale;
BigMapLuaInterface = GameFramework.BigMapLuaInterface;
UIDragAndScaleControl = GameFramework.UIDragAndScaleControl;
HomeLuaInterface = GameFramework.HomeLuaInterface;
ObjectBindData = GameFramework.ObjectBindData;

-------------------------------------------------UIFramework
TweenAlpha = EnUIFrameWork.TweenAlpha;
TweenPosition = EnUIFrameWork.TweenPosition;
TweenRotation = EnUIFrameWork.TweenRotation;
TweenScale = EnUIFrameWork.TweenScale;
TweenColor = EnUIFrameWork.TweenColor;
TweenText = EnUIFrameWork.TweenText;
TweenFillAmount = EnUIFrameWork.TweenFillAmount;
TweenSlider = EnUIFrameWork.TweenSlider;
TweenProgressBarValue = EnUIFrameWork.TweenProgressBarValue;
TweenVolume = EnUIFrameWork.TweenVolume;
TweenHeight = EnUIFrameWork.TweenHeight;
TweenWidth = EnUIFrameWork.TweenWidth;
UITweener = EnUIFrameWork.UITweener;

-----------------------------------------------Others
--Highlighter = HighlightingSystem.Highlighter;
--VirtualColliderMgr = VirtualColliderManager.GetInstance();

-----------------------------------------------Enum
QualityLevel_High = GameQuality.CustomQualityLevel.High
QualityLevel_Medium = GameQuality.CustomQualityLevel.Medium;
QualityLevel_Low = GameQuality.CustomQualityLevel.Low;
QualityLevel_Lowest = GameQuality.CustomQualityLevel.Lowest;

-----------------------------------------------Spine
SkeletonAnimation = Spine.Unity.SkeletonAnimation ---@class SkeletonAnimation
SkeletonGraphic = Spine.Unity.SkeletonGraphic ---@class SkeletonGraphic
TrackEntry = Spine.TrackEntry ---@class TrackEntry

-----------------------------------------------DOTween
DOTween = DG.Tweening.DOTween
Ease = DG.Tweening.Ease
LoopType = DG.Tweening.LoopType

-----------------------------------------------UnityEngine.UI

---@class UnityEngine.UI.Text 文本
---@class UnityEngine.UI.Image 图片


--WaitForSeconds = UnityEngine.WaitForSeconds
