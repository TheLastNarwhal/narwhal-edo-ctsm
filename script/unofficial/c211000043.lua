--Danger Dungeon! Grey Ooze!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Destroy 1 Spell/Trap your opponent controls, Special Summon this card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.sphtg)
    e1:SetOperation(s.sphop)
    c:RegisterEffect(e1)
    --Return attacking monster to hand, gain DEF equal to returned monster's ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.batcon)
    e2:SetTarget(s.battg)
    e2:SetOperation(s.batop)
    c:RegisterEffect(e2)
    --Special Summon itself from GY and send 1 "Danger Dungeon!" from hand to the GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.spfgcost)
    e3:SetTarget(s.spfgtg)
    e3:SetOperation(s.spfgop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_DANGER_DUNGEON}
--Destroy 1 Spell/Trap your opponent controls, Special Summon this card
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsSpellTrap() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_SZONE,1,nil,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.sphop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
    --Prevent non-Archetype Summons from ED 'til end of turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    --lizard check
    aux.addTempLizardCheck(c,tp,s.lizfilter)
end
--Prevent non-Archetype Summons from ED 'til end of turn
function s.splimit(e,c)
    return not c:IsSetCard(SET_DANGER_DUNGEON) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
    return not c:IsOriginalSetCard(SET_DANGER_DUNGEON)
end
--Return attacking monster to hand, gain DEF equal to returned monster's ATK
function s.batcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():IsDefensePos()
end
function s.battg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local tc=Duel.GetAttacker()
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function s.batop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttacker()
    if tc:IsRelateToBattle() then
        local atk=tc:GetAttack()
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        if not c:IsStatus(STATUS_BATTLE_DESTROYED) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_DEFENSE)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end
--Special Summon itself from GY and send 1 "Danger Dungeon!" from hand to the GY
function s.ddfilter1(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToHandAsCost()
end
function s.ddfilter2(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToGrave()
end
function s.spfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then
        if ft<0 then return false end
        if ft==0 then
            return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.ddfilter1),tp,LOCATION_MZONE,0,1,nil)
        else
            return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.ddfilter1),tp,LOCATION_ONFIELD,0,1,nil)
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    if ft==0 then
        local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.ddfilter1),tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_COST)
    else
        local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.ddfilter1),tp,LOCATION_ONFIELD,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_COST)
    end
end
function s.spfgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.ddfilter2,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.spfgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        --Banish it if it leaves the field
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.ddfilter2,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end