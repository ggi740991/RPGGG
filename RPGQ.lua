-- 단독 실행 매크로 방지 우회 (대소문자 구별 X)
-- MacroGui가 이미 떠있어도, 새로 떠도 바로 처리
-- Input과 TextBox 이름 대소문자 상관없이 찾음

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then
    warn("[매크로 우회] PlayerGui 못 찾음 - 종료")
    return
end

print("[매크로 우회] 스크립트 시작 - PlayerGui 로드 완료")

local bypassCount = 0

-- 카운터 GUI
local counterGui = Instance.new("ScreenGui")
counterGui.Name = "MacroBypassCounter"
counterGui.ResetOnSpawn = false
counterGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0, 10)
label.BackgroundTransparency = 0.4
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.TextColor3 = Color3.fromRGB(255, 255, 0)
label.Text = "매크로 우회 대기 중... (0회)"
label.Font = Enum.Font.SourceSansBold
label.TextSize = 22
label.Parent = counterGui

print("[매크로 우회] 카운터 GUI 생성")

local function tryBypassMacro()
    pcall(function()
        local macroGui = nil
        -- MacroGui 이름 대소문자 무시하고 찾기
        for _, obj in ipairs(playerGui:GetChildren()) do
            if obj:IsA("ScreenGui") and string.lower(obj.Name) == "macrogui" then
                macroGui = obj
                print("[매크로 우회] MacroGui 발견 (대소문자 무시): " .. obj.Name)
                break
            end
        end

        if not macroGui then
            print("[매크로 우회] MacroGui 못 찾음 (대소문자 포함)")
            return
        end

        local inputLabel = nil
        local textBox = nil

        -- MacroGui 아래 모든 객체 뒤지면서 대소문자 무시로 찾기
        for _, obj in ipairs(macroGui:GetDescendants()) do
            local objNameLower = string.lower(obj.Name)

            if obj:IsA("TextLabel") and (objNameLower == "input" or obj.Text:find("%d%d%d%d")) then
                inputLabel = obj
                print(" → Input(TextLabel) 찾음: " .. obj:GetFullName() .. " (텍스트: " .. (obj.Text or "nil") .. ")")
            end

            if obj:IsA("TextBox") and objNameLower:find("text") or objNameLower:find("box") or objNameLower == "textbox" then
                textBox = obj
                print(" → TextBox 찾음: " .. obj:GetFullName() .. " (현재 값: " .. (obj.Text or "nil") .. ")")
            end

            if inputLabel and textBox then break end
        end

        if not inputLabel then
            print(" → Input(TextLabel) 못 찾음")
            return
        end
        if not textBox then
            print(" → TextBox 못 찾음 (이름에 text/box 포함된 게 없음)")
            return
        end

        local text = inputLabel.Text or ""
        if text == "" then
            print(" → Input 텍스트 비어있음")
            return
        end

        local cleanText = text:gsub("[^%d]", ""):sub(1, 4)
        print(" → 추출된 숫자: '" .. cleanText .. "'")

        if #cleanText ~= 4 then
            print(" → 숫자가 4자리가 아님")
            return
        end

        if textBox.Text == cleanText then
            print(" → 이미 같은 숫자 입력됨")
            return
        end

        -- 바로 입력
        textBox.Text = cleanText
        print(" → TextBox에 입력 완료: '" .. cleanText .. "'")
        print(" → 입력 후 실제 값: '" .. textBox.Text .. "'")

        bypassCount = bypassCount + 1
        label.Text = "매크로 우회: " .. bypassCount .. "회 (성공)"
        print(" → 성공! 카운트: " .. bypassCount)
    end)
end

-- 스크립트 실행 즉시 한 번 체크 (이미 떠있는 경우)
tryBypassMacro()

-- MacroGui가 새로 추가될 때마다 체크
playerGui.ChildAdded:Connect(function(child)
    if string.lower(child.Name) == "macrogui" then
        print("[매크로 우회] 새 MacroGui 감지! (대소문자 무시) 즉시 처리")
        tryBypassMacro()
    end
end)



local MONSTER_POSITIONS = {
    ["갑옷 고블린"] = Vector3.new(71, 142.34286499023438, 2500),
    ["고블린"] = Vector3.new(-69, 120.30000305175781, 2218),
    ["페어리"] = Vector3.new(-1200, 1.1499900817871094, 2236),
    ["포자링"] = Vector3.new(30, 11.841017723083496, 50),
    ["겨울성의 수호신"] = Vector3.new(3309.999755859375, 381.0714416503906, 5350.00048828125),
    ["나락화 박쥐"] = Vector3.new(-69, 120.30000305175781, 2218),
    ["나락화 수호자"] = Vector3.new(131, -534.7440795898438, 4708),
    ["눈사람"] = Vector3.new(614, 207.1503448486328, 4357),
    ["동굴 골렘"] = Vector3.new(-129, 60.04035568237305, 2628),
    ["마그마 블래스터"] = Vector3.new(-72, -213.89990234375, 3428),
    ["무사"] = Vector3.new(-871, 152.45999145507812, 3655),
    ["미라"] = Vector3.new(-106, 135.1693115234375, 4129),
    ["슬라임"] = Vector3.new(68, 142.3430938720703, 2614),
    ["샌드 슬라임"] = Vector3.new(-136, 125.43000793457031, 3569),
    ["예티"] = Vector3.new(1147, 164.89500427246094, 3839),
    ["선혈의 사무라이"] = Vector3.new(-1310.6466064453125, 223.47955322265625, 3568.743896484375),
    ["용암 골렘"] = Vector3.new(327, -168.61343383789062, 3066),
    ["타이탄 아머로드"] = Vector3.new(3056.999267578125, 375.0549621582031, 4665.9990234375),
    ["피라미드 수호자"] = Vector3.new(-540, 64.90074157714844, 4657),
    ["파괴의 광선, 인큐네이션"] = Vector3.new(3056.999267578125, 375.0549621582031, 4665.9990234375),
    ["갈색옷 주민"] = Vector3.new(-492.000244140625, 4.002931594848633, 1165.9996337890625),
    ["기사 주민"] = Vector3.new(25.000381469726562, 4.00006103515625, 964.9990844726562),
    ["다크 기사단장"] = Vector3.new(-162, 12.994091987609863, 1981),
    ["더 할루시네이션"] = Vector3.new(566, 140.85122680664062, 565),
    ["마나 광물"] = Vector3.new(1176, -84.3188247680664, 2356),
    ["마나 광석"] = Vector3.new(-1091, 3.5250186920166016, 2042),
    ["서리 늑대"] = Vector3.new(344, 22.55022621154785, 4070),
    ["순수한 마나 광석"] = Vector3.new(1405, -91.07728576660156, 2096),
    ["아르카나"] = Vector3.new(1065, 60.347862243652344, 4056),
    ["얼어붙은 핏빛"] = Vector3.new(-119, 99.0980224609375, 6256),
    ["용력석"] = Vector3.new(1141, -111.9031753540039, 2089),
    ["크람푸스"] = Vector3.new(-1610, 8.506329536437988, 3071),
    ["파라다이스 수장"] = Vector3.new(2208, 293.93072509765625, 2888),
    ["파란옷 주민"] = Vector3.new(-100.73590850830078, 4.00006103515625, 697.5418701171875),
}
local spawnList = {
    {name = "루나마을 스폰", pos = Vector3.new(-44.0300178527832, 130.2978515625, 1996.1300048828125)},
    {name = "메이플 스폰", pos = Vector3.new(-1440.09423828125, 193.31077575683594, 3793.40234375)},
    {name = "겨울스폰", pos = Vector3.new(338.06463623046875, 186.7691650390625, 3753.471923828125)},
    {name = "겨울성 스폰", pos = Vector3.new(2183.8564453125, 373.1597900390625, 4558.10107421875)},
    {name = "2차원 포털 앞", pos = Vector3.new(-37.03, 174.36, -2232.93)},
    {name = "루나성", pos = Vector3.new(-115.56657409667969, 4.43785285949707, 648.7597045898438)},
    {name = "미궁", pos = Vector3.new(-1647.788818359375, 0.22284305095672607, 2690.137939453125)},
    {name = "파라다이스", pos = Vector3.new(1021.406494140625, 78.89376068115234, 2947.400146484375)},
    {name = "프로스티아", pos = Vector3.new(-242.86607360839844, 18.665813446044922, 3275.5498046875)},
    {name = "프로스티아2", pos = Vector3.new(9.930479049682617, 32.68927764892578, 4849.27490234375)},
}
-- nameToKey 제거! (이름 그대로 사용)
local rememberedPos = nil
local exName, exVer = "Unknown", "??"
if identifyexecutor then
    local a, b = identifyexecutor()
    if a then
        exName, exVer = a, b
    end
