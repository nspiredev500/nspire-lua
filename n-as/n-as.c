#include <stdint.h>
#include <stdbool.h>

#include <os.h>
#include <lauxlib.h>
#include <nucleus.h>
#include <lua.h>
#include <libndls.h>

#include "../nspire-toolchain/n-as/assembler.h"




// uint32_t, because the stack should be 4 byte aligned
#define ASM_STACK_SIZE 20480
uint32_t asm_stack[ASM_STACK_SIZE]; // 80K stack
uint32_t prg_regs[18]; // r0-r15, cpsr, spsr
uint32_t last_pgr_sp = -1;



void enableIRQ()
{
	asm("mrs r0, cpsr \n"
	"bic r0, r0, #0x80 \n"
	"msr cpsr, r0":::"r0");
}
void disableIRQ()
{
	asm("mrs r0, cpsr \n"
	"orr r0, r0, #0x80 \n"
	"msr cpsr, r0":::"r0");
}



// lua calling: runString(string text,bool allowSWI,bool allowPSR, bool allowCOPROC)
// returns true if successful, or false and the error string
int lua_runString(lua_State *L)
{
	luaL_checkstack(L,2,"not enough space on the lua stack!");
	if (lua_gettop(L) != 4)
	{
		return luaL_error(L,"asm.runString expects 4 arguments\n");
	}
	if (lua_isstring(L,1) != 1)
	{
		return luaL_error(L,"the first argument of asm.runString has to be a string\n");
	}
	if (lua_isboolean(L,2) != 1)
	{
		return luaL_error(L,"the second argument of asm.runString has to be a boolean\n");
	}
	if (lua_isboolean(L,3) != 1)
	{
		return luaL_error(L,"the third argument of asm.runString has to be a boolean\n");
	}
	if (lua_isboolean(L,4) != 1)
	{
		return luaL_error(L,"the fourth argument of asm.runString has to be a boolean\n");
	}
	const char* string = lua_tostring(L,1);
	bool swi = lua_toboolean(L,2);
	bool psr = lua_toboolean(L,3);
	bool cop = lua_toboolean(L,4);
	uint16_t flags = 0;
	if (swi)
		flags |= ASSEMBLER_SWI_ALLOWED;
	if (psr)
		flags |= ASSEMBLER_PSR_ALLOWED;
	if (cop)
		flags |= ASSEMBLER_COPROCESSOR_ALLOWED;
	uint32_t size = 0;
	void* block = NULL;
	uint32_t entry_offset = 0;
	bool thumb = false;
	//printf("string: %s\n",string);
	if (assemble_string(string,flags,&size,&block,&entry_offset,&thumb) != 0)
	{
		if (block != NULL)
		{
			free(block);
		}
		lua_pushboolean(L,false);
		lua_pushstring(L,asm_error_msg);
		return 2;
	}
	else
	{
		if (size == 0)
		{
			if (block != NULL)
			{
				free(block);
			}
			lua_pushboolean(L,false);
			lua_pushstring(L,"empty program");
			return 2;
		}
		if (block != NULL)
		{
			disableIRQ();
			//printf("start: 0x%x, block: %p\n",block+entry_offset,block);
			register uint32_t start_adr asm("r0") = (uint32_t) (block+entry_offset);
			if (thumb)
			{
				start_adr += 1; // set the first bit to 1 indicate thumb code
			}
			register uint32_t regs asm("r1") = (uint32_t) &prg_regs;
			register uint32_t stack_start asm("r2") = (uint32_t) (asm_stack + ASM_STACK_SIZE/2);
			register uint32_t prg_stack asm("r3") = 0;
			asm volatile(
			"str r1, saved_regs \n"
			"push {r0-r12,lr} \n"
				"mov lr, r0 \n"
				"mrs r0, cpsr \n"
				"push {r0} \n"
					"mrs r0, spsr \n"
					"push {r0} \n"
						"str sp, saved_sp \n" // set up the program stack
						"mov sp, r2 \n"
						"mov r0, #0 \n" // clear all registers
						"mov r1, #0 \n"
						"mov r2, #0 \n"
						"mov r3, #0 \n"
						"mov r4, #0 \n"
						"mov r5, #0 \n"
						"mov r6, #0 \n"
						"mov r7, #0 \n"
						"mov r8, #0 \n"
						"mov r9, #0 \n"
						"mov r10, #0 \n"
						"mov r11, #0 \n"
						"mov r12, #0 \n"
						"blx lr \n" // jump to the program
						"str sp, saved_prg_sp \n"
						"ldr sp, saved_regs \n"
						"str r0, [sp] \n" // not actually the stack here, but the register array
						"str r1, [sp, #4] \n"
						"str r2, [sp, #8] \n"
						"str r3, [sp, #12] \n"
						"str r4, [sp, #16] \n"
						"str r5, [sp, #20] \n"
						"str r6, [sp, #24] \n"
						"str r7, [sp, #28] \n"
						"str r8, [sp, #32] \n"
						"str r9, [sp, #36] \n"
						"str r10, [sp, #40] \n"
						"str r11, [sp, #44] \n"
						"str r12, [sp, #48] \n"
						"str r14, [sp, #56] \n"
						"mov r0, #0 \n"
						"str r0, [sp, #60] \n" // just use 0 as the value for pc, because the real value can't be recovered
						"mov r1, sp \n"
						"ldr sp, saved_prg_sp \n"
						"str sp, [r1, #52] \n" // store the program sp
						"mrs r0, cpsr \n"
						"str r0, [r1, #64] \n" // store the program cpsr
						"mrs r0, cpsr \n"
						"str r0, [r1, #68] \n" // store the program spsr
						"ldr sp, saved_sp \n" // load the real sp
					"pop {r0} \n"
					"msr spsr, r0 \n"
				"pop {r0} \n"
				"msr cpsr, r0 \n"
			"pop {r0-r12,lr} \n"
			"ldr r3, saved_prg_sp \n"
			"b end \n"
			"saved_sp: .word 0 \n"
			"saved_prg_sp: .word 0 \n"
			"saved_regs: .word 0 \n"
			"end: \n":[prg_stack] "=r" (prg_stack):[start_adr] "r" (start_adr),[regs] "r" (regs),[stack_start] "r" (stack_start):"memory");
			enableIRQ();
			last_pgr_sp = prg_stack;
			free(block);
			if (prg_stack > (uint32_t) (asm_stack + ASM_STACK_SIZE/2))
			{
				lua_pushboolean(L,false);
				lua_pushstring(L,"WARNING: stack smashed, you popped more than you pushed");
				return 2;
			}
		}
		else
		{
			lua_pushboolean(L,false);
			lua_pushstring(L,"empty program");
			return 2;
		}
		lua_pushboolean(L,true);
		return 1;
	}
}


