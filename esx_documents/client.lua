ESX = nil
local PlayerData                = {}
local UI_MOUSE_FOCUS = false
local USER_DOCUMENTS = {}
local fontId
local CURRENT_DOCUMENT = nil
local DOCUMENT_FORMS = nil

local MENU_OPTIONS = {
    x = 0.5,
    y = 0.2,
    width = 0.5,
    height = 0.04,
    scale = 0.4,
    font = fontId,
    --menu_title = "Document Actions",
    menu_subtitle = _U('document_options'),
    color_r = 0,
    color_g = 128,
    color_b = 255,
}


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    while ESX.IsPlayerLoaded == false do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

    DOCUMENT_FORMS = Config.Documents[Config.Locale]
    --print(dump(DOCUMENT_FORMS))

    if Config.UseCustomFonts == true then
        RegisterFontFile(Config.CustomFontFile)
        fontId = RegisterFontId(Config.CustomFontId)
        MENU_OPTIONS.font = fontId
    else
        MENU_OPTIONS.font = 4
    end


    GetAllUserForms()
    SetNuiFocus(false, false)

end)

--- Hospital

local waitingdoc = 0

Citizen.CreateThread(function()
	
		  exports['qtarget']:AddBoxZone("ambulance:documents", vector3(326.8813, -594.3829, 30.2020), 2.0, 2.0, {
		  name="ambulance:documents",
		  heading=101.8724,
		  debugPoly=false,
		  minZ=28.5,
		  maxZ=31.9
		  }, {
			  options = {
				  {
					  event = "documents:open",
					  icon = "fas fa-clipboard",
					  label = "EMS Documents Menu",
					  job = "ambulance",
					  
					  
				  },
	  
			  },
			  
			  distance = 2.5
		   
		  })

          exports['qtarget']:AddBoxZone("police:documents", vector3(442.2290, -979.4692, 30.6250),1.0, 1.0, {
            name="police:documents",
            heading=174.2965,
            debugPoly=false,
            minZ=28.5,
            maxZ=31.9
            }, {
                options = {
                    {
                        event = "documents:open",
                        icon = "fas fa-clipboard",
                        label = "Police Documents Menu",
                        job = "police",
                        
                        
                    },
        
                },
                
                distance = 2.5
             
            })

            exports['qtarget']:AddBoxZone("public:documents", vector3( -539.2827, -177.6160, 39.1087),1.0, 1.0, {
                name="public:documents",
                heading=302.3399,
                debugPoly=false,
                minZ=37.5,
                maxZ=40.9
                }, {
                    options = {
                        {
                            event = "documents:open2",
                            icon = "fas fa-clipboard",
                            label = "Documents Menu",
                         
                            
                            
                        },
            
                    },
                    
                    distance = 2.5
                 
                })
           
       
		 
	  end)
      RegisterNetEvent('documents:open')
	  AddEventHandler('documents:open', function()
        openJobMenu()
        waitingdoc = 0
	  end)

      RegisterNetEvent('documents:open2')
	  AddEventHandler('documents:open2', function()
        openJobMenu2()
        waitingdoc = 0
	  end)
      
    function openJobMenu()
        ClearMenu()
        Menu.addButton(_U('job_documents'), "OpenNewJobFormMenu", nil)
        Menu.addButton(_U('close_bt'), "CloseMenu", nil)
        Menu.hidden = false
    end

    function openJobMenu2()
        ClearMenu()
        Menu.addButton(_U('public_documents'), "OpenNewPublicFormMenu", nil)
        Menu.addButton(_U('close_bt'), "CloseMenu", nil)
        Menu.hidden = false
    end


Citizen.CreateThread(function()
    waitingdoc = 1000
    while true do
       
      if Config.UseKey then   
    if UI_MOUSE_FOCUS == true then

            --[[
            if IsControlJustReleased(0, 142) then -- MeleeAttackAlternate
                --SendNUIMessage({type = "click"})

            end
            --
        end]]

        if IsControlJustReleased(0, Config.MenuKey) and GetLastInputMethod(2) then
            Menu.hidden = false
            OpenMainMenu()

          
            SetNuiFocus(true, true)
			SendNUIMessage({
        		type = "ShowDocument",
        		enable = true
   			})
            UI_MOUSE_FOCUS = true
         

    	end

        Menu.renderGUI(MENU_OPTIONS)
    end
        Citizen.Wait(waitingdoc)
    end
 end)

