-- ╔══════════════════════════════════════════════════════╗
-- ║              NIGHT GUI v3 - LOADSTRING READY         ║
-- ║   ลาก GUI ได้ | ปุ่มเปิด/ปิด | เพิ่ม Tab/ปุ่มเองได้  ║
-- ╚══════════════════════════════════════════════════════╝
--
-- 🚀 วิธีใช้ loadstring:
--    local GUI = loadstring(game:HttpGet("URL_ของคุณ"))()
--
-- 📖 ตัวอย่าง:
--    local Tab1 = GUI:AddTab("⚔️ Combat")
--    GUI:AddButton(Tab1, "Kill All", "โจมตีทุกคน", function() end)
--    GUI:AddToggle(Tab1, "Auto Farm", "ฟาร์มอัตโนมัติ", function(s) end)
--    GUI:AddLabel(Tab1, "เวอร์ชัน 1.0")
--    GUI:SetColor(Color3.fromRGB(0,170,255))
-- ══════════════════════════════════════════════════════

-- ── SERVICES ──────────────────────────────────────────
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local PGui         = LP:WaitForChild("PlayerGui")

-- ── CLEAN UP ──────────────────────────────────────────
for _, v in ipairs(PGui:GetChildren()) do
    if v.Name == "NightGUI_v3" then v:Destroy() end
end

-- ── THEME ─────────────────────────────────────────────
local Theme = {
    Primary    = Color3.fromRGB(255, 210, 0),
    BG         = Color3.fromRGB(15, 15, 15),
    Card       = Color3.fromRGB(25, 25, 25),
    CardHover  = Color3.fromRGB(32, 32, 32),
    Text       = Color3.fromRGB(255, 255, 255),
    Sub        = Color3.fromRGB(155, 155, 155),
    ToggleOn   = Color3.fromRGB(255, 210, 0),
    ToggleOff  = Color3.fromRGB(50, 50, 50),
    TabActive  = Color3.fromRGB(255, 210, 0),
    TabInactive= Color3.fromRGB(35, 35, 35),
}

-- ── TWEEN HELPER ──────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

-- ══════════════════════════════════════════════════════
--  📦 SCREEN GUI
-- ══════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name             = "NightGUI_v3"
SG.ResetOnSpawn     = false
SG.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset   = true
SG.Parent           = PGui

-- ══════════════════════════════════════════════════════
--  🔘 TOGGLE BUTTON (ปุ่มเปิด/ปิด GUI ลอยอยู่มุม)
-- ══════════════════════════════════════════════════════
local ToggleBtn = Instance.new("TextButton", SG)
ToggleBtn.Size              = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position          = UDim2.new(0, 20, 0.5, -24)
ToggleBtn.BackgroundColor3  = Theme.BG
ToggleBtn.Text              = "N"
ToggleBtn.TextColor3        = Theme.Primary
ToggleBtn.Font              = Enum.Font.GothamBold
ToggleBtn.TextSize          = 18
ToggleBtn.BorderSizePixel   = 0
ToggleBtn.ZIndex            = 100

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TBStroke = Instance.new("UIStroke", ToggleBtn)
TBStroke.Color     = Theme.Primary
TBStroke.Thickness = 2

-- ลาก Toggle Button ได้
local tbDrag, tbStart, tbStartPos = false, nil, nil
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        tbDrag      = true
        tbStart     = i.Position
        tbStartPos  = ToggleBtn.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if tbDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or
                   i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tbStart
        ToggleBtn.Position = UDim2.new(
            tbStartPos.X.Scale, tbStartPos.X.Offset + d.X,
            tbStartPos.Y.Scale, tbStartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        tbDrag = false
    end
end)

-- ══════════════════════════════════════════════════════
--  🪟 MAIN FRAME
-- ══════════════════════════════════════════════════════
local MF = Instance.new("Frame", SG)
MF.Name               = "MainFrame"
MF.Size               = UDim2.new(0, 560, 0, 480)
MF.Position           = UDim2.new(0.5, -280, 0.5, -240)
MF.BackgroundColor3   = Theme.BG
MF.BorderSizePixel    = 0
MF.ClipsDescendants   = true

Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 14)
local MStroke = Instance.new("UIStroke", MF)
MStroke.Color     = Theme.Primary
MStroke.Thickness = 2

