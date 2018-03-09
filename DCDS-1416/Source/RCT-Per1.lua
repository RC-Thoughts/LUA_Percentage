--[[
    --------------------------------------------------------------
    Percentage application takes (almost) any telemetry sensor
    and converts a user-specified sensor-range to 0-100% 
    or 100-0% per user choise. 
    
    Also it makes a LUA control (switch) that can be used as
    any other switch,voices,alarms etc.
    
    French translation courtesy from Daniel Memim
    Spanish translation courtesy from César Casado
    Italian translation courtesy from Fabrizio Zaini
    --------------------------------------------------------------
    Percentage application is part of RC-Thoughts Jeti Tools.
    --------------------------------------------------------------
    Released under MIT-license by Tero @ RC-Thoughts.com 2016-2017
    --------------------------------------------------------------
--]]
collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local label,sensid,senspa,mini,maxi,ensensVal,result
local telemVal,sensVal,alarm,alarmTr,asce,dec1,tvalue
local altList = {}
----------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-Per1.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans2 = obj[lng] or obj[obj.default]
    end
    collectgarbage()
end
----------------------------------------------------------------------
-- Draw the telemetry windows
-- Percentage 1
local function printTelemetry(width,height)
    if(height==69)then -- Big window
        if (telemVal == "-") then
            lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-%"),10,"-%",FONT_MAXI)
            else
            lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%",telemVal)),10,string.format("%s%%",telemVal),FONT_MAXI)
        end
        if(ensensVal == 1)then 
            lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
            lcd.drawImage(1,51,":graph")
            else
            if (telemVal == "-") then
                lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
                lcd.drawImage(1,51,":graph")
                else
                lcd.drawText(145 - lcd.getTextWidth(FONT_NORMAL,string.format("%s",sensVal)),50,string.format("%s",sensVal),FONT_NORMAL)
                lcd.drawImage(1,51,":graph")
            end
        end
        else -- Small window
        if (telemVal == "-") then
            lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,"-%"),1,"-%",FONT_BIG)
            else
            lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,string.format("%s%%",telemVal)),1,string.format("%s%%",telemVal),FONT_BIG)
        end
    end
    collectgarbage()
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
    sensid = sensorsAvailable[value].id
    senspa = sensorsAvailable[value].param
    system.pSave("sensid",sensid)
    system.pSave("senspa",senspa)
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
    alarmTr = string.format("%.2f",alarm)
    system.pSave("alarmTr",alarmTr)
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

local function ensensValChanged(value)
    ensensVal=value
    system.pSave("ensensVal",value)
