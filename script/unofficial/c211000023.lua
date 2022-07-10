--Soulherder of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x252)
    c:EnableReviveLimit()
    --Special Summon condition
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.FALSE)
    c:RegisterEffect(e0)
    --Special Summon procedure from hand or GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --If a card is banished, place 1 Eternal Counter on this card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    --Gains ATK equal to the number of Eternal Counters x 600
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(s.aktval)
    c:RegisterEffect(e3)
    --During the End Phase, temp banish 1 other monster you control
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.tmpbancon)
    e4:SetTarget(s.tmpbantg)
    e4:SetOperation(s.tmpbanop)
    c:RegisterEffect(e4)
end
s.listed_series={0x200}
--Special Summon procedure from hand or GY
function s.cfilter(c)
    return c:IsSetCard(0x200) and c:IsReleasable()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
    return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
    local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
--If a card is banished, place 1 Eternal Counter on this card
function s.banfilter(c)
    return not c:IsType(TYPE_TOKEN)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(s.banfilter,1,nil,tp) then
        local ct=eg:FilterCount(s.banfilter,nil)
        for ct in eg:Iter() do
            e:GetHandler():AddCounter(0x252,1)
        end
    end
end
--Gains ATK equal to the number of Eternal Counters x 600
function s.aktval(e,c)
    return Duel.GetCounter(0,1,1,0x252)*600
end
--During the End Phase, temp banish 1 other monster you control
function s.tmpbancon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.tmpbanfilter(c)
    return c:IsFaceup() and c:IsAbleToRemove()
end
function s.tmpbantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tmpbanfilter(chkc) and chkc~=c end
    if chk==0 then return Duel.IsExistingTarget(s.tmpbanfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.tmpbanfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.tmpbanop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc then 
        if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            Duel.BreakEffect()
            if not tc:IsImmuneToEffect(e) then
                tc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_CONTROL)
                e1:SetValue(tc:GetOwner())
                e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
                tc:RegisterEffect(e1)
            end
        end
        Duel.ReturnToField(tc)
    end
end