function OpenMainMenu()
    ClearMenu()
    Menu.addButton(_U('public_documents'), "OpenNewPublicFormMenu", nil)
    Menu.addButton(_U('job_documents'), "OpenNewJobFormMenu", nil)
    --Menu.addButton(_U('saved_documents'), "OpenMyDocumentsMenu", nil)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function CopyFormToPlayer(aPlayer)
    --TriggerServerEvent('esx_documents:CopyToPlayer', GetPlayerServerId(player), aDocument)
    TriggerServerEvent('esx_documents:CopyToPlayer', aPlayer, CURRENT_DOCUMENT)
    CURRENT_DOCUMENT = nil;
    CloseMenu()
end

function ShowToNearestPlayers(aDocument)
    ClearMenu()
    local players_clean = GetNeareastPlayers()
    CURRENT_DOCUMENT = aDocument
    if #players_clean > 0 then
        for i=1, #players_clean, 1 do
            --local tmpObject = { pId = players_clean[i].playerId, pForm = aDocument }
            Menu.addButton(players_clean[i].playerName .. "[" .. tostring(players_clean[i].playerId) .. "]", "ShowDocument", players_clean[i].playerId)
        end
    else

        Menu.addButton(_U('no_player_found'), "CloseMenu", nil)
    end

    --Menu.addButton("Go Back", "OpenFormPropertiesMenu", aDocument)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
end

function CopyToNearestPlayers(aDocument)
    ClearMenu()
    local players_clean = GetNeareastPlayers()
    CURRENT_DOCUMENT = aDocument
    if #players_clean > 0 then
        for i=1, #players_clean, 1 do

            Menu.addButton(players_clean[i].playerName .. "[" .. tostring(players_clean[i].playerId) .. "]", "CopyFormToPlayer", players_clean[i].playerId)
        end
    else

        Menu.addButton(_U('no_player_found'), "CloseMenu", nil)
    end

    Menu.addButton(_U('go_back'), "OpenFormPropertiesMenu", aDocument)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
end


RegisterNetEvent('mydocuments:show')
AddEventHandler('mydocuments:show', function(item, wait, cb, aDocument)
    local metadata = ESX.GetPlayerData().inventory[item.slot].metadata
    --local aDocument = metadata.aDocument
    local aDocument = metadata.adocs
    ViewDocument2(aDocument)
    
end)


function OpenNewPublicFormMenu()
    ClearMenu()
    for i=1, #DOCUMENT_FORMS["public"], 1 do
        Menu.addButton(DOCUMENT_FORMS["public"][i].headerTitle, "CreateNewForm", DOCUMENT_FORMS["public"][i])
    end
    Menu.addButton(_U('close_bt'),"CloseMenu",nil)
    Menu.hidden = false
end

function OpenNewJobFormMenu()
    ClearMenu()
    PlayerData = ESX.GetPlayerData()
    if DOCUMENT_FORMS[PlayerData.job.name] ~= nil then

        for i=1, #DOCUMENT_FORMS[PlayerData.job.name], 1 do
            Menu.addButton(DOCUMENT_FORMS[PlayerData.job.name][i].headerTitle, "CreateNewForm", DOCUMENT_FORMS[PlayerData.job.name][i])
        end
    end
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function OpenMyDocumentsMenu()
    ClearMenu()
    for i=#USER_DOCUMENTS, 1, -1 do

        local date_created = ""
        if USER_DOCUMENTS[i].data.headerDateCreated ~= nil then
            date_created = USER_DOCUMENTS[i].data.headerDateCreated .. " - "
        end

        Menu.addButton(date_created .. USER_DOCUMENTS[i].data.headerTitle, "OpenFormPropertiesMenu", USER_DOCUMENTS[i])
        --exports['okokNotify']:Alert("Document", USER_DOCUMENTS[i].data.headerTitle, 3000, 'success')
        
    end
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function OpenFormPropertiesMenu(aDocument)
    ClearMenu()
    Menu.addButton(_U('view_bt'), "ViewDocument", aDocument.data)
    Menu.addButton(_U('show_bt'), "ShowToNearestPlayers", aDocument.data)
    Menu.addButton(_U('give_copy'), "CopyToNearestPlayers", aDocument.data)
    Menu.addButton(_U('delete_bt'), "OpenDeleteFormMenu", aDocument)
    Menu.addButton(_U('go_back'), "OpenMyDocumentsMenu", nil)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function OpenDeleteFormMenu(aDocument)
    ClearMenu()
    Menu.addButton(_U('yes_delete'), "DeleteDocument", aDocument)
    Menu.addButton(_U('go_back'), "OpenFormPropertiesMenu", aDocument)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function CloseMenu()
    ClearMenu()
    Menu.hidden = true
