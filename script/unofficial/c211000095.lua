--Yuki-Onna Chill Touch
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_YUKI_ONNA}
--Activate
function s.posfilter(c)
    return c:IsCanChangePosition() and (c:IsAttackPos() or c:IsFacedown())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local dt=Duel.GetMatchingGroupCount(s.posfilter,tp,LOCATION_MZONE,0,nil)
    if dt>1 then
        dt=2
    end
    local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,dt,dt,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.chkfilter(c,e)
    return c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and (c:IsAttackPos() or c:IsFacedown())
end
function s.negfilter(c)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsFaceup() and c:IsDefensePos()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g1=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.chkfilter,nil,e)
    if #g1>0 then
        if Duel.ChangePosition(g1,POS_FACEUP_DEFENSE)~=0 then
            Duel.BreakEffect()
            local g2=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
            local cg2=g2:Select(tp,#g1,#g1,nil)
            if Duel.ChangePosition(cg2,POS_FACEUP_DEFENSE)~=0 and Duel.GetMatchingGroupCount(s.negfilter,tp,LOCATION_MZONE,0,nil)>1 then
                for tc in g1:Iter() do
                    --ATK becomes 0
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                    e1:SetValue(0)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                end
                local ng1=g1:Filter(Card.IsNegatableMonster,nil)
                if #ng1>0 then
                    for tc in ng1:Iter() do
                        --Negate targeted monsters' effects
                        local e3=Effect.CreateEffect(c)
                        e3:SetType(EFFECT_TYPE_SINGLE)
                        e3:SetCode(EFFECT_DISABLE)
                        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
                        tc:RegisterEffect(e3)
                        local e4=Effect.CreateEffect(c)
                        e4:SetType(EFFECT_TYPE_SINGLE)
                        e4:SetCode(EFFECT_DISABLE_EFFECT)
                        e4:SetReset(RESET_EVENT+RESETS_STANDARD)
                        tc:RegisterEffect(e4)
                        if tc:IsType(TYPE_TRAPMONSTER) then
                            local e5=Effect.CreateEffect(c)
                            e5:SetType(EFFECT_TYPE_SINGLE)
                            e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                            e5:SetReset(RESET_EVENT+RESETS_STANDARD)
                            tc:RegisterEffect(e5)
                        end
                    end
                end
            end
        end
    end
end