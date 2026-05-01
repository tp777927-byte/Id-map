-- 🔑 HayateX Loader (Improved)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local userId = player.UserId

-- 🔧 ตั้งค่า
local KEY = _G.key or ""
local DOMAIN = "https://id-map-1.onrender.com" -- ✅ เปลี่ยนเป็น API ใหม่

-- 🔔 Notify กันพัง
local function Notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "HayateX",
            Text = msg,
            Duration = 4
        })
    end)
end

-- ❌ ไม่มีคีย์
if KEY == "" then
    Notify("❌ กรุณาใส่คีย์ก่อน")
    return
end

-- 🔗 API URL
local url = DOMAIN.."/api/validate?key="..KEY.."&userid="..userId

-- 🔍 ยิง API
local response
local ok = pcall(function()
    response = game:HttpGet(url)
end)

if not ok or not response then
    Notify("❌ เชื่อม API ไม่ได้ (Server อาจหลับ)")
    return
end

-- 📦 แปลง JSON
local data
local success = pcall(function()
    data = HttpService:JSONDecode(response)
end)

if not success or type(data) ~= "table" then
    Notify("❌ API ส่งค่าผิด")
    return
end

-- 🔍 ตรวจ key
if data.valid == true then
    Notify("✔ Key ถูกต้อง กำลังโหลด...")

    task.wait(1)

    -- 🔥 โหลดสคริปหลัก
    local MAIN_URL = "https://raw.githubusercontent.com/tp777927-byte/Id-map/main/DextzrHub%E0%B9%84%E0%B8%AD%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2%E0%B8%AB%E0%B8%B5%E0%B9%84%E0%B8%AD%E0%B8%AA%E0%B8%B1%E0%B8%AA%E0%B9%84%E0%B8%AD%E0%B8%84%E0%B8%A7%E0%B8%A2%E0%B8%94%E0%B8%B9%E0%B8%AB%E0%B8%B2%E0%B8%9E%E0%B9%88%E0%B8%AD%E0%B8%A1%E0%B8%B6%E0%B8%83%E0%B8%AB%E0%B8%A3%E0%B8%AD%E0%B9%84%E0%B8%AD%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A2.lua"

    local scriptData
    local loaded = pcall(function()
        scriptData = game:HttpGet(MAIN_URL)
    end)

    if loaded and scriptData and #scriptData > 0 then
        (loadstring or load)(scriptData)()
    else
        Notify("❌ โหลดสคริปไม่สำเร็จ")
    end

else
    Notify("❌ Key ไม่ถูกต้อง / หมดอายุ")
    task.wait(1)
    player:Kick("Invalid or Expired Key")
end
