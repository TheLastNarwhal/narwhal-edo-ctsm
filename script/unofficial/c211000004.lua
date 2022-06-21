--Teachings of Sakashima
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --List of counters to better enable copy effects
    c:EnableCounterPermit(COUNTER_SPELL)
    --Add "Sakashima" card from Deck to hand, then Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    --When Special Summoned, target 1 monster and copy
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetTarget(s.cptg)
    e2:SetOperation(s.cpop)
    c:RegisterEffect(e2)
end
s.listed_series={0x199}
s.listed_names={id}
s.counter_place_list={COUNTER_SPELL}
--Add "Sakashima" card from Deck to hand, then Special Summon
function s.filter(c)
    return c:IsSetCard(0x199) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    Duel.BreakEffect()
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then return end
    c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL)
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
--When Special Summoned, target 1 monster and copy
function s.cpfilter(c)
    return c:IsFaceup() and not c:IsCode(id)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
    local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
    local code=tc:GetOriginalCodeRule()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(tc:GetTextDefense())
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_SET_BASE_ATTACK)
    e3:SetValue(tc:GetTextAttack())
    c:RegisterEffect(e3)
    c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
    c:SetCardTarget(tc)
end