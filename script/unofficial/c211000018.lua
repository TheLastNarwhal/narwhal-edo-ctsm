--Binding of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x242)
    --When activated/placed in the Spell & Trap Zone, target 1 card, place 3 counters on itself
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    e1:SetHintTiming(TIMING_END_PHASE)
    c:RegisterEffect(e1)
    --Send targeted card to GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.tgcon)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    e1:SetLabelObject(e2)
    --During your Standby Phase remove 1 counter, if cannot, send to GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.rmccon)
    e3:SetOperation(s.rmcop)
    c:RegisterEffect(e3)
    --ETB version of e1 effect
    local e4=e1:Clone()
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_MOVE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.etbcon)
    c:RegisterEffect(e4)
end
--When activated/placed in the Spell & Trap Zone, target 1 card, place 3 counters on itself
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end    
    if chk==0 then return Duel.IsCanAddCounter(tp,0x242,3,c) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        c:AddCounter(0x242,3)
        c:SetCardTarget(tc)
        e:GetLabelObject():SetLabelObject(tc)
    end
end
--Force owner to send targeted card to GY
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField() and e:GetHandler():IsHasCardTarget(tc)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
--During your Standby Phase remove 1 counter, if cannot, send to GY
function s.rmccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.rmcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsCanRemoveCounter(tp,0x242,1,REASON_EFFECT) then
        c:RemoveCounter(tp,0x242,1,REASON_EFFECT)
    else
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end
--ETB version of e1 effect
function s.etbcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_SZONE) and c:IsLocation(LOCATION_SZONE)
end