-- ── TOP BAR ───────────────────────────────────────────
local TopBar = Instance.new("Frame", MF)
TopBar.Name             = "TopBar"
TopBar.Size             = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BorderSizePixel  = 0

Instance.new("UICorner", TopBar)  -- แค่ให้ไม่ Error

-- Title
local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Size               = UDim2.new(0, 120, 1, 0)
TitleLbl.Position           = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "NIGHT"
TitleLbl.TextColor3         = Theme.Primary
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextSize           = 20
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left

-- Version
local VerLbl = Instance.new("TextLabel", TopBar)
VerLbl.Size             = UDim2.new(0, 80, 1, 0)
VerLbl.Position         = UDim2.new(0, 108, 0, 0)
VerLbl.BackgroundTransparency = 1
VerLbl.Text             = "v3.0"
VerLbl.TextColor3       = Theme.Sub
VerLbl.Font             = Enum.Font.Gotham
VerLbl.TextSize         = 11
VerLbl.TextXAlignment   = Enum.TextXAlignment.Left

-- Close
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size               = UDim2.new(0, 32, 0, 32)
CloseBtn.Position           = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3   = Color3.fromRGB(200, 50, 50)
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = Color3.new(1,1,1)
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.TextSize           = 14
CloseBtn.BorderSizePixel    = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

CloseBtn.MouseButton1Click:Connect(function()
    Tween(MF, {Size = UDim2.new(0,560,0,0), Position = UDim2.new(0.5,-280,0.5,0)}, 0.2)
    task.delay(0.21, function() MF.Visible = false end)
end)

-- ── DRAG TOP BAR ──────────────────────────────────────
local dragging, dragStart, dragStartPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        dragging     = true
        dragStart    = i.Position
        dragStartPos = MF.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
                     i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        MF.Position = UDim2.new(
            dragStartPos.X.Scale, dragStartPos.X.Offset + d.X,
            dragStartPos.Y.Scale, dragStartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ══════════════════════════════════════════════════════
--  📑 TAB SYSTEM
-- ══════════════════════════════════════════════════════
-- Left: Tab list
local TabList = Instance.new("ScrollingFrame", MF)
TabList.Name                = "TabList"
TabList.Size                = UDim2.new(0, 130, 1, -46)
TabList.Position            = UDim2.new(0, 0, 0, 46)
TabList.BackgroundColor3    = Color3.fromRGB(10,10,10)
TabList.BorderSizePixel     = 0
TabList.ScrollBarThickness  = 3
TabList.ScrollBarImageColor3= Theme.Primary
TabList.CanvasSize          = UDim2.new(0,0,0,0)
TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y

local TabListLayout = Instance.new("UIListLayout", TabList)
TabListLayout.SortOrder  = Enum.SortOrder.LayoutOrder
TabListLayout.Padding    = UDim.new(0, 4)

local TabListPad = Instance.new("UIPadding", TabList)
TabListPad.PaddingTop    = UDim.new(0, 8)
TabListPad.PaddingLeft   = UDim.new(0, 6)
TabListPad.PaddingRight  = UDim.new(0, 6)

-- Right: Content area
local ContentArea = Instance.new("Frame", MF)
ContentArea.Name              = "ContentArea"
ContentArea.Size              = UDim2.new(1, -130, 1, -46)
ContentArea.Position          = UDim2.new(0, 130, 0, 46)
ContentArea.BackgroundColor3  = Theme.BG
ContentArea.BorderSizePixel   = 0

-- Divider line
local Divider = Instance.new("Frame", MF)
Divider.Size              = UDim2.new(0, 1, 1, -46)
Divider.Position          = UDim2.new(0, 130, 0, 46)
Divider.BackgroundColor3  = Theme.Primary
Divider.BorderSizePixel   = 0

-- ══════════════════════════════════════════════════════
--  🔘 TOGGLE BUTTON → เปิด/ปิด GUI
-- ══════════════════════════════════════════════════════
ToggleBtn.MouseButton1Click:Connect(function()
    if MF.Visible then
        Tween(MF, {Size = UDim2.new(0,560,0,0), Position = UDim2.new(0.5,-280,0.5,0)}, 0.2)
        task.delay(0.21, function() MF.Visible = false end)
    else
        MF.Visible = true
        MF.Size     = UDim2.new(0,560,0,0)
        MF.Position = UDim2.new(0.5,-280,0.5,0)
        Tween(MF, {Size = UDim2.new(0,560,0,480), Position = UDim2.new(0.5,-280,0.5,-240)}, 0.25)
    end
end)

-- Keyboard shortcut
UIS.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == Enum.KeyCode.RightShift then
        ToggleBtn.MouseButton1Click:Fire()
    end
end)

