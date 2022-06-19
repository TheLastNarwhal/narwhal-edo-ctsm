--Sakashima's Protégé
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Copy opponent's monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    --Return to hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.rthtg)
    e1:SetOperation(s.rthop)
    c:RegisterEffect(e1)
end
--Copy opponent's monster
function s.filter(c,e,tp)
    return c:IsFaceup() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,c:GetAttack(),c:GetDefense(),1,RACE_AQUA,ATTRIBUTE_WATER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,tc:GetAttack(),tc:GetDefense(),1,RACE_AQUA,ATTRIBUTE_WATER) then return end
    c:AddMonsterAttribute(TYPE_MONSTER+TYPE_SPELL+TYPE_EFFECT)
    if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
        c:AddMonsterAttributeComplete()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(tc:GetCode())
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_BASE_DEFENSE)
        e2:SetValue(tc:GetDefense())
        c:RegisterEffect(e2)
        local e3=e1:Clone()
        e3:SetCode(EFFECT_SET_BASE_ATTACK)
        e3:SetValue(tc:GetAttack())
        c:RegisterEffect(e3)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_CHANGE_RACE)
        e4:SetValue(RACE_AQUA)
        c:RegisterEffect(e4)
        local e5=e1:Clone()
        e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e5:SetValue(ATTRIBUTE_WATER)
        c:RegisterEffect(e5)
        local e6=e1:Clone()
        e6:SetCode(EFFECT_CHANGE_LEVEL)
        e6:SetValue(1)
        c:RegisterEffect(e6)
        c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,1)
        c:SetCardTarget(tc)
    end
    Duel.SpecialSummonComplete()
end
--Return to hand
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end