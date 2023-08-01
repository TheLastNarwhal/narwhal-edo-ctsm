--Glasspool of Serene Reflection
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Activation
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --"Sakashima" Normal Spells become QuickPlay
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_BECOME_QUICK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0x3f,0)
    e2:SetTarget(s.spellfilter)
    c:RegisterEffect(e2)
    --Link Summon 1 Link monster during opponent's Main Phase
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x1990}
--"Sakashima" Normal Spells become QuickPlay
function s.spellfilter(e,c)
    return c:IsType(TYPE_SPELL) and not c:IsType(TYPE_FIELD+TYPE_CONTINUOUS+TYPE_QUICKPLAY) and c:IsSetCard(0x1990)
end
function s.spellfilter2(c)
    return c:IsType(TYPE_SPELL) and c:IsSetCard(0x1990)
end
--Link Summon 1 Link monster during opponent's Main Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
function s.spfilter2(c,mc,fg)
	return c:IsLinkSummonable(mc,fg+mc)
end
function s.spfilter(c,e,tp,fg)
	return c:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,c,fg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanBeLinkMaterial),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,fg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanBeLinkMaterial),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,fg):GetFirst()
	if not tc then return false end
	local tg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,tc,fg)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        e1:SetOperation(s.regop)
        sc:RegisterEffect(e1)
		Duel.LinkSummon(tp,sc,tc,nil)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetOwner()
    local c=e:GetHandler()
    --Cannot be destroyed by battle when attacked by higher ATK monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(s.indes)
    c:RegisterEffect(e1)
end
function s.indes(e,c)
    local ec=e:GetHandler()
    return ec==Duel.GetAttackTarget() and c:GetAttack()>ec:GetAttack()
end