// returns a table with the register values, t[0] = r0...,t[16] = cpsr, t[17] = spsr
int lua_getRegs(lua_State *L)
{
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	if (last_pgr_sp == -1)
	{
		return luaL_error(L,"run a program before checking the registers\n");
	}
	lua_newtable(L);
	for (int i = 0;i<18;i++)
	{
		lua_pushinteger(L,prg_regs[i]);
		lua_rawseti(L,-2,i);
	}
	return 1;
}


// returns a table with all the words left on the stack by the program
int lua_getStack(lua_State *L)
{
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	if (last_pgr_sp == -1)
	{
		return luaL_error(L,"run a program before checking the stack\n");
	}
	lua_newtable(L);
	uint32_t* prg_stack = (uint32_t*) last_pgr_sp;
	if (prg_stack > (asm_stack + ASM_STACK_SIZE/2))
	{
		return luaL_error(L,"stack smashed\n");
	}
	if ((uint32_t) prg_stack % 4 != 0)
	{
		prg_stack = (uint32_t*) ((uint32_t) prg_stack - (uint32_t) prg_stack % 4); 
	}
	uint32_t nextindex = 1;
	for (uint32_t* sp = (asm_stack + ASM_STACK_SIZE/2)-1;sp >= prg_stack;sp--)
	{
		lua_pushinteger(L,*sp);
		lua_rawseti(L,-2,nextindex);
		nextindex++;
	}
	return 1;
}







static const luaL_reg lualib[] = {
	{"runString",lua_runString},
	{"getRegs",lua_getRegs},
	{"getStack",lua_getStack},
	{NULL, NULL}
};

int main(void) {
	lua_State *L = nl_lua_getstate();
	if (!L) return 0;
	luaL_register(L, "asm", lualib);
	return 0;
}