end
if exName == "Solara" then
    game.Players.LocalPlayer:Kick("Solara 실행기는 지원되지 않습니다.(추천 실행기 : 제노)")
    return
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end
-- ========== 설정 ==========
local MOBS_FOLDER_NAME = "Mobs"
local SPAWN_FOLDER_NAME = "SpawnPoint"
local TP_DISTANCE = 5
local MOVE_SPEED = 100
local SPEED_MIN, SPEED_MAX = 1, 1000
local SNAP_THRESHOLD = 0.5
local LIST_HEIGHT = 260
local MoveMode = "Smooth"
local NoclipEnabled = false
local NoclipConnection = nil
local primaryWasNil = true
-- 오토클릭
local AutoClickEnabled = false
local AutoClickLoopRunning = false
local ClickInterval = 0.1
local ClickPressTime = 0.01
-- 상태
local AutoFarmEnabled = false
local CurrentTarget = nil
local TargetList = {}
local GUIObjects = {}
local FixedMonsterNames = {Primary = nil, Secondary = nil}
local FixedSpawnPoint = nil
local TP_DIRECTION = "Back"
-- UI 상호작용 플래그
local UIInteraction = false
local function GetDirectionLocalOffset(direction, distance)
    distance = distance or TP_DISTANCE
    if direction == "Back" then
        return Vector3.new(0, 0, distance) -- 기존: 순수 뒤
    elseif direction == "Front" then
        return Vector3.new(0, 0, -distance) -- 기존: 순수 앞
    elseif direction == "Left" then
        return Vector3.new(-distance, 0, 0) -- 기존: 순수 왼쪽
    elseif direction == "Right" then
        return Vector3.new(distance, 0, 0) -- 기존: 순수 오른쪽
    elseif direction == "Up" then
        return Vector3.new(0, distance, 0) -- 기존: 순수 위
    elseif direction == "Down" then
        -- ✅ 새로 추가: 뒤(Z+) + 아래(Y-) 대각선 (정확히 몬스터 뒤에서 아래로!)
        return Vector3.new(0, -distance * 0.7, distance * 0.8)
        -- Y: -70% (아래로 충분히), Z: +80% (뒤로 충분히) → 완벽 대각선
    else
        return Vector3.new(0, 0, distance)
    end
