#include "NCLiteIncs/nc_rpg.inc"
#include <effectcalc>

ArrayList gSkillEffect;
ArrayList gSkillPercent;
ArrayList gSkillID;
StringMap gSkillEffectMap;

public Plugin myinfo = {
	name		= "NCLiteRPG ECalc Skills",
	author		= "inklesspen",
	description	= "ECalc Skills for NCLiteRPG",
	version		= "0.1a"
};

public void OnPluginStart() {
	gSkillEffect = new ArrayList(8);
	gSkillPercent = new ArrayList(1);
	gSkillID = new ArrayList(1);
	gSkillEffectMap = new StringMap();
}

public void OnMapStart()
{
	char sBuffer[96];
	KeyValues kv = new KeyValues("skills");
	BuildPath(Path_SM, sBuffer, sizeof sBuffer, "configs/NCLiteRPG/ecalc.ini");
	if(kv.ImportFromFile(sBuffer))
	{
		char skillname[MAX_SHORTNAME_LENGTH];
		kv.Rewind();
		if(kv.GotoFirstSubKey(true))
		{
			do
			{
				kv.GetSectionName(sBuffer, MAX_SHORTNAME_LENGTH);
				if(NCLiteRPG_FindSkillByShortname(sBuffer) != -1)	continue;

				gSkillID.Push(NCLiteRPG_RegSkill(skillname,
					kv.GetNum("maxlevel", 10),
					kv.GetNum("cost", 10),
					kv.GetNum("icost", 5), false));
				gSkillPercent.Push(kv.GetFloat("percent", 0.05));
				kv.GetString("effect", sBuffer, sizeof sBuffer);
				gSkillEffectMap.SetValue(sBuffer, gSkillEffect.PushString(sBuffer));
			}
			while(kv.GotoNextKey(true));
		}
	}
	kv.Close();
}

public void OnMapEnd()
{
	char sBuffer[32];
	for(int i = gSkillID.Length - 1;i!=-1;--i)
	{
		NCLiteRPG_DisableSkill(gSkillID.Get(i), true);
		gSkillEffect.GetString(i, sBuffer, sizeof sBuffer);
		ECalc_Hook2(sBuffer, "NCLiteRPG", ModifyEffect, true);
	}
	gSkillEffect.Clear();
	gSkillPercent.Clear();
	gSkillID.Clear();
	gSkillEffectMap.Clear();
}

public void ModifyEffect(int client, float &value, const char[] effect)
{
	static int lID;
	if(gSkillEffectMap.GetValue(effect, lID))
	{
		static int skillid, level;
		skillid = gSkillID.Get(lID);
		level = NCLiteRPG_GetSkillLevel(client, skillid);
		if(level)
			value += gSkillPercent.Get(lID) * level;
	}
}

public Action NCLiteRPG_OnSkillLevelChange(int client,int &skillid,int old_value,int &new_value) {
	int lID = gSkillID.FindValue(skillid);
	if(lID == -1)	return;
	char sBuffer[32];
	gSkillEffect.GetString(skillid, sBuffer, sizeof sBuffer);
	ECalc_Apply(client, sBuffer);
}