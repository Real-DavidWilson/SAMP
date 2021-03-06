/* Commands */

// CMD:name(playerID, params, languageStringID)
#define CMD:%0(%1,%2,%3) COMMAND:%0(%1, %2)

// COMMAND:name(playerID, params)
#define COMMAND:%0(%1) forward cmd_%0(%1); public cmd_%0(%1)

// NCMD:name(playerID, params, languageStringID)
#define NCMD:%0(%1,%2,%3) COMMAND:%0(%1, %2) if (!IsPlayerNPC(%1)) return COMMAND_NPC_ONLY; else

// PCMD:name[permissionField](playerID, params, languageStringID)
#define PCMD:%0[%1](%2,%3,%4) COMMAND:%0(%2, %3) if (!permissions[%2][PERMISSION_%1]) return COMMAND_PERMISSION_DENIED; else


/* Functions */

// AddCmdAlias:newName[oldName]
#define AddCmdAlias:%0[%1] COMMAND:%0(playerID, params[]) return cmd_%1(playerID, params)

// AddLine:string(string[, formatParameters])
#define AddLine:%0(%1) if (strlen(%0)) strcat(%0, "\n"); Format:addLineString(%1); strcat(%0, addLineString)

// AdminPrint(playerID, color, string, parameters)
#define AdminPrint(%0,%1,%2) Format:clientMessageString(%2); print(clientMessageString); if (%0 != INVALID_PLAYER_ID) SendClientMessage(%0, %1, clientMessageString)

// Count(countingVariable, maximumValue)
#define Count(%0,%1) for (new %0 = 0; %0 < %1; %0++)

// Count1(countingVariable, maximumValue) -> Same as Count(countingVariable, maximumValue) but starts at 1 and includes maximumValue
#define Count1(%0,%1) for (new %0 = 1; %0 <= %1; %0++)

// DialogResponse:DIALOGNAME(playerID, response, listItem, inputText[])
#define DialogResponse:%0(%1) forward DR_%0(%1); public DR_%0(%1)

// Foreach(countingVariable, array)
#define Foreach(%0,%1) for (new %0 = 0; %0 < sizeof(%1); %0++)

// Format:string(formatString, parameters)
#define Format:%0(%1) format(%0, sizeof(%0), %1)

// FormatNew:string[size](formatString, parameters)
#define FormatNew:%0[%1](%2) new %0[%1]; Format:%0(%2)

// FormatMoney(floatValue)
#define FormatMoney(%0) FormatNumber(Float:%0, 2, '.', ',')

// GetStringArg(argumentIndex, returnString)
#define GetStringArg(%0,%1); \
for (new i_%0 = 0; ; ++i_%0) \
{ \
	if ((%1[i_%0] = getarg((%0), i_%0)) != EOS) \
		continue; \
	else \
		break; \
}

// IsKeyPressed(keys)
#define IsKeyPressed(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// IsStr(string1, string2)
#define IsStr(%0,%1) (strlen(%0) && strlen(%1) && !strcmp(%0, %1, true))

// LanguageStringLimit(number)
// Language String Editor searches for this and replaces the number with the required number of strings
#define LanguageStringLimit(%0) %0

// LoadPermission:permissionField(playerID, tableField)
#define LoadPermission:%0(%1,%2) permissions[%1][PERMISSION_%0] = strval(GetMySQLField(%2))

// LoggedInPlayers(returningPlayerID)
#define LoggedInPlayers(%0) Count(%0, maxPlayers) if (IsLoggedIn(%0))

// MD5(string)
#define MD5(%0) MD5_Hash(%0, true)

// MySQLQuery(formattedString, parameters)
#define MySQLQuery(%0) Format:sqlQuery(%0); if (mysql_query(sqlQuery)) printf("SQL: %s", sqlQuery)

// PickupEvent:pickupType(parameters)
#define PickupEvent:%0(%1) forward PUE_%0(%1); public PUE_%0(%1)

// PickupModelID:pickupType(pickupID)
#define PickupModelID:%0(%1) forward PUMID_%0(%1); public PUMID_%0(%1)

// PlayerLoop(returningPlayerID)
#define PlayerLoop(%0) Count(%0, maxPlayers) if (IsPlayerConnected(%0))

// PTextDraw:playerID[textDrawField]
#define PTextDraw:%0[%1] PVar:%0[TD_%1]

// PVar:playerID[field]
#define PVar:%0[%1] playerVariables[%0][PVAR_%1]

// RandomEx(min, max)
#define RandomEx(%0,%1) (random(%1 - %0 + 1) + %0)

// SetPVarStr:playerID[field][size](string)
#define SetPVarStr:%0[%1][%2](%3) format(PVar:%0[%1], %2, %3)

// ShowDialog:DIALOGNAME(playerID [,parameters...])
#define ShowDialog:%0(%1) SD_%0(%1)

// StartScreenFader(playerID, red, green, blue, steps, waitOnEnd, extraID)
#define StartScreenFader(%0) Timer_ScreenFader(%0)

// StartTimer:name(functionName, repeat)
#define StartTimer:%0(%1,%2) SetTimer(%1, TIMER_%0, %2)

// StringID:ID("englishString")
#define StringID:%0(%1) %0

// Timer:name(parameters)
#define Timer:%0(%1) forward Timer_%0(%1); public Timer_%0(%1)

// VehicleProperty:vehicleID[property]
#define VehicleProperty:%0[%1] vehicles[%0 - 1][VEHICLE_%1]