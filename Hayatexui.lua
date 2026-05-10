-- HayateX Hub GUI Library
-- Refactored & Bug Fixed

-- ============================================================
--  CLEANUP: ลบ GUI เก่าออกก่อน (ถ้ามี)
-- ============================================================
local CoreGui = game:GetService('CoreGui')

for _, name in ipairs({'HAYATEXHUB', 'AlertFrame', 'ScreenGui'}) do
    local found = CoreGui:FindFirstChild(name)
    if found then found:Destroy() end
end

-- ============================================================
--  THEME SETUP
-- ============================================================
local VALID_THEMES = {
    Red        = { primary = Color3.fromRGB(255, 30,  50),  dark = Color3.fromRGB(90,  10,  20)  },
    Cyan       = { primary = Color3.fromRGB(40,  230, 255), dark = Color3.fromRGB(10,  80,  115) },
    Blue       = { primary = Color3.fromRGB(40,  155, 255), dark = Color3.fromRGB(10,  80,  115) },
    DarkBlue   = { primary = Color3.fromRGB(50,  30,  255), dark = Color3.fromRGB(20,  10,  90)  },
    Green      = { primary = Color3.fromRGB(70,  255, 205), dark = Color3.fromRGB(20,  90,  90)  },
    LightGreen = { primary = Color3.fromRGB(205, 255, 205), dark = Color3.fromRGB(70,  90,  70)  },
    Purple     = { primary = Color3.fromRGB(205, 125, 255), dark = Color3.fromRGB(60,  20,  95)  },
    Zinc       = { primary = Color3.fromRGB(30,  30,  30),  dark = Color3.fromRGB(10,  10,  10)  },
}

local DEFAULT_THEME = { primary = Color3.fromRGB(110, 110, 120), dark = Color3.fromRGB(20, 20, 30) }

local theme = VALID_THEMES[_G.Theme] or DEFAULT_THEME
_G.Primary = theme.primary
_G.Dark    = theme.dark

if not _G.Theme then
    print('[HayateX Hub] Theme not set — using default.')
end

-- ============================================================
--  WAIT FOR GAME LOAD
-- ============================================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================
--  SERVICES
-- ============================================================
local UserInputService = game:GetService('UserInputService')
local TweenService     = game:GetService('TweenService')
local TextService      = game:GetService('TextService')
local RunService       = game:GetService('RunService')
local Players          = game:GetService('Players')

-- ============================================================
--  TOGGLE BUTTON (มุมซ้ายบน)
-- ============================================================
local toggleGui = Instance.new('ScreenGui')
toggleGui.Parent          = CoreGui
toggleGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling

local toggleBtn = Instance.new('ImageButton')
toggleBtn.Parent               = toggleGui
toggleBtn.Position             = UDim2.new(0, 10, 0, 10)
toggleBtn.Size                 = UDim2.new(0, 50, 0, 50)
toggleBtn.Draggable            = true
toggleBtn.BackgroundColor3     = _G.Dark
toggleBtn.ImageColor3          = _G.Primary
toggleBtn.ImageTransparency    = 0.1
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.Image                = 'rbxassetid://134091073885645'

local toggleStroke = Instance.new('UIStroke')
toggleStroke.Color       = _G.Primary
toggleStroke.Thickness   = 1
toggleStroke.Transparency = 0
toggleStroke.Parent      = toggleBtn

local toggleCorner = Instance.new('UICorner')
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent       = toggleBtn

-- ============================================================
--  HELPER: DRAG FUNCTION (ใช้ TweenService แทน deprecated Draggable)
-- ============================================================
local function makeDraggable(handle, target)
    local dragging    = false
    local dragStart   = nil
    local startPos    = nil
    local lastInput   = nil

    local function onInputChanged(input)
        if input == lastInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(target, TweenInfo.new(0.15), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            lastInput = input
        end
    end)

    UserInputService.InputChanged:Connect(onInputChanged)
end

-- ============================================================
--  LIBRARY TABLE
-- ============================================================
local HayateX = {}

