--[[
	---------------------------------------------------------
    Percentage application takes (almost) any telemetry sensor
	and converts a user-specified sensor-range to 0-100% 
	or 100-0% per user choise. 
	
	Also it makes a LUA control (switch) that can be used as
	any other switch, voices, alarms etc.
	
	French translation courtesy from Daniel Memim
	Spanish translation courtesy from César Casado
	Italian translation courtesy from Fabrizio Zaini
	---------------------------------------------------------
	Percentage application is part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2016
	---------------------------------------------------------
--]]
collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local label, sens, sensid, senspa, mini, maxi, id, param
local label2, sens2, sensid2, senspa2, mini2, maxi2, id2, param2 
local telem, telemVal, alarm, asce, limit, enalm, dec1, dec2
local telem2, telemVal2, alarm2, asce2, limit2, enalm2
local result, result2, tvalue, tvalue2, limit, limit2
local sensorLalist = {"..."}
local sensorLalist2 = {"..."}
local sensorIdlist = {"..."}
local sensorIdlist2 = {"..."}
local sensorPalist = {"..."}
local sensorPalist2 = {"..."}
local enalarmlist = {}
local enalarmlist2 = {}
local ascelist = {}
local ascelist2 = {}
----------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-Perc.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans2 = obj[lng] or obj[obj.default]
    end
end
----------------------------------------------------------------------
-- Read available sensors for user to select
local sensors = system.getSensors()
for i,sensor in ipairs(sensors) do
	if (sensor.label ~= "") then
		table.insert(sensorLalist, string.format("%s", sensor.label))
		table.insert(sensorIdlist, string.format("%s", sensor.id))
		table.insert(sensorPalist, string.format("%s", sensor.param))
		table.insert(sensorLalist2, string.format("%s", sensor.label))
		table.insert(sensorIdlist2, string.format("%s", sensor.id))
		table.insert(sensorPalist2, string.format("%s", sensor.param))
	end
end
----------------------------------------------------------------------
-- Draw the telemetry windows
local function printTelemetry()
	if (telemVal == "-") then
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-"),10,"-",FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
		else
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%", telemVal)),10,string.format("%s%%", telemVal),FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
	end
end

local function printTelemetry2()
	if (telemVal2 == "-") then
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-"),10,"-",FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
		else
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%", telemVal2)),10,string.format("%s%%", telemVal2),FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
	end
end
----------------------------------------------------------------------
-- Store settings when changed by user
local function labelChanged(value)
	label=value
	system.pSave("label",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,label,2,printTelemetry)
end

local function sensorChanged(value)
	sens=value
	sensid=value
	senspa=value
	system.pSave("sens",value)
	system.pSave("sensid",value)
	system.pSave("senspa",value)
	id = string.format("%s", sensorIdlist[sensid])
	param = string.format("%s", sensorPalist[senspa])
	if (id == "...") then
		id = 0
		param = 0
	end
	system.pSave("id", id)
	system.pSave("param", param)
end

local function miniChanged(value)
	if (value == nil) then
		value = 0
	end
	mini=value
	system.pSave("mini",value)
end

local function maxiChanged(value)
	if (value == nil) then
		value = 0
	end
	maxi=value
	system.pSave("maxi",value)	
end

local function alarmChanged(value)
	alarm=value
	system.pSave("alarm",value)
	system.setControl(1,0,0,0)
	alarmTr = string.format("%.2f", alarm)
	system.pSave("alarmTr", alarmTr)
end

local function dec1Changed(value)
	dec1=value
	system.pSave("dec1",value)
	form.reinit(1)
	form.setFocusedRow(6)
	miniChanged()
	maxiChanged()
end

local function asceChanged(value)
	asce=value
	system.pSave("asce",value)
	system.setControl(1,0,0,0)
end

local function enalmChanged(value)
	enalm=value
	system.pSave("enalm",value)
