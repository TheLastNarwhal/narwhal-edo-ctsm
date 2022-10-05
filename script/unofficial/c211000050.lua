--Danger Dungeon! Treasure!? - Holy Targe
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Equip only to monsters you control
    aux.AddEquipProcedure(c,0)
    --Equipped monster cannot be destroyed by battle or card effect, and cannot be targeted by your opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    --Send 1 other card you control to the GY, until end of turn "Danger Dungeon!" monsters you control cannot be destroyed by card effects
    local e4=Effect.CreateEffect(c)
    e4: SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.indescon1)
    e4:SetCost(s.indescost)
    e4:SetOperation(s.indesop)
    c:RegisterEffect(e4)
    --Same as above but QE
    local e5=e4:Clone()
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetCondition(s.indescon2)
    c:RegisterEffect(e5)
end
s.listed_series={SET_DANGER_DUNGEON,SET_DANGER_DUNGEON_TREASURE}
--Send 1 other card you control to the GY, until end of turn "Danger Dungeon!" monsters you control cannot be destroyed by card effects
--Non-QE version condition
function s.indescon1(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DANGER_DUNGEON_TREASURE),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
--QE version condition
function s.indescon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DANGER_DUNGEON_TREASURE),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler() 
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,nil,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,c)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.indtg)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.indtg(e,c)
    return c:IsSetCard(SET_DANGER_DUNGEON)
end