end
-- ========== 스타일 헬퍼 ==========
local function ApplyRounded(uiElement, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = uiElement
end
local function ApplyStroke(uiElement, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(230,230,230)
    stroke.Transparency = 0.75
    stroke.Parent = uiElement
end
local function CreateGUI()
    pcall(function()
        local old = game.CoreGui:FindFirstChild("AutoFarmGUI")
        if old then old:Destroy() end
    end)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoFarmGUI"
    ScreenGui.Parent = game.CoreGui
    -- 열기 버튼
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 70, 0, 30)
    OpenBtn.Position = UDim2.new(0, 16, 0, 16)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(24,24,24)
    OpenBtn.TextColor3 = Color3.fromRGB(240,240,240)
    OpenBtn.Text = "열기"
    OpenBtn.Font = Enum.Font.GothamSemibold
    OpenBtn.TextSize = 14
    OpenBtn.Parent = ScreenGui
    ApplyRounded(OpenBtn, 8)
    ApplyStroke(OpenBtn, 1, Color3.fromRGB(240,240,240))
    -- 메인 프레임
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 520, 0, 620)
    Frame.Position = UDim2.new(0.5, -260, 0.5, -310)
    Frame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Visible = false
    GUIObjects.Frame = Frame
    ApplyRounded(Frame, 14)
    ApplyStroke(Frame, 1.25, Color3.fromRGB(235,235,235))
    do
        local TweenService = game:GetService("TweenService")
        local gui = game.CoreGui.AutoFarmGUI
        local frame = gui.Frame
        local openBtn = gui:FindFirstChild("TextButton")
        local scale = 1.0
        local original = {} -- 원본 사이즈/포지션 저장용
        -- 원본 저장 (최초 1번만)
        local function SaveOriginal()
            if original.saved then return end
            original.saved = true
            original.frameSize = frame.Size
            original.framePos = frame.Position
            original.openSize = openBtn.Size
            original.openPos = openBtn.Position
            original.openText = openBtn.TextSize
            for _, obj in ipairs(frame:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    original[obj] = {
                        Size = obj.Size,
                        Position = obj.Position,
                        TextSize = (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.TextSize or nil
                    }
                end
            end
        end
        -- 스케일 적용
        local function ApplyScale(s)
            SaveOriginal()
            scale = s
            -- 메인 프레임
            frame.Size = UDim2.new(original.frameSize.X.Scale, original.frameSize.X.Offset * s, original.frameSize.Y.Scale, original.frameSize.Y.Offset * s)
            frame.Position = UDim2.new(original.framePos.X.Scale, original.framePos.X.Offset * s + (1-s)*260, original.framePos.Y.Scale, original.framePos.Y.Offset * s + (1-s)*310)
            -- 열기 버튼
            openBtn.Size = UDim2.new(0, original.openSize.X.Offset * s, 0, original.openSize.Y.Offset * s)
            openBtn.Position = UDim2.new(0, 16*s, 0, 16*s)
            openBtn.TextSize = original.openText * s
            -- 모든 자식 요소 (ScrollingFrame 포함 완벽 적용)
            for obj, data in pairs(original) do
                if typeof(data) == "table" and obj and obj.Parent then
                    if data.Size then
                        obj.Size = UDim2.new(data.Size.X.Scale, data.Size.X.Offset * s, data.Size.Y.Scale, data.Size.Y.Offset * s)
                    end
                    if data.Position then
                        obj.Position = UDim2.new(data.Position.X.Scale, data.Position.X.Offset * s, data.Position.Y.Scale, data.Position.Y.Offset * s)
                    end
                    if data.TextSize then
                        obj.TextSize = data.TextSize * s
                    end
                end
            end
        end
        -- 모바일 자동 축소
        if game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled then
            scale = 0.68
            ApplyScale(0.68)
        end
        -- − 버튼 (고정 크기)
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0,44,0,44)
        minus.Position = UDim2.new(0,14,0,56)
        minus.BackgroundColor3 = Color3.fromRGB(15,15,15)
        minus.Text = "−"
        minus.TextColor3 = Color3.new(1,1,1)
        minus.TextSize = 32
        minus.Font = Enum.Font.GothamBlack
        minus.Parent = gui
        ApplyRounded(minus,14)
        ApplyStroke(minus,2.5,Color3.new(1,1,1))
        -- + 버튼 (고정 크기)
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0,44,0,44)
        plus.Position = UDim2.new(0,64,0,56)
        plus.BackgroundColor3 = Color3.fromRGB(15,15,15)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(1,1,1)
        plus.TextSize = 28
        plus.Font = Enum.Font.GothamBlack
        plus.Parent = gui
        ApplyRounded(plus,14)
        ApplyStroke(plus,2.5,Color3.new(1,1,1))
        -- 클릭 이벤트
        minus.MouseButton1Click:Connect(function()
            if scale > 0.55 then
                ApplyScale(scale - 0.05)
            end
        end)
        plus.MouseButton1Click:Connect(function()
            if scale < 1.0 then
                ApplyScale(scale + 0.05)
            end
        end)
        -- 기존 − + 버튼 만들고 난 뒤 마지막에 이거만 추가 (또는 기존 거 교체)
        task.delay(1, function()
            if minus and minus.Parent then minus.Visible = true end
            if plus and plus.Parent then plus.Visible = true end
        end)
    end
    -- Header
    local HeaderHeight = 28
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -36, 0, HeaderHeight)
    Header.Position = UDim2.new(0, 18, 0, 8)
    Header.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Header.Parent = Frame
    ApplyRounded(Header, 8)
    ApplyStroke(Header, 1, Color3.fromRGB(235,235,235))
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -120, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "제목없는 RPG(무료)"
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextSize = 16
    HeaderLabel.TextColor3 = Color3.fromRGB(245,245,245)
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = Header
    local HeaderCloseBtn = Instance.new("TextButton")
    HeaderCloseBtn.Size = UDim2.new(0, 41, 0, HeaderHeight - 4)
    HeaderCloseBtn.Position = UDim2.new(1.12, -100, 0, 2)
    HeaderCloseBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
    HeaderCloseBtn.Text = "닫기"
    HeaderCloseBtn.Font = Enum.Font.Gotham
    HeaderCloseBtn.TextSize = 13
    HeaderCloseBtn.TextColor3 = Color3.fromRGB(240,240,240)
    HeaderCloseBtn.Parent = Header
    ApplyRounded(HeaderCloseBtn, 6)
    ApplyStroke(HeaderCloseBtn, 1, Color3.fromRGB(240,240,240))
    HeaderCloseBtn.MouseButton1Click:Connect(function()
        Frame.Visible = false
        OpenBtn.Visible = true
    end)
    -- ===== ClickContainer 끝부분 (AlwaysAutoSkill 버튼 아래 ~340px 위치)에 추가 =====
   
    -- TopBar
    local TopBarY = 8 + HeaderHeight + 6
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.Position = UDim2.new(0, 0, 0, TopBarY)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Frame
    local function NewTabButton(parent, xScale, text)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 96, 0, 34)
        b.Position = UDim2.new(xScale, 0, 0, 10)
        b.BackgroundColor3 = Color3.fromRGB(26,26,26)
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.Parent = parent
        ApplyRounded(b, 8)
        ApplyStroke(b, 1, Color3.fromRGB(245,245,245))
        return b
    end
    -- 탭: 메인 / 방향 / 클릭(오토) / 정보
    local TabMain = NewTabButton(TopBar, 0.1, "메인")
    local TabDir = NewTabButton(TopBar, 0.3, "방향")
    local TabClick = NewTabButton(TopBar, 0.5, "보조")
    local TabInfo = NewTabButton(TopBar, 0.7, "정보")
    GUIObjects.TabMain, GUIObjects.TabDir, GUIObjects.TabClick, GUIObjects.TabInfo = TabMain, TabDir, TabClick, TabInfo
    OpenBtn.MouseButton1Click:Connect(function()
        Frame.Visible = true
        OpenBtn.Visible = false
    end)
    -- Drag handlers
    do
        local topDragging, topStartPos, topDragOrigin = false, nil, nil
        TopBar.InputBegan:Connect(function(inp)
            if UIInteraction then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                topDragging = true
                topDragOrigin = inp.Position
                topStartPos = Frame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then topDragging = false end
                end)
            end
        end)
        TopBar.InputChanged:Connect(function(inp)
            if topDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - topDragOrigin
                Frame.Position = UDim2.new(topStartPos.X.Scale, topStartPos.X.Offset + delta.X, topStartPos.Y.Scale, topStartPos.Y.Offset + delta.Y)
            end
        end)
        local headerDragging, headerStartPos, headerDragOrigin = false, nil, nil
        Header.InputBegan:Connect(function(inp)
            if UIInteraction then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                headerDragging = true
                headerDragOrigin = inp.Position
                headerStartPos = Frame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then headerDragging = false end
                end)
            end
        end)
        Header.InputChanged:Connect(function(inp)
            if headerDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - headerDragOrigin
                Frame.Position = UDim2.new(headerStartPos.X.Scale, headerStartPos.X.Offset + delta.X, headerStartPos.Y.Scale, headerStartPos.Y.Offset + delta.Y)
            end
        end)
    end
    -- Content
    local ContentStartY = TopBarY + 52 + 12
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -36, 1, -(ContentStartY + 28))
    Content.Position = UDim2.new(0, 18, 0, ContentStartY)
    Content.BackgroundTransparency = 1
    Content.Parent = Frame
    -- containers
    local MainContainer = Instance.new("Frame") MainContainer.Size = UDim2.new(1,0,1,0) MainContainer.Position = UDim2.new(0,0,0,0) MainContainer.BackgroundTransparency = 1 MainContainer.Parent = Content GUIObjects.MainContainer = MainContainer
    local ClickContainer = Instance.new("Frame") ClickContainer.Size = UDim2.new(1,0,1,0) ClickContainer.Position = UDim2.new(0,0,0,0) ClickContainer.BackgroundTransparency = 1 ClickContainer.Parent = Content ClickContainer.Visible = false GUIObjects.ClickContainer = ClickContainer
    local DirContainer = Instance.new("Frame") DirContainer.Size = UDim2.new(1,0,1,0) DirContainer.Position = UDim2.new(0,0,0,0) DirContainer.BackgroundTransparency = 1 DirContainer.Parent = Content DirContainer.Visible = false GUIObjects.DirContainer = DirContainer
    local InfoContainer = Instance.new("Frame") InfoContainer.Size = UDim2.new(1,0,1,0) InfoContainer.Position = UDim2.new(0,0,0,0) InfoContainer.BackgroundTransparency = 1 InfoContainer.Parent = Content InfoContainer.Visible = false GUIObjects.InfoContainer = InfoContainer
    -- MAIN content
    local labelY = 6
    local function AddMainLabel(txt)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 22)
        lbl.Position = UDim2.new(0, 10, 0, labelY)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(235,235,235)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = MainContainer
        labelY = labelY + 28
        return lbl
    end
    -- 기존 NameLabel 하나만 있던 부분을 아래로 교체
    GUIObjects.NameLabel = AddMainLabel("1순위: 없음")
    GUIObjects.SecondaryLabel = AddMainLabel("2순위: 없음") -- 새로 추가
    GUIObjects.LevelLabel = AddMainLabel("최소 레벨: -")
    GUIObjects.HealthLabel = AddMainLabel("체력: - / -")
    -- (주의) 메인에서 스킬 UI 제거 — 스킬은 이제 오토 탭에 위치합니다.
    -- 오토팜 버튼들
    local function NewActionButton(parent, xPct, y, text, accent)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.45, -8, 0, 36)
        b.Position = UDim2.new(xPct, (xPct==0 and 10 or 6), 1, y)
        b.BackgroundColor3 = Color3.fromRGB(26,26,26)
        b.Text = text
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        b.TextColor3 = Color3.fromRGB(235,235,235)
        b.Parent = parent
        ApplyRounded(b, 8)
        ApplyStroke(b, 1, Color3.fromRGB(245,245,245))
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 6, 1, 0)
        accentBar.Position = UDim2.new(0, 0, 0, 0)
        accentBar.BackgroundColor3 = accent or Color3.fromRGB(0,160,100)
        accentBar.Parent = b
        ApplyRounded(accentBar, 6)
        return b
    end
    local toggleBtn = NewActionButton(MainContainer, 0, -124, "오토팜 OFF", Color3.fromRGB(0,160,100))
    GUIObjects.ToggleButton = toggleBtn
    local selectBtn = NewActionButton(MainContainer, 0.55, -124, "타겟 선택", Color3.fromRGB(255,140,0))
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(0.9, 0, 0, 36)
    spawnBtn.Position = UDim2.new(0.05, 0, 1, -170)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(26,26,26)
    spawnBtn.Text = "스폰포인트 선택"
    spawnBtn.Font = Enum.Font.GothamSemibold
    spawnBtn.TextSize = 14
    spawnBtn.TextColor3 = Color3.fromRGB(235,235,235)
    spawnBtn.Parent = MainContainer
    ApplyRounded(spawnBtn, 8)
    ApplyStroke(spawnBtn, 1, Color3.fromRGB(240,240,240))
    toggleBtn.MouseButton1Click:Connect(function()
        AutoFarmEnabled = not AutoFarmEnabled
        toggleBtn.BackgroundColor3 = AutoFarmEnabled and Color3.fromRGB(18,90,18) or Color3.fromRGB(26,26,26)
        toggleBtn.Text = AutoFarmEnabled and "오토팜 ON" or "오토팜 OFF"
        if AutoFarmEnabled then
            NoclipEnabled = true
            print("오토팜 ON")
            NoclipConnection = RunService.Stepped:Connect(function()
                if NoclipEnabled and LocalPlayer.Character then
                    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            NoclipEnabled = false
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            -- 오토팜 OFF 시 50스터드 위로 한 번만 올리고 자연 착지
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                pcall(function()
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
                    print("오토팜 OFF → 50스터드 위로 올림 (자연 착지)")
                end)
            end
            print("오토팜 OFF")
        end
    end)
    selectBtn.MouseButton1Click:Connect(function()
    local playerLevel = LocalPlayer:FindFirstChild("leaderstats") 
        and LocalPlayer.leaderstats:FindFirstChild("Level") 
        and LocalPlayer.leaderstats.Level.Value or 0
   
    if GUIObjects.ListFrame then
        GUIObjects.ListFrame:Destroy()
        GUIObjects.ListFrame = nil
    end

    local START_Y = 88
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -36, 0, LIST_HEIGHT)
    Scroll.Position = UDim2.new(0, 18, 0, START_Y)
    Scroll.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Scroll.BorderSizePixel = 0
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.ScrollBarThickness = 8
    Scroll.Parent = MainContainer
    ApplyRounded(Scroll, 8)
    ApplyStroke(Scroll, 1, Color3.fromRGB(235,235,235))
    Scroll.ClipsDescendants = true
    GUIObjects.ListFrame = Scroll

    -- X 닫기 버튼 (기존 그대로)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.Parent = Scroll
    CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100) end)
    CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200) end)
    CloseBtn.MouseButton1Click:Connect(function()
        if Scroll and Scroll.Parent then
            Scroll:Destroy()
            GUIObjects.ListFrame = nil
        end
    end)

    local layout = Instance.new("UIListLayout")
    layout.Parent = Scroll
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function updateCanvas()
        Scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    local mobDataList = {}   -- {name, level} 모음
    local displayedNames = {} -- 중복 방지

    local mobsFolder = Workspace:FindFirstChild(MOBS_FOLDER_NAME)
    if not mobsFolder then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -40, 0, 48)
        lbl.Position = UDim2.new(0, 20, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220, 180, 180)
        lbl.Text = "Mobs 폴더를 찾을 수 없습니다."
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = Scroll
        return
    end

    -- 1. 레벨 정보 모으기 (죽은 몹도 포함)
    for _, mob in ipairs(mobsFolder:GetChildren()) do
        if not mob:IsA("Model") then continue end
        local name = mob.Name
        
        if displayedNames[name] then continue end
        
        local config = mob:FindFirstChild("Config")
        if not config then continue end
        
        local success, cfg = pcall(require, config)
        if not success or not cfg or not cfg.RequireLevel then continue end
        
        if playerLevel >= cfg.RequireLevel then
            displayedNames[name] = true
            table.insert(mobDataList, {
                name = name,
                level = cfg.RequireLevel
            })
        end
    end

    -- 2. 레벨 낮은 순으로 정렬 (오름차순)
    table.sort(mobDataList, function(a, b)
        return a.level < b.level
    end)

    local allButtons = {}

    -- 3. 정렬된 순서대로 버튼 생성
    for _, data in ipairs(mobDataList) do
        local name = data.name
        local level = data.level

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -44, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(24,24,24)
        btn.TextColor3 = Color3.fromRGB(230,230,230)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Text = name .. " (Lv. " .. level .. ")"
        btn.Parent = Scroll
        ApplyRounded(btn, 6)
        ApplyStroke(btn, 1, Color3.fromRGB(235,235,235))
        table.insert(allButtons, btn)

        local function updateButton()
            local primary = FixedMonsterNames.Primary == name
            local secondary = FixedMonsterNames.Secondary == name
            if primary then
                btn.Text = name .. " (Lv. " .. level .. ") ← 1순위"
                btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            elseif secondary then
                btn.Text = name .. " (Lv. " .. level .. ") ← 2순위"
                btn.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
            else
                btn.Text = name .. " (Lv. " .. level .. ")"
                btn.BackgroundColor3 = Color3.fromRGB(24,24,24)
            end
        end
        updateButton()

        btn.MouseButton1Click:Connect(function()
            local primary = FixedMonsterNames.Primary
            local secondary = FixedMonsterNames.Secondary

            if primary == name then
                FixedMonsterNames.Primary = nil
                rememberedPos = nil
            elseif secondary == name then
                FixedMonsterNames.Secondary = nil
            elseif not primary then
                FixedMonsterNames.Primary = name
                if MONSTER_POSITIONS[name] then
                    rememberedPos = MONSTER_POSITIONS[name]
                end
            elseif not secondary then
                FixedMonsterNames.Secondary = name
            end

            GUIObjects.NameLabel.Text = "1순위: " .. (FixedMonsterNames.Primary or "없음")
            GUIObjects.SecondaryLabel.Text = "2순위: " .. (FixedMonsterNames.Secondary or "없음")

            -- 모든 버튼 텍스트 갱신
            for _, b in ipairs(allButtons) do
                local monsterName = b.Text:match("^(.-)%s*(%(Lv|←)")
                if monsterName then
                    monsterName = monsterName:match("^(.+)%s*$") or monsterName
                    if FixedMonsterNames.Primary == monsterName then
                        b.Text = monsterName .. " (Lv. ??) ← 1순위"
                        b.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                    elseif FixedMonsterNames.Secondary == monsterName then
                        b.Text = monsterName .. " (Lv. ??) ← 2순위"
                        b.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
                    else
                        b.Text = monsterName .. " (Lv. ??)"
                        b.BackgroundColor3 = Color3.fromRGB(24,24,24)
                    end
                end
            end
            updateButton()
        end)
    end

    if #mobDataList == 0 then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -40, 0, 48)
        lbl.Position = UDim2.new(0, 20, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220, 180, 180)
        lbl.Text = "현재 레벨로 갈 수 있는 몹이 없습니다.\n(몹 로딩 대기 중이거나 레벨 부족)"
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextWrapped = true
        lbl.Parent = Scroll
    
            for i, data in ipairs(mobList) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -44, 0, 42)
                btn.BackgroundColor3 = Color3.fromRGB(24,24,24)
                btn.TextColor3 = Color3.fromRGB(230,230,230)
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 13
                btn.Parent = Scroll
                ApplyRounded(btn, 6)
                ApplyStroke(btn, 1, Color3.fromRGB(235,235,235))
                table.insert(allButtons, btn)
                local function updateButton()
                    local primary = FixedMonsterNames.Primary == data.name
                    local secondary = FixedMonsterNames.Secondary == data.name
                    if primary then
                        btn.Text = data.name .. " (Lv. " .. data.level .. ") ← 1순위"
                        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                    elseif secondary then
                        btn.Text = data.name .. " (Lv. " .. data.level .. ") ← 2순위"
                        btn.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
                    else
                        btn.Text = data.name .. " (Lv. " .. data.level .. ")"
                        btn.BackgroundColor3 = Color3.fromRGB(24,24,24)
                    end
                end
                updateButton()
                btn.MouseButton1Click:Connect(function()
                    local primary = FixedMonsterNames.Primary
                    local secondary = FixedMonsterNames.Secondary
                    if primary == data.name then
                        FixedMonsterNames.Primary = nil
                        rememberedPos = nil
                        arrivedAtMemoryPos = false
                    elseif secondary == data.name then
                        FixedMonsterNames.Secondary = nil
                    elseif not primary then
                        FixedMonsterNames.Primary = data.name
                        if MONSTER_POSITIONS[data.name] then
                            rememberedPos = MONSTER_POSITIONS[data.name]
                            arrivedAtMemoryPos = false
                        end
                    elseif not secondary then
                        FixedMonsterNames.Secondary = data.name
                    else
                        warn(" ")
                        return
                    end
                    GUIObjects.NameLabel.Text = "1순위: " .. (FixedMonsterNames.Primary or "없음")
                    GUIObjects.SecondaryLabel.Text = "2순위: " .. (FixedMonsterNames.Secondary or "없음")
                    for _, b in ipairs(allButtons) do
                        if b and b.Parent then
                            local monsterName = b.Text:match("^(.-) %(")
                            if monsterName then
                                local level = b.Text:match("%(Lv%. (%d+)%)") or "??"
                                if FixedMonsterNames.Primary == monsterName then
                                    b.Text = monsterName .. " (Lv. " .. level .. ") ← 1순위"
                                    b.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                                elseif FixedMonsterNames.Secondary == monsterName then
                                    b.Text = monsterName .. " (Lv. " .. level .. ") ← 2순위"
                                    b.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
                                else
                                    b.Text = monsterName .. " (Lv. " .. level .. ")"
                                    b.BackgroundColor3 = Color3.fromRGB(24,24,24)
                                end
                            end
                        end
                    end
                    updateButton()
                end)
            end
        end
        GUIObjects.NameLabel.Text = "1순위: " .. (FixedMonsterNames.Primary or "없음")
        GUIObjects.SecondaryLabel.Text = "2순위: " .. (FixedMonsterNames.Secondary or "없음")
        task.defer(updateCanvas)
    end)
        spawnBtn.MouseButton1Click:Connect(function()
        if GUIObjects.ListFrame then GUIObjects.ListFrame:Destroy() end
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, -36, 0, LIST_HEIGHT)
        Scroll.Position = UDim2.new(0, 18, 0, 88)
        Scroll.BackgroundColor3 = Color3.fromRGB(18,18,18)
        Scroll.BorderSizePixel = 0
        Scroll.CanvasSize = UDim2.new(0,0,0,0)
        Scroll.ScrollBarThickness = 8
        Scroll.Parent = MainContainer
        ApplyRounded(Scroll, 8)
        ApplyStroke(Scroll, 1, Color3.fromRGB(235,235,235))
        GUIObjects.ListFrame = Scroll
        local layout = Instance.new("UIListLayout")
        layout.Parent = Scroll
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local function updateCanvas()
            Scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        local spawnList = {}
        local spawnFolder = workspace:FindFirstChild("SpawnPoint") or workspace:FindFirstChild("SpawnPoints")
        if spawnFolder then
            if spawnFolder:FindFirstChild("루나마을 스폰") then
                table.insert(spawnList, {name = "루나마을 스폰", pos = Vector3.new(-44.03, 130.3, 1996.13)})
            end
            if spawnFolder:FindFirstChild("메이플 스폰") then
                table.insert(spawnList, {name = "메이플 스폰", pos = Vector3.new(-1440.09, 193.31, 3793.4)})
            end
            if spawnFolder:FindFirstChild("겨울스폰") then
                table.insert(spawnList, {name = "겨울스폰", pos = Vector3.new(338.06, 186.77, 3753.47)})
            end
            if spawnFolder:FindFirstChild("겨울성 스폰") then
                table.insert(spawnList, {name = "겨울성 스폰", pos = Vector3.new(2183.86, 373.16, 4558.1)})
            end
            if spawnFolder:FindFirstChild("루나성") then
                table.insert(spawnList, {name = "루나성", pos = Vector3.new(-115.57, 4.44, 648.76)})
            end
            if spawnFolder:FindFirstChild("미궁") then
                table.insert(spawnList, {name = "미궁", pos = Vector3.new(-1647.79, 0.22, 2690.14)})
            end
            if spawnFolder:FindFirstChild("파라다이스") then
                table.insert(spawnList, {name = "파라다이스", pos = Vector3.new(1021.41, 78.89, 2947.4)})
            end
            if spawnFolder:FindFirstChild("프로스티아") then
                table.insert(spawnList, {name = "프로스티아", pos = Vector3.new(-242.87, 18.67, 3275.55)})
            end
            if spawnFolder:FindFirstChild("프로스티아2") then
                table.insert(spawnList, {name = "프로스티아2", pos = Vector3.new(9.93, 32.69, 4849.27)})
            end
            local portal = workspace:FindFirstChild("Map")
                and workspace.Map:FindFirstChild("Teleport")
                and workspace.Map.Teleport:FindFirstChild("다지엇음")
            if portal then
                table.insert(spawnList, {name = "2차원 포털", pos = Vector3.new(-37.03, 174.36, -2232.93)})
            end
        end
        if #spawnList == 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -40, 0, 28)
            lbl.Position = UDim2.new(0, 20, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = "스폰 위치가 없습니다."
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.fromRGB(210,210,210)
            lbl.Parent = Scroll
        else
            for i, data in ipairs(spawnList) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -44, 0, 36)
                btn.BackgroundColor3 = Color3.fromRGB(24,24,24)
                btn.TextColor3 = Color3.fromRGB(230,230,230)
                btn.Text = data.name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.Parent = Scroll
                btn.LayoutOrder = i
                ApplyRounded(btn, 6)
                ApplyStroke(btn, 1, Color3.fromRGB(235,235,235))
                btn.MouseButton1Click:Connect(function()
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            hrp.CFrame = CFrame.new(data.pos + Vector3.new(0, 3, 0))
                        end)
                        print("스폰 TP: " .. data.name .. " → " .. tostring(data.pos))
                    end
                    if GUIObjects.ListFrame then
                        GUIObjects.ListFrame:Destroy()
                        GUIObjects.ListFrame = nil
                    end
                    -- 난독화 내성 최고로 강화된 2차원 포털 처리
                    if data.name == "2차원 포털" then
                        task.spawn(function()
                            task.wait(0.6) -- 안정적인 대기
                            pcall(function()
                                local map = workspace:FindFirstChild("Map")
                                if not map then return end
                                local teleport = map:FindFirstChild("Teleport")
                                if not teleport then return end
                                local portal = teleport:FindFirstChild("World2")
                                if not portal then return end
                                -- ProximityPrompt 강제 활성화 및 강화
                                local prompt = portal:FindFirstChild("ProximityPrompt")
                                if prompt then
                                    prompt.HoldDuration = 0
                                    prompt.Enabled = true
                                    prompt.MaxActivationDistance = 50
                                    prompt.RequiresLineOfSight = false -- 시야 막혀도 작동
                                end
                                -- 포털 시각 효과 강제 ON
                                portal.Transparency = 0
                                local attachment = portal:FindFirstChild("Attachment")
                                if attachment then
                                    for _, emitter in pairs(attachment:GetChildren()) do
                                        if emitter:IsA("ParticleEmitter") then
                                            emitter.Enabled = true
                                        end
                                    end
                                end
                                -- 지속 유지 루프 (난독화에 가장 강한 구조)
                                while task.wait(0.3) do
                                    if not portal or not portal.Parent then break end
                                    portal.Transparency = 0
                                    if prompt then
                                        prompt.Enabled = true
                                        prompt.HoldDuration = 0
                                    end
                                    if attachment then
                                        for _, emitter in pairs(attachment:GetChildren()) do
                                            if emitter:IsA("ParticleEmitter") then
                                                emitter.Enabled = true
                                            end
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                end)
            end
        end
        task.defer(updateCanvas)
    end)
    local function CreateSlider(parent, name, min, max, default, callback, posY)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 0, 18)
        label.Position = UDim2.new(0, 20, 0, posY)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Text = name..": "..default
        label.Parent = parent
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -40, 0, 16)
        sliderFrame.Position = UDim2.new(0, 20, 0, posY+22)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
        sliderFrame.Parent = parent
        ApplyRounded(sliderFrame, 8)
        ApplyStroke(sliderFrame, 1, Color3.fromRGB(235,235,235))
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(0,160,100)
        fill.Parent = sliderFrame
        ApplyRounded(fill, 8)
        local dragging = false
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UIInteraction = true
            end
        end)
        sliderFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                task.delay(0, function() UIInteraction = false end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local x = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                fill.Size = UDim2.new(x/sliderFrame.AbsoluteSize.X,0,1,0)
                local value = min + (x/sliderFrame.AbsoluteSize.X)*(max-min)
                label.Text = name..": "..math.floor(value*100)/100
                callback(value)
            end
        end)
    end
    CreateSlider(MainContainer, "오프셋 거리 (stud)", 0, 80, TP_DISTANCE, function(v) TP_DISTANCE = v end, 100)
    CreateSlider(MainContainer, "속도 (stud/s)", SPEED_MIN, SPEED_MAX, MOVE_SPEED, function(v) MOVE_SPEED = math.clamp(math.floor(v), SPEED_MIN, SPEED_MAX) end, 160)
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(0.9, 0, 0, 36)
    modeBtn.Position = UDim2.new(0.05, 0, 0, 220)
    modeBtn.BackgroundColor3 = Color3.fromRGB(26,26,26)
    modeBtn.Text = "모드: "..MoveMode
    modeBtn.Font = Enum.Font.GothamSemibold
    modeBtn.TextSize = 14
    modeBtn.TextColor3 = Color3.fromRGB(235,235,235)
    modeBtn.Parent = MainContainer
    ApplyRounded(modeBtn, 8)
    ApplyStroke(modeBtn, 1, Color3.fromRGB(235,235,235))
    modeBtn.MouseButton1Click:Connect(function()
        MoveMode = (MoveMode == "Smooth") and "Instant" or "Smooth"
        modeBtn.Text = "모드: "..MoveMode
    end)
    -- 방향 탭 UI
    local dirButtons = {}
    local btnInfos = {
        {text = "뒤 (Back)", dir = "Back", pos = UDim2.new(0.06,0,0,8)},
        {text = "앞 (Front)", dir = "Front", pos = UDim2.new(0.56,0,0,8)},
        {text = "왼쪽 (Left)", dir = "Left", pos = UDim2.new(0.06,0,0,92)},
        {text = "오른쪽 (Right)", dir = "Right", pos = UDim2.new(0.56,0,0,92)},
        {text = "위 (Up)", dir = "Up", pos = UDim2.new(0.06,0,0,176)},
        {text = "아래 (Down)", dir = "Down", pos = UDim2.new(0.56,0,0,176)},
    }
    for _, info in ipairs(btnInfos) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.42, 0, 0, 64)
        b.Position = info.pos
        b.Text = info.text
        b.Name = info.dir
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        b.TextColor3 = Color3.fromRGB(235,235,235)
        b.BackgroundColor3 = (TP_DIRECTION == info.dir) and Color3.fromRGB(16,90,16) or Color3.fromRGB(26,26,26)
        b.Parent = DirContainer
        ApplyRounded(b, 10)
        ApplyStroke(b, 1, Color3.fromRGB(240,240,240))
        b.MouseButton1Click:Connect(function()
            TP_DIRECTION = info.dir
            for _, cb in ipairs(dirButtons) do
                cb.BackgroundColor3 = (cb.Name == TP_DIRECTION) and Color3.fromRGB(16,90,16) or Color3.fromRGB(26,26,26)
            end
        end)
        table.insert(dirButtons, b)
    end
    -- 정보 탭
    local function addInfo(txt, container, y)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -28, 0, 44)
        l.Position = UDim2.new(0, 14, 0, y or 12)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.fromRGB(240,240,240)
        l.TextWrapped = true
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 14
        l.Text = txt
        l.Parent = container
    end
    addInfo("개발자 디스코드: park75816150(부키 덕질중)", InfoContainer)
    addInfo("몬스터 TP가 실패할 경우, 대상 근처로 이동한 뒤 재시도하세요.", InfoContainer, 62)
    addInfo("피드백이나 버그제보는 개발자 한테 dm을 보내주세요", InfoContainer, 112)
    addInfo("이 스크립트는 개발자 혼자 개발한 무료 스크립트입니다. 무단 판매를 금지합니다.", InfoContainer, 152)
    -- ClickContainer UI: 오토클릭 + 스킬 통합 (요청대로 스킬을 여기로 이동함)
    do
        -- 오토클릭 버튼
        local autoClickBtn = Instance.new("TextButton")
        autoClickBtn.Size = UDim2.new(0.9, 0, 0, 44)
        autoClickBtn.Position = UDim2.new(0.05, 0, 0, 8)
        autoClickBtn.BackgroundColor3 = Color3.fromRGB(26,26,26)
        autoClickBtn.Text = "오토클릭: OFF(B키토글 ㅆㄱㄴ)"
        autoClickBtn.Font = Enum.Font.GothamSemibold
        autoClickBtn.TextSize = 15
        autoClickBtn.TextColor3 = Color3.fromRGB(235,235,235)
        autoClickBtn.Parent = ClickContainer
        ApplyRounded(autoClickBtn, 10)
        ApplyStroke(autoClickBtn, 1, Color3.fromRGB(235,235,235))
        GUIObjects.AutoClickBtn = autoClickBtn
        -- 여기서 스킬 버튼 행을 생성 (메인에서 제거됨)
        local skillRow = Instance.new("Frame")
        skillRow.Size = UDim2.new(0.9, 0, 0, 120)
        skillRow.Position = UDim2.new(0.05, 0, 0, 120)
        skillRow.BackgroundTransparency = 1
        skillRow.Parent = ClickContainer
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 12)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Parent = skillRow
        local function createSkillButton(name)
            local b = Instance.new("TextButton")
            b.Name = name .. "_Btn"
            b.Size = UDim2.new(0, 140, 0, 56)
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.TextColor3 = Color3.fromRGB(220,220,220)
            b.Font = Enum.Font.GothamSemibold
            b.TextSize = 18
            b.Text = name
            ApplyRounded(b, 8)
            ApplyStroke(b, 1, Color3.fromRGB(235,235,235))
            b.Parent = skillRow
            local cd = Instance.new("TextLabel")
            cd.Size = UDim2.new(1, 0, 0, 16)
            cd.Position = UDim2.new(0, 0, 1, -18)
            cd.BackgroundTransparency = 1
            cd.Font = Enum.Font.Gotham
            cd.TextSize = 12
            cd.TextColor3 = Color3.fromRGB(200,200,200)
            cd.Text = "N/A"
            cd.Parent = b
            return b, cd
        end
        local eBtn, eCd = createSkillButton("E")
        local rBtn, rCd = createSkillButton("R")
        local tBtn, tCd = createSkillButton("T")
        GUIObjects.SkillButtons = {E=eBtn, R=rBtn, T=tBtn}
        GUIObjects.SkillCooldownLabels = {E=eCd, R=rCd, T=tCd}
        -- 토글 연결
        _G.AutoSkill = _G.AutoSkill or {}
        _G.AutoSkill.E = _G.AutoSkill.E or false
        _G.AutoSkill.R = _G.AutoSkill.R or false
        _G.AutoSkill.T = _G.AutoSkill.T or false
        eBtn.MouseButton1Click:Connect(function() _G.AutoSkill.E = not _G.AutoSkill.E end)
        rBtn.MouseButton1Click:Connect(function() _G.AutoSkill.R = not _G.AutoSkill.R end)
        tBtn.MouseButton1Click:Connect(function() _G.AutoSkill.T = not _G.AutoSkill.T end)
                -- ===== 항상 자동 사용 토글 버튼 추가 =====
                -- ===== 항상 자동 사용 토글 버튼 (텍스트 항상 하얀색 + 확실히 보이게) =====
        local AlwaysAutoBtn = Instance.new("TextButton")
        AlwaysAutoBtn.Size = UDim2.new(0.9, 0, 0, 50)
        AlwaysAutoBtn.Position = UDim2.new(0.05, 0, 0, 220) -- 충분히 아래로 내려서 절대 안 가려짐
        AlwaysAutoBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
        AlwaysAutoBtn.Text = "스킬 사용: OFF"
        AlwaysAutoBtn.TextColor3 = Color3.new(1, 1, 1) -- 항상 하얀색
        AlwaysAutoBtn.Font = Enum.Font.GothamBold
        AlwaysAutoBtn.TextSize = 16
        AlwaysAutoBtn.Parent = ClickContainer
        AlwaysAutoBtn.ZIndex = 20 -- 위에 뜨게
        ApplyRounded(AlwaysAutoBtn, 12)
        ApplyStroke(AlwaysAutoBtn, 2, Color3.fromRGB(100, 255, 100))
        
        _G.AlwaysAutoSkill = _G.AlwaysAutoSkill or false
        AlwaysAutoBtn.MouseButton1Click:Connect(function()
            _G.AlwaysAutoSkill = not _G.AlwaysAutoSkill
            AlwaysAutoBtn.Text = "스킬 사용: " .. (_G.AlwaysAutoSkill and "ON" or "OFF")
            -- 배경만 초록/검정 변경, 텍스트는 무조건 흰색 유지
            AlwaysAutoBtn.BackgroundColor3 = _G.AlwaysAutoSkill and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(26, 26, 26)
        end)
        -- 쿨다운 탐색 함수
        local function searchForCooldownInGuis(skillName)
            local lower = skillName:lower()
            local function checkContainer(root)
                for _, v in pairs(root:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local n = v.Name:lower()
                        local p = tostring(v.Parent and v.Parent.Name or ""):lower()
                        if n:find(lower) or n:find("cd") or n:find("cool") or p:find(lower) or p:find("cd") then
                            return v.Value
                        end
                    end
                end
                return nil
            end
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                local found = checkContainer(LocalPlayer.PlayerGui)
                if found then return found end
            end
            local foundCore = checkContainer(game.CoreGui)
            if foundCore then return foundCore end
            return nil
        end
        local function findGuiRoot()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if v:FindFirstChild("E") or v:FindFirstChild("R") or v:FindFirstChild("T") or v:FindFirstChildWhichIsA("Frame") then
                        return v
                    end
                end
            end
            for _, v in pairs(game.CoreGui:GetChildren()) do
                if v:FindFirstChild("E") or v:FindFirstChild("R") or v:FindFirstChild("T") or v:FindFirstChildWhichIsA("Frame") then
                    return v
                end
            end
            return nil
        end
        local guiRoot = findGuiRoot()
        local function getCooldownFromGuiName(name)
            if guiRoot then
                local child = guiRoot:FindFirstChild(name)
                if child and child:FindFirstChild("Frame") then
                    local vv = child.Frame:FindFirstChild("Value")
                    if vv and (vv:IsA("NumberValue") or vv:IsA("IntValue")) then return vv.Value end
                end
            end
            return nil
        end
        spawn(function()
            while ClickContainer and ClickContainer.Parent do
                local ev = getCooldownFromGuiName("E") or searchForCooldownInGuis("E")
                if ev == nil then eCd.Text = "N/A" elseif ev > 0 then eCd.Text = tostring(math.floor(ev*10)/10) .. "s" else eCd.Text = "Ready" end
                if _G.AutoSkill.E then eBtn.BackgroundColor3 = Color3.fromRGB(30,130,30); eBtn.Text = "E (ON)" else eBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); eBtn.Text = "E" end
                local rv = getCooldownFromGuiName("R") or searchForCooldownInGuis("R")
                if rv == nil then rCd.Text = "N/A" elseif rv > 0 then rCd.Text = tostring(math.floor(rv*10)/10) .. "s" else rCd.Text = "Ready" end
                if _G.AutoSkill.R then rBtn.BackgroundColor3 = Color3.fromRGB(30,130,30); rBtn.Text = "R (ON)" else rBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); rBtn.Text = "R" end
                local tv = getCooldownFromGuiName("T") or searchForCooldownInGuis("T")
                if tv == nil then tCd.Text = "N/A" elseif tv > 0 then tCd.Text = tostring(math.floor(tv*10)/10) .. "s" else tCd.Text = "Ready" end
                if _G.AutoSkill.T then tBtn.BackgroundColor3 = Color3.fromRGB(30,130,30); tBtn.Text = "T (ON)" else tBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); tBtn.Text = "T" end
                task.wait(0.12)
            end
        end)
    end
    -- 최종 nil-safe 쿨다운 함수 (인라인 + pcall 완벽 적용)
    local function getSafeCooldown(skillName)
        local lower = skillName:lower()
      
        -- 1. PlayerGui / CoreGui에서 직접 검색 (기존 함수 호출 없이 인라인)
        local success, cd = pcall(function()
            local containers = {}
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                table.insert(containers, LocalPlayer.PlayerGui)
            end
            table.insert(containers, game.CoreGui)
          
            for _, container in ipairs(containers) do
                -- 방법 1: 스킬 이름 직접 찾기 (E, R, T 버튼)
                local skillBtn = container:FindFirstChild(skillName)
                if skillBtn and skillBtn:FindFirstChild("Frame") then
                    local val = skillBtn.Frame:FindFirstChild("Value")
                    if val and (val:IsA("NumberValue") or val:IsA("IntValue")) then
                        return val.Value
                    end
                end
              
                -- 방법 2: 전체 Descendants 검색 (cd, cool 등 키워드)
                for _, v in pairs(container:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local n = v.Name:lower()
                        local pName = v.Parent and v.Parent.Name:lower() or ""
                        if n:find(lower) or n:find("cd") or n:find("cool") or pName:find(lower) or pName:find("cd") then
                            return v.Value
                        end
                    end
                end
            end
            return nil
        end)
      
        return success and cd or nil
    end
   
    -- 오토 스킬 루프 (난독화 대응, 2초 간격, 쿨타임 확인 제거)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    -- 동적으로 스킬 리모트 찾기
    local function findSkillRemote()
        local remoteFolder = ReplicatedStorage:FindFirstChild("Remote")
        if not remoteFolder then
            for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
                if obj:IsA("Folder") or obj:IsA("RemoteEvent") then
                    local skillRemote = obj:FindFirstChild("Skill") or obj:FindFirstChildWhichIsA("RemoteEvent")
                    if skillRemote then
                        return skillRemote
                    end
                end
            end
        else
            return remoteFolder:FindFirstChild("Skill") or remoteFolder:FindFirstChildWhichIsA("RemoteEvent")
        end
        return nil
    end
    local SkillRemote = findSkillRemote()
    -- 스킬 발동 함수 (오류 처리 강화)
    local function tryFireSkill(name)
        if not SkillRemote then
            -- 리모트 없으면 재탐색
            SkillRemote = findSkillRemote()
            if not SkillRemote then
                warn("스킬 리모트 찾기 실패")
                return
            end
        end
        pcall(function()
            SkillRemote:FireServer(name) -- 스킬 이름 직접 전달
        end)
    end
    -- 각 스킬(E, R, T)에 대해 2초 간격 실행
    for _, name in ipairs({"E", "R", "T"}) do
        task.spawn(function()
            local debounce = false
            while task.wait(1.1) do -- 2초마다 실행
                if _G.AutoSkill[name] and not debounce and LocalPlayer.Character then
                    debounce = true
                    -- 항상 자동 사용 ON이면 타겟 상관없이 발동
                    if _G.AlwaysAutoSkill then
                        tryFireSkill(name)
                    else
                        -- 타겟이 살아있을 때만 발동
                        local targetValid = CurrentTarget and CurrentTarget.Parent
                        local hum = targetValid and CurrentTarget:FindFirstChild("Humanoid")
                        local targetAlive = hum and hum.Health > 0
                        if targetValid and targetAlive then
                            tryFireSkill(name)
                        end
                    end
                    task.wait(0.1) -- 짧은 대기 후 debounce 해제
                    debounce = false
                end
            end
        end)
    end
    -- 쿨타임 GUI 업데이트 (난독화 대응, 단순화)
    local function updateSkillCooldownDisplay()
        local guiRoot = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
        for _, name in ipairs({"E", "R", "T"}) do
            local cdLabel = GUIObjects.SkillCooldownLabels[name]
            if not cdLabel then continue end
            -- 동적으로 쿨타임 값 찾기
            local cdValue = nil
            pcall(function()
                for _, v in pairs(guiRoot:GetDescendants()) do
                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find(name:lower()) or v.Parent.Name:lower():find(name:lower())) then
                        cdValue = v.Value
                        break
                    end
                end
            end)
            -- 쿨타임 표시
            if cdValue == nil then
                cdLabel.Text = "N/A"
            elseif cdValue > 0 then
                cdLabel.Text = string.format("%.1fs", cdValue)
            else
                cdLabel.Text = "Ready"
            end
            -- 버튼 상태 업데이트
            local btn = GUIObjects.SkillButtons[name]
            if btn then
                btn.BackgroundColor3 = _G.AutoSkill[name] and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(40, 40, 40)
                btn.Text = name .. (_G.AutoSkill[name] and " (ON)" or "")
            end
        end
    end
   
    -- GUI 쿨타임 표시 루프
    task.spawn(function()
        while GUIObjects.ClickContainer and GUIObjects.ClickContainer.Parent do
            pcall(updateSkillCooldownDisplay)
            task.wait(0.12)
        end
    end)
    -- 탭 제어
    local function ResetTabColors()
        if TabMain then TabMain.BackgroundColor3 = Color3.fromRGB(26,26,26); TabMain.TextColor3 = Color3.fromRGB(230,230,230) end
        if TabDir then TabDir.BackgroundColor3 = Color3.fromRGB(26,26,26); TabDir.TextColor3 = Color3.fromRGB(230,230,230) end
        if TabClick then TabClick.BackgroundColor3 = Color3.fromRGB(26,26,26); TabClick.TextColor3 = Color3.fromRGB(230,230,230) end
        if TabInfo then TabInfo.BackgroundColor3 = Color3.fromRGB(26,26,26); TabInfo.TextColor3 = Color3.fromRGB(230,230,230) end
    end
    local function SafeSetVisible(container, visible)
        if container and container.Parent then container.Visible = visible end
    end
    local function ShowMain() ResetTabColors() if TabMain then TabMain.BackgroundColor3 = Color3.fromRGB(36,36,36) end SafeSetVisible(MainContainer, true) SafeSetVisible(DirContainer, false) SafeSetVisible(ClickContainer, false) SafeSetVisible(InfoContainer, false) end
    local function ShowDir() ResetTabColors() if TabDir then TabDir.BackgroundColor3 = Color3.fromRGB(36,36,36) end SafeSetVisible(MainContainer, false) SafeSetVisible(DirContainer, true) SafeSetVisible(ClickContainer, false) SafeSetVisible(InfoContainer, false) end
    local function ShowClick() ResetTabColors() if TabClick then TabClick.BackgroundColor3 = Color3.fromRGB(36,36,36) end SafeSetVisible(MainContainer, false) SafeSetVisible(DirContainer, false) SafeSetVisible(ClickContainer, true) SafeSetVisible(InfoContainer, false) end
    local function ShowInfo() ResetTabColors() if TabInfo then TabInfo.BackgroundColor3 = Color3.fromRGB(36,36,36) end SafeSetVisible(MainContainer, false) SafeSetVisible(DirContainer, false) SafeSetVisible(ClickContainer, false) SafeSetVisible(InfoContainer, true) end
    TabMain.MouseButton1Click:Connect(ShowMain)
    TabDir.MouseButton1Click:Connect(ShowDir)
    TabClick.MouseButton1Click:Connect(ShowClick)
    TabInfo.MouseButton1Click:Connect(ShowInfo)
    ShowMain()
    GUIObjects.MainContainer = MainContainer
    GUIObjects.ClickContainer = ClickContainer
    GUIObjects.DirContainer = DirContainer
    GUIObjects.InfoContainer = InfoContainer
  
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CoreGui = game:GetService("CoreGui")
    local MacroEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Macro")
    -- 오토 탭에 넣을 토글 버튼 (ClickContainer 안에 붙이세요!)
    local MacroSection = Instance.new("Frame")
    MacroSection.Size = UDim2.new(0.9, 0, 0, 100)
    MacroSection.Position = UDim2.new(0.05, 0, 0, 340) -- 스킬 아래로 위치 조정
    MacroSection.BackgroundTransparency = 1
    MacroSection.Parent = ClickContainer
    local InfoLabel = Instance.new("TextLabel", MacroSection)
    InfoLabel.Size = UDim2.new(1, 0, 0, 28)
    InfoLabel.Position = UDim2.new(0, 0, 0, 8)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "메크로 방지 우회 : 작동중"
    InfoLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 40