-- ============================================================
--  WINDOW FUNCTION
-- ============================================================
function HayateX:Window(subtitle)
    subtitle = subtitle or ''

    local isFirstTab  = false
    local currentPage = ''
    local keybind     = Enum.KeyCode.RightControl

    -- Alert ScreenGui
    local alertGui = Instance.new('ScreenGui')
    alertGui.Name            = 'AlertFrame'
    alertGui.Parent          = CoreGui
    alertGui.ZIndexBehavior  = Enum.ZIndexBehavior.Global

    -- Main ScreenGui
    local mainGui = Instance.new('ScreenGui')
    mainGui.Name           = 'HAYATEXHUB'
    mainGui.Parent         = CoreGui
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    -- Main Frame
    local mainFrame = Instance.new('Frame')
    mainFrame.Name                 = 'Main'
    mainFrame.Parent               = mainGui
    mainFrame.ClipsDescendants     = true
    mainFrame.AnchorPoint          = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3     = _G.Dark
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Position             = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                 = UDim2.new(0, 0, 0, 0)

    -- BUG FIX: ใช้ TweenService แทน TweenSize ที่เรียกผิด
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 524, 0, 332)
    }):Play()

    local mainStroke = Instance.new('UIStroke')
    mainStroke.Color       = _G.Primary
    mainStroke.Thickness   = 1
    mainStroke.Transparency = 0
    mainStroke.Parent      = mainFrame

    local mainCorner = Instance.new('UICorner')
    mainCorner.Name         = 'CircleMain'
    mainCorner.CornerRadius = UDim.new(0, 5)
    mainCorner.Parent       = mainFrame

    -- Resize Handle (มุมขวาล่าง)
    local resizeHandle = Instance.new('Frame')
    resizeHandle.Name                 = 'DragButton'
    resizeHandle.Parent               = mainFrame
    resizeHandle.Position             = UDim2.new(1, 5, 1, 5)
    resizeHandle.AnchorPoint          = Vector2.new(1, 1)
    resizeHandle.Size                 = UDim2.new(0, 15, 0, 15)
    resizeHandle.BackgroundColor3     = _G.Primary
    resizeHandle.BackgroundTransparency = 0.1
    resizeHandle.ZIndex               = 10

    local resizeCorner = Instance.new('UICorner')
    resizeCorner.Name         = 'CircleDragButton'
    resizeCorner.CornerRadius = UDim.new(0, 99)
    resizeCorner.Parent       = resizeHandle

    -- Top Bar
    local topBar = Instance.new('Frame')
    topBar.Name                 = 'Top'
    topBar.Parent               = mainFrame
    topBar.BackgroundColor3     = Color3.fromRGB(10, 10, 10)
    topBar.Size                 = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1

    local topCorner = Instance.new('UICorner')
    topCorner.Name         = 'TCNR'
    topCorner.CornerRadius = UDim.new(0, 5)
    topCorner.Parent       = topBar

    -- Title Label "HAYATEX HUB |"
    local titleLabel = Instance.new('TextLabel')
    titleLabel.Name                 = 'Title'
    titleLabel.Parent               = topBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position             = UDim2.new(0, 15, 0.5, 0)
    titleLabel.AnchorPoint          = Vector2.new(0, 0.5)
    titleLabel.Size                 = UDim2.new(0, 1, 0, 25)
    titleLabel.Font                 = Enum.Font.GothamBold
    titleLabel.Text                 = 'HAYATEX HUB |'
    titleLabel.TextSize             = 15
    titleLabel.TextColor3           = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment       = Enum.TextXAlignment.Left
    titleLabel.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

    local titleSize = TextService:GetTextSize(titleLabel.Text, titleLabel.TextSize, titleLabel.Font, Vector2.new(math.huge, math.huge))
    titleLabel.Size = UDim2.new(0, titleSize.X, 0, 25)

    -- Subtitle / patch label
    local subtitleLabel = Instance.new('TextLabel')
    subtitleLabel.Name                 = 'Subtitle'
    subtitleLabel.Parent               = titleLabel
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Position             = UDim2.new(1, 5, 0.5, 0)
    subtitleLabel.AnchorPoint          = Vector2.new(0, 0.5)
    subtitleLabel.Size                 = UDim2.new(0, 1, 0, 25)
    subtitleLabel.Font                 = Enum.Font.Gotham
    subtitleLabel.Text                 = subtitle
    subtitleLabel.TextSize             = 15
    subtitleLabel.TextColor3           = _G.Primary
    subtitleLabel.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

    local subSize = TextService:GetTextSize(subtitleLabel.Text, subtitleLabel.TextSize, subtitleLabel.Font, Vector2.new(math.huge, math.huge))
    subtitleLabel.Size = UDim2.new(0, subSize.X, 0, 25)

    -- Hide Button
    local hideBtn = Instance.new('ImageButton')
    hideBtn.Name                   = 'Hide'
    hideBtn.Parent                 = topBar
    hideBtn.BackgroundTransparency = 1
    hideBtn.AnchorPoint            = Vector2.new(1, 0.5)
    hideBtn.Position               = UDim2.new(1, -10, 0.5, 0)
    hideBtn.Size                   = UDim2.new(0, 25, 0, 25)
    hideBtn.Image                  = 'rbxassetid://7743878857'
    hideBtn.ImageTransparency      = 0
    hideBtn.ImageColor3            = Color3.fromRGB(245, 245, 245)
    hideBtn.BackgroundColor3       = _G.Primary

    local hideBtnCorner = Instance.new('UICorner')
    hideBtnCorner.Name         = 'HideBtnCorner'
    hideBtnCorner.CornerRadius = UDim.new(0, 3)
    hideBtnCorner.Parent       = hideBtn

    -- Separator under top bar
    local topSep = Instance.new('Frame')
    topSep.Name                 = 'SepBot'
    topSep.Parent               = topBar
    topSep.BackgroundColor3     = _G.Primary
    topSep.BackgroundTransparency = 0
    topSep.BorderSizePixel      = 0
    topSep.AnchorPoint          = Vector2.new(0.5, 1)
    topSep.Position             = UDim2.new(0.5, 0, 1, 0)
    topSep.Size                 = UDim2.new(1, 0, 0, 1)

    -- Tab Panel (ซ้าย)
    local tabPanel = Instance.new('Frame')
    tabPanel.Name                 = 'Tab'
    tabPanel.Parent               = mainFrame
    tabPanel.BackgroundColor3     = Color3.fromRGB(45, 45, 45)
    tabPanel.Position             = UDim2.new(0, 8, 0, 45)
    tabPanel.BackgroundTransparency = 1
    tabPanel.Size                 = UDim2.new(0, 148, 0, 275)

    local tabPanelCorner = Instance.new('UICorner')
    tabPanelCorner.CornerRadius = UDim.new(0, 5)
    tabPanelCorner.Parent       = tabPanel

    local tabScroll = Instance.new('ScrollingFrame')
    tabScroll.Name                 = 'ScrollTab'
    tabScroll.Parent               = tabPanel
    tabScroll.Active               = true
    tabScroll.BackgroundTransparency = 1
    tabScroll.Position             = UDim2.new(0, 0, 0, 0)
    tabScroll.Size                 = UDim2.new(1, 0, 1, 0)
    tabScroll.ScrollBarThickness   = 0
    tabScroll.ScrollingDirection   = Enum.ScrollingDirection.Y

    local tabListLayout = Instance.new('UIListLayout')
    tabListLayout.Name       = 'PLL'
    tabListLayout.Parent     = tabScroll
    tabListLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding    = UDim.new(0, 2)

    local tabPadding = Instance.new('UIPadding')
    tabPadding.Name   = 'PPD'
    tabPadding.Parent = tabScroll

    -- Content Panel (ขวา)
    local contentPanel = Instance.new('Frame')
    contentPanel.Name                 = 'Page'
    contentPanel.Parent               = mainFrame
    contentPanel.BackgroundColor3     = _G.Dark
    contentPanel.Position             = UDim2.new(0, 166, 0, 45)
    contentPanel.Size                 = UDim2.new(0, 350, 0, 275)
    contentPanel.BackgroundTransparency = 1

    local contentCorner = Instance.new('UICorner')
    contentCorner.CornerRadius = UDim.new(0, 3)
    contentCorner.Parent       = contentPanel

    local mainPage = Instance.new('Frame')
    mainPage.Name                 = 'MainPage'
    mainPage.Parent               = contentPanel
    mainPage.ClipsDescendants     = true
    mainPage.BackgroundTransparency = 1
    mainPage.Size                 = UDim2.new(1, 0, 1, 0)

    local pageFolder = Instance.new('Folder')
    pageFolder.Name   = 'PageList'
    pageFolder.Parent = mainPage

    local pageLayout = Instance.new('UIPageLayout')
    pageLayout.Parent                 = pageFolder
    pageLayout.SortOrder              = Enum.SortOrder.LayoutOrder
    pageLayout.EasingDirection        = Enum.EasingDirection.InOut
    pageLayout.EasingStyle            = Enum.EasingStyle.Quad
    pageLayout.FillDirection          = Enum.FillDirection.Vertical
    pageLayout.Padding                = UDim.new(0, 10)
    pageLayout.TweenTime              = 0
    pageLayout.GamepadInputEnabled    = false
    pageLayout.ScrollWheelInputEnabled = false
    pageLayout.TouchInputEnabled      = false

    -- ============================================================
    --  DRAG: ลาก Window ด้วย TopBar
    -- ============================================================
    makeDraggable(topBar, mainFrame)

    -- ============================================================
    --  RESIZE: ปรับขนาด Window ด้วย resize handle
    -- ============================================================
    local resizing = false

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            mainFrame.Size   = UDim2.new(0, math.clamp(input.Position.X - mainFrame.AbsolutePosition.X, 524, math.huge), 0, math.clamp(input.Position.Y - mainFrame.AbsolutePosition.Y, 322, math.huge))
            contentPanel.Size = UDim2.new(0, math.clamp(input.Position.X - contentPanel.AbsolutePosition.X - 8, 350, math.huge), 0, math.clamp(input.Position.Y - contentPanel.AbsolutePosition.Y - 8, 270, math.huge))
            tabPanel.Size    = UDim2.new(0, 148, 0, math.clamp(input.Position.Y - tabPanel.AbsolutePosition.Y - 8, 270, math.huge))
        end
    end)

    -- ============================================================
    --  TOGGLE: ปุ่ม Hide + Toggle button + Keyboard (Insert)
    -- ============================================================
    local function toggleVisible()
        local hub = CoreGui:FindFirstChild('HAYATEXHUB')
        if hub then hub.Enabled = not hub.Enabled end
    end

    hideBtn.MouseButton1Click:Connect(toggleVisible)
    toggleBtn.MouseButton1Click:Connect(toggleVisible)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleVisible()
        end
    end)

    -- ============================================================
    --  UPDATE CANVAS SIZE (ใช้ Heartbeat แทน Stepped)
    -- ============================================================
    RunService.Heartbeat:Connect(function()
        pcall(function()
            tabScroll.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y)
        end)
    end)

    -- ============================================================
    --  ALERT FUNCTION
    -- ============================================================
    function HayateX:Alert(message)
        local alertParent = CoreGui:FindFirstChild('AlertFrame')
        if not alertParent then return end

        -- ลบ alert เก่า
        local old = alertParent:FindFirstChild('Frame')
        if old then old:Destroy() end

        local alertFrame = Instance.new('Frame')
        alertFrame.Name                 = 'Frame'
        alertFrame.Parent               = alertParent
        alertFrame.BackgroundColor3     = _G.Dark
        alertFrame.BackgroundTransparency = 0.1
        alertFrame.Position             = UDim2.new(1, 0, 0, 0)
        alertFrame.Size                 = UDim2.new(0, 200, 0, 60)

        local alertStroke = Instance.new('UIStroke')
        alertStroke.Color       = _G.Primary
        alertStroke.Thickness   = 1
        alertStroke.Transparency = 0
        alertStroke.Parent      = alertFrame

        local alertCorner = Instance.new('UICorner')
        alertCorner.CornerRadius = UDim.new(0, 5)
        alertCorner.Parent       = alertFrame

        local alertIcon = Instance.new('ImageLabel')
        alertIcon.Name                 = 'Icon'
        alertIcon.Parent               = alertFrame
        alertIcon.BackgroundTransparency = 1
        alertIcon.Position             = UDim2.new(0, 8, 0, 8)
        alertIcon.Size                 = UDim2.new(0, 45, 0, 45)
        alertIcon.Image                = 'rbxassetid://13940080072'
        alertIcon.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

        local alertTitle = Instance.new('TextLabel')
        alertTitle.Parent               = alertFrame
        alertTitle.BackgroundTransparency = 1
        alertTitle.Position             = UDim2.new(0, 55, 0, 14)
        alertTitle.Size                 = UDim2.new(0, 140, 0, 20)
        alertTitle.Font                 = Enum.Font.GothamBold
        alertTitle.Text                 = 'HayateX Hub'
        alertTitle.TextColor3           = Color3.fromRGB(255, 255, 255)
        alertTitle.TextSize             = 16
        alertTitle.TextXAlignment       = Enum.TextXAlignment.Left
        alertTitle.BackgroundColor3     = Color3.fromRGB(150, 150, 150)

        local alertMsg = Instance.new('TextLabel')
        alertMsg.Parent               = alertFrame
        alertMsg.BackgroundTransparency = 1
        alertMsg.Position             = UDim2.new(0, 55, 0, 33)
        alertMsg.Size                 = UDim2.new(0, 140, 0, 20)
        alertMsg.Font                 = Enum.Font.GothamSemibold
        alertMsg.TextTransparency     = 0.3
        alertMsg.Text                 = message
        alertMsg.TextColor3           = Color3.fromRGB(200, 200, 200)
        alertMsg.TextSize             = 12
        alertMsg.TextXAlignment       = Enum.TextXAlignment.Left
        alertMsg.BackgroundColor3     = Color3.fromRGB(150, 150, 150)

        -- Animate in/out
        alertFrame:TweenPosition(UDim2.new(1, -205, 0, 0), 'Out', 'Quad', 0.4, true)
        task.wait(2)
        alertFrame:TweenPosition(UDim2.new(1, 0, 0, 0), 'Out', 'Quad', 0.5, true)
        task.wait(0.6)
        alertFrame:Destroy()
    end

    -- ============================================================
    --  RETURN: TAB FUNCTION
    -- ============================================================
    return {
        Tab = function(_, tabName, tabIcon)
            -- Tab Button
            local tabBtn = Instance.new('TextButton')
            tabBtn.Parent               = tabScroll
            tabBtn.Name                 = tabName .. 'Server'
            tabBtn.Text                 = ''
            tabBtn.BackgroundColor3     = _G.Primary
            tabBtn.BackgroundTransparency = 1
            tabBtn.Size                 = UDim2.new(1, 0, 0, 35)
            tabBtn.Font                 = Enum.Font.GothamSemibold
            tabBtn.TextColor3           = Color3.fromRGB(255, 255, 255)
            tabBtn.TextSize             = 12
            tabBtn.TextTransparency     = 0.9

            local tabCorner = Instance.new('UICorner')
            tabCorner.CornerRadius = UDim.new(0, 5)
            tabCorner.Parent       = tabBtn

            -- Selected indicator bar
            local selectedBar = Instance.new('Frame')
            selectedBar.Name                 = 'SelectedTab'
            selectedBar.Parent               = tabBtn
            selectedBar.BackgroundColor3     = _G.Primary
            selectedBar.BackgroundTransparency = 0
            selectedBar.Size                 = UDim2.new(0, 3, 0, 0)
            selectedBar.Position             = UDim2.new(0, 0, 0.5, 0)
            selectedBar.AnchorPoint          = Vector2.new(0, 0.5)
            selectedBar.ZIndex               = 4

            local selectedBarCorner = Instance.new('UICorner')
            selectedBarCorner.CornerRadius = UDim.new(0, 100)
            selectedBarCorner.Parent       = selectedBar

            -- Tab Title
            local tabTitle = Instance.new('TextLabel')
            tabTitle.Name                 = 'Title'
            tabTitle.Parent               = tabBtn
            tabTitle.BackgroundTransparency = 1
            tabTitle.Position             = UDim2.new(0, 30, 0.5, 0)
            tabTitle.Size                 = UDim2.new(0, 100, 0, 30)
            tabTitle.Font                 = Enum.Font.GothamSemibold
            tabTitle.Text                 = tabName
            tabTitle.AnchorPoint          = Vector2.new(0, 0.5)
            tabTitle.TextColor3           = Color3.fromRGB(255, 255, 255)
            tabTitle.TextTransparency     = 0.4
            tabTitle.TextSize             = 13
            tabTitle.TextXAlignment       = Enum.TextXAlignment.Left
            tabTitle.BackgroundColor3     = Color3.fromRGB(150, 150, 150)

            -- Tab Icon
            local tabIconImg = Instance.new('ImageLabel')
            tabIconImg.Name                 = 'IDK'
            tabIconImg.Parent               = tabBtn
            tabIconImg.BackgroundTransparency = 1
            tabIconImg.ImageTransparency    = 0.3
            tabIconImg.Position             = UDim2.new(0, 7, 0.5, 0)
            tabIconImg.Size                 = UDim2.new(0, 15, 0, 15)
            tabIconImg.AnchorPoint          = Vector2.new(0, 0.5)
            tabIconImg.Image                = tabIcon or ''
            tabIconImg.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

            -- Content ScrollingFrame สำหรับ tab นี้
            local contentScroll = Instance.new('ScrollingFrame')
            contentScroll.Name                 = tabName .. '_Page'
            contentScroll.Parent               = pageFolder
            contentScroll.Active               = true
            contentScroll.BackgroundTransparency = 1
            contentScroll.Position             = UDim2.new(0, 0, 0, 0)
            contentScroll.Size                 = UDim2.new(1, 0, 1, 0)
            contentScroll.ScrollBarThickness   = 0
            contentScroll.ScrollingDirection   = Enum.ScrollingDirection.Y
            contentScroll.BackgroundColor3     = _G.Dark

            local contentPadding = Instance.new('UIPadding')
            contentPadding.Parent = contentScroll

            local contentList = Instance.new('UIListLayout')
            contentList.Padding    = UDim.new(0, 3)
            contentList.Parent     = contentScroll
            contentList.SortOrder  = Enum.SortOrder.LayoutOrder

            -- อัพเดต canvas
            RunService.Heartbeat:Connect(function()
                pcall(function()
                    contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y)
                end)
            end)

            -- Helper: deselect all tabs
            local function deselectAll()
                for _, child in ipairs(tabScroll:GetChildren()) do
                    if child:IsA('TextButton') then
                        TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(child.SelectedTab, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 0)}):Play()
                        TweenService:Create(child.IDK, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                        TweenService:Create(child.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                    end
                end
            end

            -- Helper: select this tab
            local function selectThis()
                TweenService:Create(tabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
                TweenService:Create(selectedBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 15)}):Play()
                TweenService:Create(tabIconImg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
                TweenService:Create(tabTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            end

            tabBtn.MouseButton1Click:Connect(function()
                deselectAll()
                selectThis()

                -- Jump ไปยัง page ที่ถูกต้อง
                local pageName = string.gsub(tabBtn.Name, 'Server', '') .. '_Page'
                for _, child in ipairs(pageFolder:GetChildren()) do
                    if child.Name == pageName then
                        pageLayout:JumpTo(child)
                        break
                    end
                end
            end)

            -- Auto-select แท็บแรก
            if not isFirstTab then
                isFirstTab = true
                task.defer(function()
                    deselectAll()
                    selectThis()
                    pageLayout:JumpToIndex(0)
                end)
            end

            -- ============================================================
            --  RETURN: ELEMENT FUNCTIONS
            -- ============================================================
            return {

                -- ─── BUTTON ───────────────────────────────────────────
                Button = function(_, label, callback)
                    local btnFrame = Instance.new('Frame')
                    btnFrame.Name                 = 'Button'
                    btnFrame.Parent               = contentScroll
                    btnFrame.BackgroundColor3     = _G.Primary
                    btnFrame.BackgroundTransparency = 0.8
                    btnFrame.Size                 = UDim2.new(1, 0, 0, 36)

                    local btnFrameCorner = Instance.new('UICorner')
                    btnFrameCorner.CornerRadius = UDim.new(0, 5)
                    btnFrameCorner.Parent       = btnFrame

                    local btnLabel = Instance.new('TextLabel')
                    btnLabel.Name                 = 'TextLabel'
                    btnLabel.Parent               = btnFrame
                    btnLabel.BackgroundTransparency = 1
                    btnLabel.AnchorPoint          = Vector2.new(0, 0.5)
                    btnLabel.Position             = UDim2.new(0, 15, 0.5, 0)
                    btnLabel.Size                 = UDim2.new(1, -50, 1, 0)
                    btnLabel.Font                 = Enum.Font.GothamSemibold
                    btnLabel.Text                 = label
                    btnLabel.TextXAlignment       = Enum.TextXAlignment.Left
                    btnLabel.TextColor3           = Color3.fromRGB(255, 255, 255)
                    btnLabel.TextSize             = 13
                    btnLabel.BackgroundColor3     = _G.Primary

                    local clickBtn = Instance.new('TextButton')
                    clickBtn.Name                 = 'TextButton'
                    clickBtn.Parent               = btnFrame
                    clickBtn.BackgroundColor3     = _G.Primary
                    clickBtn.BackgroundTransparency = 0
                    clickBtn.AnchorPoint          = Vector2.new(1, 0.5)
                    clickBtn.Position             = UDim2.new(1, -10, 0.5, 0)
                    clickBtn.Size                 = UDim2.new(0, 22, 0, 22)
                    clickBtn.Font                 = Enum.Font.GothamSemibold
                    clickBtn.Text                 = ''
                    clickBtn.TextColor3           = Color3.fromRGB(255, 255, 255)
                    clickBtn.TextSize             = 13

                    local clickBtnCorner = Instance.new('UICorner')
                    clickBtnCorner.CornerRadius = UDim.new(0, 4)
                    clickBtnCorner.Parent       = clickBtn

                    local clickIcon = Instance.new('ImageLabel')
                    clickIcon.Name                 = 'ImageLabel'
                    clickIcon.Parent               = clickBtn
                    clickIcon.BackgroundTransparency = 1
                    clickIcon.AnchorPoint          = Vector2.new(0.5, 0.5)
                    clickIcon.Position             = UDim2.new(0.5, 0, 0.5, 0)
                    clickIcon.Size                 = UDim2.new(0, 15, 0, 15)
                    clickIcon.Image                = 'rbxassetid://10723375250'
                    clickIcon.ImageTransparency    = 0.2
                    clickIcon.ImageColor3          = Color3.fromRGB(245, 245, 245)
                    clickIcon.BackgroundColor3     = _G.Primary

                    local blackOverlay = Instance.new('Frame')
                    blackOverlay.Name                 = 'Black'
                    blackOverlay.Parent               = btnFrame
                    blackOverlay.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
                    blackOverlay.BackgroundTransparency = 1
                    blackOverlay.BorderSizePixel      = 0
                    blackOverlay.Position             = UDim2.new(0, 0, 0, 0)
                    blackOverlay.Size                 = UDim2.new(1, 0, 0, 33)

                    local blackCorner = Instance.new('UICorner')
                    blackCorner.CornerRadius = UDim.new(0, 5)
                    blackCorner.Parent       = blackOverlay

                    clickBtn.MouseButton1Click:Connect(function()
                        pcall(callback)
                    end)
                end,

                -- ─── TOGGLE ───────────────────────────────────────────
                Toggle = function(_, label, defaultVal, description, callback)
                    local state = defaultVal or false
                    _G.TrueColor  = _G.Primary

                    local toggleFrame = Instance.new('TextButton')
                    toggleFrame.Name                 = 'Button'
                    toggleFrame.Parent               = contentScroll
                    toggleFrame.BackgroundColor3     = _G.Primary
                    toggleFrame.BackgroundTransparency = 0.8
                    toggleFrame.Size                 = UDim2.new(1, 0, 0, description and 46 or 36)
                    toggleFrame.AutoButtonColor      = false
                    toggleFrame.Font                 = Enum.Font.SourceSans
                    toggleFrame.Text                 = ''
                    toggleFrame.TextColor3           = Color3.fromRGB(0, 0, 0)
                    toggleFrame.TextSize             = 11

                    local toggleFrameCorner = Instance.new('UICorner')
                    toggleFrameCorner.CornerRadius = UDim.new(0, 5)
                    toggleFrameCorner.Parent       = toggleFrame

                    local labelMain = Instance.new('TextLabel')
                    labelMain.Parent               = toggleFrame
                    labelMain.BackgroundTransparency = 1
                    labelMain.Size                 = UDim2.new(1, 0, 0, 35)
                    labelMain.Font                 = Enum.Font.GothamSemibold
                    labelMain.Text                 = label
                    labelMain.TextColor3           = Color3.fromRGB(255, 255, 255)
                    labelMain.TextSize             = 13
                    labelMain.TextXAlignment       = Enum.TextXAlignment.Left
                    labelMain.AnchorPoint          = Vector2.new(0, 0.5)
                    labelMain.BackgroundColor3     = Color3.fromRGB(150, 150, 150)

                    if description then
                        labelMain.Position = UDim2.new(0, 15, 0.5, -5)
                    else
                        labelMain.Position = UDim2.new(0, 15, 0.5, 0)
                    end

                    if description then
                        local descLabel = Instance.new('TextLabel')
                        descLabel.Parent               = labelMain
                        descLabel.BackgroundTransparency = 1
                        descLabel.Position             = UDim2.new(0, 0, 0, 22)
                        descLabel.Size                 = UDim2.new(0, 280, 0, 16)
                        descLabel.Font                 = Enum.Font.Gotham
                        descLabel.Text                 = description
                        descLabel.TextColor3           = Color3.fromRGB(200, 200, 200)
                        descLabel.TextSize             = 10
                        descLabel.TextXAlignment       = Enum.TextXAlignment.Left
                        descLabel.BackgroundColor3     = Color3.fromRGB(150, 150, 150)
                    end

                    -- Toggle Track
                    local track = Instance.new('Frame')
                    track.Name                 = 'ToggleFrame'
                    track.Parent               = toggleFrame
                    track.BackgroundColor3     = _G.Dark
                    track.BackgroundTransparency = 1
                    track.Position             = UDim2.new(1, -10, 0.5, 0)
                    track.Size                 = UDim2.new(0, 35, 0, 20)
                    track.AnchorPoint          = Vector2.new(1, 0.5)

                    local trackCorner = Instance.new('UICorner')
                    trackCorner.CornerRadius = UDim.new(0, 10)
                    trackCorner.Parent       = track

                    local trackBtn = Instance.new('TextButton')
                    trackBtn.Name                 = 'ToggleImage'
                    trackBtn.Parent               = track
                    trackBtn.BackgroundColor3     = _G.Dark
                    trackBtn.BackgroundTransparency = 0
                    trackBtn.Position             = UDim2.new(0, 0, 0, 0)
                    trackBtn.AnchorPoint          = Vector2.new(0, 0)
                    trackBtn.Size                 = UDim2.new(1, 0, 1, 0)
                    trackBtn.Text                 = ''
                    trackBtn.AutoButtonColor      = false

                    local trackBtnCorner = Instance.new('UICorner')
                    trackBtnCorner.CornerRadius = UDim.new(0, 10)
                    trackBtnCorner.Parent       = trackBtn

                    local trackStroke = Instance.new('UIStroke')
                    trackStroke.Color       = _G.Primary
                    trackStroke.Thickness   = 1
                    trackStroke.Transparency = 0
                    trackStroke.Parent      = track

                    local knob = Instance.new('Frame')
                    knob.Name                 = 'Circle'
                    knob.Parent               = trackBtn
                    knob.BackgroundColor3     = _G.Primary
                    knob.BackgroundTransparency = 0
                    knob.Position             = UDim2.new(0, 3, 0.5, 0)
                    knob.Size                 = UDim2.new(0, 14, 0, 14)
                    knob.AnchorPoint          = Vector2.new(0, 0.5)

                    local knobCorner = Instance.new('UICorner')
                    knobCorner.CornerRadius = UDim.new(0, 10)
                    knobCorner.Parent       = knob

                    local function applyState(on, instant)
                        local speed = instant and 0 or 0.4
                        if on then
                            trackStroke.Thickness = 0
                            knob:TweenPosition(UDim2.new(0, 18, 0.5, 0), 'Out', 'Sine', instant and 0 or 0.2, true)
                            TweenService:Create(knob, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.Dark}):Play()
                            TweenService:Create(trackBtn, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.Primary}):Play()
                        else
                            trackStroke.Thickness = 1
                            knob:TweenPosition(UDim2.new(0, 3, 0.5, 0), 'Out', 'Sine', instant and 0 or 0.2, true)
                            TweenService:Create(knob, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.Primary}):Play()
                            TweenService:Create(trackBtn, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.Dark}):Play()
                        end
                    end

                    trackBtn.MouseButton1Click:Connect(function()
                        state = not state
                        applyState(state, false)
                        pcall(callback, state)
                    end)

                    -- Apply default
                    if state then
                        applyState(true, true)
                        pcall(callback, true)
                    end
                end,

                -- ─── DROPDOWN ─────────────────────────────────────────
                Dropdown = function(_, label, items, defaultItem, callback)
                    local isOpen = false

                    local dropFrame = Instance.new('Frame')
                    dropFrame.Name                 = 'Dropdown'
                    dropFrame.Parent               = contentScroll
                    dropFrame.BackgroundColor3     = _G.Primary
                    dropFrame.BackgroundTransparency = 0.8
                    dropFrame.ClipsDescendants     = false
                    dropFrame.Size                 = UDim2.new(1, 0, 0, 40)

                    local dropCorner = Instance.new('UICorner')
                    dropCorner.CornerRadius = UDim.new(0, 5)
                    dropCorner.Parent       = dropFrame

                    local dropTitle = Instance.new('TextLabel')
                    dropTitle.Name                 = 'DropTitle'
                    dropTitle.Parent               = dropFrame
                    dropTitle.BackgroundTransparency = 1
                    dropTitle.Size                 = UDim2.new(1, 0, 0, 30)
                    dropTitle.Font                 = Enum.Font.GothamSemibold
                    dropTitle.Text                 = label
                    dropTitle.TextColor3           = Color3.fromRGB(255, 255, 255)
                    dropTitle.TextSize             = 13
                    dropTitle.TextXAlignment       = Enum.TextXAlignment.Left
                    dropTitle.Position             = UDim2.new(0, 15, 0, 5)
                    dropTitle.AnchorPoint          = Vector2.new(0, 0)
                    dropTitle.BackgroundColor3     = _G.Primary

                    local selectBtn = Instance.new('TextButton')
                    selectBtn.Name                 = 'SelectItems'
                    selectBtn.Parent               = dropFrame
                    selectBtn.BackgroundColor3     = _G.Dark
                    selectBtn.TextColor3           = Color3.fromRGB(255, 255, 255)
                    selectBtn.BackgroundTransparency = 0.1
                    selectBtn.Position             = UDim2.new(1, -5, 0, 5)
                    selectBtn.Size                 = UDim2.new(0, 100, 0, 30)
                    selectBtn.AnchorPoint          = Vector2.new(1, 0)
                    selectBtn.Font                 = Enum.Font.GothamMedium
                    selectBtn.TextSize             = 9
                    selectBtn.ZIndex               = 1
                    selectBtn.ClipsDescendants     = true
                    selectBtn.TextXAlignment       = Enum.TextXAlignment.Left
                    selectBtn.Text                 = defaultItem and ('   ' .. defaultItem) or '   Select Items'

                    local selectBtnCorner = Instance.new('UICorner')
                    selectBtnCorner.CornerRadius = UDim.new(0, 5)
                    selectBtnCorner.Parent       = selectBtn

                    local dropListFrame = Instance.new('Frame')
                    dropListFrame.Name                 = 'DropdownFrameScroll'
                    dropListFrame.Parent               = dropFrame
                    dropListFrame.BackgroundColor3     = _G.Dark
                    dropListFrame.BackgroundTransparency = 0
                    dropListFrame.ClipsDescendants     = true
                    dropListFrame.Size                 = UDim2.new(1, -10, 0, 100)
                    dropListFrame.Position             = UDim2.new(0, 5, 0, 40)
                    dropListFrame.Visible              = false
                    dropListFrame.AnchorPoint          = Vector2.new(0, 0)

                    local dropListCorner = Instance.new('UICorner')
                    dropListCorner.CornerRadius = UDim.new(0, 5)
                    dropListCorner.Parent       = dropListFrame

                    local dropScroll = Instance.new('ScrollingFrame')
                    dropScroll.Name                 = 'DropScroll'
                    dropScroll.Parent               = dropListFrame
                    dropScroll.ScrollingDirection   = Enum.ScrollingDirection.Y
                    dropScroll.Active               = true
                    dropScroll.BackgroundTransparency = 1
                    dropScroll.BorderSizePixel      = 0
                    dropScroll.Position             = UDim2.new(0, 0, 0, 10)
                    dropScroll.Size                 = UDim2.new(1, 0, 0, 80)
                    dropScroll.ClipsDescendants     = true
                    dropScroll.ScrollBarThickness   = 3
                    dropScroll.ZIndex               = 3
                    dropScroll.BackgroundColor3     = Color3.fromRGB(255, 255, 255)
                    dropScroll.AnchorPoint          = Vector2.new(0, 0)

                    local dropScrollCorner = Instance.new('UICorner')
                    dropScrollCorner.CornerRadius = UDim.new(0, 5)
                    dropScrollCorner.Parent       = dropScroll

                    local dropPad = Instance.new('UIPadding')
                    dropPad.PaddingLeft  = UDim.new(0, 10)
                    dropPad.PaddingRight = UDim.new(0, 10)
                    dropPad.Name         = 'PaddingDrop'
                    dropPad.Parent       = dropScroll

                    local dropList = Instance.new('UIListLayout')
                    dropList.Parent    = dropScroll
                    dropList.SortOrder = Enum.SortOrder.LayoutOrder
                    dropList.Padding   = UDim.new(0, 1)

                    local function closeDropdown()
                        isOpen = false
                        TweenService:Create(dropListFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 0)}):Play()
                        task.delay(0.3, function() dropListFrame.Visible = false end)
                        TweenService:Create(dropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    end

                    local function openDropdown()
                        isOpen = true
                        dropListFrame.Visible = true
                        TweenService:Create(dropListFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 100)}):Play()
                        TweenService:Create(dropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 145)}):Play()
                    end

                    local function createItem(itemText)
                        local item = Instance.new('TextButton')
                        item.Name                 = 'Item'
                        item.Parent               = dropScroll
                        item.BackgroundColor3     = _G.Primary
                        item.BackgroundTransparency = 1
                        item.Size                 = UDim2.new(1, 0, 0, 30)
                        item.Font                 = Enum.Font.GothamSemibold
                        item.Text                 = tostring(itemText)
                        item.TextColor3           = Color3.fromRGB(255, 255, 255)
                        item.TextSize             = 11
                        item.TextTransparency     = 0.5
                        item.TextXAlignment       = Enum.TextXAlignment.Left
                        item.ZIndex               = 4

                        local itemPad = Instance.new('UIPadding')
                        itemPad.PaddingLeft = UDim.new(0, 8)
                        itemPad.Parent      = item

                        local itemCorner = Instance.new('UICorner')
                        itemCorner.CornerRadius = UDim.new(0, 5)
                        itemCorner.Parent       = item

                        local selBar = Instance.new('Frame')
                        selBar.Name                 = 'SelectedItems'
                        selBar.Parent               = item
                        selBar.BackgroundColor3     = _G.Primary
                        selBar.BackgroundTransparency = 1
                        selBar.Size                 = UDim2.new(0, 3, 0.4, 0)
                        selBar.Position             = UDim2.new(0, -8, 0.5, 0)
                        selBar.AnchorPoint          = Vector2.new(0, 0.5)
                        selBar.ZIndex               = 4

                        local selBarCorner = Instance.new('UICorner')
                        selBarCorner.CornerRadius = UDim.new(0, 999)
                        selBarCorner.Parent       = selBar

                        item.MouseEnter:Connect(function()
                            TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, BackgroundTransparency = 0.8}):Play()
                            TweenService:Create(selBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                        end)
                        item.MouseLeave:Connect(function()
                            TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.5, BackgroundTransparency = 1}):Play()
                            TweenService:Create(selBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                        end)
                        item.MouseButton1Click:Connect(function()
                            selectBtn.Text = '   ' .. item.Text
                            pcall(callback, item.Text)
                            closeDropdown()
                        end)
                    end

                    -- สร้าง items เริ่มต้น
                    for _, v in ipairs(items) do
                        createItem(v)
                    end

                    dropScroll.CanvasSize = UDim2.new(0, 0, 0, dropList.AbsoluteContentSize.Y)

                    selectBtn.MouseButton1Click:Connect(function()
                        if isOpen then closeDropdown() else openDropdown() end
                    end)

                    return {
                        Add = function(_, newItem)
                            createItem(newItem)
                            dropScroll.CanvasSize = UDim2.new(0, 0, 0, dropList.AbsoluteContentSize.Y)
                        end,
                        Clear = function(_)
                            selectBtn.Text = '   Select Items'
                            closeDropdown()
                            for _, child in ipairs(dropScroll:GetChildren()) do
                                if child:IsA('TextButton') then child:Destroy() end
                            end
                        end,
                    }
                end,

                -- ─── SLIDER ───────────────────────────────────────────
                Slider = function(_, label, minVal, maxVal, defaultVal, callback)
                    local Value = defaultVal or minVal

                    local sliderOuter = Instance.new('Frame')
                    sliderOuter.Name                 = 'Slider'
                    sliderOuter.Parent               = contentScroll
                    sliderOuter.BackgroundTransparency = 1
                    sliderOuter.Size                 = UDim2.new(1, 0, 0, 45)

                    local sliderOuterCorner = Instance.new('UICorner')
                    sliderOuterCorner.Name         = 'slidercorner'
                    sliderOuterCorner.CornerRadius = UDim.new(0, 5)
                    sliderOuterCorner.Parent       = sliderOuter

                    local sliderInner = Instance.new('Frame')
                    sliderInner.Name                 = 'sliderr'
                    sliderInner.Parent               = sliderOuter
                    sliderInner.BackgroundColor3     = _G.Primary
                    sliderInner.BackgroundTransparency = 0.8
                    sliderInner.Position             = UDim2.new(0, 0, 0, 0)
                    sliderInner.Size                 = UDim2.new(1, 0, 0, 45)

                    local sliderInnerCorner = Instance.new('UICorner')
                    sliderInnerCorner.Name         = 'sliderrcorner'
                    sliderInnerCorner.CornerRadius = UDim.new(0, 5)
                    sliderInnerCorner.Parent       = sliderInner

                    local sliderLabel = Instance.new('TextLabel')
                    sliderLabel.Parent               = sliderInner
                    sliderLabel.BackgroundTransparency = 1
                    sliderLabel.Position             = UDim2.new(0, 15, 0.5, 0)
                    sliderLabel.Size                 = UDim2.new(0.5, 0, 0, 30)
                    sliderLabel.Font                 = Enum.Font.GothamSemibold
                    sliderLabel.Text                 = label
                    sliderLabel.AnchorPoint          = Vector2.new(0, 0.5)
                    sliderLabel.TextColor3           = Color3.fromRGB(255, 255, 255)
                    sliderLabel.TextSize             = 13
                    sliderLabel.TextXAlignment       = Enum.TextXAlignment.Left
                    sliderLabel.BackgroundColor3     = Color3.fromRGB(150, 150, 150)

                    -- Track bar
                    local track = Instance.new('Frame')
                    track.Name                 = 'bar'
                    track.Parent               = sliderInner
                    track.BackgroundColor3     = _G.Primary
                    track.Size                 = UDim2.new(0, 100, 0, 4)
                    track.Position             = UDim2.new(1, -10, 0.5, 10)
                    track.BackgroundTransparency = 0.8
                    track.AnchorPoint          = Vector2.new(1, 0.5)

                    local trackCorner = Instance.new('UICorner')
                    trackCorner.Name         = 'barcorner'
                    trackCorner.CornerRadius = UDim.new(0, 5)
                    trackCorner.Parent       = track

                    -- Fill bar
                    local fill = Instance.new('Frame')
                    fill.Name                 = 'bar1'
                    fill.Parent               = track
                    fill.BackgroundColor3     = _G.Dark
                    fill.BackgroundTransparency = 0
                    fill.Size                 = UDim2.new((Value - minVal) / (maxVal - minVal), 0, 0, 4)

                    local fillCorner = Instance.new('UICorner')
                    fillCorner.Name         = 'bar1corner'
                    fillCorner.CornerRadius = UDim.new(0, 5)
                    fillCorner.Parent       = fill

                    -- Knob
                    local knob = Instance.new('Frame')
                    knob.Name                 = 'circlebar'
                    knob.Parent               = fill
                    knob.BackgroundColor3     = _G.Dark
                    knob.Position             = UDim2.new(1, 0, 0, -5)
                    knob.AnchorPoint          = Vector2.new(0.5, 0)
                    knob.Size                 = UDim2.new(0, 13, 0, 13)

                    local knobCorner = Instance.new('UICorner')
                    knobCorner.CornerRadius = UDim.new(0, 100)
                    knobCorner.Parent       = knob

                    -- Value textbox
                    local valueBox = Instance.new('TextBox')
                    valueBox.Parent               = sliderInner
                    valueBox.BackgroundColor3     = _G.Dark
                    valueBox.BackgroundTransparency = 0.1
                    valueBox.Font                 = Enum.Font.Code
                    valueBox.Size                 = UDim2.new(0, 35, 0, 15)
                    valueBox.AnchorPoint          = Vector2.new(1, 0.5)
                    valueBox.Position             = UDim2.new(1, -10, 0.5, -10)
                    valueBox.TextColor3           = Color3.fromRGB(255, 255, 255)
                    valueBox.TextSize             = 9
                    valueBox.Text                 = tostring(Value)
                    valueBox.TextTransparency     = 0.1
                    valueBox.ClearTextOnFocus     = false
                    valueBox.TextXAlignment       = Enum.TextXAlignment.Center

                    local valueBoxCorner = Instance.new('UICorner')
                    valueBoxCorner.CornerRadius = UDim.new(0, 3)
                    valueBoxCorner.Parent       = valueBox

                    -- Drag state
                    local draggingSlider = false

                    local function updateSlider(posX)
                        local rel = math.clamp(posX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        local pct = rel / track.AbsoluteSize.X
                        Value = math.floor(pct * (maxVal - minVal) + minVal)
                        fill.Size = UDim2.new(0, rel, 0, 4)
                        knob.Position = UDim2.new(0, math.clamp(rel - 5, 0, track.AbsoluteSize.X), 0, -5)
                        valueBox.Text = tostring(Value)
                        pcall(callback, Value)
                    end

                    knob.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = true
                        end
                    end)
                    track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            updateSlider(input.Position.X)
                        end
                    end)

                    valueBox.FocusLost:Connect(function()
                        local typed = tonumber(valueBox.Text) or minVal
                        typed = math.clamp(typed, minVal, maxVal)
                        Value = typed
                        valueBox.Text = tostring(Value)
                        fill.Size = UDim2.new((Value - minVal) / (maxVal - minVal), 0, 0, 4)
                        pcall(callback, Value)
                    end)
                end,

                -- ─── TEXTBOX ──────────────────────────────────────────
                Textbox = function(_, label, callback)
                    local tbFrame = Instance.new('Frame')
                    tbFrame.Name                 = 'Textbox'
                    tbFrame.Parent               = contentScroll
                    tbFrame.BackgroundColor3     = _G.Primary
                    tbFrame.BackgroundTransparency = 0.8
                    tbFrame.Size                 = UDim2.new(1, 0, 0, 35)

                    local tbFrameCorner = Instance.new('UICorner')
                    tbFrameCorner.Name         = 'TextboxCorner'
                    tbFrameCorner.CornerRadius = UDim.new(0, 5)
                    tbFrameCorner.Parent       = tbFrame

                    local tbLabel = Instance.new('TextLabel')
                    tbLabel.Name                 = 'TextboxLabel'
                    tbLabel.Parent               = tbFrame
                    tbLabel.BackgroundTransparency = 1
                    tbLabel.Position             = UDim2.new(0, 15, 0.5, 0)
                    tbLabel.Text                 = label
                    tbLabel.Size                 = UDim2.new(1, 0, 0, 35)
                    tbLabel.Font                 = Enum.Font.GothamSemibold
                    tbLabel.AnchorPoint          = Vector2.new(0, 0.5)
                    tbLabel.TextColor3           = Color3.fromRGB(255, 255, 255)
                    tbLabel.TextSize             = 13
                    tbLabel.TextTransparency     = 0
                    tbLabel.TextXAlignment       = Enum.TextXAlignment.Left
                    tbLabel.BackgroundColor3     = _G.Primary

                    local tbInput = Instance.new('TextBox')
                    tbInput.Name                 = 'RealTextbox'
                    tbInput.Parent               = tbFrame
                    tbInput.BackgroundColor3     = _G.Dark
                    tbInput.BackgroundTransparency = 0.1
                    tbInput.Position             = UDim2.new(1, -5, 0.5, 0)
                    tbInput.AnchorPoint          = Vector2.new(1, 0.5)
                    tbInput.Size                 = UDim2.new(0, 80, 0, 25)
                    tbInput.Font                 = Enum.Font.GothamSemibold
                    tbInput.Text                 = ''
                    tbInput.TextColor3           = Color3.fromRGB(225, 225, 225)
                    tbInput.TextSize             = 11
                    tbInput.TextTransparency     = 0
                    tbInput.ClipsDescendants     = true

                    local tbInputCorner = Instance.new('UICorner')
                    tbInputCorner.CornerRadius = UDim.new(0, 5)
                    tbInputCorner.Parent       = tbInput

                    tbInput.FocusLost:Connect(function()
                        pcall(callback, tbInput.Text)
                    end)
                end,

                -- ─── LABEL ────────────────────────────────────────────
                Label = function(_, text)
                    local lbl = Instance.new('TextLabel')
                    lbl.Name                 = 'Label'
                    lbl.Parent               = contentScroll
                    lbl.BackgroundTransparency = 1
                    lbl.Size                 = UDim2.new(1, 0, 0, 20)
                    lbl.Font                 = Enum.Font.GothamSemibold
                    lbl.TextColor3           = Color3.fromRGB(225, 225, 225)
                    lbl.TextSize             = 13
                    lbl.Text                 = text
                    lbl.TextXAlignment       = Enum.TextXAlignment.Left
                    lbl.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

                    local lblPad = Instance.new('UIPadding')
                    lblPad.Name        = 'PaddingLabel'
                    lblPad.PaddingLeft = UDim.new(0, 2)
                    lblPad.Parent      = lbl

                    local api = {}
                    function api:Set(newText) lbl.Text = newText end
                    return api
                end,

                -- ─── SEPARATOR ────────────────────────────────────────
                Seperator = function(_, text)
                    local sepOuter = Instance.new('Frame')
                    sepOuter.Name                 = 'Seperator'
                    sepOuter.Parent               = contentScroll
                    sepOuter.BackgroundTransparency = 1
                    sepOuter.Size                 = UDim2.new(1, 0, 0, 36)

                    local sepText = Instance.new('TextLabel')
                    sepText.Name                 = 'Sep2'
                    sepText.Parent               = sepOuter
                    sepText.BackgroundTransparency = 1
                    sepText.AnchorPoint          = Vector2.new(0.5, 1)
                    sepText.Position             = UDim2.new(0.5, 0, 0, 30)
                    sepText.Size                 = UDim2.new(1, 0, 0, 36)
                    sepText.Font                 = Enum.Font.GothamBold
                    sepText.Text                 = text
                    sepText.TextColor3           = Color3.fromRGB(255, 255, 255)
                    sepText.TextSize             = 14
                    sepText.BackgroundColor3     = Color3.fromRGB(255, 255, 255)

                    local sepLine = Instance.new('Frame')
                    sepLine.Name                 = 'Sep3'
                    sepLine.Parent               = sepOuter
                    sepLine.BackgroundColor3     = _G.Primary
                    sepLine.BackgroundTransparency = 0
                    sepLine.BorderSizePixel      = 0
                    sepLine.AnchorPoint          = Vector2.new(0.5, 0.5)
                    sepLine.Position             = UDim2.new(0.5, 0, 0, 25)

                    local textW = TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge))
                    sepLine.Size = UDim2.new(0, textW.X * 0.7, 0, 3)

                    local sepLineCorner = Instance.new('UICorner')
                    sepLineCorner.CornerRadius = UDim.new(0, math.huge)
                    sepLineCorner.Parent       = sepLine
                end,

                -- ─── LINE ─────────────────────────────────────────────
                Line = function(_)
                    local lineOuter = Instance.new('Frame')
                    lineOuter.Name                 = 'Linee'
                    lineOuter.Parent               = contentScroll
                    lineOuter.BackgroundTransparency = 1
                    lineOuter.Position             = UDim2.new(0, 0, 0, 0)
                    lineOuter.Size                 = UDim2.new(1, 0, 0, 20)

                    local lineInner = Instance.new('Frame')
                    lineInner.Name                 = 'Line'
                    lineInner.Parent               = lineOuter
                    lineInner.BackgroundColor3     = Color3.new(125/255, 125/255, 125/255)
                    lineInner.BorderSizePixel      = 0
                    lineInner.Position             = UDim2.new(0, 0, 0, 10)
                    lineInner.Size                 = UDim2.new(1, 0, 0, 1)

                    local lineGrad = Instance.new('UIGradient')
                    lineGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   _G.Dark),
                        ColorSequenceKeypoint.new(0.4, _G.Primary),
                        ColorSequenceKeypoint.new(0.5, _G.Primary),
                        ColorSequenceKeypoint.new(0.6, _G.Primary),
                        ColorSequenceKeypoint.new(1,   _G.Dark),
                    })
                    lineGrad.Parent = lineInner
                end,
            }
        end,
    }
end

return HayateX
