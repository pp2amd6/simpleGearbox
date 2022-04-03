local needPreventReverse = false
local needPreventForward = false
local neutralGear = true

function ResetVariableStates()
    needPreventReverse = false
    needPreventForward = false
end

function SpeedSetter()
    if (needPreventReverse) then
        DisableControlAction(2, 72, true)
    else
        EnableControlAction(2, 72, true)
    end

    if (needPreventForward) then
        DisableControlAction(2, 71, true)
    else
        EnableControlAction(2, 71, true)
    end
end

Citizen.CreateThread(function()
    local ped = PlayerPedId()

    while true do
        Citizen.Wait(0)

        if (IsPedInAnyVehicle(ped)) then
            local veh = GetVehiclePedIsIn(ped, false)

            if (GetPedInVehicleSeat(veh, -1) == ped) then
                if (GetVehicleCurrentGear(veh) > 0) then -- forward gears
                    if (GetEntitySpeed(veh) > 0) then -- vehicle is moving
                        if ((IsControlPressed(2, 71) or IsDisabledControlPressed(2, 71)) and needPreventForward) then -- INPUT_VEH_ACCELERATE
                            SpeedSetter()
                        else
                            needPreventForward = false
                        end

                        if (IsControlPressed(2, 72)) then -- INPUT_VEH_BRAKE
                            needPreventReverse = true
                        else
                            needPreventReverse = false
                        end
                    else
                        if (IsControlPressed(2, 72) and (needPreventReverse)) then
                            SpeedSetter()
                        else
                            needPreventReverse = false
                        end
                    end
                else    -- reverse gear (neutral also)
                    if (GetEntitySpeed(veh) > 0) then
                        if ((IsControlPressed(2, 72) or IsDisabledControlPressed(2, 72)) and needPreventReverse) then -- INPUT_VEH_BRAKE
                            SpeedSetter()
                        else
                            needPreventReverse = false
                        end

                        if (IsControlPressed(2, 71) and (not neutralGear)) then -- INPUT_VEH_ACCELERATE
                            needPreventForward = true
                        else
                            needPreventForward = false
                            neutralGear = false
                        end
                    else
                        if (IsControlPressed(2, 72) and (needPreventReverse)) then
                            SpeedSetter()
                        else
                            needPreventForward = false
                        end
                    end
                end
            end
        else
            ResetVariableStates()
        end
    end
end)