end
-- Create GUI
CreateGUI()
local CurrentTarget = nil
local TargetLockTime = 0
local LOCK_DURATION = 0.5  -- 0.5초 동안 타겟 고정 (스폰돼도 안 바꿈)

-- 몹 폴더 실시간 감시용 연결 (한 번만 연결)
local mobsFolderConnection = nil

local function UpdateTargetList()
    TargetList = {}
    local folder = workspace:FindFirstChild(MOBS_FOLDER_NAME)
    if not folder then return end

    -- 폴더가 처음 발견되면 ChildAdded 이벤트 연결 (실시간 스폰 감지)
    if not mobsFolderConnection then
        mobsFolderConnection = folder.ChildAdded:Connect(function(child)
            -- 새 몹 추가될 때마다 즉시 리스트 갱신 트리거
            task.defer(UpdateTargetList)  -- 다음 프레임에 갱신
        end)
    end

    for _, obj in ipairs(folder:GetChildren()) do
        if not obj:IsA("Model") then continue end
        
        local hum = obj:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        table.insert(TargetList, obj)
    end
end

local function SelectBestTarget()
    local now = tick()
    
    -- 현재 타겟이 살아있고 락 시간 내이면 유지 (이건 그대로 둬도 OK)
    if CurrentTarget and CurrentTarget.Parent and (now - TargetLockTime < LOCK_DURATION) then
        local hum = CurrentTarget:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            return
        end
    end
    
    CurrentTarget = nil
    if #TargetList == 0 then return end
    
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local bestMob, bestDist, bestPri = nil, math.huge, 4
    
    for _, mob in ipairs(TargetList) do
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if not root then continue end
        
        local pri = 3
        if FixedMonsterNames.Primary and mob.Name == FixedMonsterNames.Primary then 
            pri = 1
        elseif FixedMonsterNames.Secondary and mob.Name == FixedMonsterNames.Secondary then 
            pri = 2 
        else
            -- ★★★ 핵심 ★★★ : 1·2순위 아니면 아예 무시
            continue
        end
        
        local dist = (myHrp.Position - root.Position).Magnitude
        if pri < bestPri or (pri == bestPri and dist < bestDist) then
            bestPri = pri
            bestDist = dist
            bestMob = mob
        end
    end
    
    if bestMob then
        CurrentTarget = bestMob
        TargetLockTime = tick()
    end
