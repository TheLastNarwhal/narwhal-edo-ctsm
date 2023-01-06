--Danger Dungeon! Friendly Ooze!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Activation
    Pendulum.AddProcedure(c)
    --Fusion Summon 1 Level 7 or higher Fusion Monster
    local fparams = {aux.FilterBoolFunction(Card.IsLevelAbove,7),Fusion.InHandMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil}
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(Fusion.SummonEffTG(table.unpack(fparams)))
    e1:SetOperation(Fusion.SummonEffOP(table.unpack(fparams)))
    c:RegisterEffect(e1)
    --Add 1 banished "Danger Dungeon!" card to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_MOVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DANGER_DUNGEON}
--Fusion Summon 1 Level 7 or higher Fusion Monster
function s.fextra(e,tp,mg)
    return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE+LOCATION_PZONE,0,nil)
end
--Add 1 banished "Danger Dungeon!" card to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end