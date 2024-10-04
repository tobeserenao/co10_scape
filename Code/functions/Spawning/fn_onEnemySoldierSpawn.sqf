private["_nighttime"];
params["_unit"];
_unit setVehicleAmmo (0.2 + random 0.4);
if(daytime > 19 OR daytime < 8) then {
	_nighttime = true;
} else {
	_nighttime = false;
};   

//Hopefully fixing BIS broken scripts:
private _AISkill = 0.1;
switch (A3E_Param_EnemySkill) do {
	case 0: { _AISkill = 0.6; };
	case 1: { _AISkill = 0.7; };
	case 2: { _AISkill = 0.8; };
	case 3: { _AISkill = 0.9; };
	case 4: { _AISkill = 1.0; };
	default { _AISkill = 0.2; };
};

_unit setSkill ["aimingAccuracy", (0.4 + (random 0.2)) * _AISkill];
_unit setSkill ["aimingShake", (0.4 + (random 0.3)) * _AISkill];
_unit setSkill ["aimingSpeed", (0.6 + (random 0.2)) * _AISkill];
_unit setSkill ["commanding", (0.8 + (random 0.2)) * _AISkill];
_unit setSkill ["courage", (0.5 + (random 0.5)) * _AISkill];
_unit setSkill ["general", (0.9 + (random 0.1)) * _AISkill];
_unit setSkill ["reloadSpeed", (0.5 + (random 0.5)) * _AISkill];
_unit setSkill ["spotDistance", (0.4 + random 0.2) * _AISkill];
_unit setSkill ["spotTime", (0.7 + random 0.2) * _AISkill];

_unit removeItem "FirstAidKit";

//Chance for a random scope (and no scope):
if(random 100 < 70) then {

	removeAllPrimaryWeaponItems _unit;
	if((random 100 < 30)) then {
		_scopes = A3E_arr_Scopes;
		if(A3E_Param_NoNightvision==0) then {
			_scopes = _scopes + A3E_arr_TWSScopes;
		};
		if(_nighttime) then {
			_scopes = _scopes + A3E_arr_NightScopes;
		};
		_scope = selectRandom _scopes;
		_unit addPrimaryWeaponItem _scope;
	};
};

private _nvgs = hmd _unit; //NVGoggles
private _missionHasNVGs = missionnamespace getvariable ["A3E_Var_AllowVanillaNightVision", true];
if (_nvgs isEqualTo "") then {
	private _cfgWeapons = configFile >> "CfgWeapons";
	{
		if (616 == getNumber (_cfgWeapons >> _x >> "ItemInfo" >> "type")) exitWith {
			_nvgs = _x;
		};
	} forEach items _unit;
};
if(_nvgs != "") then {
	if((_nighttime) && (random 100 > 40) || !(_nighttime) && (random 100 > 5) || (A3E_Param_NoNightvision>0)) then {
		_unit unlinkItem _nvgs;
		_unit removeItem _nvgs;
	};
} else {
	if((((_nighttime) && (random 100 < 40)) || (!(_nighttime) && (random 100 < 5))) && (A3E_Param_NoNightvision==0) && _missionHasNVGs) then {
		_unit linkItem "NVGoggles_OPFOR";
	};
};


//Chance for random attachment
if((random 100 < 15) OR (_nighttime)) then {
	if(random 100 < 70 || (A3E_Param_NoNightvision>0)) then {
		_unit addPrimaryWeaponItem "acc_flashlight";
	} else {
		_unit addPrimaryWeaponItem "acc_pointer_IR";
		_unit linkItem "NVGoggles_OPFOR";
	};
};

//Bipod chance
if((random 100 < 20)) then {
	_unit addPrimaryWeaponItem (selectRandom a3e_arr_Bipods);
};

//Chance for silencers
if(((random 100 < 10) && (!_nighttime)) OR ((random 100 < 40) && (_nighttime))) then {
	//Not yet
};
if (random 100 > 20) then {
	//_unit additem "ItemMap";
	//_unit assignItem "ItemMap";
	private _mapItems = missionNamespace getVariable ["A3E_MapItemsUsedInMission",["ItemMap"]];
	{_unit unlinkItem _x;} foreach _mapItems;
};
if (random 100 > 30) then {
	//_unit additem "ItemCompass";
	//_unit assignItem "ItemCompass";
	_unit unlinkItem "ItemCompass";
};

private _itemsToRemove = missionNamespace getVariable ["A3E_ItemsToBeRemoved",[]];
{
	private _items = items _unit;
	if(random 100 > 30) then {
		_unit unlinkItem _x;
	};
} foreach _itemsToRemove;



if (random 100 > 5) then {
	//_unit additem "ItemGPS";
   // _unit assignItem "ItemGPS";
	_unit unlinkItem "ItemGPS";
};
if ("Binocular" in (assignedItems _unit)) then {
	if (random 100 > 30) then {
		//_unit additem "ItemGPS";
	   // _unit assignItem "ItemGPS";
		_unit unlinkItem "Binocular";
	};
};
if ("Rangefinder" in (assignedItems _unit)) then {
	if (random 100 > 30) then {
		//_unit additem "ItemGPS";
	   // _unit assignItem "ItemGPS";
		_unit unlinkItem "Rangefinder";
	};
};
if(A3E_Param_UseIntel==1) then {
	[_unit] call A3E_fnc_AddIntel;
};



//Track kills
_unit addEventHandler ["Killed", {
	params ["_unit", "_killer"];
	if(isPlayer _killer) then {
		private _killStats = missionNamespace getvariable ["A3E_Kill_Count",0];
		missionNamespace setvariable ["A3E_Kill_Count",_killStats+1,false];
	};
}];