end
local function UpdateGUI()
    if not GUIObjects.MainContainer or not GUIObjects.MainContainer.Visible then return end
    if CurrentTarget and CurrentTarget.Parent then
        GUIObjects.NameLabel.Text = "1순위: ".. (FixedMonsterNames.Primary or "없음") .. " → 현재 타겟: " .. CurrentTarget.Name
        GUIObjects.SecondaryLabel.Text = "2순위: " .. (FixedMonsterNames.Secondary or "없음")
      
        local ok, lvl = pcall(function() return require(CurrentTarget:FindFirstChild("Config")).RequireLevel end)
        GUIObjects.LevelLabel.Text = "최소 레벨: "..(ok and lvl or "-")
        local hum = CurrentTarget:FindFirstChild("Humanoid")
        GUIObjects.HealthLabel.Text = hum and ("체력: %.0f / %.0f"):format(hum.Health, hum.MaxHealth) or "체력: - / -"
    else
        GUIObjects.NameLabel.Text = "1순위: " .. (FixedMonsterNames.Primary or "없음")
        GUIObjects.SecondaryLabel.Text = "2순위: " .. (FixedMonsterNames.Secondary or "없음")
        GUIObjects.LevelLabel.Text = "최소 레벨: -"
        GUIObjects.HealthLabel.Text = "체력: - / -"
    end
