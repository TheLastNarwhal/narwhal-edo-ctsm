--Sakashima's Hall of Mirrors
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Activation
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Activate 1 "Sakashima" Normal Spell from GY on opponent's Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.recurcon)
    e2:SetTarget(s.recurtg)
    e2:SetOperation(s.recurop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)
end
s.listed_series={0x1990}
--Activate 1 "Sakashima" Normal Spell from GY on opponent's Special Summon
function s.recurcon(e,tp,eg,ep,ev,re,r,rp)
    return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.NOT(Card.IsSummonPlayer),1,nil,tp)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
    local te=c:CheckActivateEffect(false,false,false)
    return c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD+TYPE_QUICKPLAY) and c:IsSetCard(0x1990) and te
end
function s.recurtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.recurop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local tpe=tc:GetType()
    local te=tc:GetActivateEffect()
    local tg=te:GetTarget()
    local co=te:GetCost()
    local op=te:GetOperation()
    e:SetCategory(te:GetCategory())
    e:SetProperty(te:GetProperty())
    Duel.ClearTargetCard()
    tc:CreateEffectRelation(te)
    if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
    if tg then
        tg(te,tp,eg,ep,ev,re,r,rp,1)
    end
    Duel.BreakEffect()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local etc=g:GetFirst()
    for etc in aux.Next(g) do
        etc:CreateEffectRelation(te)
    end
    if op then
        op(te,tp,eg,ep,ev,re,r,rp)
        --Banish if leaves field
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        tc:RegisterEffect(e1,true)
        tc:ReleaseEffectRelation(te)
    end
    etc=g:GetFirst()
    for etc in aux.Next(g) do
        etc:ReleaseEffectRelation(te)
    end
end