end


function DeleteDocument(aDocument)

    local key_to_remove = nil

    ESX.TriggerServerCallback('esx_documents:deleteDocument', function (cb)
        if cb == true then
            --remove form_close
            for i=1, #USER_DOCUMENTS, 1 do
                if USER_DOCUMENTS[i].id == aDocument.id then
                    key_to_remove = i
                end
            end

            if key_to_remove ~= nil then
                table.remove(USER_DOCUMENTS, key_to_remove)
            end
            OpenMyDocumentsMenu()
        end
    end, aDocument.id)
end

function CreateNewForm(aDocument)

    PlayerData = ESX.GetPlayerData()
    ESX.TriggerServerCallback('esx_documents:getPlayerDetails', function (cb_player_details)
        if cb_player_details ~= nil then
            --print("Received dump : " .. dump(cb_player_details))
            SetNuiFocus(true, true)
            aDocument.headerFirstName = cb_player_details.firstname
            aDocument.headerLastName = cb_player_details.lastname
            aDocument.headerDateOfBirth = cb_player_details.dateofbirth
            aDocument.headerJobLabel = PlayerData.job.label
            aDocument.headerJobGrade = PlayerData.job.grade_label
            aDocument.locale = Config.Locale

            SendNUIMessage({
                type = "createNewForm",
                data = aDocument
            })
        else
            print ("Received nil from newely created scale object.")
        end
    end, data)

end

function ShowDocument(aPlayer)
     --   print("ssss: " .. dump(aPlayer))
        TriggerServerEvent('esx_documents:ShowToPlayer', aPlayer, CURRENT_DOCUMENT)
        CURRENT_DOCUMENT = nil
        CloseMenu()
end

RegisterNetEvent('esx_documents:viewDocument')
AddEventHandler('esx_documents:viewDocument', function( data )

    ViewDocument(data)
end)

function ViewDocument(aDocument)
    
    --exports['okokNotify']:Alert("Document", aDocument, 3000, 'success')
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ShowDocument",
        data = aDocument
    })
end


function ViewDocument2(aDocument)
    
    --exports['okokNotify']:Alert("Document2", aDocument, 3000, 'success')
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ShowDocument",
        data = aDocument
    })
end


RegisterNetEvent('esx_documents:copyForm')
AddEventHandler('esx_documents:copyForm', function( data )
       --  print("dump: " .. dump(data))

    table.insert(USER_DOCUMENTS, data)
end)

function CopyForm(aDocument)
    --table.insert(USER_DOCUMENTS, aDocument)
end

function GetAllUserForms()

    ESX.TriggerServerCallback('esx_documents:getPlayerDocuments', function (cb_forms)
        if cb_forms ~= nil then
         --   print("Received dump : " .. dump(cb_forms))
            USER_DOCUMENTS = cb_forms
        else
            print ("Received nil from newely created scale object.")
        end
    end, data)

end


RegisterNUICallback('form_close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('form_submit', function(data, cb)
   -- print("received: " .. dump(data))
    CloseMenu()
    ESX.TriggerServerCallback('esx_documents:submitDocument', function (cb_form)
        if cb_form ~= nil then
            
            table.insert(USER_DOCUMENTS, cb_form)
          --  OpenFormPropertiesMenu(cb_form)
        else
            print ("Received nil from newely created scale object.")
        end
    end, data)

    SetNuiFocus(false, false)

end)


function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

    local players_clean = {}
    local found_players = false

    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            found_players = true
            table.insert(players_clean, {playerName = GetPlayerName(players[i]), playerId = GetPlayerServerId(players[i])} )
        end
    end
    return players_clean
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
