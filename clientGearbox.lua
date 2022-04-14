local needPreventReverse = false
local needPreventForward = false
local neutralGear = true

function ResetVariableStates()
    needPreventReverse = false
    needPreventForward = false
    neutralGear = true
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
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()

        if (IsPedInAnyVehicle(ped)) then
            local veh = GetVehiclePedIsIn(ped, false)

            if (GetPedInVehicleSeat(veh, -1) == ped) then -- ped is driver?
                if (GetEntitySpeed(veh) > 0) then -- vehicle is moving
                    if (GetVehicleCurrentGear(veh) > 0) then -- forward gears
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
                    else -- reverse gear (neutral also)
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
                    end
                else -- vehicle is stopped
                    neutralGear = true
                end
            end
        else
            ResetVariableStates()
        end
    end
end)