end
----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm(subform)
    -- List sensors only if menu is active to preserve memory at runtime 
    -- (measured up to 25% save if menu is not opened)
    sensorsAvailable = {}
    local sensors = system.getSensors()
    local sensorTx = system.getTxTelemetry()
    local list={}
    local curIndex1 = -1
    local descr = ""
    -- Add some of RX Telemetry items to beginning in list of sensors, get name from translation
    list[#list + 1] = string.format("%s",trans2.sensorRx1)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 1,["id"] = 999,["label"] = trans2.sensorRx1}
    if(sensid == 999 and senspa == 1) then
        curIndex1 = 1
    end
    list[#list + 1] = string.format("%s",trans2.sensorRx2)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 2,["id"] = 999,["label"] = trans2.sensorRx2}
    if(sensid == 999 and senspa == 2) then
        curIndex1 = 2
    end
    list[#list + 1] = string.format("%s",trans2.sensorRxB)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 3,["id"] = 999,["label"] = trans2.sensorRxB}
    if(sensid == 999 and senspa == 3) then
        curIndex1 = 3
    end
    -- Create a list of normal sensors
    for index,sensor in ipairs(sensors) do 
        if(sensor.param == 0) then
            descr = sensor.label
            else
            list[#list + 1] = string.format("%s - %s",descr,sensor.label)
            sensorsAvailable[#sensorsAvailable + 1] = sensor
            if(sensor.id == sensid and sensor.param == senspa) then
                curIndex1 =# sensorsAvailable
            end
        end
    end
    collectgarbage()
    
    local form,addRow,addLabel = form,form.addRow,form.addLabel
    local addIntbox,addSelectbox = form.addIntbox,form.addSelectbox
    local addInputbox,addCheckbox = form.addInputbox,form.addCheckbox
    local addAudioFilebox,setButton = form.addAudioFilebox,form.setButton
    local addTextbox = form.addTextbox
    
    addRow(1)
    addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
    
    addRow(1)
    addLabel({label=trans2.labelW1,font=FONT_BOLD})
    
    addRow(2)
    addLabel({label=trans2.winLbl,width=160})
    addTextbox(label,14,labelChanged)
    
    addRow(1)
    addLabel({label=trans2.sensorLbl1,font=FONT_BOLD})
    
    addRow(2)
    addLabel({label=trans2.selSens})
    addSelectbox(list,curIndex1,true,sensorChanged)
    
    addRow(2)
    addLabel({label=trans2.decimal})
    addIntbox(dec1,0,3,0,0,1,dec1Changed)
    
    addRow(2)
    addLabel({label=trans2.sensLow})
    addIntbox(mini,0,32767,0,dec1,1,miniChanged)
    
    addRow(2)
    addLabel({label=trans2.sensHigh})
    addIntbox(maxi,0,32767,0,dec1,1,maxiChanged)
    
    addRow(2)
    addLabel({label=trans2.sensValue})
    addSelectbox(altList,ensensVal,false,ensensValChanged)
    
    addRow(1)
    addLabel({label=trans2.almTxt1,font=FONT_BOLD})
    
    addRow(2)
    addLabel({label=trans2.almLow})
    addSelectbox(altList,asce,false,asceChanged)
    
    addRow(2)
    addLabel({label=trans2.almPnt})
    addIntbox(alarm,0,32767,0,0,1,alarmChanged)
    
    addRow(1)
    addLabel({label="Powered by RC-Thoughts.com - "..percVersion.." ",font=FONT_MINI,alignRight=true})
    
    formID = 1
    
    collectgarbage()
end
----------------------------------------------------------------------
-- Runtime functions,read sensor,convert to percentage,keep percentage between 0 and 100 at all times
local function loop()
    -- Take care of percentage 1
    local sensor = {}
    local sensorTx = system.getTxTelemetry()
    if(sensid == 999) then
        sensor.valid = true
        sensor.unit = "V"
        if(senspa == 1) then
            sensor.value = sensorTx.rx1Voltage
            elseif (senspa == 2) then
            sensor.value = sensorTx.rx2Voltage
            elseif (senspa == 3) then
            sensor.value = sensorTx.rxBVoltage
        end
        else
        sensor = system.getSensorByID(sensid,senspa)
    end
    
    if(sensor and sensor.valid) then
        sensVal = string.format("%.2f%s", sensor.value, sensor.unit)
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
        tvalue = string.format("%s",sensor.value)
        if (mini < maxi) then
            local result = (((tvalue - mini) * 100) / (maxi - mini))
            if (result > 100) then
                result = 100
                else
                if (result < 0) then 
                    result = 0
                end
            end
            telemVal = string.format("%.1f",result)
            else
            local result = (((mini - tvalue) * 100) / (mini - maxi))
            if (result < 0) then
                result = 0
                else
                if (result > 100) then
                    result = 100
                end
            end
            telemVal = string.format("%.1f",result)
        end
        if (alarm and alarm > 0) then
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
            system.setControl(1,0,1000,1)
        end
        else
        telemVal = "-"
    end
    collectgarbage()
end
----------------------------------------------------------------------
-- Application initialization
local function init()
    local pLoad,registerForm,registerTelemetry = system.pLoad,system.registerForm
    local registerControl,registerTelemetry = system.registerControl,system.registerTelemetry
    registerForm(1,MENU_APPS,trans2.appName,initForm,keyPressed)
    label = pLoad("label",trans2.labelDef1)
    sensid = pLoad("sensid",0)
    senspa = pLoad("senspa",0)
    mini = pLoad("mini",0)
    maxi = pLoad("maxi",0)
    alarm = pLoad("alarm",0)
    alarmTr = pLoad("alarmTr",0)
    asce = pLoad("asce",1)
    ensensVal = pLoad("ensensVal",1)
    dec1 = pLoad("dec1",0)
    telemVal = "-"
    table.insert(altList,trans2.neg)
    table.insert(altList,trans2.pos)
    registerTelemetry(1,label,0,printTelemetry)
    registerControl(1,trans2.control1,trans2.cl1)
    collectgarbage()
end
----------------------------------------------------------------------
percVersion = "v.2.5"
setLanguage()
collectgarbage()
return {init=init,loop=loop,author="RC-Thoughts",version="2.5",name=trans2.appName}     