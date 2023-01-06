--Danger Dungeon! Slime Witch!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Activation
	Pendulum.AddProcedure(c,false)
    --Check for activation as Pendulum
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(1160)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.threg)
    c:RegisterEffect(e1)
    --If activated as Pendulum this turn, can add 1 "Danger Dungeon!" Aqua monster from GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_PZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --Fusion Summon 1 "Danger Dungeon!" Fusion monster using only cards in your hand, including this card
    local params = {aux.FilterBoolFunction(Card.IsSetCard,SET_DANGER_DUNGEON),Fusion.InHandMat,nil,nil,Fusion.ForcedHandler}
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,id)
    e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
    e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    c:RegisterEffect(e3)
end
s.listed_series={SET_DANGER_DUNGEON}
--Check for activation as Pendulum
function s.threg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
--If activated as Pendulum this turn, can add 1 "Danger Dungeon!" Aqua monster from GY to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end
function s.thfilter(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
--Fusion Summon 1 "Danger Dungeon!" Fusion monster using only cards in your hand, including this card