-- ══════════════════════════════════════════════════════
--  🏗️ INTERNAL: สร้าง Tab Content Page
-- ══════════════════════════════════════════════════════
local activeTabBtn = nil
local tabPages = {}

local function SetActiveTab(tabBtn, page)
    -- ซ่อนทุก page
    for _, p in ipairs(tabPages) do p.Visible = false end
    -- reset ปุ่มทั้งหมด
    for _, b in ipairs(TabList:GetChildren()) do
        if b:IsA("TextButton") then
            Tween(b, {BackgroundColor3 = Theme.TabInactive}, 0.15)
            local lbl = b:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = Theme.Sub end
        end
    end
    -- เปิด page ที่เลือก
    page.Visible = true
    Tween(tabBtn, {BackgroundColor3 = Theme.TabActive}, 0.15)
    local lbl = tabBtn:FindFirstChildOfClass("TextLabel")
    if lbl then lbl.TextColor3 = Color3.fromRGB(15,15,15) end
    activeTabBtn = tabBtn
end

-- ══════════════════════════════════════════════════════
--  🏗️ INTERNAL: สร้าง scroll page ใน ContentArea
-- ══════════════════════════════════════════════════════
local function MakePage()
    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size                 = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel      = 0
    Page.ScrollBarThickness   = 4
    Page.ScrollBarImageColor3 = Theme.Primary
    Page.CanvasSize           = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    Page.Visible              = false

    local Layout = Instance.new("UIListLayout", Page)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding   = UDim.new(0, 8)

    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop    = UDim.new(0, 10)
    Pad.PaddingBottom = UDim.new(0, 10)
    Pad.PaddingLeft   = UDim.new(0, 10)
    Pad.PaddingRight  = UDim.new(0, 10)

    table.insert(tabPages, Page)
    return Page
end

-- ══════════════════════════════════════════════════════
--  🧩 PUBLIC API
-- ══════════════════════════════════════════════════════
local NightGUI = {}

-- ─────────────────────────────────────────────────────
--  📂 AddTab(name) → TabRef
-- ─────────────────────────────────────────────────────
function NightGUI:AddTab(name)
    local Page = MakePage()

    local Btn = Instance.new("TextButton", TabList)
    Btn.Size              = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3  = Theme.TabInactive
    Btn.Text              = ""
    Btn.BorderSizePixel   = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local BtnLbl = Instance.new("TextLabel", Btn)
    BtnLbl.Size             = UDim2.new(1, -10, 1, 0)
    BtnLbl.Position         = UDim2.new(0, 8, 0, 0)
    BtnLbl.BackgroundTransparency = 1
    BtnLbl.Text             = name
    BtnLbl.TextColor3       = Theme.Sub
    BtnLbl.Font             = Enum.Font.GothamBold
    BtnLbl.TextSize         = 12
    BtnLbl.TextXAlignment   = Enum.TextXAlignment.Left
    BtnLbl.TextWrapped      = true

    Btn.MouseButton1Click:Connect(function()
        SetActiveTab(Btn, Page)
    end)

    -- เลือก tab แรกอัตโนมัติ
    if #tabPages == 1 then
        SetActiveTab(Btn, Page)
    end

    return {Page = Page, Btn = Btn}
end