end
--
local function labelChanged2(value)
	label2=value
	system.pSave("label2",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(2,label2,2,printTelemetry2)
end

local function sensorChanged2(value)
	sens2=value
	sensid2=value
	senspa2=value
	system.pSave("sens2",value)
	system.pSave("sensid2",value)
	system.pSave("senspa2",value)
	id2 = string.format("%s", sensorIdlist2[sensid2])
	param2 = string.format("%s", sensorPalist2[senspa2])
	if (id2 == "...") then
		id2 = 0
		param2 = 0
	end
	system.pSave("id2", id2)
	system.pSave("param2", param2)
end

local function miniChanged2(value)
	if (value == nil) then
		value = 0
	end
	mini2=value
	system.pSave("mini2",value)
end

local function maxiChanged2(value)
	if (value == nil) then
		value = 0
	end
	maxi2=value
	system.pSave("maxi2",value)	
end

local function alarmChanged2(value)
	alarm2=value
	system.pSave("alarm2",value)
	system.setControl(2,0,0,0)
	local alarmTr2 = string.format("%.2f", alarm2)
	system.pSave("alarmTr2", alarmTr2)
end

local function dec2Changed(value)
	dec2=value
	system.pSave("dec2",value)
	form.reinit(2)
	form.setFocusedRow(6)
	miniChanged2()
	maxiChanged2()
end

local function asceChanged2(value)
	asce2=value
	system.pSave("asce2",value)
	system.setControl(2,0,0,0)
end

local function enalmChanged(value)
	enalm=value
	system.pSave("enalm",value)
end
----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm(subform)
	if(subform == 1) then
		form.setButton(1,"Sen 1",HIGHLIGHTED)
		form.setButton(2,"Sen 2",ENABLED)
		
		form.addRow(1)
		form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
		
		form.addRow(1)
		form.addLabel({label=trans2.labelW1,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=trans2.winLbl,width=160})
		form.addTextbox(label,14,labelChanged)
		
		form.addRow(1)
		form.addLabel({label=trans2.sensorLbl1,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=trans2.selSens})
		form.addSelectbox(sensorLalist,sens,true,sensorChanged)
		
		form.addRow(2)
		form.addLabel({label=trans2.decimal})
		form.addIntbox(dec1,0,3,0,0,1,dec1Changed)
		
		form.addRow(2)
		form.addLabel({label=trans2.sensLow})
		form.addIntbox(mini,0,32767,0,dec1,1,miniChanged)
		
		form.addRow(2)
		form.addLabel({label=trans2.sensHigh})
		form.addIntbox(maxi,0,32767,0,dec1,1,maxiChanged)
		
		form.addRow(1)
		form.addLabel({label=trans2.almTxt1,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=trans2.almEn})
		form.addSelectbox(enalarmlist,enalm,false,enalmChanged)
		
		form.addRow(2)
		form.addLabel({label=trans2.almLow})
		form.addSelectbox(ascelist,asce,false,asceChanged)
		
		form.addRow(2)
		form.addLabel({label=trans2.almPnt})
		form.addIntbox(alarm,0,32767,0,0,1,alarmChanged)
		
		form.addRow(1)
		form.addLabel({label="Powered by RC-Thoughts.com - "..percVersion.." ",font=FONT_MINI, alignRight=true})
		
		formID = 1
		
		else
		-- If we are on second app build the form for display
		if(subform == 2) then		
			form.setButton(1,"Sen 1",ENABLED)
			form.setButton(2,"Sen 2",HIGHLIGHTED)
			
			form.addRow(1)
			form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
			
			form.addRow(1)
			form.addLabel({label=trans2.labelW2,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=trans2.winLbl,width=160})
			form.addTextbox(label2,14,labelChanged2)
			
			form.addRow(1)
			form.addLabel({label=trans2.sensorLbl2,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=trans2.selSens})
			form.addSelectbox(sensorLalist2,sens2,true,sensorChanged2)
			
			form.addRow(2)
			form.addLabel({label=trans2.decimal})
			form.addIntbox(dec2,0,3,0,0,1,dec2Changed)
			
			form.addRow(2)
			form.addLabel({label=trans2.sensLow})
			form.addIntbox(mini2,0,32767,0,dec2,1,miniChanged2)
			
			form.addRow(2)
			form.addLabel({label=trans2.sensHigh})
			form.addIntbox(maxi2,0,32767,0,dec2,1,maxiChanged2)
			
			form.addRow(1)
			form.addLabel({label=trans2.almTxt2,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=trans2.almEn})
			form.addSelectbox(enalarmlist2,enalm2,false,enalmChanged2)
			
			form.addRow(2)
			form.addLabel({label=trans2.almLow})
			form.addSelectbox(ascelist2,asce2,false,asceChanged2)
			
			form.addRow(2)
			form.addLabel({label=trans2.almPnt})
			form.addIntbox(alarm2,0,32767,0,0,1,alarmChanged2)
			
			form.addRow(1)
			form.addLabel({label="Powered by RC-Thoughts.com - "..percVersion.." ",font=FONT_MINI, alignRight=true})
			
			formID = 2
		end
	end
    collectgarbage()
end
----------------------------------------------------------------------
-- Re-init correct form if navigation buttons are pressed
local function keyPressed(key)
	if(key==KEY_1) then
		if(formID == 1) then
			form.reinit(1)
			else if(formID == 2) then
				form.reinit(1)
			end
		end
		else if(key == KEY_2) then
			if(formID == 1) then
				form.reinit(2)
			end
		end
	end
end
----------------------------------------------------------------------
-- Runtime functions, read sensor, convert to percentage, keep percentage between 0 and 100 at all times
local function loop()
	local sensor = system.getSensorByID(id, param)
	if(sensor and sensor.valid) then
		if(dec1 == 1) then
			sensor.value = (sensor.value*10)
			else
			if(dec1 == 2) then
				sensor.value = (sensor.value*100)
				else
				if(dec1 == 3) then
					sensor.value = (sensor.value*1000)
				end
			end
		end
		tvalue = string.format("%s", sensor.value)
		if (mini < maxi) then
			local result = (((tvalue - mini) * 100) / (maxi - mini))
			if (result > 100) then
				result = 100
				else
				if (result < 0) then 
					result = 0
				end
			end
			telemVal = string.format("%.1f", result)
			else
			local result = (((mini - tvalue) * 100) / (mini - maxi))
			if (result < 0) then
				result = 0
				else
				if (result > 100) then
					result = 100
				end
			end
			telemVal = string.format("%.1f", result)
		end
		if (enalm == 2) then
			if (asce == 2) then
				if (telemVal <= alarmTr) then
					system.setControl(1,1,0,0)
					else
					system.setControl(1,0,0,0)
				end
				else
				if (telemVal >= alarmTr) then
					system.setControl(1,1,0,1)
					else
					system.setControl(1,0,0,1)
				end
			end
			else
			system.setControl(1, 0 ,1000,1)
		end
		else
		telemVal = "-"
	end
	
	-- Take care of percentage 2
	local sensor = system.getSensorByID(id2, param2)
	if(sensor and sensor.valid) then
		if(dec2 == 1) then
			sensor.value = (sensor.value*10)
			else
			if(dec2 == 2) then
				sensor.value = (sensor.value*100)
				else
				if(dec2 == 3) then
					sensor.value = (sensor.value*1000)
				end
			end
		end
		tvalue2 = string.format("%s", sensor.value)
		if (mini2 < maxi2) then
			local result2 = (((tvalue2 - mini2) * 100) / (maxi2 - mini2))
			if (result2 > 100) then
				result2 = 100
				else
				if (result2 < 0) then 
					result2 = 0
				end
			end
			telemVal2 = string.format("%.1f", result2)
			else
			local result2 = (((mini2 - tvalue2) * 100) / (mini2 - maxi2))
			if (result2 < 0) then
				result2 = 0
				else
				if (result2 > 100) then
					result2 = 100
				end
			end
			telemVal2 = string.format("%.1f", result2)
		end
		if (enalm2 == 2) then
			if (asce2 == 2) then
				if (telemVal2 <= alarmTr2) then
					system.setControl(2,1,0,0)
					else
					system.setControl(2,0,0,0)
				end
				else
				if (telemVal2 >= alarmTr2) then
					system.setControl(2,1,0,0)
					else
					system.setControl(2,0,0,1)
				end
			end
			else
			system.setControl(2,0,0,0)
		end
		else
		telemVal2 = "-"
	end
    collectgarbage()
end
----------------------------------------------------------------------
-- Application initialization
local function init()
	system.registerForm(1,MENU_APPS,trans2.appName,initForm,keyPressed)
	label = system.pLoad("label",trans2.labelDef1)
	label2 = system.pLoad("label2",trans2.labelDef2)
	sens = system.pLoad("sens",0)
	sens2 = system.pLoad("sens2",0)
	sensid = system.pLoad("sensid",0)
	sensid2 = system.pLoad("sensid2",0)
	senspa = system.pLoad("senspa",0)
	senspa2 = system.pLoad("senspa2",0)
	mini = system.pLoad("mini",0)
	mini2 = system.pLoad("mini2",0)
	maxi = system.pLoad("maxi",0)
	maxi2 = system.pLoad("maxi2",0)
	alarm = system.pLoad("alarm",0)
	alarm2 = system.pLoad("alarm2",0)
	alarmTr = system.pLoad("alarmTr",0)
	alarmTr2 = system.pLoad("alarmTr2",0)
	asce = system.pLoad("asce",1)
	asce2 = system.pLoad("asce2",1)
	enalm = system.pLoad("enalm",1)
	enalm2 = system.pLoad("enalm2",1)
	id = system.pLoad("id",0)
	id2 = system.pLoad("id2",0)
	param = system.pLoad("param",0)
	param2 = system.pLoad("param2",0)
	dec1 = system.pLoad("dec1",0)
	dec2 = system.pLoad("dec2",0)
	telemVal = "-"
	telemVal2 = "-"
	table.insert(enalarmlist,trans2.neg)
	table.insert(enalarmlist,trans2.pos)
	table.insert(enalarmlist2,trans2.neg)
	table.insert(enalarmlist2,trans2.pos)
	table.insert(ascelist,trans2.neg)
	table.insert(ascelist,trans2.pos)
	table.insert(ascelist2,trans2.neg)
	table.insert(ascelist2,trans2.pos)
	system.registerTelemetry(1,label,2,printTelemetry)
	system.registerTelemetry(2,label2,2,printTelemetry2)
	system.registerControl(1,trans2.control1,trans2.cl1)
	system.registerControl(2,trans2.control2,trans2.cl2)
    collectgarbage()
end
----------------------------------------------------------------------
percVersion = "v.2.4"
setLanguage()
collectgarbage()
return {init=init, loop=loop, author="RC-Thoughts", version="2.1", name=trans2.appName} 