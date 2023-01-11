--Custom Card Constants
CARD_LAWSTONES_ETERNAL_REALM     = 211000027
CARD_QUEEN_MARCHESA              = 211000061
CARD_ARISTITHE_REGISTER          = 211000062
CARD_ARISTITHE_HOLY_KINGDOM      = 211000075
CARD_ARISTITHE_MINISTER_PATIENCE = 211000067
CARD_YUKI_ONNA_ETERNAL_WINTER    = 211000090

--Card Image for Monarch Effect
TOKEN_MONARCH                  = 211000085

--Custom Flag Effects
FLAG_MONARCH                  = 7885642837359028234

--Custom Tokens Constants
TOKEN_ETERNAL_SHARD           = 211000020

--Custom Counters
COUNTER_LOYALTY               = 0xa61
COUNTER_PHEAROIL              = 0x1224
COUNTER_ABSORB                = 0xddac
COUNTER_DILIGENCE             = 0x1000

--Custom Archetypes
SET_DANGER_DUNGEON            = 0xdd3
SET_DANGER_DUNGEON_TREASURE   = 0x1dd3
SET_DANGER_DUNGEON_ALARM      = 0x2dd3
SET_ARISTITHE                 = 0x4172
SET_YUKI_ONNA                 = 0x7975

--[[
    Effect.CreateEternalSPEffect(c,id,desc,uniquecat,uniquetg,uniqueop)

    Creates an Ignition Effect object for the "Eternal" effects that banish 1 other "Eternal" card from the hand or field.
    Includes handling for "CARD_LAWSTONES_ETERNAL_REALM" cost replacement.

    Card c: the owner of the Effect.
    int id: the card ID used for the HOPT restriction and strings.
    int desc: the string ID of the effect description (will also be used for the limitcount code.)
    int uniquecat: the category of the unique effect.
    function uniquetg: the target function for the effect.
    function uniqueop: the unique effect's operation function, excluding the Special Summoning procedure,
        the function must return true to proceed to the Special Summon,
        it can also return an optional passcode (int) which will be excluded from the Special Summon.
]]
Effect.CreateEternalSPEffect=(function()
    local stringbase=211000015 --use strings from "Ehir the Omen-Speaker Eternal"
    local function eternalcostfilter(c)
        return c:IsSetCard(0x200) and c:IsAbleToRemoveAsCost()
    end

    local function eternalcost(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then return Duel.IsExistingMatchingCard(eternalcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,eternalcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end

    function eternalspfilter(c,e,tp)
        return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(id)
    end

    local function eternalop(uniqueop,e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and e:GetHandler():RegisterFlagEffect(e:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1) and Duel.SpecialSummon(e:GetHandler(),1,tp,tp,false,false,POS_FACEUP) then
            uniqueop(e,tp,eg,ep,ev,re,r,rp)
        end
    end

    return function(c,id,desc,uniquecat,uniquetg,uniqueop)
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,desc))
        e1:SetCategory(uniquecat|CATEGORY_SPECIAL_SUMMON)
        e1:SetType(EFFECT_TYPE_IGNITION)
        e1:SetRange(LOCATION_HAND)
        e1:SetCountLimit(1,{id,desc})
        e1:SetCost(aux.CostWithReplace(eternalcost,CARD_LAWSTONES_ETERNAL_REALM))
        e1:SetTarget(uniquetg)
        e1:SetOperation(function(...) eternalop(uniqueop,...) end)
        return e1
    end
end)()

--Auxiliary Monarch Functions
--Created the Monarch table at Hatters direction, since according to them the Auxiliary table is oversaturated at the moment.
Monarch={}
mon=Monarch

--[[Monarch Effect: During your End Phase: Draw 1 card. When you take battle damage from an opponent's attacking monster: Your opponent becomes the Monarch.]]

--Global Monarch Effect Function
local MonarchRegistration=false
function Monarch.EnableMonarchEffect(c)
    if not MonarchRegistration then
        MonarchRegistration=true
        --Draw Monarch Effect
        local dummy=Debug.AddCard(TOKEN_MONARCH,0,0,-2,0,0)
        local ge1=Effect.CreateEffect(dummy)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCategory(CATEGORY_DRAW)
        ge1:SetCode(EVENT_PHASE+PHASE_END)
        ge1:SetCountLimit(1)
        ge1:SetCondition(Monarch.MonarchCondition)
        ge1:SetOperation(Monarch.MonarchOperation)
        Duel.RegisterEffect(ge1,0)
        --"Regicide" Monarch Effect
        local ge2=Effect.GlobalEffect()
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_BATTLE_DAMAGE)
        ge2:SetCondition(Monarch.RegicideCondition)
        ge2:SetOperation(Monarch.RegicideOperation)
        Duel.RegisterEffect(ge2,0)
    end
end

--Helper auxiliary function that sets and removes the Monarch flag, as well as reseting the client hint
function Monarch.SetMonarch(e,p)
    if Duel.GetFlagEffect(1-p,FLAG_MONARCH)>0 then
        Duel.ResetFlagEffect(1-p,FLAG_MONARCH)
    end
    Duel.RegisterFlagEffect(p,FLAG_MONARCH,0,0,1)
    if monarch_hint and not monarch_hint:IsDeleted() then
        monarch_hint:Reset()
    end
    monarch_hint=aux.RegisterClientHint(e:GetHandler(),nil,p,1,0,aux.Stringid(CARD_QUEEN_MARCHESA,1))
    monarch_hint:SetReset(0)
    --Calls the forced tribute function
    mon.MinisterTribute(e,p)
end

--Helper auxiliary function that controls the draw during end phase
function Monarch.MonarchCondition(e,tp,eg,ep,ev,re,r,rp)
    return ((Duel.GetFlagEffect(tp,FLAG_MONARCH)>0 and tp==Duel.GetTurnPlayer()) or (Duel.GetFlagEffect(1-tp,FLAG_MONARCH)>0 and tp~=Duel.GetTurnPlayer())) 
end
function Monarch.MonarchOperation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,FLAG_MONARCH)>0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    elseif Duel.GetFlagEffect(1-tp,FLAG_MONARCH)>0 then
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end

--Helper auxiliary function that controls the "Regicide" Monarch Effect (other player gains Monarch effect if they attack and inflict damage to the current Monarch)
function Monarch.RegicideCondition(e,tp,eg,ep,ev,re,r,rp)
    local opponent=Duel.GetAttacker():GetControler()
    local player
    if opponent==1-tp then
        player=tp
    else
        player=1-tp
    end
    return ep==player and opponent
end
function Monarch.RegicideOperation(e,tp,eg,ep,ev,re,r,rp)
    local p1=Duel.GetAttacker():IsControler(1-tp)
    local p2=Duel.GetAttacker():IsControler(tp)
    if p1 and Duel.GetFlagEffect(tp,FLAG_MONARCH)>0 then
        Monarch.SetMonarch(e,1-tp)
    elseif p2 and Duel.GetFlagEffect(1-tp,FLAG_MONARCH)>0 then
        Monarch.SetMonarch(e,tp)
    end
end

--Filter for "Aristithe Minister of Patience"
function ministerfilter(c)
    return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsCode(CARD_ARISTITHE_MINISTER_PATIENCE) and not c:IsDisabled()
end

--Helper auxiliary function that controls the forced tributing from "Aristithe Minister of Patience" when you become the Monarch
function Monarch.MinisterTribute(e,p)
    if Duel.GetFlagEffect(p,FLAG_MONARCH)>0 and Duel.CheckReleaseGroup(1-p,nil,1,nil) and Duel.IsExistingMatchingCard(ministerfilter,p,LOCATION_MZONE,0,1,nil) then
        local g=Duel.SelectReleaseGroup(1-p,nil,1,1,nil)
        if g then
            Duel.Release(g,REASON_RULE)
        end
    end
end

--Utility call -- not really needed anymore, but doesn't really hurt anything
Duel.LoadScript("cstm_ritualp_proc.lua")