--Winter Queen of the Yuki-Onna
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
    --Tribute Summon by Tributing 1 Defense Position "Yuki-Onna" monster
    local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.onetribfilter)
    local e2=aux.AddNormalSetProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.onetribfilter)
    --Tribute Summon with 3 Tributes
    local e3=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,1))
    --Cannot be Special Summoned
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e4)
    --If Tribute Summoned, can change all other monsters to face-up Defense Position
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_POSITION)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetCondition(s.poscon)
    e5:SetTarget(s.postg)
    e5:SetOperation(s.posop)
    c:RegisterEffect(e5)
    --Cannot activate the effects of Defencse Position monsters
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetCode(EFFECT_CANNOT_ACTIVATE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTargetRange(0,1)
    e6:SetCondition(s.trsumcon)
    e6:SetValue(s.actlmtval)
    c:RegisterEffect(e6)
    --Can attack directly
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e7)
end
s.listed_series={SET_YUKI_ONNA}
--Filter for single Tribute Summon
function s.onetribfilter(c,tp)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsDefensePos() and (c:IsControler(tp) or c:IsFaceup())
end
--If Tribute Summoned, can change all other monsters to face-up Defense Position
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.posfilter(c)
    return c:IsAttackPos() or c:IsFacedown()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
    if #g==0 then return end
    Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
--Cannot activate the effects of Defencse Position monsters
function s.trsumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_TRIBUTE+1
end
function s.actlmtval(e,re,rp)
    local rc=re:GetHandler()
    return rc:IsDefensePos() and rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
end