end
-- 전역 플래그 추가 (스크립트 상단에 한 번만 추가)
-- 전역 플래그 (스크립트 상단에 추가)
local primaryWasNil = true
local isFloating = false -- 10000스터드 고정 중인지
RunService.RenderStepped:Connect(function(dt)
    if not AutoFarmEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart

    UpdateTargetList()
    SelectBestTarget()
    UpdateGUI()

    _G.LastYCheck = _G.LastYCheck or {pos = hrp.Position.Y, time = tick()}

    if FixedMonsterNames.Primary == nil then
        if not primaryWasNil then
            arrivedAtMemoryPos = false
            primaryWasNil = true
        end
    else
        primaryWasNil = false
    end

    local hasPrimary = false
    local hasSecondary = false
    for _, mob in ipairs(TargetList) do
        if FixedMonsterNames.Primary and mob.Name == FixedMonsterNames.Primary then
            hasPrimary = true
        end
        if FixedMonsterNames.Secondary and mob.Name == FixedMonsterNames.Secondary then
            hasSecondary = true
        end
    end

    -- 1순위 처리
    if hasPrimary then
        local targetMemoryPos = MONSTER_POSITIONS[FixedMonsterNames.Primary]
        if targetMemoryPos then
            local destination = targetMemoryPos + Vector3.new(0, 5, 0)
            if not arrivedAtMemoryPos then
                local dist = (hrp.Position - destination).Magnitude
                if MoveMode == "Instant" then
                    pcall(function()
                        hrp.CFrame = CFrame.new(destination)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end)
                    arrivedAtMemoryPos = true
                else
                    local speedThisFrame = MOVE_SPEED * dt
                    if dist > 1 then
                        local direction = (destination - hrp.Position).Unit
                        local newPos = hrp.Position + direction * speedThisFrame
                        pcall(function()
                            hrp.CFrame = CFrame.new(newPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                    else
                        pcall(function()
                            hrp.CFrame = CFrame.new(destination)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                        arrivedAtMemoryPos = true
                    end
                end
            else
                if CurrentTarget and CurrentTarget.Name == FixedMonsterNames.Primary then
                    local mobHrp = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget.PrimaryPart
                    if mobHrp then
                        local offset = GetDirectionLocalOffset(TP_DIRECTION, TP_DISTANCE)
                        local targetPos = (mobHrp.CFrame * CFrame.new(offset)).Position
                        pcall(function()
                            if MoveMode == "Instant" then
                                hrp.CFrame = CFrame.new(targetPos, mobHrp.Position)
                            else
                                local current = hrp.Position
                                local lerp = math.min(30 * dt, 1)
                                local newX = current.X + (targetPos.X - current.X) * lerp
                                local newZ = current.Z + (targetPos.Z - current.Z) * lerp
                                hrp.CFrame = CFrame.new(Vector3.new(newX, targetPos.Y, newZ), mobHrp.Position)
                            end
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                    end
                end
            end
            isFloating = false
            return
        end
    end

    -- 2순위 처리
    if not hasPrimary and hasSecondary then
        local targetMemoryPos = MONSTER_POSITIONS[FixedMonsterNames.Secondary]
        if targetMemoryPos then
            local destination = targetMemoryPos + Vector3.new(0, 5, 0)
            if not arrivedAtMemoryPos then
                local dist = (hrp.Position - destination).Magnitude
                if MoveMode == "Instant" then
                    pcall(function()
                        hrp.CFrame = CFrame.new(destination)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end)
                    arrivedAtMemoryPos = true
                else
                    local speedThisFrame = MOVE_SPEED * dt
                    if dist > 1 then
                        local direction = (destination - hrp.Position).Unit
                        local newPos = hrp.Position + direction * speedThisFrame
                        pcall(function()
                            hrp.CFrame = CFrame.new(newPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                    else
                        pcall(function()
                            hrp.CFrame = CFrame.new(destination)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                        arrivedAtMemoryPos = true
                    end
                end
            else
                if CurrentTarget and CurrentTarget.Name == FixedMonsterNames.Secondary then
                    local mobHrp = CurrentTarget:FindFirstChild("HumanoidRootPart") or CurrentTarget.PrimaryPart
                    if mobHrp then
                        local offset = GetDirectionLocalOffset(TP_DIRECTION, TP_DISTANCE)
                        local targetPos = (mobHrp.CFrame * CFrame.new(offset)).Position
                        pcall(function()
                            if MoveMode == "Instant" then
                                hrp.CFrame = CFrame.new(targetPos, mobHrp.Position)
                            else
                                local current = hrp.Position
                                local lerp = math.min(30 * dt, 1)
                                local newX = current.X + (targetPos.X - current.X) * lerp
                                local newZ = current.Z + (targetPos.Z - current.Z) * lerp
                                hrp.CFrame = CFrame.new(Vector3.new(newX, targetPos.Y, newZ), mobHrp.Position)
                            end
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end)
                    end
                end
            end
            isFloating = false
            return
        end
    end

    -- 1,2순위 둘 다 없을 때 플로팅
    if not hasPrimary and not hasSecondary then
        if not isFloating then
            pcall(function()
                local floatPos = hrp.Position + Vector3.new(0, 100, 0)
                hrp.CFrame = CFrame.new(floatPos)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
            isFloating = true
            arrivedAtMemoryPos = false
        else
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        return
    else
        isFloating = false
    end

    
    -- 추락 방지
    local currentY = hrp.Position.Y
    local currentTime = tick()
    if currentTime - _G.LastYCheck.time >= 0.5 then
        local fallDistance = _G.LastYCheck.pos - currentY
        if fallDistance > 150 then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 400, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        end
        _G.LastYCheck.pos = currentY
        _G.LastYCheck.time = currentTime
    end
end)
-- ==================== 최종 세련된 오토클릭 + 완벽 속도 슬라이더 ====================
-- ==================== 오토클릭 + AFK 방지 점프 (B키 토글) ====================
do
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local GuiService = game:GetService("GuiService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local AutoEnabled = false
    local loopConnection = nil
    local lastJumpTime = 0
    local jumpInterval = 20 -- 20초마다 점프
    _G.AutoClickDelay = _G.AutoClickDelay or 0.08
    -- 화면 중앙 위치 계산
    local function GetCenterPos()
        local cam = workspace.CurrentCamera
        local size = cam.ViewportSize
        local inset = GuiService:GetGuiInset().Y
        return Vector2.new(size.X / 2, size.Y / 2 + inset / 2)
    end
    -- 한 번 클릭
    local function ClickCenter()
        local pos = GetCenterPos()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end
    -- 점프 실행 (Humanoid 방식 - 더 안정적)
    local function DoJump()
        pcall(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
    -- 토글 함수
    local function SetAutoEnabled(enabled)
        if AutoEnabled == enabled then return end
        AutoEnabled = enabled
        -- 기존 루프 완전 정리 (이게 핵심! 꺼지지 않는 문제 해결)
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        if enabled then
            -- 처음 바로 점프
            DoJump()
            lastJumpTime = os.clock()
            -- 단일 루프로 오토클릭 + 주기적 점프 관리
            loopConnection = RunService.Heartbeat:Connect(function()
                if not AutoEnabled then
                    if loopConnection then loopConnection:Disconnect() end
                    return
                end
                -- 오토클릭
                ClickCenter()
                -- 20초마다 점프
                if os.clock() - lastJumpTime >= jumpInterval then
                    DoJump()
                    lastJumpTime = os.clock()
                    print("AFK 방지 점프 실행 (20초 간격)")
                end
                task.wait(_G.AutoClickDelay)
            end)
        end
        -- GUI 버튼 업데이트 (기존 GUIObjects.AutoClickBtn 사용)
        local btn = GUIObjects and GUIObjects.AutoClickBtn
        if btn and btn.Parent then
            btn.Text = enabled and "오토클릭 & afk : ON (B)" or "오토클릭 & 점프: OFF (B)"
            btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(26, 26, 26)
        end
        print("오토클릭 + 점프: " .. (enabled and "ON" or "OFF"))
    end
    -- GUI 버튼 연결 (이미 있는 버튼 재활용)
    if GUIObjects and GUIObjects.AutoClickBtn then
        GUIObjects.AutoClickBtn.MouseButton1Click:Connect(function()
            SetAutoEnabled(not AutoEnabled)
        end)
    end
    -- B 키 토글
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.B then
            SetAutoEnabled(not AutoEnabled)
        end
    end)
    -- 캐릭터 리스폰 시 Humanoid 재연결
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
    end)
-- ==================== 오토클릭 + 점프 끝 ====================
    -- =============== 완벽한 속도 조절 슬라이더 (오토클릭 버튼 바로 아래) ===============
    local container = GUIObjects.ClickContainer
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 80)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, 58)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = container
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "클릭 속도"
    Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = SliderFrame
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, 0, 0, 28)
    ValueLabel.Position = UDim2.new(0, 0, 0, 22)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 19
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.Parent = SliderFrame
    -- 트랙 (배경 바)
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 8)
    Track.Position = UDim2.new(0, 0, 0, 56)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Track.BorderSizePixel = 0
    Track.Parent = SliderFrame
    ApplyRounded(Track, 4)
    -- 채워지는 부분
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0.5, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    ApplyRounded(Fill, 4)
    -- Knob (손잡이)
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 24, 0, 24)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5) -- 중앙 기준으로 움직임 (핵심!)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.Parent = Track
    ApplyRounded(Knob, 12)
    ApplyStroke(Knob, 3, Color3.fromRGB(0, 180, 255))
    -- 드래그 상태 변수
    local dragging = false
    local dragOffsetX = 0
    -- 드래그 시작 함수 (Track 또는 Knob 클릭 모두 가능)
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            -- Knob 중앙 위치와 마우스 위치 차이 계산
            local knobCenterX = Knob.AbsolutePosition.X + Knob.AbsoluteSize.X / 2
            dragOffsetX = input.Position.X - knobCenterX
        end
    end
    Track.InputBegan:Connect(startDrag)
    Knob.InputBegan:Connect(startDrag) -- Knob 직접 잡아도 드래그 가능
    -- 드래그 중
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local mouseX = input.Position.X - dragOffsetX
        local trackLeft = Track.AbsolutePosition.X
        local trackRight = trackLeft + Track.AbsoluteSize.X
        local clampedX = math.clamp(mouseX, trackLeft, trackRight)
        local relX = (clampedX - trackLeft) / Track.AbsoluteSize.X
        -- 로그 스케일로 지수적 변환 (0.01 ~ 5.0초)
        local min, max = 0.01, 5.0
        _G.AutoClickDelay = math.exp(math.log(min) + relX * (math.log(max) - math.log(min)))
        -- UI 업데이트
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        Knob.Position = UDim2.new(relX, 0, 0.5, 0) -- AnchorPoint 때문에 오프셋 0으로 깔끔
        ValueLabel.Text = string.format("%.3f초 (%.1f CPS)", _G.AutoClickDelay, 1 / _G.AutoClickDelay)
    end)
    -- 드래그 종료
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    -- 슬라이더 초기값 반영
    local function updateSlider()
        local relX = (math.log(_G.AutoClickDelay) - math.log(0.01)) / (math.log(5.0) - math.log(0.01))
        relX = math.clamp(relX, 0, 1)
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        Knob.Position = UDim2.new(relX, 0, 0.5, 0)
        ValueLabel.Text = string.format("%.3f초 (%.1f CPS)", _G.AutoClickDelay, 1 / _G.AutoClickDelay)
    end
    updateSlider()
end
-- ==================== HP 0 → 5초 후 죽은 자리 TP (완벽 버전) ====================
do
    local DeathTP_Enabled = false
    local DeathPosition = nil
    -- 매 프레임 HP 체크 (Humanoid.Died보다 빠르고 확실함)
    spawn(function()
        while true do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                if hum.Health <= 0 and DeathTP_Enabled and DeathPosition == nil then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        DeathPosition = hrp.Position + Vector3.new(0, 8, 0)
                        print("[HP 0 감지] 죽은 위치 저장:", DeathPosition)
                      
                        -- 5초 딱 기다렸다가 TP
                        task.wait(5)
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local newHrp = LocalPlayer.Character.HumanoidRootPart
                            pcall(function()
                                newHrp.CFrame = CFrame.new(DeathPosition)
                            end)
                            print("[5초 후 TP 완료] 죽은 자리로 귀환!")
                        end
                        DeathPosition = nil -- 다음 죽음 대비 초기화
                    end
                end
            end
            task.wait(0.1) -- 0.1초마다 체크 (부하 없음)
        end
    end)
    -- 오토 탭에 토글 버튼 추가
    task.spawn(function()
        task.wait(2) -- GUI 로드 대기
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 50)
        btn.Position = UDim2.new(0.05, 0, 0, 280) -- 오토클릭 아래쪽
        btn.BackgroundColor3 = Color3.fromRGB(26,26,26)
        btn.Text = "뒤진곳 TP: OFF"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Parent = GUIObjects.ClickContainer
        ApplyRounded(btn, 12)
        ApplyStroke(btn, 2, Color3.fromRGB(255,100,100))
        btn.MouseButton1Click:Connect(function()
            DeathTP_Enabled = not DeathTP_Enabled
            btn.Text = DeathTP_Enabled and "뒤진곳 TP: ON" or "뒤진곳 TP: OFF"
            btn.BackgroundColor3 = DeathTP_Enabled and Color3.fromRGB(160,30,30) or Color3.fromRGB(26,26,26)
        end)
    end)
end
-- 오토팜 OFF 시 노클립 완전 정리 (안전장치)
game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if not AutoFarmEnabled and NoclipEnabled then
        NoclipEnabled = false
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end)
