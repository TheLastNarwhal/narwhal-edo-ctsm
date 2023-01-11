--Yuki-Onna Moonlit Night
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_YUKI_ONNA}
--Activate
--Filter for the monster to be returned to hand
function s.costfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(SET_YUKI_ONNA) and c:IsAbleToHandAsCost()
        and Duel.IsExistingTarget(s.sendfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp)
end
--Filter for the sending of the monster on field for Normal Summon of Spirit monster
function s.sendfilter(c,tp)
    return c:IsAbleToGrave() and c:HasLevel()
        and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,c:GetLevel())
end
--Filter for the Normal Summon of Spirit monster with Level below sent monster
function s.sumfilter(c,lv)
    return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(lv-1) and c:IsSummonable(true,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SendtoHand(g,nil,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.sendfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.sendfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.sendfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
        local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel())
        local tc2=g:GetFirst()
        if tc2 then
            Duel.Summon(tp,tc2,true,nil)
        end
    end
end