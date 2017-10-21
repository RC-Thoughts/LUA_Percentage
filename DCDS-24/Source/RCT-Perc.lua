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
local label,sensid,senspa,mini,maxi,ensensVal,unit
local label2,sensid2,senspa2,mini2,maxi2,ensensVal2,unit2
local telemVal,sensVal,alarm,alarmTr,asce,limit,dec1
local telemVal2,sensVal2,alarm2,alarmTr2,asce2,limit2,dec2
local result,result2,tvalue,tvalue2,limit,limit2
local altList = {}
----------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-Perc.jsn")
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

-- Percentage 2
local function printTelemetry2(width,height)
    if(height==69)then -- Big window
        if (telemVal2 == "-") then
            lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-%"),10,"-%",FONT_MAXI)
            else
            lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%",telemVal2)),10,string.format("%s%%",telemVal2),FONT_MAXI)
        end
        if(ensensVal2 == 1)then 
            lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
            lcd.drawImage(1,51,":graph")
            else
            if (telemVal2 == "-") then 
                lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
                lcd.drawImage(1,51,":graph")
                else
                lcd.drawText(145 - lcd.getTextWidth(FONT_NORMAL,string.format("%s",sensVal2)),50,string.format("%s",sensVal2),FONT_NORMAL)
                lcd.drawImage(1,51,":graph")
            end
        end
        else -- Small window
        if (telemVal2 == "-") then
            lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,"-"),1,"-",FONT_BIG)
            else
            lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,string.format("%s%%",telemVal2)),1,string.format("%s%%",telemVal2),FONT_BIG)
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
--
local function labelChanged2(value)
    label2=value
    system.pSave("label2",value)
    -- Redraw telemetrywindow if label is changed by user
    system.registerTelemetry(2,label2,2,printTelemetry2)
end

local function sensorChanged2(value)
    sensid2 = sensorsAvailable[value].id
    senspa2 = sensorsAvailable[value].param
    system.pSave("sensid2",sensid2)
    system.pSave("senspa2",senspa2)
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
    local alarmTr2 = string.format("%.2f",alarm2)
    system.pSave("alarmTr2",alarmTr2)
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

