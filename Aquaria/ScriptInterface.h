/*
Copyright (C) 2007, 2010 - Bit-Blot

This file is part of Aquaria.

Aquaria is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/
#pragma once

#include "../BBGE/Base.h"

struct lua_State;

class Entity;
class CollideEntity;
class ScriptedParticleEffect;
class ParticleData;
class ScriptedEntity;

struct ParticleEffectScript
{
	lua_State* lua;
	std::string name;
	int idx;
};

class Script
{
public:
	Script(lua_State *L, const std::string &file) : L(L), file(file) {}

	// function()
	bool call(const char *name);
	// function(number)
	bool call(const char *name, float param1);
	// function(pointer)
	bool call(const char *name, void *param1);
	// function(pointer, number)
	bool call(const char *name, void *param1, float param2);
	// function(pointer, pointer)
	bool call(const char *name, void *param1, void *param2);
	// function(pointer, number, number)
	bool call(const char *name, void *param1, float param2, float param3);
	// boolean = function(pointer, number, number)
	bool call(const char *name, void *param1, float param2, float param3, bool *ret1);
	// function(pointer, string, number)
	bool call(const char *name, void *param1, const char *param2, float param3);
	// function(pointer, pointer, pointer)
	bool call(const char *name, void *param1, void *param2, void *param3);
	// function(pointer, number, number, number)
	bool call(const char *name, void *param1, float param2, float param3, float param4);
	// function(pointer, pointer, pointer, pointer)
	bool call(const char *name, void *param1, void *param2, void *param3, void *param4);
	// boolean = function(pointer, pointer, pointer, number, number, number, number, pointer)
	bool call(const char *name, void *param1, void *param2, void *param3, float param4, float param5, float param6, float param7, void *param8, bool *ret1);

	lua_State *getLuaState() {return L;}
	const std::string &getFile() {return file;}
	const std::string &getLastError() {return lastError;}

protected:
	// Low-level helper
	bool doCall(int nparams, int nrets = 0);

	lua_State *L;
	std::string file;
	std::string lastError;
};

class ScriptInterface
{
public:
	void init();
	void loadParticleEffectScripts();
	void collectGarbage();
	void shutdown();
	void setCurrentParticleEffect(ScriptedParticleEffect *e);
	bool setCurrentEntity (Entity *e);
	void setCurrentParticleData(ParticleData *p);
	ScriptedParticleEffect *getCurrentParticleEffect() { return currentParticleEffect; }


	ParticleData *getCurrentParticleData() { return currentParticleData; }
	Script *openScript(const std::string &file);
	void closeScript(Script *script);

	bool runScript(const std::string &file, const std::string &func);
	bool runScriptNum(const std::string &file, const std::string &func, int num);

	typedef std::map<std::string, ParticleEffectScript> ParticleEffectScripts;
	ParticleEffectScripts particleEffectScripts;
	ParticleEffectScript *getParticleEffectScriptByIdx(int idx);
	//bool simpleConversation(const std::string &file);
	bool noMoreConversationsThisRun;

	//ScriptedEntity *se;
	//CollideEntity *collideEntity;
	//int currentEntityTarget;
	//Entity *getCurrentEntity() { return currentEntity; }
protected:

	lua_State *createLuaVM();
	void destroyLuaVM(lua_State *state);
	lua_State *createLuaThread(lua_State *baseState);
	void destroyLuaThread(lua_State *baseState, lua_State *thread);

	typedef std::map<std::string, lua_State*> ScriptFileMap;
	ScriptFileMap loadedScripts;

	ParticleData* currentParticleData;
	ScriptedParticleEffect* currentParticleEffect;
	Entity *currentEntity;
};
extern ScriptInterface *si;
