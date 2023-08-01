--Sakashima's Deal - Rebirth
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Return 2 of your banished cards to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
--Return 2 of your banished cards to hand
function s.cfilter(c)
    return c:IsFaceup() and c:IsCode(211000008)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToHand()  and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1990,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    Duel.BreakEffect()
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1990,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then return end
    c:AddMonsterAttribute(TYPE_MONSTER+TYPE_SPELL+TYPE_EFFECT)
    if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
        c:AddMonsterAttributeComplete()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(RACE_AQUA)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(ATTRIBUTE_WATER)
        c:RegisterEffect(e2)
    end
    Duel.SpecialSummonComplete()
end