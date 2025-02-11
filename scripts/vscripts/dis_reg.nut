Msg("[INFO] L4D2 Enemy HP Display Mod Loading...!\n");

function OnGameEvent_player_activate(params)
{
    local tname = GetPlayerFromUserID(params.userid);
	if(!IsPlayerABot(tname) && tname.GetZombieType() == 9)
	{
		tname.__KeyValueFromString("targetname","player"+UniqueString());
		EntFire(tname.GetName(),"runscriptcode","RegisterFunc()");
	}

}
function OnGameEvent_player_disconnect(params)
{

    local tname = GetPlayerFromUserID(params.userid).GetName();
	if(!IsPlayerABot(GetPlayerFromUserID(params.userid)) && GetPlayerFromUserID(params.userid).GetZombieType() == 9)
    EntFire(tname,"runscriptcode","DestoryHandle()");
}
local maxLen = 50;
//for SI

function OnGameEvent_player_hurt(params)
{
    //Msg("123");
    local victim = GetPlayerFromUserID(params.userid);
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker)||victim.IsSurvivor())return;
    if(!victim.IsDead()&&!victim.IsDying()&&!victim.IsIncapacitated())
    {
        ShowHpBar(params.health,NetProps.GetPropInt(victim,"m_iMaxHealth"),attacker,0,victim.GetPlayerName());
    }
}
::deathdmg <- -1;

//for witch and ci
function OnGameEvent_infected_hurt(params)
{
    local victim = Ent(params.entityid);
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker) || attacker == null)return;
    local nowHp = NetProps.GetPropInt(victim,"m_iHealth");
    local maxHp = NetProps.GetPropInt(victim,"m_iMaxHealth");
    if(nowHp-params.amount <= 0)deathdmg = params.amount;
    if(victim.GetClassname() == "witch")
    {
        ShowHpBar(nowHp,maxHp,attacker,0,"witch");
    }else if(victim.GetClassname() == "infected" && nowHp > 0)
    {
		//print("at"+attacker+"\n");
        // EntFire(attacker.GetName(),"runscriptcode",format("SetArray(%d,%d)",params.amount,0));
    }
}
//for all zombies
function OnGameEvent_player_death(params)
{
    local victim;
    if(params.victimname == "Infected" || params.victimname == "Witch")
    {victim = Ent(params.entityid);}
    else
    {victim =GetPlayerFromUserID(params.userid);}
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker) || (victim.IsPlayer()&&victim.GetZombieType()==9))return;
    local isheadshot = params.headshot;
    switch(params.victimname)
    {
        case "Infected" :
        {
            if(!isheadshot)
            //localplayer.SetArray(deathdmg,FL_IF_DEAD);
            ShowHpBar(-1,100,attacker,0,params.victimname);
            else
            ShowHpBar(-1,100,attacker,isheadshot,params.victimname);
            break;
        }
        default :
        {
            if(!isheadshot)
            ShowHpBar(-1,100,attacker,0,params.victimname);
            else
            ShowHpBar(-1,100,attacker,isheadshot,params.victimname);
            break;
        }
    }
}
function ShowHpBar(nowHp, maxHp, clientWho, isheadshot, theName = "unknown")
{
    if (!maxHp) return;

    if (nowHp <= 0)
    {
        if (isheadshot == 1)
        {
            // Displaying headshot notification
            ClientPrint(clientWho, DirectorScript.HUD_PRINTTALK, "\x05Headshot!");
        }
        else
        {
            // Displaying theName followed by "killed!" in bright green
            ClientPrint(clientWho, DirectorScript.HUD_PRINTTALK, "\x04" + theName + "\x01 killed!");
        }
        return;
    }

    local prencent = ((nowHp.tofloat() / maxHp.tofloat())).tofloat();
    local nowHpsLen = ceil(prencent * maxLen);
    local dmgLen = ceil((1 - prencent).tofloat() * maxLen);

    local strNow = "";
    local strDmg = "";
    for (local i = 0; i < nowHpsLen; i++) strNow += "#";
    for (local i = 0; i < dmgLen; i++) strDmg += "=";
    local strT = (strNow.tostring() + strDmg.tostring()).tostring();

    // ClientPrint(clientWho, 4, format("[%d / %d] %s\n", nowHp, maxHp, theName));
    ClientPrint(clientWho, DirectorScript.HUD_PRINTTALK, "\x03[" + nowHp + " / " + maxHp + "] \x04" + theName + "\n");

}