local function ensensValChanged2(value)
    ensensVal2=value
    system.pSave("ensensVal2",value)
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
    local curIndex1,curIndex2 = -1,-1
    local descr = ""
    -- Add some of RX Telemetry items to beginning in list of sensors, get name from translation
    list[#list + 1] = string.format("%s",trans2.sensorRx1)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 1,["id"] = 999,["label"] = trans2.sensorRx1}
    if(sensid == 999 and senspa == 1) then
        curIndex1 = 1
    end
    if(sensid2 == 999 and senspa2 == 1) then
        curIndex2 = 1
    end
    list[#list + 1] = string.format("%s",trans2.sensorRx2)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 2,["id"] = 999,["label"] = trans2.sensorRx2}
    if(sensid == 999 and senspa == 2) then
        curIndex1 = 2
    end
    if(sensid2 == 999 and senspa2 == 2) then
        curIndex2 = 2
    end
    list[#list + 1] = string.format("%s",trans2.sensorRxB)
    sensorsAvailable[#sensorsAvailable + 1] = {["unit"] = "V", ["param"] = 3,["id"] = 999,["label"] = trans2.sensorRxB}
    if(sensid == 999 and senspa == 3) then
        curIndex1 = 3
    end
    if(sensid2 == 999 and senspa2 == 3) then
        curIndex2 = 3
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
            if(sensor.id == sensid2 and sensor.param == senspa2) then
                curIndex2 =# sensorsAvailable
            end
        end
    end
    collectgarbage()
    
    local form,addRow,addLabel = form,form.addRow,form.addLabel
    local addIntbox,addSelectbox = form.addIntbox,form.addSelectbox
    local addInputbox,addCheckbox = form.addInputbox,form.addCheckbox
    local addAudioFilebox,setButton = form.addAudioFilebox,form.setButton
    local addTextbox = form.addTextbox
    
    if(subform == 1) then
        setButton(1,"Sen 1",HIGHLIGHTED)
        setButton(2,"Sen 2",ENABLED)
        
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
        
        else
        -- If we are on second app build the form for display
        if(subform == 2) then        
            setButton(1,"Sen 1",ENABLED)
            setButton(2,"Sen 2",HIGHLIGHTED)
            
            addRow(1)
            addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
            
            addRow(1)
            addLabel({label=trans2.labelW2,font=FONT_BOLD})
            
            addRow(2)
            addLabel({label=trans2.winLbl,width=160})
            addTextbox(label2,14,labelChanged2)
            
            addRow(1)
            addLabel({label=trans2.sensorLbl2,font=FONT_BOLD})
            
            addRow(2)
            addLabel({label=trans2.selSens})
            addSelectbox(list,curIndex2,true,sensorChanged2)
            
            addRow(2)
            addLabel({label=trans2.decimal})
            addIntbox(dec2,0,3,0,0,1,dec2Changed)
            
            addRow(2)
            addLabel({label=trans2.sensLow})
            addIntbox(mini2,0,32767,0,dec2,1,miniChanged2)
            
            addRow(2)
            addLabel({label=trans2.sensHigh})
            addIntbox(maxi2,0,32767,0,dec2,1,maxiChanged2)
            
            addRow(2)
            addLabel({label=trans2.sensValue})
            addSelectbox(altList,ensensVal2,false,ensensValChanged2)
            
            addRow(1)
            addLabel({label=trans2.almTxt2,font=FONT_BOLD})
            
            addRow(2)
            addLabel({label=trans2.almLow})
            addSelectbox(altList,asce2,false,asceChanged2)
            
            addRow(2)
            addLabel({label=trans2.almPnt})
            addIntbox(alarm2,0,32767,0,0,1,alarmChanged2)
            
            addRow(1)
            addLabel({label="Powered by RC-Thoughts.com - "..percVersion.." ",font=FONT_MINI,alignRight=true})
            
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
    
    -- Take care of percentage 2
    local sensorTx = system.getTxTelemetry()
    if(sensid2 == 999) then
        sensor.valid = true
        sensor.unit = "V"
        if(senspa2 == 1) then
            sensor.value = sensorTx.rx1Voltage
            elseif (senspa2 == 2) then
            sensor.value = sensorTx.rx2Voltage
            elseif (senspa2 == 3) then
            sensor.value = sensorTx.rxBVoltage
        end
        else
        sensor = system.getSensorByID(sensid,senspa)
    end
    
    if(sensor and sensor.valid) then
        sensVal2 = string.format("%.2f%s", sensor.value, sensor.unit)
        unit2 = sensor.unit
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
        tvalue2 = string.format("%s",sensor.value)
        if (mini2 < maxi2) then
            local result2 = (((tvalue2 - mini2) * 100) / (maxi2 - mini2))
            if (result2 > 100) then
                result2 = 100
                else
                if (result2 < 0) then 
                    result2 = 0
                end
            end
            telemVal2 = string.format("%.1f",result2)
            else
            local result2 = (((mini2 - tvalue2) * 100) / (mini2 - maxi2))
            if (result2 < 0) then
                result2 = 0
                else
                if (result2 > 100) then
                    result2 = 100
                end
            end
            telemVal2 = string.format("%.1f",result2)
        end
        if (alarm2 and alarm2 > 0) then
            if (asce2 == 2) then
                if (telemVal2 <= alarmTr2) then
                    system.setControl(2,1,0,0)
                    else
                    system.setControl(2,0,0,0)
                end
                else
                if (telemVal2 >= alarmTr2) then
                    system.setControl(2,1,0,1)
                    else
                    system.setControl(2,0,0,1)
                end
            end
            else
            system.setControl(2,0,1000,1)
        end
        else
        telemVal2 = "-"
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
    label2 = pLoad("label2",trans2.labelDef2)
    sensid = pLoad("sensid",0)
    sensid2 = pLoad("sensid2",0)
    senspa = pLoad("senspa",0)
    senspa2 = pLoad("senspa2",0)
    mini = pLoad("mini",0)
    mini2 = pLoad("mini2",0)
    maxi = pLoad("maxi",0)
    maxi2 = pLoad("maxi2",0)
    alarm = pLoad("alarm",0)
    alarm2 = pLoad("alarm2",0)
    alarmTr = pLoad("alarmTr",0)
    alarmTr2 = pLoad("alarmTr2",0)
    asce = pLoad("asce",1)
    asce2 = pLoad("asce2",1)
    ensensVal = pLoad("ensensVal",1)
    ensensVal2 = pLoad("ensensVal2",1)
    dec1 = pLoad("dec1",0)
    dec2 = pLoad("dec2",0)
    telemVal = "-"
    telemVal2 = "-"
    table.insert(altList,trans2.neg)
    table.insert(altList,trans2.pos)
    registerTelemetry(1,label,0,printTelemetry)
    registerTelemetry(2,label2,0,printTelemetry2)
    registerControl(1,trans2.control1,trans2.cl1)
    registerControl(2,trans2.control2,trans2.cl2)
    collectgarbage()
end
----------------------------------------------------------------------
percVersion = "v.2.5"
setLanguage()
collectgarbage()
return {init=init,loop=loop,author="RC-Thoughts",version="2.5",name=trans2.appName}     