--Logi, Historian of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon itself from the hand - Ignition version
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(aux.NOT(s.spquickcon))
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Special Summon itself from the hand - Quick verion if you control "Celestial Realm of the Eternals"
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(s.spquickcon)
    c:RegisterEffect(e2)
    --If placed in the Monster Zone, target 1 other monster on the field and return to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_MOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.etbthcon)
    e3:SetTarget(s.etbthtg)
    e3:SetOperation(s.etbthop)
    c:RegisterEffect(e3)
    --If a card you own was returned to your hand, draw 1 card
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.drwcon)
    e4:SetTarget(s.drwtg)
    e4:SetOperation(s.drwop)
    c:RegisterEffect(e4)
    --Sets flag for above effect
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_TO_HAND)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.regcon)
    e5:SetOperation(s.regop)
    c:RegisterEffect(e5)
end
s.listed_names={211000013}
--Condition for QE Special Summon
function s.cfilter(c)
    return c:IsFaceup() and c:IsCode(211000013)
end
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,0,1,nil)
end
--Special Summon itself from the hand
function s.spfilter(c,tp)
    return c:IsRace(RACE_FAIRY) and c:IsAbleToRemove() and aux.SpElimFilter(c,true) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.spfilter(chkc,tp) end
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
--If placed in the Monster Zone, target 1 other monster on the field and return to hand
function s.etbthcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
end
function s.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.etbthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.etbthop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
--Sets flag for above draw effect
function s.regfilter(c,tp)
    return c:GetOwner()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_HAND)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.regfilter,1,nil,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,0,1,aux.Stringid(id,3))
end
--If a card you own was returned to your hand, draw 1 card
function s.drwcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end