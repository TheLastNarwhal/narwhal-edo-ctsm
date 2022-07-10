--Svenri, Shaper of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x200),1,1)
    c:EnableReviveLimit()
    --Direct Attack / cannot be attack target
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    e1:SetCondition(s.checkcon)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.imval2)
    c:RegisterEffect(e2)
    --If placed in the Monster Zone, target 1 other face-up card on the field, negate its effects until the end of the next turn
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_MOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.etbnegcon)
    e3:SetTarget(s.etbnegtg)
    e3:SetOperation(s.etbnegop)
    c:RegisterEffect(e3)
end
--Direct Attack / cannot be attack target
function s.cfilter1(c)
    return c:IsFaceup() and c:IsCode(211000013)
end
function s.cfilter2(c)
    return c:IsFaceup() and c:IsSetCard(0x200) and c:IsType(TYPE_MONSTER)
end
function s.checkcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_FZONE,0,1,nil) and not Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
--If placed in the Monster Zone, target 1 other face-up card on the field, negate its effects until the end of the next turn
function s.etbnegcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
end
function s.etbnegtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and aux.disfilter1(chkc) and chkc~=c end
    if chk==0 then return Duel.IsExistingTarget(aux.disfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local tg=Duel.SelectTarget(tp,aux.disfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,1,0,0)
end
function s.etbnegop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        --Negate its effects
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(e2)
    end
end