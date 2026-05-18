import discord
from discord.ext import commands
import random
import tempfile
import os

TOKEN = "MTQ2NDE5MTM2Nzc1MTQwNTU4MQ.Gr2pwJ.bJDG-MOz_ZWIMCHanwCYIQU_cMN-e_vZUXW5JM"

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='.', intents=intents)

# =========================
# OPCODES
# =========================
OPCODES = {
    "LOAD_CONST": 0x01,
    "LOAD_VAR":   0x02,
    "STORE_VAR":  0x03,
    "CONCAT":     0x04,
    "CALL":       0x05,
    "CHAR":       0x06,
    "XOR":        0x07,
    "HALT":       0xFF,
}

# =========================
# SAFE RANDOM VARS
# =========================
def rand_var(n=10):
    first = random.choice(
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    )

    rest = "".join(
        random.choices(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789",
            k=n-1
        )
    )

    return first + rest


def used_names():
    seen = set()

    def get(n=10):
        while True:
            v = rand_var(n)
            if v not in seen:
                seen.add(v)
                return v
    return get

new_var = used_names()

# =========================
# HEAVY NUMBERS
# =========================
def heavy(n):
    mode = random.randint(0,2)

    if mode == 0:
        a = random.randint(1000,9999)
        return f"({n+a}-{a})"

    elif mode == 1:
        a = random.randint(1,127)
        return f"bit32.bxor({n ^ a},{a})"

    else:
        a = random.randint(10,99)
        b = random.randint(10,99)
        return f"({n+a*b}-{a}*{b})"

# =========================
# JUNK
# =========================
def junk(n=4):
    lines = []

    for _ in range(n):
        v = new_var()
        lines.append(
            f"local {v}={random.randint(1,9999)};"
        )

    return "".join(lines)

# =========================
# BYTECODE COMPILER
# =========================
def compile_to_bytecode(lua_code):

    bytecode = []

    xor_key = random.randint(1,255)

    encoded = [
        b ^ xor_key
        for b in lua_code.encode("utf-8")
    ]

    bytecode.append(
        (OPCODES["LOAD_CONST"], xor_key)
    )

    bytecode.append(
        (OPCODES["STORE_VAR"], 0)
    )

    for b in encoded:

        bytecode.append(
            (OPCODES["LOAD_CONST"], b)
        )

        bytecode.append(
            (OPCODES["LOAD_VAR"], 0)
        )

        bytecode.append(
            (OPCODES["XOR"], 0)
        )

        bytecode.append(
            (OPCODES["CHAR"], 0)
        )

        bytecode.append(
            (OPCODES["CONCAT"], 0)
        )

    bytecode.append(
        (OPCODES["CALL"], 0)
    )

    bytecode.append(
        (OPCODES["HALT"], 0)
    )

    return bytecode

# =========================
# VM EMITTER
# =========================
def emit_vm(bytecode):

    V = {
        k:new_var()
        for k in [
            "instructions",
            "ip",
            "stack",
            "sp",
            "registers",
            "acc",
            "op",
            "arg",
            "tmp",
            "fn",
            "loader"
        ]
    }

    bc = []

    for op,arg in bytecode:
        bc.append(
            f"{{{heavy(op)},{heavy(arg)}}}"
        )

    bc_str = ",".join(bc)

    vm = f"""
{junk(5)}

local {V['instructions']}={{{bc_str}}}
local {V['ip']}=1
local {V['stack']}={{}}
local {V['sp']}=0
local {V['registers']}={{}}
local {V['acc']}=""

{junk(4)}

while {V['ip']}<=#{V['instructions']} do

    local {V['op']}={V['instructions']}[{V['ip']}][1]
    local {V['arg']}={V['instructions']}[{V['ip']}][2]

    {V['ip']}={V['ip']}+1

    if {V['op']}=={heavy(OPCODES['LOAD_CONST'])} then

        {V['sp']}={V['sp']}+1
        {V['stack']}[{V['sp']}]={V['arg']}

    elseif {V['op']}=={heavy(OPCODES['STORE_VAR'])} then

        {V['registers']}[{V['arg']}]={V['stack']}[{V['sp']}]
        {V['sp']}={V['sp']}-1

    elseif {V['op']}=={heavy(OPCODES['LOAD_VAR'])} then

        {V['sp']}={V['sp']}+1
        {V['stack']}[{V['sp']}]={V['registers']}[{V['arg']}]

    elseif {V['op']}=={heavy(OPCODES['XOR'])} then

        local a={V['stack']}[{V['sp']}]
        {V['sp']}={V['sp']}-1

        local b={V['stack']}[{V['sp']}]
        {V['sp']}={V['sp']}-1

        {V['sp']}={V['sp']}+1
        {V['stack']}[{V['sp']}]=bit32.bxor(a,b)

    elseif {V['op']}=={heavy(OPCODES['CHAR'])} then

        local c={V['stack']}[{V['sp']}]
        {V['sp']}={V['sp']}-1

        {V['sp']}={V['sp']}+1
        {V['stack']}[{V['sp']}]=string.char(c)

    elseif {V['op']}=={heavy(OPCODES['CONCAT'])} then

        local s={V['stack']}[{V['sp']}]
        {V['sp']}={V['sp']}-1
        {V['acc']}={V['acc']}..s

    elseif {V['op']}=={heavy(OPCODES['CALL'])} then

        local {V['loader']} =
            loadstring or load

        local {V['fn']},err =
            {V['loader']}(
                {V['acc']}
            )

        if {V['fn']} then
            pcall({V['fn']})
        else
            warn(err)
        end

    elseif {V['op']}=={heavy(OPCODES['HALT'])} then
        break
    end
end
"""

    return vm.strip()

# =========================
# FULL OBF
# =========================
def obf_lua(code):

    bytecode = compile_to_bytecode(code)

    return emit_vm(bytecode)

# =========================
# DISCORD COMMAND
# =========================
@bot.command(name="obf")
async def obf(ctx):

    if not ctx.message.attachments:
        await ctx.reply(
            "ใส่ไฟล์ .lua หรือ .txt"
        )
        return

    file = ctx.message.attachments[0]

    if not (
        file.filename.endswith(".lua")
        or
        file.filename.endswith(".txt")
    ):
        await ctx.reply(
            "รองรับ .lua และ .txt"
        )
        return

    try:

        data = await file.read()

        text = data.decode(
            "utf-8",
            errors="ignore"
        )

        result = obf_lua(text)

        temp = tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".lua",
            mode="w",
            encoding="utf-8"
        )

        temp.write(result)
        temp.close()

        await ctx.reply(
            content="✅ OBF VM เสร็จ",
            file=discord.File(
                temp.name,
                filename="obf_vm.lua"
            )
        )

        os.remove(temp.name)

    except Exception as e:
        await ctx.reply(
            f"Error: {e}"
        )

# =========================
# RUN
# =========================
bot.run(TOKEN)
