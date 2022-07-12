--Friga, Guardian of the Eternals
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
    --If placed in the Monster Zone, draw 1 card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_MOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.etbdrwcon)
    e3:SetTarget(s.etbdrwtg)
    e3:SetOperation(s.etbdrwop)
    c:RegisterEffect(e3)
    --While more cards in hand than opponent, "Eternal" monsters you control cannot be destroyed by opponent's effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCondition(s.indcon)
    e4:SetTarget(s.indtg)
    e4:SetValue(aux.indoval)
    c:RegisterEffect(e4)
end
s.listed_names={211000013}
s.listed_series={0x200}
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
--If placed in the Monster Zone, draw 1 card
function s.etbdrwcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
end
function s.etbdrwtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.etbdrwop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
--While more cards in hand than opponent, "Eternal" monsters you control cannot be destroyed by opponent's effects
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)
end
function s.indtg(e,c)
    return c:IsSetCard(0x200) and c:IsFaceup()
end