-- ─────────────────────────────────────────────────────
--  🔘 AddButton(tab, title, desc, callback)
-- ─────────────────────────────────────────────────────
function NightGUI:AddButton(tab, title, desc, callback)
    local Page = tab.Page

    local Card = Instance.new("TextButton", Page)
    Card.Size              = UDim2.new(1, 0, 0, 62)
    Card.BackgroundColor3  = Theme.Card
    Card.Text              = ""
    Card.BorderSizePixel   = 0
    Card.AutoButtonColor   = false
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
    local CStroke = Instance.new("UIStroke", Card)
    CStroke.Color     = Theme.Primary
    CStroke.Thickness = 1
    CStroke.Transparency = 0.6

    local TLbl = Instance.new("TextLabel", Card)
    TLbl.Size               = UDim2.new(1, -16, 0, 26)
    TLbl.Position           = UDim2.new(0, 12, 0, 8)
    TLbl.BackgroundTransparency = 1
    TLbl.Text               = title
    TLbl.TextColor3         = Theme.Text
    TLbl.Font               = Enum.Font.GothamBold
    TLbl.TextSize           = 13
    TLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local DLbl = Instance.new("TextLabel", Card)
    DLbl.Size               = UDim2.new(1, -16, 0, 20)
    DLbl.Position           = UDim2.new(0, 12, 0, 34)
    DLbl.BackgroundTransparency = 1
    DLbl.Text               = desc or ""
    DLbl.TextColor3         = Theme.Sub
    DLbl.Font               = Enum.Font.Gotham
    DLbl.TextSize           = 11
    DLbl.TextXAlignment     = Enum.TextXAlignment.Left

    -- Arrow icon
    local Arrow = Instance.new("TextLabel", Card)
    Arrow.Size              = UDim2.new(0, 24, 1, 0)
    Arrow.Position          = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text              = "›"
    Arrow.TextColor3        = Theme.Primary
    Arrow.Font              = Enum.Font.GothamBold
    Arrow.TextSize          = 22

    Card.MouseEnter:Connect(function()
        Tween(Card, {BackgroundColor3 = Theme.CardHover}, 0.1)
        Tween(CStroke, {Transparency = 0}, 0.1)
    end)
    Card.MouseLeave:Connect(function()
        Tween(Card, {BackgroundColor3 = Theme.Card}, 0.1)
        Tween(CStroke, {Transparency = 0.6}, 0.1)
    end)
    Card.MouseButton1Click:Connect(function()
        Tween(Card, {BackgroundColor3 = Theme.Primary}, 0.08)
        Tween(TLbl, {TextColor3 = Color3.fromRGB(15,15,15)}, 0.08)
        task.delay(0.12, function()
            Tween(Card, {BackgroundColor3 = Theme.Card}, 0.15)
            Tween(TLbl, {TextColor3 = Theme.Text}, 0.15)
        end)
        if callback then task.spawn(callback) end
    end)
end

