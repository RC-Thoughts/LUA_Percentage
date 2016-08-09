--[[
    Percentage script takes (almost) any telemetry sensor
	and converts a user-specified sensor-range to 0-100% 
	or 100-0% per user choise. 
	
	Also it makes a LUA control (switch) that can be used as
	any other switch, voices, alarms etc.
	
	Script is my first serious attempt to something and is
	something like beta, there are no safety checks. 
	
	I am not responsible for anything you mess up with this.
	
	Tero @ RC-Thoughts.com 2016
--]]

local appName = "Percentage Display"
--------------------------------------------------------------------------------
local label, sens, sensid, senspa, mini, maxi 
local id, param, telem, telemVal, alarm, asce
local sensorLalist = {"..."}
local sensorIdlist = {"..."}
local sensorPalist = {"..."}
--------------------------------------------------------------------------------
local sensors = system.getSensors()
	for i,sensor in ipairs(sensors) do
		if (sensor.label ~= "") then
			table.insert(sensorLalist, string.format("%s", sensor.label))
			table.insert(sensorIdlist, string.format("%s", sensor.id))
			table.insert(sensorPalist, string.format("%s", sensor.param))
		end
	end
--------------------------------------------------------------------------------
local function labelChanged(value)
	label=value
	system.pSave("label",value)
end

local function sensorChanged(value)
	sens=value
	sensid=value
	senspa=value
	system.pSave("sens",value)
	system.pSave("sensid",value)
	system.pSave("senspa",value)
end

local function miniChanged(value)
	mini=value
	system.pSave("mini",value)
end

local function maxiChanged(value)
	maxi=value
	system.pSave("maxi",value)	
end

local function alarmChanged(value)
	alarm=value
	system.pSave("alarm",value)
	system.setControl(1, 0 ,1000,1)
end

local function asceChanged(value)
	asce=value
	system.pSave("asce",value)
	system.setControl(1, 0 ,1000,1)
end
--------------------------------------------------------------------------------
local function initForm()
	form.addRow(2)
	form.addLabel({label="Window label"})
	form.addTextbox(label,20,labelChanged)
	
	form.addRow(2)
	form.addLabel({label="Select sensor"})
	form.addSelectbox(sensorLalist,sens,true,sensorChanged)

	form.addRow(2)
	form.addLabel({label="Sensor low value"})
	form.addIntbox(mini,0,32767,0,0,1,miniChanged)
	
	form.addRow(2)
	form.addLabel({label="Sensor high value"})
	form.addIntbox(maxi,0,32767,0,0,1,maxiChanged)
	
	form.addRow(2)
	form.addLabel({label="Alarm point value"})
	form.addIntbox(alarm,0,32767,0,0,1,alarmChanged)
	
	form.addRow(2)
	form.addLabel({label="Low alarm (0/1)"})
	form.addIntbox(asce,0,1,0,0,1,asceChanged)

	form.addRow(1)
	form.addLabel({label="Powered by RC-Thoughts.com",font=FONT_MINI, alignRight=true})
end
---------------------------------------------------------------------------------
local function printTelemetry()
	if (telemVal == "-") then
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-"),10,"-",FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),55,"RC-Thoughts.com",FONT_MINI)
	else
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%", telemVal)),10,string.format("%s%%", telemVal),FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),55,"RC-Thoughts.com",FONT_MINI)
	end
end
--------------------------------------------------------------------------------
local function loop()
	local id = string.format("%s", sensorIdlist[sensid])
	local param = string.format("%s", sensorPalist[senspa])
	telemVal = "0"
	local result = "0"
	local tvalue = "0"
	local alarm = string.format("%.2f", alarm)
	
	local sensors = system.getSensors()
	for i,sensor in ipairs(sensors) do
		if (string.format("%s", sensor.id) == id) and (string.format("%s", sensor.param) == param) then
			if sensor.valid then
				tvalue = string.format("%s", sensor.value)
				if (mini < maxi) then
					local result = (((tvalue - mini) * 100) / (maxi - mini))
					telemVal = string.format("%.1f", result)
				else
					local result = (((mini - tvalue) * 100) / (mini - maxi))
					telemVal = string.format("%.1f", result)
				end
				if (string.format("%s", asce) == "1") then
					if (telemVal <= alarm) then
						system.setControl(1, 1 ,1000,1)
					else
						system.setControl(1, 0 ,1000,1)
					end
				else
					if (telemVal >= alarm) then
						system.setControl(1, 1 ,1000,1)
					else
						system.setControl(1, 0 ,1000,1)
					end
				end
			else
				telemVal = "-"
			end
		end
	end
	
end
--------------------------------------------------------------------------------
local function init() 
	label = system.pLoad("label","N/A")
	sens = system.pLoad("sens",0)
	sensid = system.pLoad("sensid",0)
	senspa = system.pLoad("senspa",0)
	mini = system.pLoad("mini",0)
	maxi = system.pLoad("maxi",0)
	alarm = system.pLoad("alarm",0)
	asce = system.pLoad("asce",0)
	telemVal = "-"
	system.registerForm(1, MENU_APPS, appName, initForm)
	system.registerTelemetry(1,label,2,printTelemetry)
	system.registerControl (1, "PercentageCtrl", "C01")
	system.setControl(1, 0 ,1000,1)
end
--------------------------------------------------------------------------------
return {init=init, loop=loop, author="RC-Thoughts", version="1.0", name=appName} 
