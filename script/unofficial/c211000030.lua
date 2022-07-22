--Lofn the Secret-Keeper Eternal
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If placed in the Monster Zone, except by its own effect: Banish 1 card or add 1 banished card to hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_MOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.etbcon)
    e2:SetTarget(s.etbtg)
    e2:SetOperation(s.etbop)
    c:RegisterEffect(e2)
    --Special Summon self and then can banish top card of Deck face-down
    c:RegisterEffect(Effect.CreateEternalSPEffect(c,id,0,CATEGORY_REMOVE,s.rmtg,s.rmop))
end
--Special Summon self and then can banish top card of Deck face-down
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetDecktopGroup(tp,1)
        local tc=g:GetFirst()
        return tc and tc:IsAbleToRemove()
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        local g=Duel.GetDecktopGroup(tp,1)
        local bc=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
        Duel.DisableShuffleCheck()
        if bc>0 then
            local tc=g
            for tc in g:Iter() do
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
        end
    end
end
--If placed in the Monster Zone: Banish 1 card or add 1 banished card to hand
function s.etbcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Debug.Message("[etb condition] is "..tostring(not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE) and c:GetFlagEffect(id)==0))
    -- Debug.Message("[flag is placed etbcon] is "..tostring(c:GetFlagEffect(id)))
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE) and c:GetFlagEffect(id)==0
end
--Setting up the optional effects
function s.etbtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ban=s.bantg(e,tp,eg,ep,ev,re,r,rp,0)
    local add=s.addtg(e,tp,eg,ep,ev,re,r,rp,0)
    if chk==0 then return ban or add end
end
--Presenting the choices
function s.etbop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local ban=s.bantg(e,tp,eg,ep,ev,re,r,rp,0) --Stringid 1
    local add=s.addtg(e,tp,eg,ep,ev,re,r,rp,0) --Stringid 2
    local op=-1
    if ban and add then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif ban then
        op=0
    elseif add then
        op=1
    end
    if op==0 then
        s.banop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==1 then
        s.addop(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if chk==0 then return tc and tc:IsAbleToRemove() and Duel.GetFlagEffect(tp,id+2)==0 end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,1)
    local bc=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
    Duel.DisableShuffleCheck()
    if bc>0 then
        local tc=g
        for tc in g:Iter() do
            tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
        end
    end
    Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
end
function s.addfilter(c)
    return c:IsAbleToHand() and c:GetFlagEffect(id)>0
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.addfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.addfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.GetFlagEffect(tp,id+3)==0 end
    local g=Duel.SelectTarget(tp,s.addfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectTarget(tp,s.addfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
    Duel.RegisterFlagEffect(tp,id+3,RESET_PHASE+PHASE_END,0,1)
end