-- ─────────────────────────────────────────────────────
--  🔄 AddToggle(tab, title, desc, callback) → {SetState}
-- ─────────────────────────────────────────────────────
function NightGUI:AddToggle(tab, title, desc, callback)
    local Page  = tab.Page
    local state = false

    local Card = Instance.new("Frame", Page)
    Card.Size             = UDim2.new(1, 0, 0, 62)
    Card.BackgroundColor3 = Theme.Card
    Card.BorderSizePixel  = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
    local CStroke = Instance.new("UIStroke", Card)
    CStroke.Color        = Theme.Primary
    CStroke.Thickness    = 1
    CStroke.Transparency = 0.7

    local TLbl = Instance.new("TextLabel", Card)
    TLbl.Size               = UDim2.new(1, -70, 0, 26)
    TLbl.Position           = UDim2.new(0, 12, 0, 8)
    TLbl.BackgroundTransparency = 1
    TLbl.Text               = title
    TLbl.TextColor3         = Theme.Text
    TLbl.Font               = Enum.Font.GothamBold
    TLbl.TextSize           = 13
    TLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local DLbl = Instance.new("TextLabel", Card)
    DLbl.Size               = UDim2.new(1, -70, 0, 20)
    DLbl.Position           = UDim2.new(0, 12, 0, 34)
    DLbl.BackgroundTransparency = 1
    DLbl.Text               = desc or ""
    DLbl.TextColor3         = Theme.Sub
    DLbl.Font               = Enum.Font.Gotham
    DLbl.TextSize           = 11
    DLbl.TextXAlignment     = Enum.TextXAlignment.Left

    -- Toggle track
    local Track = Instance.new("Frame", Card)
    Track.Size             = UDim2.new(0, 44, 0, 24)
    Track.Position         = UDim2.new(1, -56, 0.5, -12)
    Track.BackgroundColor3 = Theme.ToggleOff
    Track.BorderSizePixel  = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size             = UDim2.new(0, 18, 0, 18)
    Knob.Position         = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.BorderSizePixel  = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

    local function setState(val)
        state = val
        if state then
            Tween(Track, {BackgroundColor3 = Theme.ToggleOn}, 0.18)
            Tween(Knob,  {Position = UDim2.new(0, 23, 0.5, -9)}, 0.18)
            Tween(CStroke, {Transparency = 0}, 0.18)
        else
            Tween(Track, {BackgroundColor3 = Theme.ToggleOff}, 0.18)
            Tween(Knob,  {Position = UDim2.new(0, 3, 0.5, -9)}, 0.18)
            Tween(CStroke, {Transparency = 0.7}, 0.18)
        end
        if callback then task.spawn(callback, state) end
    end

    local HitBtn = Instance.new("TextButton", Card)
    HitBtn.Size               = UDim2.new(1, 0, 1, 0)
    HitBtn.BackgroundTransparency = 1
    HitBtn.Text               = ""
    HitBtn.MouseButton1Click:Connect(function() setState(not state) end)

    return {SetState = setState, GetState = function() return state end}
end

-- ─────────────────────────────────────────────────────
--  🔢 AddSlider(tab, title, min, max, default, callback) → {SetValue}
-- ─────────────────────────────────────────────────────
function NightGUI:AddSlider(tab, title, min, max, default, callback)
    local Page = tab.Page
    min     = min or 0
    max     = max or 100
    default = default or min
    local value = default

    local Card = Instance.new("Frame", Page)
    Card.Size             = UDim2.new(1, 0, 0, 68)
    Card.BackgroundColor3 = Theme.Card
    Card.BorderSizePixel  = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local TLbl = Instance.new("TextLabel", Card)
    TLbl.Size               = UDim2.new(1, -60, 0, 22)
    TLbl.Position           = UDim2.new(0, 12, 0, 8)
    TLbl.BackgroundTransparency = 1
    TLbl.Text               = title
    TLbl.TextColor3         = Theme.Text
    TLbl.Font               = Enum.Font.GothamBold
    TLbl.TextSize           = 13
    TLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", Card)
    ValLbl.Size             = UDim2.new(0, 50, 0, 22)
    ValLbl.Position         = UDim2.new(1, -58, 0, 8)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text             = tostring(default)
    ValLbl.TextColor3       = Theme.Primary
    ValLbl.Font             = Enum.Font.GothamBold
    ValLbl.TextSize         = 13
    ValLbl.TextXAlignment   = Enum.TextXAlignment.Right

    -- Track
    local TrackBG = Instance.new("Frame", Card)
    TrackBG.Size             = UDim2.new(1, -24, 0, 6)
    TrackBG.Position         = UDim2.new(0, 12, 0, 42)
    TrackBG.BackgroundColor3 = Theme.ToggleOff
    TrackBG.BorderSizePixel  = 0
    Instance.new("UICorner", TrackBG).CornerRadius = UDim.new(1,0)

    local TrackFill = Instance.new("Frame", TrackBG)
    local pct = (default - min) / (max - min)
    TrackFill.Size             = UDim2.new(pct, 0, 1, 0)
    TrackFill.BackgroundColor3 = Theme.Primary
    TrackFill.BorderSizePixel  = 0
    Instance.new("UICorner", TrackFill).CornerRadius = UDim.new(1,0)

    local Thumb = Instance.new("Frame", TrackBG)
    Thumb.Size             = UDim2.new(0, 14, 0, 14)
    Thumb.Position         = UDim2.new(pct, -7, 0.5, -7)
    Thumb.BackgroundColor3 = Color3.new(1,1,1)
    Thumb.BorderSizePixel  = 0
    Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1,0)

    local sliding = false

    local function updateSlider(inputPos)
        local relX = inputPos.X - TrackBG.AbsolutePosition.X
        local pct2 = math.clamp(relX / TrackBG.AbsoluteSize.X, 0, 1)
        local v = math.round(min + (max - min) * pct2)
        value = v
        ValLbl.Text = tostring(v)
        TrackFill.Size = UDim2.new(pct2, 0, 1, 0)
        Thumb.Position = UDim2.new(pct2, -7, 0.5, -7)
        if callback then task.spawn(callback, v) end
    end

    TrackBG.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(i.Position)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or
                        i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i.Position)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    return {
        SetValue = function(_, v)
            local p = math.clamp((v-min)/(max-min), 0, 1)
            value = v; ValLbl.Text = tostring(v)
            TrackFill.Size = UDim2.new(p, 0, 1, 0)
            Thumb.Position = UDim2.new(p, -7, 0.5, -7)
        end,
        GetValue = function() return value end
    }
