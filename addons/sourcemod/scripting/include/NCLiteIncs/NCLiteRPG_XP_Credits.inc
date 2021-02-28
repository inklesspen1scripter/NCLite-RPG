/*
 * Получение количества кредитов игрока
 *
 * @param client индекс игрока.
 * @return value
 */

native int NCLiteRPG_GetCredits(int client);

/*
 * Изменение количества кредитов игрока
 *
 * @param client индекс игрока.
 * @param amount количество кредитов.
 * @return amount
 */
 
native int NCLiteRPG_SetCredits(int client,int amount);


/*
 * Добавление кредитов игроку
 *
 * @param client индекс игрока.
 * @param amount количество кредитов.
 * @param event модификатор перехвата события.
 * @param event_name имя события.
 * @return amount
 */
 

native int NCLiteRPG_GiveCredits(int client,int amount, NCLiteRPG_EventMode event=EVENT_ALL, char[] event_name="");

/*
 * Получение уровня игрока
 *
 * @param client индекс игрока.
 * @return value
 */

native int NCLiteRPG_GetLevel(int client);

/*
 * Изменение уровня игрока
 *
 * @param client индекс игрока.
 * @param amount количество кредитов.
 * @return amount
 */
 
native int NCLiteRPG_SetLevel(int client,int amount);

/*
 * Получение опыта игрока
 *
 * @param client индекс игрока.
 * @return value
 */

native int NCLiteRPG_GetXP(int client);

/*
 * Изменение опыта игрока
 *
 * @param client индекс игрока.
 * @param amount количество кредитов.
 * @return amount
 */
 
native int NCLiteRPG_SetXP(int client, int amount);

/*
 * Добавление опыта игроку с учетом уровня
 *
 * @param client индекс игрока.
 * @param exp количество опыта.
 * @param msg будет ли выводиться сообщение.
 * @param checkexp будет ли проверятся переменная exp_max.
 * @param minplayers будет ли проверятся переменная min_players.
 * @param maxlevel будет ли проверятся переменная level_max.
 * @return exp
 */
 
native int NCLiteRPG_GiveExp(int client, int exp, bool msg = true, bool checkexp = true, bool minplayers = true, bool maxlevel = true, NCLiteRPG_EventMode event=EVENT_ALL, char[] event_name="");

/*
 * Уменьшения опыта игроку с учетом уровня
 *
 * @param client индекс игрока.
 * @param exp количество опыта.
 * @param msg будет ли выводиться сообщение.
 * @param minplayers будет ли проверятся переменная min_players.
 * @return exp
 */
 
native int NCLiteRPG_TakeExp(int client, int exp, bool msg = true, bool minplayers = true);

/*
 * Установка опыта игроку с учетом уровня
 *
 * @param client индекс игрока.
 * @param exp количество опыта.
 * @param totalXP true - текущий опыт, false - общий опыт.
 * @param msg будет ли выводиться сообщение.
 * @param checkexp будет ли проверятся переменная exp_max.
 * @param minplayers будет ли проверятся переменная min_players.
 * @param maxlevel будет ли проверятся переменная level_max.
 * @return exp
 */

native int NCLiteRPG_SetExp(int client, int exp, bool totalXP, bool msg = true, bool checkexp = true, bool minplayers = true, bool maxlevel = true);

/*
 * Получение необходимого опыта для повышения уровня игрока
 *
 * @param client индекс игрока.
 * @return value
 */

native int NCLiteRPG_GetReqXP(int client);

/*
 * Изменение необходимого опыта для повышения уровня игрока
 *
 * @param client индекс игрока.
 * @param amount количество кредитов.
 * @return amount
 */
 
native int NCLiteRPG_SetReqXP(int client,int amount);

/*
 * Вызывается при изменении уровня игрока
 *
 * @param client индекс игрока.
 * @param level уровень игрока.
 *
 */

forward void NCLiteRPG_OnPlayerLevelUp(int client,int level);

/*
 * Обнуление игрока
 *
 * @param client индекс игрока.
 * @noreturn
 */
 
native void NCLiteRPG_ResetPlayer(int client);

/*
 * Обнуление всех игроков
 *
 * @noparam 
 * @noreturn
 */
native void NCLiteRPG_ResetAllPlayers();

/*
 * Вызывается до получения опыта игроком
 *
 * @param client индекс игрока.
 * @param Exp предварительное количество получаемого опыта.
 *
 */
 
 forward Action NCLiteRPG_OnPlayerGiveExpPre(int client,int &Exp, char[] event);
 
 /*
 * Вызывается после получения опыта игроком
 *
 * @param client индекс игрока.
 * @param Exp количество опыта.
 *
 */
 
 forward NCLiteRPG_OnPlayerGiveExpPost(int client,int Exp, char[] event);
 
 /*
 * Вызывается до получения кредитов игроком
 *
 * @param client индекс игрока.
 * @param Credits предварительное количество получаемых кредитов.
 * @param Event имя события.
 *
 */
 
 forward Action NCLiteRPG_OnPlayerGiveCreditsPre(int client,int &Credits, char[] event);
 
 /*
 * Вызывается после получения опыта игроком
 *
 * @param client индекс игрока.
 * @param Credits количество кредитов.
 * @param Event имя события.
 *
 */
 
 forward NCLiteRPG_OnPlayerGiveCreditsPost(int client,int Credits,char[] event);
 
 
 /*
 * Получение String параметра игрока из базы по steamid
 *
 * @param steamid стимид игрока.
 * @param param параметр.
 * @param buffer массив.
 * @param maxlen размер массив.
 * @return true Если игрок есть в базе или false Если нету
 */
 
native bool NCLiteRPG_GetParamStringBySteamID(char[] steamid, char[] param, char[] buffer, int maxlen);

 /*
 * Получение Int параметра игрока из базы по steamid
 *
 * @param steamid стимид игрока.
 * @param param параметр.
 * @return количество кредитов
 */
 
native int NCLiteRPG_GetParamIntBySteamID(char[] steamid,char[] param);

 /*
 * Установка Int параметра игрока в базе по steamid
 *
 * @param steamid стимид игрока.
 * @param param параметр.
 * @param value значение параметра
 * @return value значение
 */
 
native int NCLiteRPG_SetParamIntBySteamID(char[] steamid,char[] param,int value);

/*
 * Добавление опыта игроку с учетом уровня по steamid
 *
 * @param steamid steamid игрока.
 * @param exp количество опыта.
 * @param checkexp будет ли проверятся переменная exp_max.
 * @param maxlevel будет ли проверятся переменная level_max.
 * @return exp
 */
native int NCLiteRPG_GiveExpBySteamID(char[] steamid,int exp,bool checkexp = true, bool maxlevel = true);


/*
 * Уменьшения опыта игроку с учетом уровня по steamid
 *
 * @param client индекс игрока.
 * @param exp количество опыта.
 * @return exp
 */
 
native int NCLiteRPG_TakeExpBySteamID(char[] steamid, int exp);

/*
 * Установка опыта игроку с учетом уровня по steamid
 *
 * @param client индекс игрока.
 * @param exp количество опыта.
 * @param totalXP true - текущий опыт, false - общий опыт.
 * @param checkexp будет ли проверятся переменная exp_max.
 * @param maxlevel будет ли проверятся переменная level_max.
 * @return exp
 */

native int NCLiteRPG_SetExpBySteamID(char[] steamid, int exp, bool totalXP, bool checkexp = true, bool maxlevel = true);