end

-- ─────────────────────────────────────────────────────
--  🏷️ AddLabel(tab, text)
-- ─────────────────────────────────────────────────────
function NightGUI:AddLabel(tab, text)
    local Page = tab.Page
    local Lbl = Instance.new("TextLabel", Page)
    Lbl.Size              = UDim2.new(1, 0, 0, 28)
    Lbl.BackgroundColor3  = Color3.fromRGB(20,20,20)
    Lbl.Text              = "  " .. (text or "")
    Lbl.TextColor3        = Theme.Sub
    Lbl.Font              = Enum.Font.Gotham
    Lbl.TextSize          = 12
    Lbl.TextXAlignment    = Enum.TextXAlignment.Left
    Lbl.BorderSizePixel   = 0
    Instance.new("UICorner", Lbl).CornerRadius = UDim.new(0, 6)
end

-- ─────────────────────────────────────────────────────
--  ─── AddSeparator(tab)
-- ─────────────────────────────────────────────────────
function NightGUI:AddSeparator(tab)
    local Page = tab.Page
    local Sep = Instance.new("Frame", Page)
    Sep.Size             = UDim2.new(1, 0, 0, 1)
    Sep.BackgroundColor3 = Theme.Primary
    Sep.BorderSizePixel  = 0
    Sep.BackgroundTransparency = 0.7
end

-- ─────────────────────────────────────────────────────
--  🎨 SetColor(primary)
-- ─────────────────────────────────────────────────────
function NightGUI:SetColor(primary)
    Theme.Primary   = primary
    Theme.ToggleOn  = primary
    Theme.TabActive = primary
    MStroke.Color   = primary
    TitleLbl.TextColor3 = primary
    TBStroke.Color  = primary
    ToggleBtn.TextColor3 = primary
    Divider.BackgroundColor3 = primary
    -- update tab active button
    if activeTabBtn then
        activeTabBtn.BackgroundColor3 = primary
    end
end

-- ─────────────────────────────────────────────────────
--  📛 SetTitle(name)
-- ─────────────────────────────────────────────────────
function NightGUI:SetTitle(name)
    TitleLbl.Text = name
    ToggleBtn.Text = string.sub(name,1,1)
end

-- ─────────────────────────────────────────────────────
--  👁️ Show / Hide / Toggle
-- ─────────────────────────────────────────────────────
function NightGUI:Show()
    MF.Visible = true
    Tween(MF, {Size = UDim2.new(0,560,0,480), Position = UDim2.new(0.5,-280,0.5,-240)}, 0.25)
end
function NightGUI:Hide()
    Tween(MF, {Size = UDim2.new(0,560,0,0)}, 0.2)
    task.delay(0.21, function() MF.Visible = false end)
end

-- ══════════════════════════════════════════════════════
--  ✅ STARTUP
-- ══════════════════════════════════════════════════════
MF.Visible = true
print("╔══════════════════════════════╗")
print("║   NIGHT GUI v3 - Loaded! ✅  ║")
print("║  กด RightShift เปิด/ปิด      ║")
print("║  ลากปุ่ม N เพื่อย้าย         ║")
print("╚══════════════════════════════╝")

return NightGUI
